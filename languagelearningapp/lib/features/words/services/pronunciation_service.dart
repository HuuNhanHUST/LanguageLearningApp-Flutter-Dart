import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/word_model.dart';

class PronunciationService {
  final http.Client _client;
  final AuthService _authService;

  PronunciationService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  /// Lấy danh sách từ vựng cho bài học phát âm từ database
  /// Sử dụng API GET /words để lấy danh sách từ của user
  Future<List<WordModel>> getWordsForPronunciation({
    String? topic,
    int? limit, // Đổi thành nullable để có thể lấy tất cả từ
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      // Gọi API GET /words để lấy danh sách từ của user
      var url = ApiConstants.getWords;
      
      // Thêm filter theo topic nếu có
      if (topic != null && topic.isNotEmpty) {
        url += '?topic=$topic';
      }
      
      final response = await _client.get(
        Uri.parse(url),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final wordsList = data['data']?['words'] as List?;
        
        if (wordsList != null && wordsList.isNotEmpty) {
          // Chuyển đổi thành danh sách WordModel
          final allWords = wordsList
              .map((item) => WordModel.fromJson(item as Map<String, dynamic>))
              .toList();
          
          // Shuffle để random
          allWords.shuffle();
          
          // Nếu có giới hạn thì lấy theo limit, không thì lấy tất cả
          if (limit != null && limit > 0) {
            return allWords.take(limit).toList();
          } else {
            return allWords; // Trả về tất cả từ từ database
          }
        }
      }

      // Nếu user chưa có từ nào, trả về danh sách mẫu
      return _getDemoWords();
    } catch (e) {
      // Nếu lỗi, trả về danh sách mẫu để app không bị crash
      return _getDemoWords();
    }
  }

  /// Danh sách từ mẫu khi chưa có API
  /// để 1 cái đề phòng không có từ trong database 
  List<WordModel> _getDemoWords() {
    return [
      const WordModel(
        id: '1',
        word: 'Apple',
        meaning: 'Quả táo',
        type: 'noun',
        example: 'I eat an apple every day',
        topic: 'Food',
      ),
    ];
  }
}
