import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/grammar_question_model.dart';

class GrammarQuestionService {
  final http.Client _client;
  final AuthService _authService;

  GrammarQuestionService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  /// Lấy câu hỏi ngữ pháp ngẫu nhiên theo difficulty (không cần wordId)
  /// Dùng cho bài học ngữ pháp - lấy 10 câu random theo level
  Future<List<GrammarQuestionModel>> fetchRandomQuestions({
    required String difficulty,
    int limit = 10,
  }) async {
    print('🔄 Fetching random grammar questions - difficulty: $difficulty, limit: $limit');
    
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    final queryParams = {
      'difficulty': difficulty,
      'limit': limit.toString(),
    };

    final uri = Uri.parse('${ApiConstants.baseUrl}/grammar/questions/random').replace(
      queryParameters: queryParams,
    );
    
    print('📡 Request URL: $uri');

    final response = await _client.get(
      uri,
      headers: ApiConstants.getHeaders(token: token),
    );

    print('📦 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode == 200 && body is Map<String, dynamic>) {
      final data = body['data'] as Map<String, dynamic>?;
      final rawQuestions = data?['questions'] as List? ?? [];
      return rawQuestions
          .map((item) => GrammarQuestionModel.fromJson(
                (item as Map<dynamic, dynamic>).cast<String, dynamic>(),
              ))
          .toList();
    }

    final errorMessage =
        (body is Map<String, dynamic> ? body['message'] : null)?.toString() ??
        'Không thể tải câu hỏi ngữ pháp';
    throw Exception(errorMessage);
  }

  Future<List<GrammarQuestionModel>> fetchQuestions({
    required String wordId,
    int limit = 3,
    String difficulty = 'beginner',
    String lessonKey = 'lesson-2',
    bool autoGenerate = true,
  }) async {
    print('🔄 Fetching grammar questions for wordId: $wordId, lessonKey: $lessonKey');
    
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    final queryParams = {
      'wordId': wordId,
      'limit': limit.toString(),
      'difficulty': difficulty,
      'lessonKey': lessonKey,
      'autoGenerate': autoGenerate.toString(),
    };

    final uri = Uri.parse(ApiConstants.grammarQuestions).replace(
      queryParameters: queryParams,
    );
    
    print('📡 Request URL: $uri');

    final response = await _client.get(
      uri,
      headers: ApiConstants.getHeaders(token: token),
    );

    print('📦 Response status: ${response.statusCode}');
    print('📦 Response body: ${response.body}');

    final statusCode = response.statusCode;
    final body = response.body.isNotEmpty ? jsonDecode(response.body) : null;

    if (statusCode == 200 && body is Map<String, dynamic>) {
      final data = body['data'] as Map<String, dynamic>?;
      final rawQuestions = data?['questions'] as List? ?? [];
      return rawQuestions
          .map((item) => GrammarQuestionModel.fromJson(
                (item as Map<dynamic, dynamic>).cast<String, dynamic>(),
              ))
          .toList();
    }

    final errorMessage =
        (body is Map<String, dynamic> ? body['message'] : null)?.toString() ??
        'Không thể tải câu hỏi ngữ pháp';
    throw Exception(errorMessage);
  }
}
