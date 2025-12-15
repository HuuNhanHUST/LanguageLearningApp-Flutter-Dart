import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/word_model.dart';
import '../models/pronunciation_result_model.dart';

class PronunciationService {
  final http.Client _client;
  final AuthService _authService;

  PronunciationService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  /// Lấy danh sách từ vựng cho bài học hàng ngày (30 từ unique mỗi ngày)
  /// Sử dụng API GET /words/daily-lesson
  Future<List<WordModel>> getDailyLessonWords() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client.get(
        Uri.parse('${ApiConstants.getWords}/daily-lesson'),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final wordsList = data['data']?['words'] as List?;

        if (wordsList != null && wordsList.isNotEmpty) {
          return wordsList
              .map((item) => WordModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        
        // Nếu đã đạt giới hạn 30 từ/ngày
        if (data['data']?['dailyLimitReached'] == true) {
          print('📅 Daily limit reached: ${data['message']}');
          return [];
        }
        
        // Nếu đã học hết tất cả từ
        if (data['data']?['allLearned'] == true) {
          print('🎓 All words learned at current level');
          return [];
        }
      }

      // Nếu có lỗi, trả về danh sách rỗng
      return [];
    } catch (e) {
      print('Error getting daily lesson words: $e');
      throw Exception('Lỗi tải bài học: $e');
    }
  }

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

  /// So sánh phát âm và trả về kết quả chấm điểm chi tiết
  /// [target] - Câu/từ mẫu cần đọc
  /// [transcript] - Kết quả STT từ giọng nói của người dùng
  Future<PronunciationResultModel> comparePronunciation({
    required String target,
    required String transcript,
  }) async {
    final token = await _authService.getAccessToken();

    // 🔍 DEBUG: Log token
    print('🔑 Token exists: ${token != null}');
    if (token != null && token.length > 20) {
      print('🔑 Token preview: ${token.substring(0, 20)}...');
    }

    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final url = ApiConstants.pronunciationCompare;
      final headers = ApiConstants.getHeaders(token: token);
      final body = jsonEncode({'target': target, 'transcript': transcript});

      // 🔍 DEBUG: Log request details
      print('📤 POST ${url}');
      print('📋 Headers: ${headers}');
      print('📦 Body: $body');

      final response = await _client.post(
        Uri.parse(url),
        headers: headers,
        body: body,
      );

      // 🔍 DEBUG: Log response
      print('📥 Response Status: ${response.statusCode}');
      print('📥 Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return PronunciationResultModel.fromJson(
            data['data'] as Map<String, dynamic>,
          );
        } else {
          throw Exception(data['message'] ?? 'Không thể chấm điểm phát âm');
        }
      } else {
        // Parse error response
        try {
          final error = jsonDecode(response.body) as Map<String, dynamic>;
          final errorMsg = error['message'] ?? 'Lỗi kết nối máy chủ';
          print('❌ Error message: $errorMsg');
          throw Exception(errorMsg);
        } catch (parseError) {
          print('❌ Parse error failed: $parseError');
          throw Exception('Lỗi ${response.statusCode}: ${response.body}');
        }
      }
    } catch (e) {
      throw Exception('Lỗi chấm điểm phát âm: $e');
    }
  }

  /// Tính điểm phát âm đơn giản (chỉ trả về số điểm)
  /// [target] - Câu/từ mẫu cần đọc
  /// [transcript] - Kết quả STT từ giọng nói của người dùng
  Future<double> calculateScore({
    required String target,
    required String transcript,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.pronunciationScore),
        headers: ApiConstants.getHeaders(token: token),
        body: jsonEncode({'target': target, 'transcript': transcript}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return (data['data']['score'] as num).toDouble();
        } else {
          throw Exception(data['message'] ?? 'Không thể tính điểm');
        }
      } else {
        final error = jsonDecode(response.body) as Map<String, dynamic>;
        throw Exception(error['message'] ?? 'Lỗi kết nối máy chủ');
      }
    } catch (e) {
      throw Exception('Lỗi tính điểm: $e');
    }
  }
}
