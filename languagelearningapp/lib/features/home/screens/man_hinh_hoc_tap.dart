import 'package:flutter/material.dart';
import 'man_hinh_bai_hoc_phat_am.dart';
import '../../../screens/text_scan_screen.dart';

/// Màn hình Dashboard - Tab Học tập chính
/// Hiển thị các bài học, categories, tiến độ giống ELSA
class ManHinhHocTap extends StatelessWidget {
  const ManHinhHocTap({super.key});

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
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header với avatar và greeting
                _xayDungHeader(),
                const SizedBox(height: 30),

                // Vòng tròn tiến độ tổng thể
                _xayDungVongTronTienDo(),
                const SizedBox(height: 30),

                // Danh sách bài học
                _xayDungTieuDe('Bài học của bạn'),
                const SizedBox(height: 15),
                _xayDungDanhSachBaiHoc(),
                const SizedBox(height: 30),

                // Categories
                _xayDungTieuDe('Chủ đề học tập'),
                const SizedBox(height: 15),
                _xayDungDanhSachChuDe(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng header với avatar và lời chào
  Widget _xayDungHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào! 👋',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Sẵn sàng học hôm nay?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        // Avatar
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.person, color: Color(0xFF6C63FF), size: 30),
        ),
      ],
    );
  }

  /// Xây dựng vòng tròn hiển thị tiến độ tổng thể
  Widget _xayDungVongTronTienDo() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Vòng tròn tiến độ
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 0.86, // 86%
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '86%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hoàn thành',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Thông tin thống kê
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _xayDungThongKe('🎯', 'Mục tiêu', '5/7 ngày'),
              const SizedBox(height: 15),
              _xayDungThongKe('🔥', 'Chuỗi ngày', '12 ngày'),
              const SizedBox(height: 15),
              _xayDungThongKe('⏱️', 'Thời gian', '2.5 giờ'),
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng một dòng thống kê (icon + label + value)
  Widget _xayDungThongKe(String icon, String nhan, String giaTri) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nhan,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              giaTri,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng tiêu đề section
  Widget _xayDungTieuDe(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Xây dựng danh sách các bài học
  Widget _xayDungDanhSachBaiHoc() {
    final cacBaiHoc = [
      {
        'ten': 'Bài học 1',
        'chuDe': 'Phát âm /p/, /t/, /k/',
        'tienDo': 0.8,
        'mau': const Color(0xFF6C63FF),
      },
      {
        'ten': 'Bài học 2',
        'chuDe': 'Ngữ điệu câu hỏi',
        'tienDo': 0.5,
        'mau': const Color(0xFF4CAF50),
      },
      {
        'ten': 'Bài học 3',
        'chuDe': 'Từ vựng hàng ngày',
        'tienDo': 0.3,
        'mau': const Color(0xFFFF9800),
      },
    ];

    return Column(
      children: cacBaiHoc.map((baiHoc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Icon bài học
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: baiHoc['mau'] as Color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              // Thông tin bài học
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baiHoc['ten'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      baiHoc['chuDe'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: baiHoc['tienDo'] as double,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          baiHoc['mau'] as Color,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Nút bắt đầu
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: baiHoc['mau'] as Color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.play_arrow, color: Colors.white),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Xây dựng grid các chủ đề học tập
  Widget _xayDungDanhSachChuDe() {
    final cacChuDe = [
      {
        'ten': 'Phát âm',
        'soLuong': '24 bài',
        'icon': Icons.mic,
        'mau': const Color(0xFF6C63FF),
      },
      {
        'ten': 'Ngữ pháp',
        'soLuong': '18 bài',
        'icon': Icons.book,
        'mau': const Color(0xFF4CAF50),
      },
      {
        'ten': 'Từ vựng',
        'soLuong': '32 bài',
        'icon': Icons.library_books,
        'mau': const Color(0xFFFF9800),
      },
      {
        'ten': 'Giao tiếp',
        'soLuong': '15 bài',
        'icon': Icons.chat,
        'mau': const Color(0xFFE91E63),
      },
      {
        'ten': 'Quét văn bản',
        'soLuong': 'OCR',
        'icon': Icons.document_scanner,
        'mau': const Color(0xFF00BCD4),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemCount: cacChuDe.length,
      itemBuilder: (context, index) {
        final chuDe = cacChuDe[index];
        return GestureDetector(
          onTap: () {
            // Nếu là chủ đề Phát âm -> chuyển thẳng đến bài học
            if (chuDe['ten'] == 'Phát âm') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManHinhBaiHocPhatAm(
                    tenBaiHoc: 'Luyện phát âm cơ bản',
                    chuDe: 'Phát âm',
                  ),
                ),
              );
            }
            // Nếu là Quét văn bản -> chuyển đến Text Scan Screen
            else if (chuDe['ten'] == 'Quét văn bản') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TextScanScreen()),
              );
            }
            // Các chủ đề khác hiển thị thông báo
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chức năng ${chuDe['ten']} đang phát triển'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  chuDe['mau'] as Color,
                  (chuDe['mau'] as Color).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: (chuDe['mau'] as Color).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(chuDe['icon'] as IconData, color: Colors.white, size: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chuDe['ten'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chuDe['soLuong'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
