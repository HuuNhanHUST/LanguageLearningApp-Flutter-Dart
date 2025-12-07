import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/user_stats.dart';

/// Service để gọi API user statistics
class UserService {
  final http.Client _client;
  final AuthService _authService;

  UserService({http.Client? client, AuthService? authService})
      : _client = client ?? http.Client(),
        _authService = authService ?? AuthService();

  /// Lấy thống kê sâu về user từ API GET /api/users/stats
  /// 
  /// Returns: UserStats object với đầy đủ thông tin:
  /// - streak: Chuỗi ngày học liên tiếp
  /// - totalWords: Tổng số từ đã học
  /// - accuracy: Tỷ lệ chính xác (%)
  /// - xp: Điểm kinh nghiệm hiện tại
  /// - level: Level hiện tại
  /// - nextLevelXp: XP cần để lên level tiếp theo
  /// - xpProgress: XP đã đạt trong level hiện tại
  /// - xpNeeded: Tổng XP cần trong level hiện tại
  /// - wordsLearnedToday: Số từ đã học hôm nay
  Future<UserStats> getUserStats() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      print('📊 Fetching user stats from API...');
      
      final response = await _client
          .get(
            Uri.parse(ApiConstants.getUserStats),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      print('📊 Stats API response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        
        if (data['success'] == true) {
          final statsData = data['data'];
          if (statsData == null) {
            throw Exception('Backend returned null stats data');
          }
          
          print('✅ User stats loaded: Streak ${statsData['streak']}, Total ${statsData['totalWords']}, XP ${statsData['xp']}, Level ${statsData['level']}');
          
          return UserStats.fromJson(statsData);
        } else {
          throw Exception(data['message'] ?? 'Failed to get user stats');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể lấy thống kê người dùng');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'Không thể kết nối với server. Vui lòng kiểm tra kết nối mạng.',
        );
      }
      print('❌ Error fetching user stats: $e');
      rethrow;
    }
  }

  /// Update daily goal (minutes per day)
  Future<void> updateDailyGoal(int minutes) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .put(
            Uri.parse(ApiConstants.updateDailyGoal),
            headers: ApiConstants.getHeaders(token: token),
            body: jsonEncode({'dailyGoal': minutes}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Failed to update daily goal');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể cập nhật mục tiêu hàng ngày');
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
