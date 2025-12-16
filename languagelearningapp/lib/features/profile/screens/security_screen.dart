import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:go_router/go_router.dart';

/// Màn hình cài đặt bảo mật
class SecurityScreen extends StatefulWidget {
  const SecurityScreen({super.key});

  @override
  State<SecurityScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  final _authService = AuthService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Bảo mật'),
        backgroundColor: const Color(0xFF1F1147),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Password section
            _buildSectionTitle('Mật khẩu'),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.lock_reset,
              title: 'Đổi mật khẩu',
              subtitle: 'Cập nhật mật khẩu của bạn',
              color: Colors.orange,
              onTap: _showChangePasswordDialog,
            ),
            const SizedBox(height: 32),

            // Danger zone
            _buildSectionTitle('Vùng nguy hiểm', color: Colors.red),
            const SizedBox(height: 16),
            _buildActionTile(
              icon: Icons.delete_forever,
              title: 'Xóa tài khoản',
              subtitle: 'Xóa vĩnh viễn tài khoản và dữ liệu',
              color: Colors.red,
              onTap: _showDeleteAccountDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = Colors.white}) {
    return Text(
      title,
      style: TextStyle(
        color: color,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1147),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                'Đổi mật khẩu',
                style: TextStyle(color: Colors.white),
              ),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Current password
                      TextFormField(
                        controller: currentPasswordController,
                        obscureText: obscureCurrent,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu hiện tại',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.lock_outline, color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureCurrent ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => obscureCurrent = !obscureCurrent);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu hiện tại';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // New password
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: obscureNew,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Mật khẩu mới',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureNew ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => obscureNew = !obscureNew);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mật khẩu mới';
                          }
                          if (value.length < 6) {
                            return 'Mật khẩu phải có ít nhất 6 ký tự';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirm password
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: obscureConfirm,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Xác nhận mật khẩu mới',
                          labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                          prefixIcon: const Icon(Icons.lock_clock, color: Colors.white54),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm ? Icons.visibility_off : Icons.visibility,
                              color: Colors.white54,
                            ),
                            onPressed: () {
                              setState(() => obscureConfirm = !obscureConfirm);
                            },
                          ),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.05),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng xác nhận mật khẩu';
                          }
                          if (value != newPasswordController.text) {
                            return 'Mật khẩu không khớp';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(dialogContext);
                      await _changePassword(
                        currentPasswordController.text,
                        newPasswordController.text,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Đổi mật khẩu'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _changePassword(String currentPassword, String newPassword) async {
    setState(() => _isLoading = true);

    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text('Đổi mật khẩu thành công! Vui lòng đăng nhập lại.'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );

        // Logout and redirect to login
        final authProvider = context.read<AuthProvider>();
        authProvider.logout();
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteAccountDialog() {
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1F1147),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Xóa tài khoản',
                    style: TextStyle(color: Colors.red),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Hành động này không thể hoàn tác!',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tất cả dữ liệu học tập, tiến độ, huy hiệu của bạn sẽ bị xóa vĩnh viễn.',
                    style: TextStyle(color: Colors.white.withOpacity(0.7)),
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: passwordController,
                    obscureText: obscurePassword,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Nhập mật khẩu để xác nhận',
                      labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                      prefixIcon: const Icon(Icons.lock, color: Colors.white54),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscurePassword ? Icons.visibility_off : Icons.visibility,
                          color: Colors.white54,
                        ),
                        onPressed: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.05),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('Hủy', style: TextStyle(color: Colors.white54)),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (passwordController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vui lòng nhập mật khẩu'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }
                    Navigator.pop(dialogContext);
                    await _deleteAccount(passwordController.text);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Xóa tài khoản'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _deleteAccount(String password) async {
    setState(() => _isLoading = true);

    try {
      await _authService.deleteAccount(password: password);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tài khoản đã được xóa thành công'),
            backgroundColor: Colors.green,
          ),
        );

        // Logout and redirect to login
        final authProvider = context.read<AuthProvider>();
        authProvider.logout();
        context.go('/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
