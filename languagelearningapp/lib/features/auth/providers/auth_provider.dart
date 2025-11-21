import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService();

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      _state = AuthState.loading;
      notifyListeners();

      final isLoggedIn = await _authService.isLoggedIn();

      if (isLoggedIn) {
        _user = await _authService.getStoredUser();
        if (_user != null) {
          _state = AuthState.authenticated;
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }

      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Set authenticated user (for Facebook/Social login)
  void setAuthenticatedUser(Map<String, dynamic> userData) {
    try {
      _user = User.fromJson(userData);
      _state = AuthState.authenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// Register new user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String firstName,
    required String lastName,
    String? nativeLanguage,
  }) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.register(
        username: username,
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        nativeLanguage: nativeLanguage,
      );

      _user = authResponse.user;
      _state = AuthState.authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      notifyListeners();

      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _user = authResponse.user;
      _state = AuthState.authenticated;
      notifyListeners();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    try {
      _user = await _authService.getProfile();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateProfile({
    String? firstName,
    String? lastName,
    String? avatar,
    String? nativeLanguage,
  }) async {
    try {
      _errorMessage = null;

      _user = await _authService.updateProfile(
        firstName: firstName,
        lastName: lastName,
        avatar: avatar,
        nativeLanguage: nativeLanguage,
      );

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      _errorMessage = null;

      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
