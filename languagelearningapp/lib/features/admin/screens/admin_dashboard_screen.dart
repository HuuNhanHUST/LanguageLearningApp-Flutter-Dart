import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/admin_service.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  State<AdminDashboardScreen> createState() =>
      _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final _adminService = AdminService();
  final _authService = AuthService();
  List<User> _users = [];
  bool _isLoading = false;
  String? _error;
  String _selectedRole = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authState = context.read<AuthProvider>().user;
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('No access token');
      }

      final response = await _adminService.getAllUsers(
        token: token,
        role: _selectedRole == 'all' ? null : _selectedRole,
        search: _searchController.text.isEmpty ? null : _searchController.text,
      );

      setState(() {
        _users = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _promoteToTeacher(User user) async {
    try {
      final authState = context.read<AuthProvider>().user;
      final token = await _authService.getAccessToken();
      if (token == null) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Nâng ${user.username} lên Teacher?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _adminService.promoteToTeacher(
          user.id,
          token,
        );
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã nâng ${user.username} lên Teacher')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _demoteToUser(User user) async {
    try {
      final authState = context.read<AuthProvider>().user;
      final token = await _authService.getAccessToken();
      if (token == null) return;

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận'),
          content: Text('Hạ ${user.username} xuống User?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      );

      if (confirm == true) {
        await _adminService.demoteToUser(
          user.id,
          token,
        );
        _loadUsers();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Đã hạ ${user.username} xuống User')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _toggleActive(User user) async {
    try {
      final authState = context.read<AuthProvider>().user;
      final token = await _authService.getAccessToken();
      if (token == null) return;

      await _adminService.toggleUserActive(
        user.id,
        token,
      );
      _loadUsers();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã cập nhật trạng thái user')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = context.watch<AuthProvider>().user;

    if (currentUser == null || !currentUser.isAdmin) {
      return Scaffold(
        appBar: AppBar(title: const Text('Admin Dashboard')),
        body: const Center(
          child: Text('Bạn không có quyền truy cập'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('👑 Admin Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadUsers,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and Filter
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm user...',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _loadUsers();
                            },
                          )
                        : null,
                  ),
                  onSubmitted: (_) => _loadUsers(),
                ),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('Tất cả', 'all'),
                      _buildFilterChip('👤 User', 'user'),
                      _buildFilterChip('👨‍🏫 Teacher', 'teacher'),
                      _buildFilterChip('👑 Admin', 'admin'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // User List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Lỗi: $_error'),
                            ElevatedButton(
                              onPressed: _loadUsers,
                              child: const Text('Thử lại'),
                            ),
                          ],
                        ),
                      )
                    : _users.isEmpty
                        ? const Center(child: Text('Không có user nào'))
                        : ListView.builder(
                            itemCount: _users.length,
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemBuilder: (context, index) {
                              final user = _users[index];
                              return _buildUserCard(user);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedRole == value;
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedRole = value;
          });
          _loadUsers();
        },
      ),
    );
  }

  Widget _buildUserCard(User user) {
    final currentUser = context.watch<AuthProvider>().user;
    final isCurrentUser = currentUser?.id == user.id;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: user.avatar != null
              ? NetworkImage(user.avatar!)
              : null,
          child: user.avatar == null
              ? Text(user.firstName[0].toUpperCase())
              : null,
        ),
        title: Row(
          children: [
            Text(
              user.username,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 8),
            _buildRoleBadge(user.role),
            if (isCurrentUser) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text('${user.firstName} ${user.lastName}'),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow('Email', user.email),
                _buildInfoRow('XP', user.xp.toString()),
                _buildInfoRow('Level', user.level.toString()),
                _buildInfoRow('Streak', '${user.streak} days'),
                const SizedBox(height: 16),
                if (!isCurrentUser) ...[
                  const Text(
                    'Hành động:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (user.role == 'user')
                        ElevatedButton.icon(
                          onPressed: () => _promoteToTeacher(user),
                          icon: const Icon(Icons.arrow_upward, size: 16),
                          label: const Text('Nâng lên Teacher'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                        ),
                      if (user.role == 'teacher')
                        ElevatedButton.icon(
                          onPressed: () => _demoteToUser(user),
                          icon: const Icon(Icons.arrow_downward, size: 16),
                          label: const Text('Hạ xuống User'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      // OutlinedButton.icon(
                      //   onPressed: () => _toggleActive(user),
                      //   icon: Icon(
                      //     user.isActive
                      //         ? Icons.block
                      //         : Icons.check_circle,
                      //     size: 16,
                      //   ),
                      //   label: Text(
                      //     user.isActive ? 'Vô hiệu hóa' : 'Kích hoạt',
                      //   ),
                      // ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String? role) {
    final roleInfo = _getRoleInfo(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: roleInfo['color'],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        roleInfo['label'],
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Map<String, dynamic> _getRoleInfo(String? role) {
    switch (role) {
      case 'admin':
        return {'label': '👑 Admin', 'color': Colors.red};
      case 'teacher':
        return {'label': '👨‍🏫 Teacher', 'color': Colors.blue};
      default:
        return {'label': '👤 User', 'color': Colors.grey};
    }
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
