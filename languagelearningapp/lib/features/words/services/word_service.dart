import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/word_model.dart';

class WordService {
  final http.Client _client;
  final AuthService _authService;

  WordService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  Future<WordModel> lookupWord(String word) async {
    final trimmedWord = word.trim();
    if (trimmedWord.isEmpty) {
      throw Exception('Vui lòng nhập từ cần tra cứu');
    }

    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.wordLookup),
        headers: ApiConstants.getHeaders(token: token),
        body: jsonEncode({'word': trimmedWord}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode == 200 || response.statusCode == 201) {
        final wordData = data['data']?['word'];
        if (wordData is Map<String, dynamic>) {
          return WordModel.fromJson(wordData);
        }
        throw Exception('Dữ liệu trả về không hợp lệ');
      }

      throw Exception(data['message']?.toString() ?? 'Không thể tra cứu từ');
    } catch (e) {
      throw Exception('Lỗi khi tra cứu từ: $e');
    }
  }
}
