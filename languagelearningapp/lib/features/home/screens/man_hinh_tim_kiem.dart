import 'dart:async';
import 'package:flutter/material.dart';
import '../../words/models/word_model.dart';
import '../../words/services/word_service.dart';

/// Màn hình Tìm kiếm từ vựng
class ManHinhTimKiem extends StatefulWidget {
  const ManHinhTimKiem({super.key});

  @override
  State<ManHinhTimKiem> createState() => _ManHinhTimKiemState();
}

class _ManHinhTimKiemState extends State<ManHinhTimKiem> {
  final TextEditingController _boTimKiem = TextEditingController();
  final WordService _wordService = WordService();
  
  List<WordModel> _ketQuaTimKiem = [];
  bool _dangTimKiem = false;
  String? _loiTimKiem;
  Timer? _debounceTimer;
  int _thoiGianTimKiem = 0;

  @override
  void dispose() {
    _boTimKiem.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _timKiem(String query) {
    // Hủy timer cũ
    _debounceTimer?.cancel();
    
    if (query.trim().isEmpty) {
      setState(() {
        _ketQuaTimKiem = [];
        _loiTimKiem = null;
        _dangTimKiem = false;
      });
      return;
    }

    // Debounce: chờ 500ms sau khi user ngừng gõ
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      setState(() {
        _dangTimKiem = true;
        _loiTimKiem = null;
      });

      try {
        final result = await _wordService.searchWords(
          query: query.trim(),
          limit: 20,
        );
        
        if (mounted) {
          setState(() {
            _ketQuaTimKiem = result['words'] as List<WordModel>;
            _thoiGianTimKiem = result['searchTime'] as int;
            _dangTimKiem = false;
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _loiTimKiem = e.toString().replaceAll('Exception: ', '');
            _dangTimKiem = false;
          });
        }
      }
    });
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
        autofocus: true,
        decoration: InputDecoration(
          hintText: 'Nhập từ vựng cần tìm...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
          suffixIcon: _boTimKiem.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _boTimKiem.clear();
                    _timKiem('');
                  },
                )
              : null,
        ),
        onChanged: _timKiem,
      ),
    );
  }

  /// Xây dựng nội dung: kết quả tìm kiếm
  Widget _xayDungNoiDung() {
    if (_dangTimKiem) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6C63FF)),
            SizedBox(height: 16),
            Text(
              'Đang tìm kiếm...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_loiTimKiem != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: Colors.red,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                _loiTimKiem!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    if (_boTimKiem.text.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Nhập từ vựng để tìm kiếm',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Hỗ trợ tìm kiếm theo từ, nghĩa, chủ đề',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_ketQuaTimKiem.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey,
            ),
            const SizedBox(height: 16),
            Text(
              'Không tìm thấy kết quả cho "${_boTimKiem.text}"',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Tìm thấy ${_ketQuaTimKiem.length} kết quả',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B69),
              ),
            ),
            if (_thoiGianTimKiem > 0)
              Text(
                '${_thoiGianTimKiem}ms',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
          ],
        ),
        const SizedBox(height: 15),
        ..._ketQuaTimKiem.map((word) => _xayDungTheKetQua(word)),
      ],
    );
  }

  /// Xây dựng thẻ kết quả tìm kiếm
  Widget _xayDungTheKetQua(WordModel word) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF6C63FF),
                  ),
                ),
              ),
              if (word.isMemorized)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle, size: 16, color: Colors.green[700]),
                      const SizedBox(width: 4),
                      Text(
                        'Đã thuộc',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          if (word.type.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _layTenLoaiTu(word.type),
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6C63FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            word.meaning,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black87,
            ),
          ),
          if (word.example != null && word.example!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                word.example!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (word.topic != null && word.topic!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.topic, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(
                  word.topic!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _layTenLoaiTu(String type) {
    switch (type.toLowerCase()) {
      case 'noun':
        return 'Danh từ';
      case 'verb':
        return 'Động từ';
      case 'adj':
      case 'adjective':
        return 'Tính từ';
      case 'adv':
      case 'adverb':
        return 'Trạng từ';
      default:
        return type;
    }
  }
}
