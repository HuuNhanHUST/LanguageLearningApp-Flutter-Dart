import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/models/user_model.dart';
import '../models/user_list_response.dart';
import '../models/user_stats_response.dart';

class AdminService {
  final http.Client _client;

  AdminService({http.Client? client}) : _client = client ?? http.Client();

  /// Lấy token từ storage (cần implement)
  Future<String> _getToken() async {
    // TODO: Get token from secure storage
    // For now, return empty - sẽ cần inject token từ AuthProvider
    return '';
  }

  /// Lấy danh sách tất cả users
  Future<UserListResponse> getAllUsers({
    String? role,
    bool? isActive,
    int page = 1,
    int limit = 20,
    String? search,
    required String token,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };

      if (role != null) queryParams['role'] = role;
      if (isActive != null) queryParams['isActive'] = isActive.toString();
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final uri = Uri.parse('${ApiConstants.baseUrl}/users/admin/all')
          .replace(queryParameters: queryParams);

      print('📋 Getting all users: $uri');

      final response = await _client.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📋 Get users response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('📦 Response data keys: ${data.keys}');
        print('📦 Data field type: ${data['data'].runtimeType}');
        if (data['data'] is List && (data['data'] as List).isNotEmpty) {
          print('📦 First user keys: ${(data['data'] as List).first.keys}');
          
          // Try parsing first user to see exact error
          try {
            final firstUserJson = (data['data'] as List).first;
            print('🔍 Trying to parse first user...');
            final testUser = User.fromJson(firstUserJson);
            print('✅ First user parsed successfully: ${testUser.username}');
          } catch (e, stackTrace) {
            print('❌ ERROR parsing first user: $e');
            print('Stack: $stackTrace');
            rethrow;
          }
        }
        return UserListResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch users');
      }
    } catch (e) {
      print('❌ Get users error: $e');
      rethrow;
    }
  }

  /// Nâng user lên teacher
  Future<void> promoteToTeacher(String userId, String token) async {
    try {
      print('⬆️ Promoting user $userId to teacher');

      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/users/admin/promote/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('⬆️ Promote response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to promote user');
      }
    } catch (e) {
      print('❌ Promote error: $e');
      rethrow;
    }
  }

  /// Hạ teacher xuống user
  Future<void> demoteToUser(String userId, String token) async {
    try {
      print('⬇️ Demoting user $userId to regular user');

      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/users/admin/demote/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('⬇️ Demote response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to demote user');
      }
    } catch (e) {
      print('❌ Demote error: $e');
      rethrow;
    }
  }

  /// Cập nhật role của user
  Future<void> updateUserRole(
    String userId,
    String newRole,
    String token,
  ) async {
    try {
      print('🔄 Updating user $userId role to $newRole');

      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/users/admin/role/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'role': newRole}),
      );

      print('🔄 Update role response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update role');
      }
    } catch (e) {
      print('❌ Update role error: $e');
      rethrow;
    }
  }

  /// Kích hoạt/vô hiệu hóa user
  Future<void> toggleUserActive(String userId, String token) async {
    try {
      print('🔄 Toggling user $userId active status');

      final response = await _client.put(
        Uri.parse('${ApiConstants.baseUrl}/users/admin/toggle-active/$userId'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('🔄 Toggle active response: ${response.statusCode}');

      if (response.statusCode != 200) {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to toggle user status');
      }
    } catch (e) {
      print('❌ Toggle active error: $e');
      rethrow;
    }
  }

  /// Lấy thống kê users
  Future<UserStatsResponse> getUserStats(String token) async {
    try {
      print('📊 Getting user stats');

      final response = await _client.get(
        Uri.parse('${ApiConstants.baseUrl}/users/admin/stats'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('📊 Stats response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserStatsResponse.fromJson(data);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to fetch stats');
      }
    } catch (e) {
      print('❌ Get stats error: $e');
      rethrow;
    }
  }
}
