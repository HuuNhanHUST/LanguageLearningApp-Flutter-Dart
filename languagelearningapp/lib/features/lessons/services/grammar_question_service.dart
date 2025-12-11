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

  Future<List<GrammarQuestionModel>> fetchQuestions({
    required String wordId,
    int limit = 3,
    String difficulty = 'beginner',
    String lessonKey = 'lesson-2',
    bool autoGenerate = true,
  }) async {
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

    final response = await _client.get(
      uri,
      headers: ApiConstants.getHeaders(token: token),
    );

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
