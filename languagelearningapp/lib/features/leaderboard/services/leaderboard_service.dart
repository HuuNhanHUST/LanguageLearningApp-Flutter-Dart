import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/leaderboard_entry.dart';

class LeaderboardService {
  final http.Client _client;
  final AuthService _authService;

  LeaderboardService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  /// Lấy top 100 users từ leaderboard
  /// GET /api/leaderboard/top100
  Future<Map<String, dynamic>> getTop100() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/leaderboard/top100'),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('📊 Leaderboard Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          final leaderboardData = data['data'] as Map<String, dynamic>;
          final leaderboardList =
              leaderboardData['leaderboard'] as List<dynamic>? ?? [];

          final entries = leaderboardList
              .map(
                (item) =>
                    LeaderboardEntry.fromJson(item as Map<String, dynamic>),
              )
              .toList();

          return {
            'leaderboard': entries,
            'currentUserRank': leaderboardData['currentUserRank'] as int?,
            'totalUsers': leaderboardData['totalUsers'] as int? ?? 0,
          };
        }

        throw Exception(data['message'] ?? 'Không thể tải bảng xếp hạng');
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi tải bảng xếp hạng');
      }
    } catch (e) {
      print('❌ Leaderboard Service Error: $e');
      rethrow;
    }
  }

  /// Lấy rank của user hiện tại
  /// GET /api/leaderboard/my-rank
  Future<Map<String, dynamic>> getMyRank() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse('${ApiConstants.baseUrl}/leaderboard/my-rank'),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 10),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return data['data'] as Map<String, dynamic>;
        }

        throw Exception(data['message'] ?? 'Không thể tải thứ hạng');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Lỗi tải thứ hạng');
      }
    } catch (e) {
      print('❌ My Rank Service Error: $e');
      rethrow;
    }
  }
}
