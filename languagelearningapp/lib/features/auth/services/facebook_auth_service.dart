import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class FacebookAuthService {
  static const String _backendUrl = 'http://10.10.10.124:  git status/api';
  static const _storage = FlutterSecureStorage();

  /// Đăng nhập bằng Facebook
  /// Returns: Map với user + tokens nếu thành công
  static Future<Map<String, dynamic>?> signInWithFacebook() async {
    try {
      // Bước 1: Đăng nhập với Facebook
      final LoginResult result = await FacebookAuth.instance.login(
        permissions: ['public_profile'],
      );

      if (result.status == LoginStatus.success) {
        // Bước 2: Lấy access token
        final String? tokenString = result.accessToken?.tokenString;

        if (tokenString == null) {
          throw Exception('Failed to get Facebook access token');
        }

        // Bước 3: Gửi token tới backend
        final responseData = await _sendTokenToBackend(tokenString);

        if (responseData != null) {
          // Bước 4: Lưu JWT vào secure storage
          final token = responseData['accessToken'];
          if (token != null) {
            await _saveTokenToSecureStorage(token);
          }
        }

        return responseData;
      } else {
        throw Exception('Facebook login failed: ${result.message}');
      }
    } catch (e) {
      print('Facebook Sign In Error: $e');
      rethrow;
    }
  }

  /// Gửi Facebook token tới backend và nhận JWT
  static Future<Map<String, dynamic>?> _sendTokenToBackend(
    String facebookToken,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$_backendUrl/users/auth/facebook'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'facebookToken': facebookToken}),
          )
          .timeout(
            const Duration(seconds: 30),
            onTimeout: () => throw Exception('Backend request timeout'),
          );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);

        if (data['success'] == true) {
          return data['data'];
        } else {
          throw Exception(data['message'] ?? 'Backend error');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Invalid Facebook token');
      } else if (response.statusCode == 400) {
        final data = jsonDecode(response.body);
        throw Exception(data['message'] ?? 'Bad request');
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      print('Send Token to Backend Error: $e');
      rethrow;
    }
  }

  /// Lưu JWT vào secure storage
  static Future<void> _saveTokenToSecureStorage(String token) async {
    try {
      await _storage.write(key: 'jwt_token', value: token);
    } catch (e) {
      print('Error saving token to secure storage: $e');
      rethrow;
    }
  }

  /// Đăng xuất Facebook
  static Future<void> logout() async {
    try {
      await FacebookAuth.instance.logOut();
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      print('Facebook Logout Error: $e');
      rethrow;
    }
  }

  /// Kiểm tra trạng thái đăng nhập hiện tại
  static Future<AccessToken?> getAccessToken() async {
    try {
      return await FacebookAuth.instance.accessToken;
    } catch (e) {
      print('Get Access Token Error: $e');
      return null;
    }
  }

  /// Lấy JWT token từ secure storage
  static Future<String?> getJWTToken() async {
    try {
      return await _storage.read(key: 'jwt_token');
    } catch (e) {
      print('Get JWT Token Error: $e');
      return null;
    }
  }
}
