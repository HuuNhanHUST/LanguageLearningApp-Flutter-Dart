import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

class AuthService {
  final http.Client _client;
  static const _secureStorage = FlutterSecureStorage();

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Register a new user
  Future<AuthResponse> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? nativeLanguage,
  }) async {
    try {
      print('📝 Register Request to: ${ApiConstants.register}');
      final response = await _client.post(
        Uri.parse(ApiConstants.register),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
          'firstName': firstName,
          'lastName': lastName,
          if (nativeLanguage != null) 'nativeLanguage': nativeLanguage,
        }),
      );

      print('📝 Register Response Status: ${response.statusCode}');
      print('📝 Register Response Body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Registration failed');
        }
        final authResponse = AuthResponse.fromJson(data['data']);

        // Save tokens and user data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      print('❌ Registration error: $e');
      rethrow;
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      print('🔐 Login Request to: ${ApiConstants.login}');
      final response = await _client.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({'email': email, 'password': password}),
      );

      print('🔐 Login Response Status: ${response.statusCode}');
      print('🔐 Login Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] != true) {
          throw Exception(data['message'] ?? 'Login failed');
        }
        final authResponse = AuthResponse.fromJson(data['data']);

        // Save tokens and user data
        await _saveAuthData(authResponse);

        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      print('❌ Login error: $e');
      rethrow;
    }
  }

  /// Get user profile
  Future<User> getProfile() async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.get(
        Uri.parse(ApiConstants.profile),
        headers: ApiConstants.getHeaders(token: token),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data['data']['user']);
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to get profile');
      }
    } catch (e) {
      throw Exception('Get profile error: $e');
    }
  }

  /// Update user profile
  Future<User> updateProfile({
    String? firstName,
    String? lastName,
    String? avatar,
    String? nativeLanguage,
  }) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final body = <String, dynamic>{};
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (avatar != null) body['avatar'] = avatar;
      if (nativeLanguage != null) body['nativeLanguage'] = nativeLanguage;

      final response = await _client.put(
        Uri.parse(ApiConstants.updateProfile),
        headers: ApiConstants.getHeaders(token: token),
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final user = User.fromJson(data['data']['user']);

        // Update stored user data
        await _saveUserData(user);

        return user;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to update profile');
      }
    } catch (e) {
      throw Exception('Update profile error: $e');
    }
  }

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final token = await getAccessToken();
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await _client.put(
        Uri.parse(ApiConstants.changePassword),
        headers: ApiConstants.getHeaders(token: token),
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Update tokens after password change
        await _secureStorage.write(
          key: StorageKeys.accessToken,
          value: data['data']['accessToken'],
        );
        await _secureStorage.write(
          key: StorageKeys.refreshToken,
          value: data['data']['refreshToken'],
        );
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Failed to change password');
      }
    } catch (e) {
      throw Exception('Change password error: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _clearStoredAuthData();
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final storedToken = await _secureStorage.read(
        key: StorageKeys.accessToken,
      );
      final prefs = await SharedPreferences.getInstance();
      final isMarkedLoggedIn = prefs.getBool(StorageKeys.isLoggedIn) ?? false;

      if (storedToken == null || storedToken.isEmpty) {
        await _clearStoredAuthData();
        return false;
      }

      if (_isTokenExpired(storedToken)) {
        await _clearStoredAuthData();
        return false;
      }

      return isMarkedLoggedIn;
    } catch (e) {
      return false;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final token = await _secureStorage.read(key: StorageKeys.accessToken);

      if (token == null || token.isEmpty) {
        return null;
      }

      if (_isTokenExpired(token)) {
        await _clearStoredAuthData();
        return null;
      }

      return token;
    } catch (e) {
      return null;
    }
  }

  /// Get stored user data
  Future<User?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(StorageKeys.userData);
      if (userData != null) {
        return User.fromJson(jsonDecode(userData));
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Save authentication data from social login (Facebook/Google)
  Future<void> saveAuthDataFromSocial(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save tokens to secure storage
      if (data['accessToken'] != null) {
        await _secureStorage.write(
          key: StorageKeys.accessToken,
          value: data['accessToken'],
        );
      }
      if (data['refreshToken'] != null) {
        await _secureStorage.write(
          key: StorageKeys.refreshToken,
          value: data['refreshToken'],
        );
      }

      // Save user data
      if (data['user'] != null) {
        final user = User.fromJson(data['user']);
        await prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));
        await prefs.setString(StorageKeys.userId, user.id);
        await prefs.setString(StorageKeys.userEmail, user.email);
      }

      await prefs.setBool(StorageKeys.isLoggedIn, true);

      print(
        '✅ Social login data saved (tokens in Secure Storage, user data in SharedPreferences)',
      );
    } catch (e) {
      print('❌ Failed to save social auth data: $e');
      throw Exception('Failed to save social auth data: $e');
    }
  }

  /// Save authentication data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    try {
      // Save tokens to secure storage
      await _secureStorage.write(
        key: StorageKeys.accessToken,
        value: authResponse.accessToken,
      );
      await _secureStorage.write(
        key: StorageKeys.refreshToken,
        value: authResponse.refreshToken,
      );

      // Save user data to shared preferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        StorageKeys.userData,
        jsonEncode(authResponse.user.toJson()),
      );
      await prefs.setBool(StorageKeys.isLoggedIn, true);
      await prefs.setString(StorageKeys.userId, authResponse.user.id);
      await prefs.setString(StorageKeys.userEmail, authResponse.user.email);
    } catch (e) {
      throw Exception('Failed to save auth data: $e');
    }
  }

  /// Save user data
  Future<void> _saveUserData(User user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.userData, jsonEncode(user.toJson()));
    } catch (e) {
      throw Exception('Failed to save user data: $e');
    }
  }

  Future<void> _clearStoredAuthData() async {
    // Clear tokens from secure storage
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);

    // Clear user data from shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(StorageKeys.userData);
    await prefs.remove(StorageKeys.isLoggedIn);
    await prefs.remove(StorageKeys.userId);
    await prefs.remove(StorageKeys.userEmail);
  }

  bool _isTokenExpired(String token) {
    try {
      return JwtDecoder.isExpired(token);
    } catch (_) {
      return true;
    }
  }
}
