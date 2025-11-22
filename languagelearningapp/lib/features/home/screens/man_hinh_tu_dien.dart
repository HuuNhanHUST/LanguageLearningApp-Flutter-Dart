import 'package:flutter/material.dart';

/// Màn hình Từ điển
/// Cho phép tìm kiếm và học từ vựng
class ManHinhTuDien extends StatefulWidget {
  const ManHinhTuDien({super.key});

  @override
  State<ManHinhTuDien> createState() => _ManHinhTuDienState();
}

class _ManHinhTuDienState extends State<ManHinhTuDien> {
  final TextEditingController _boTimKiem = TextEditingController();
  
  // Danh sách từ vựng mẫu
  final List<Map<String, String>> _danhSachTuVung = [
    {'tu': 'Apple', 'phienAm': '/ˈæp.əl/', 'nghia': 'Quả táo', 'loai': 'noun'},
    {'tu': 'Beautiful', 'phienAm': '/ˈbjuː.tɪ.fəl/', 'nghia': 'Đẹp', 'loai': 'adjective'},
    {'tu': 'Cat', 'phienAm': '/kæt/', 'nghia': 'Con mèo', 'loai': 'noun'},
    {'tu': 'Dance', 'phienAm': '/dæns/', 'nghia': 'Nhảy múa', 'loai': 'verb'},
    {'tu': 'Excited', 'phienAm': '/ɪkˈsaɪ.tɪd/', 'nghia': 'Phấn khích', 'loai': 'adjective'},
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
              // Header
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Từ điển',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Thanh tìm kiếm
                    _xayDungThanhTimKiem(),
                  ],
                ),
              ),
              
              // Danh sách từ vựng
              Expanded(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: _xayDungDanhSachTuVung(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Xây dựng thanh tìm kiếm từ vựng
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
          hintText: 'Tìm kiếm từ vựng...',
          border: InputBorder.none,
          icon: Icon(Icons.search, color: Color(0xFF6C63FF)),
        ),
        onChanged: (value) {
          setState(() {}); // Cập nhật UI khi search
        },
      ),
    );
  }

  /// Xây dựng danh sách các từ vựng
  Widget _xayDungDanhSachTuVung() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _danhSachTuVung.length,
      itemBuilder: (context, index) {
        final tuVung = _danhSachTuVung[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              // Icon phát âm
              Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF6C63FF),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.volume_up, color: Colors.white),
              ),
              const SizedBox(width: 15),
              // Thông tin từ vựng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          tuVung['tu']!,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFF6C63FF).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            tuVung['loai']!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tuVung['phienAm']!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      tuVung['nghia']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              // Nút bookmark
              IconButton(
                icon: const Icon(Icons.bookmark_border),
                color: const Color(0xFF6C63FF),
                onPressed: () {
                  // Xử lý lưu từ vựng
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
