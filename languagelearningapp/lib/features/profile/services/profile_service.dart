import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/badge_model.dart';

class ProfileService {
  final http.Client _client;
  final AuthService _authService;

  ProfileService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  Future<Map<String, dynamic>> fetchUserStats() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(ApiConstants.getUserStats),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          return body['data'] as Map<String, dynamic>;
        }
      }
      throw Exception('Không thể tải thống kê người dùng');
    } catch (e) {
      return {
        'streak': 0,
        'totalWords': 0,
        'minutes': 0,
        'xp': 0,
      };
    }
  }

  Future<Map<String, dynamic>> fetchVocabularyStats() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(ApiConstants.vocabularyStats),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final data = body['data'];
          if (data is Map<String, dynamic>) {
            return data;
          }
        }
      }
      throw Exception('Không thể tải thống kê từ vựng');
    } catch (e) {
      return const {
        'total': 0,
        'memorized': 0,
        'learning': 0,
        'dueForReview': 0,
        'memorizedPercentage': 0,
      };
    }
  }

  Future<List<BadgeModel>> fetchBadges() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      final response = await _client
          .get(
            Uri.parse(ApiConstants.gamificationBadges),
            headers: ApiConstants.getHeaders(token: token),
          )
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () {
              throw Exception('Request timeout');
            },
          );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['success'] == true) {
          final List<dynamic> list = body['data'] as List<dynamic>? ?? const [];
          if (list.isEmpty) {
            return BadgeModel.sampleBadges();
          }
          return list
              .map((item) => BadgeModel.fromJson(
                    (item as Map<dynamic, dynamic>).cast<String, dynamic>(),
                  ))
              .toList();
        }
      }
      throw Exception('Không thể tải danh sách badges');
    } catch (e) {
      return BadgeModel.sampleBadges();
    }
  }
}
