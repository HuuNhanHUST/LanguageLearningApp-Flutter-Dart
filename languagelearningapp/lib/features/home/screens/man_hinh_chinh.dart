import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'man_hinh_hoc_tap.dart';
import 'man_hinh_tu_dien.dart';
import 'man_hinh_tim_kiem.dart';
import 'man_hinh_tien_do.dart';
import 'man_hinh_ho_so.dart';

/// Màn hình chính với Bottom Navigation Bar
/// Quản lý 5 tabs: Học tập, Từ điển, Tìm kiếm, Tiến độ, Hồ sơ
class ManHinhChinh extends StatefulWidget {
  const ManHinhChinh({super.key});

  @override
  State<ManHinhChinh> createState() => _ManHinhChinhState();
}

class _ManHinhChinhState extends State<ManHinhChinh> {
  // Chỉ số tab hiện tại (0-4)
  int _chiSoTabHienTai = 0;

  // Danh sách các màn hình tương ứng với mỗi tab
  final List<Widget> _cacManHinh = [
    const ManHinhHocTap(), // Tab 0: Học tập
    const ManHinhTuDien(), // Tab 1: Từ điển
    const ManHinhTimKiem(), // Tab 2: Tìm kiếm
    const ManHinhTienDo(), // Tab 3: Tiến độ
    const ManHinhHoSo(), // Tab 4: Hồ sơ
  ];

  /// Xử lý khi người dùng tap vào tab
  void _khi_tap_tab(int chiSo) {
    setState(() {
      _chiSoTabHienTai = chiSo;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình tương ứng với tab được chọn
      body: _cacManHinh[_chiSoTabHienTai],

      // Floating Action Button để quét văn bản
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.push('/text-scan');
        },
        backgroundColor: const Color(0xFF6C63FF),
        icon: const Icon(Icons.document_scanner, color: Colors.white),
        label: const Text(
          'Quét văn bản',
          style: TextStyle(color: Colors.white),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // Thanh điều hướng phía dưới
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _chiSoTabHienTai,
        onTap: _khi_tap_tab,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF6C63FF),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Học'),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Từ điển'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Tìm kiếm'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Tiến độ',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Hồ sơ'),
        ],
      ),
    );
  }
}
