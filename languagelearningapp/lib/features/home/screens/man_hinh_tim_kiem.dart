import 'package:flutter/material.dart';

/// Màn hình Tìm kiếm
/// Tìm kiếm bài học, từ vựng, chủ đề
class ManHinhTimKiem extends StatefulWidget {
  const ManHinhTimKiem({super.key});

  @override
  State<ManHinhTimKiem> createState() => _ManHinhTimKiemState();
}

class _ManHinhTimKiemState extends State<ManHinhTimKiem> {
  final TextEditingController _boTimKiem = TextEditingController();
  
  // Danh sách kết quả tìm kiếm gần đây
  final List<String> _lichSuTimKiem = [
    'Phát âm cơ bản',
    'Ngữ pháp thì hiện tại',
    'Từ vựng công việc',
    'Giao tiếp hàng ngày',
  ];

  @override
  void dispose() {
    _boTimKiem.dispose();
    super.dispose();
  }

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
          child: Column(
            children: [
              // Header với thanh tìm kiếm
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tìm kiếm',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    _xayDungThanhTimKiem(),
                  ],
                ),
              ),
              
              // Kết quả tìm kiếm
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _xayDungNoiDung(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng thanh tìm kiếm
  Widget _xayDungThanhTimKiem() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _boTimKiem,
        decoration: const InputDecoration(
          hintText: 'Tìm bài học, từ vựng, chủ đề...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF6C63FF)),
        ),
        onChanged: (value) {
          setState(() {}); // Cập nhật kết quả
        },
      ),
    );
  }

  /// Xây dựng nội dung: lịch sử tìm kiếm hoặc kết quả
  Widget _xayDungNoiDung() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const Text(
          'Tìm kiếm gần đây',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 15),
        ..._lichSuTimKiem.map((tuKhoa) => _xayDungMucLichSu(tuKhoa)),
      ],
    );
  }

  /// Xây dựng một mục trong lịch sử tìm kiếm
  Widget _xayDungMucLichSu(String tuKhoa) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFF6C63FF)),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              tuKhoa,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              // Xóa khỏi lịch sử
            },
          ),
        ],
      ),
    );
  }
}
