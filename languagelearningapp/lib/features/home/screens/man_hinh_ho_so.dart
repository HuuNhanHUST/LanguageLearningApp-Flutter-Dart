import 'package:flutter/material.dart';

/// Màn hình Hồ sơ người dùng
/// Hiển thị thông tin cá nhân, cài đặt
class ManHinhHoSo extends StatelessWidget {
  const ManHinhHoSo({super.key});

  @override
  Widget build(BuildContext context) {
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
                // Header với avatar và thông tin
                _xayDungHeader(),
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
                        // Thành tích
                        _xayDungThanhTich(),
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
  Widget _xayDungHeader() {
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
            child: const Icon(Icons.person, size: 50, color: Color(0xFF6C63FF)),
          ),
          const SizedBox(height: 15),
          
          // Tên user
          const Text(
            'Nguyễn Văn A',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          
          // Email
          Text(
            'nguyenvana@example.com',
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
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text(
                  'Level 12 - Intermediate',
                  style: TextStyle(
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
  Widget _xayDungThanhTich() {
    final cacThanhTich = [
      {'icon': '🏆', 'ten': 'Huy chương', 'soLuong': '24'},
      {'icon': '🎯', 'ten': 'Mục tiêu', 'soLuong': '18'},
      {'icon': '⭐', 'ten': 'Điểm thưởng', 'soLuong': '3,420'},
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
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
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
      {'icon': Icons.edit, 'ten': 'Chỉnh sửa hồ sơ', 'mau': const Color(0xFF6C63FF)},
      {'icon': Icons.notifications, 'ten': 'Thông báo', 'mau': const Color(0xFF4CAF50)},
      {'icon': Icons.language, 'ten': 'Ngôn ngữ học', 'mau': const Color(0xFFFF9800)},
      {'icon': Icons.lock, 'ten': 'Bảo mật', 'mau': const Color(0xFFE91E63)},
      {'icon': Icons.help, 'ten': 'Trợ giúp', 'mau': const Color(0xFF00BCD4)},
      {'icon': Icons.logout, 'ten': 'Đăng xuất', 'mau': const Color(0xFFF44336)},
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
                onTap: () {
                  // Xử lý khi nhấn vào tùy chọn
                  if (tuyChon['ten'] == 'Đăng xuất') {
                    _xuLyDangXuat(context);
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
                      const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
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

  /// Xử lý đăng xuất
  void _xuLyDangXuat(BuildContext context) {
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
            onPressed: () {
              Navigator.pop(context);
              // TODO: Thực hiện đăng xuất và quay về màn hình login
              Navigator.pushReplacementNamed(context, '/auth');
            },
            child: const Text(
              'Đăng xuất',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
