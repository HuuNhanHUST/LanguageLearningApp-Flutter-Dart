import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';

/// Service để gọi API learning progress và XP system
class LearningService {
  final http.Client _client;
  final AuthService _authService;

  LearningService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  /// Đánh dấu một từ đã học và nhận XP
  /// POST /api/learning/word-learned
  /// Body: { wordId: string }
  Future<Map<String, dynamic>> markWordLearned(String wordId) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/learning/word-learned'),
            headers: ApiConstants.getHeaders(token: token),
            body: jsonEncode({'wordId': wordId}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to mark word as learned');
        }
      } else if (response.statusCode == 429) {
        // Daily limit reached
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Daily limit reached');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể đánh dấu từ đã học');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'Không thể kết nối với server. Vui lòng kiểm tra kết nối mạng.',
        );
      }
      rethrow;
    }
  }

  /// Lấy thông tin tiến độ học tập
  /// GET /api/learning/progress
  /// Returns: { totalWordsLearned, wordsLearnedToday, remaining, dailyLimit, xp, level, streak }
  Future<Map<String, dynamic>> getProgress() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/learning/progress'),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('📦 Backend response for progress: $data');
        
        if (data['success'] == true) {
          final progressData = data['data'];
          if (progressData == null) {
            print('❌ Backend returned null data field');
            throw Exception('Backend returned null data');
          }
          print('✅ Progress data parsed successfully');
          return progressData as Map<String, dynamic>;
        } else {
          throw Exception(data['message'] ?? 'Failed to get progress');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể lấy thông tin tiến độ');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'Không thể kết nối với server. Vui lòng kiểm tra kết nối mạng.',
        );
      }
      rethrow;
    }
  }

  /// Lấy danh sách ID các từ đã học
  /// GET /api/learning/learned-words
  /// Returns: { learnedWords: [String], total: int }
  Future<List<String>> getLearnedWords() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/learning/learned-words'),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        print('📦 Backend response for learned-words: $data');
        
        if (data['success'] == true) {
          final dataField = data['data'];
          if (dataField == null) {
            print('⚠️ Backend returned null data field, using empty list');
            return []; // Return empty list if no data
          }
          
          // Backend returns 'learnedWordIds', not 'learnedWords'
          final learnedWordsRaw = dataField['learnedWordIds'];
          if (learnedWordsRaw == null) {
            print('⚠️ Backend returned null learnedWordIds array, using empty list');
            return []; // Return empty list if learnedWords is null
          }
          
          final learnedWords = (learnedWordsRaw as List<dynamic>)
              .map((id) => id.toString())
              .toList();
          print('✅ Parsed ${learnedWords.length} learned words');
          return learnedWords;
        } else {
          throw Exception(data['message'] ?? 'Failed to get learned words');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(
          error['message'] ?? 'Không thể lấy danh sách từ đã học',
        );
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'Không thể kết nối với server. Vui lòng kiểm tra kết nối mạng.',
        );
      }
      rethrow;
    }
  }
}
