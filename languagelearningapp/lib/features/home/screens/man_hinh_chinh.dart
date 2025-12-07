import 'package:flutter/material.dart';
import 'man_hinh_hoc_tap.dart';
import 'man_hinh_tu_dien.dart';
import 'man_hinh_tim_kiem.dart';
import 'man_hinh_tien_do.dart';
import 'man_hinh_ho_so.dart';
import '../../chat/screens/chat_screen.dart';

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

  /// Xử lý khi người dùng tap vào tab
  void _khi_tap_tab(int chiSo) {
    setState(() {
      _chiSoTabHienTai = chiSo;
    });
  }

  /// Build màn hình theo tab - TẠO MỚI mỗi lần để reload data
  Widget _buildScreen() {
    switch (_chiSoTabHienTai) {
      case 0:
        return const ManHinhHocTap();
      case 1:
        return const ManHinhTuDien();
      case 2:
        return const ChatScreen();
      case 3:
        return const ManHinhTimKiem();
      case 4:
        return const ManHinhTienDo();
      case 5:
        return const ManHinhHoSo();
      default:
        return const ManHinhHocTap();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Hiển thị màn hình tương ứng với tab được chọn
      body: _buildScreen(),
      
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
          BottomNavigationBarItem(
            icon: Icon(Icons.school),
            label: 'Học',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Từ điển',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble),
            label: 'AI Chat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Tìm kiếm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Tiến độ',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Hồ sơ',
          ),
        ],
      ),
    );
  }
}
