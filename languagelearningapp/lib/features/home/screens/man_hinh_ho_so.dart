import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../widgets/cached_avatar.dart';
import '../../auth/services/auth_service.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../learning/providers/learning_provider.dart';
import '../../user/user.dart'; // Import user stats widget
import '../../profile/screens/edit_profile_screen.dart';
import '../../profile/screens/security_screen.dart';
import '../../profile/screens/help_screen.dart';

/// Màn hình Hồ sơ người dùng
/// Hiển thị thông tin cá nhân, cài đặt
class ManHinhHoSo extends ConsumerStatefulWidget {
  const ManHinhHoSo({super.key});

  @override
  ConsumerState<ManHinhHoSo> createState() => _ManHinhHoSoState();
}

class _ManHinhHoSoState extends ConsumerState<ManHinhHoSo> {
  @override
  void initState() {
    super.initState();
    // Load progress when screen opens
    Future.microtask(() {
      ref.read(learningProvider.notifier).loadProgress();
    });
  }

  Future<User?> _loadUserProfile(AuthService authService) async {
    try {
      // Thử lấy từ API trước
      return await authService.getProfile();
    } catch (e) {
      // Nếu lỗi (ví dụ token hết hạn), fallback về stored user
      return await authService.getStoredUser();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();
    final learningState = ref.watch(learningProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B69), Color(0xFF1A0F3E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Header với avatar và thông tin (dựa trên dữ liệu thực)
                FutureBuilder<User?>(
                  key: ValueKey(DateTime.now().millisecondsSinceEpoch),
                  future: _loadUserProfile(authService),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.all(20),
                        child: SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      );
                    }

                    final user = snapshot.data;
                    return _xayDungHeader(user, context, learningState);
                  },
                ),

                const SizedBox(height: 30),

                // Container trắng chứa nội dung
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // User Statistics Card (NEW: API stats)
                        const UserStatsCard(),
                        const SizedBox(height: 20),

                        // Thành tích
                        _xayDungThanhTich(learningState),
                        const SizedBox(height: 30),

                        // Cài đặt
                        _xayDungCaiDat(context),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng header với avatar và thông tin user
  Widget _xayDungHeader(
    User? user,
    BuildContext context,
    LearningState learningState,
  ) {
    final displayName = user != null ? user.fullName : 'Bạn chưa đăng nhập';
    final email = user?.email ?? '';

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Avatar
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: CachedAvatar(
              imageUrl: user?.avatar,
              radius: 50,
              fallbackText: displayName,
              backgroundColor: const Color(0xFF6C63FF),
            ),
          ),
          const SizedBox(height: 15),

          // Tên user
          Text(
            displayName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),

          // Email
          Text(
            email,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 15),

          // Cấp độ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4CAF50).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Level ${learningState.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng section thành tích
  Widget _xayDungThanhTich(LearningState learningState) {
    final medals = learningState.totalWordsLearned;
    final goals = learningState.dailyLimit;
    final points = learningState.xp;

    final cacThanhTich = [
      {'icon': '📚', 'ten': 'Từ đã học', 'soLuong': '$medals'},
      {'icon': '🎯', 'ten': 'Mục tiêu/ngày', 'soLuong': '$goals'},
      {'icon': '⭐', 'ten': 'Điểm XP', 'soLuong': '$points'},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Thành tích',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: cacThanhTich.map((thanhTich) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Text(
                    thanhTich['icon']!,
                    style: const TextStyle(fontSize: 40),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    thanhTich['soLuong']!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    thanhTich['ten']!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Xây dựng danh sách cài đặt
  Widget _xayDungCaiDat(BuildContext context) {
    final cacTuyChon = [
      {
        'icon': Icons.edit,
        'ten': 'Chỉnh sửa hồ sơ',
        'mau': const Color(0xFF6C63FF),
      },
      {'icon': Icons.lock, 'ten': 'Bảo mật', 'mau': const Color(0xFFE91E63)},
      {'icon': Icons.help, 'ten': 'Trợ giúp', 'mau': const Color(0xFF00BCD4)},
      {
        'icon': Icons.logout,
        'ten': 'Đăng xuất',
        'mau': const Color(0xFFF44336),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Cài đặt',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 15),
        ...cacTuyChon.map((tuyChon) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () async {
                  if (tuyChon['ten'] == 'Đăng xuất') {
                    _xuLyDangXuat(context);
                  } else if (tuyChon['ten'] == 'Chỉnh sửa hồ sơ') {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                    // Reload profile after returning from edit screen
                    if (mounted) {
                      setState(() {});
                    }
                  } else if (tuyChon['ten'] == 'Bảo mật') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SecurityScreen(),
                      ),
                    );
                  } else if (tuyChon['ten'] == 'Trợ giúp') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HelpScreen(),
                      ),
                    );
                  }
                },
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: (tuyChon['mau'] as Color).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          tuyChon['icon'] as IconData,
                          color: tuyChon['mau'] as Color,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          tuyChon['ten'] as String,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: Colors.grey),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }

  /// Hiển thị dialog "Coming Soon"
  void _showComingSoon(BuildContext context, String feature) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.info_outline, color: Color(0xFF6C63FF)),
            const SizedBox(width: 10),
            const Text('Sắp ra mắt'),
          ],
        ),
        content: Text('Tính năng "$feature" đang được phát triển và sẽ sớm có mặt!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Đã hiểu'),
          ),
        ],
      ),
    );
  }

  /// Xử lý đăng xuất
  void _xuLyDangXuat(BuildContext context) async {
    final authService = AuthService();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                // 1. Reset learning provider state TRƯỚC
                ref.read(learningProvider.notifier).reset();

                // 2. Đăng xuất qua AuthService
                await authService.logout();

                // 3. Cập nhật AuthProvider (sẽ trigger router rebuild)
                final authProvider = context.read<AuthProvider>();
                authProvider.logout();

                // Router sẽ tự động redirect về login
              } catch (e) {
                print('Logout error: $e');
                // Vẫn chuyển về login nếu có lỗi
                if (context.mounted) {
                  context.go('/login');
                }
              }
            },
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
