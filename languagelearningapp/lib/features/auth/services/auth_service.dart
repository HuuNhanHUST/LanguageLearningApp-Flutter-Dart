import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/constants/storage_keys.dart';
import '../models/user_model.dart';

class AuthService {
  final http.Client _client;
  
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

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data['data']);
        
        // Save tokens and user data
        await _saveAuthData(authResponse);
        
        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw Exception('Registration error: $e');
    }
  }

  /// Login user
  Future<AuthResponse> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post(
        Uri.parse(ApiConstants.login),
        headers: ApiConstants.getHeaders(),
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final authResponse = AuthResponse.fromJson(data['data']);
        
        // Save tokens and user data
        await _saveAuthData(authResponse);
        
        return authResponse;
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      throw Exception('Login error: $e');
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
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(StorageKeys.accessToken, data['data']['accessToken']);
        await prefs.setString(StorageKeys.refreshToken, data['data']['refreshToken']);
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
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(StorageKeys.accessToken);
      await prefs.remove(StorageKeys.refreshToken);
      await prefs.remove(StorageKeys.userData);
      await prefs.remove(StorageKeys.isLoggedIn);
      await prefs.remove(StorageKeys.userId);
      await prefs.remove(StorageKeys.userEmail);
    } catch (e) {
      throw Exception('Logout error: $e');
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(StorageKeys.isLoggedIn) ?? false;
    } catch (e) {
      return false;
    }
  }

  /// Get access token
  Future<String?> getAccessToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(StorageKeys.accessToken);
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

  /// Save authentication data
  Future<void> _saveAuthData(AuthResponse authResponse) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(StorageKeys.accessToken, authResponse.accessToken);
      await prefs.setString(StorageKeys.refreshToken, authResponse.refreshToken);
      await prefs.setString(StorageKeys.userData, jsonEncode(authResponse.user.toJson()));
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
}
