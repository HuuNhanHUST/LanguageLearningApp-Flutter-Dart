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

  /// Lấy danh sách từ vựng với phân trang
  Future<Map<String, dynamic>> getWords({
    int page = 1,
    int limit = 20,
    String? filter, // 'all', 'memorized', 'not-memorized'
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      var url = '${ApiConstants.getWords}?page=$page&limit=$limit';
      if (filter != null && filter != 'all') {
        url += '&filter=$filter';
      }

      final response = await _client.get(
        Uri.parse(url),
        headers: ApiConstants.getHeaders(token: token),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final words = (data['data']?['words'] as List?)
                ?.map((json) => WordModel.fromJson(json as Map<String, dynamic>))
                .toList() ??
            [];

        return {
          'words': words,
          'total': data['data']?['total'] ?? 0,
          'page': data['data']?['page'] ?? page,
          'totalPages': data['data']?['totalPages'] ?? 1,
        };
      }

      throw Exception(data['message']?.toString() ?? 'Không thể tải danh sách từ');
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách từ: $e');
    }
  }

  /// Xóa từ vựng
  Future<void> deleteWord(String wordId) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client.delete(
        Uri.parse(ApiConstants.deleteWord(wordId)),
        headers: ApiConstants.getHeaders(token: token),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode != 200) {
        throw Exception(data['message']?.toString() ?? 'Không thể xóa từ');
      }
    } catch (e) {
      throw Exception('Lỗi khi xóa từ: $e');
    }
  }

  /// Đánh dấu từ đã thuộc/chưa thuộc
  Future<WordModel> toggleMemorized(String wordId, bool isMemorized) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client.patch(
        Uri.parse(ApiConstants.toggleMemorized(wordId)),
        headers: ApiConstants.getHeaders(token: token),
        body: jsonEncode({'isMemorized': isMemorized}),
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      
      if (response.statusCode == 200) {
        final wordData = data['data']?['word'];
        if (wordData is Map<String, dynamic>) {
          return WordModel.fromJson(wordData);
        }
        throw Exception('Dữ liệu trả về không hợp lệ');
      }

      throw Exception(data['message']?.toString() ?? 'Không thể cập nhật trạng thái');
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái: $e');
    }
  }
}
