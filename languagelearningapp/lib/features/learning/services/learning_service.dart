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

  /// Đánh dấu từ là đã học và nhận XP
  /// POST /api/learning/word-learned
  /// Body: { wordId }
  Future<Map<String, dynamic>> markWordLearned(
    String wordId, {
    int score = 100,
    String difficulty = 'medium',
    String activityType = 'lesson',
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .post(
            Uri.parse('${ApiConstants.baseUrl}/learning/word-learned'),
            headers: ApiConstants.getHeaders(token: token),
            body: jsonEncode({
              'wordId': wordId,
            }),
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
          return {
            'success': true,
            'message': data['message'] ?? 'Word learned!',
            'leveledUp': data['data']?['leveledUp'] ?? false,
            'xpGained': data['data']?['xpGained'] ?? 0,
            'totalXp': data['data']?['totalXp'] ?? 0,
            'level': data['data']?['level'] ?? 1,
            'oldLevel': data['data']?['oldLevel'] ?? 1,
            'newLevel': data['data']?['newLevel'] ?? 1,
            'wordsLearnedToday': data['data']?['wordsLearnedToday'] ?? 0,
            'totalWordsLearned': data['data']?['totalWordsLearned'] ?? 0,
            'remaining': data['data']?['remaining'] ?? 0,
            'streak': data['data']?['streak'] ?? 0,
          };
        } else {
          throw Exception(data['message'] ?? 'Failed to mark word as learned');
        }
      } else if (response.statusCode == 400) {
        final error = jsonDecode(response.body);
        // Từ đã học rồi - trả về thành công nhưng không có XP
        if (error['message']?.toString().contains('already learned') == true) {
          return {
            'success': true,
            'message': 'Bạn đã học từ này rồi!',
            'leveledUp': false,
            'xpGained': 0,
          };
        }
        throw Exception(error['message'] ?? 'Invalid request');
      } else if (response.statusCode == 429) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Đã đạt giới hạn 30 từ/ngày');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể cập nhật tiến độ');
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
          final dataField = data['data'] as Map<String, dynamic>;
          final learnedWordsRaw = dataField['learnedWordIds'];
          
          // Xử lý null an toàn
          if (learnedWordsRaw == null) {
            print('⚠️ learnedWordIds is null, returning empty list');
            return [];
          }
          
          final learnedWords = (learnedWordsRaw as List<dynamic>)
              .map((id) => id.toString())
              .toList();
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

  /// Lấy thông tin gamification (XP, level boundaries)
  /// GET /api/gamification/stats
  Future<Map<String, dynamic>> getGamificationStats() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/gamification/stats'),
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
        if (data['success'] == true) {
          return data['data'] as Map<String, dynamic>;
        } else {
          throw Exception(
            data['message'] ?? 'Failed to get gamification stats',
          );
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể lấy thông tin XP/Level');
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
