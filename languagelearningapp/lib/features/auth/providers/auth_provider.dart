import 'dart:async';

import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { initial, loading, authenticated, unauthenticated, error }

class AuthStatus {
  final AuthState state;
  final User? user;
  final String? errorMessage;

  const AuthStatus({
    required this.state,
    this.user,
    this.errorMessage,
  });

  bool get isAuthenticated => state == AuthState.authenticated && user != null;
  bool get isLoading => state == AuthState.initial || state == AuthState.loading;
}

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  final StreamController<AuthStatus> _authStatusController =
      StreamController<AuthStatus>.broadcast();

  AuthState _state = AuthState.initial;
  User? _user;
  String? _errorMessage;

  AuthProvider({AuthService? authService})
    : _authService = authService ?? AuthService() {
    _emitStatus();
  }

  AuthState get state => _state;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  Stream<AuthStatus> get authStatusStream => _authStatusController.stream;
  AuthStatus get currentStatus => AuthStatus(
        state: _state,
        user: _user,
        errorMessage: _errorMessage,
      );

  /// Initialize auth state
  Future<void> initialize() async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      _notifyStateChanged();

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

      _notifyStateChanged();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      _notifyStateChanged();
    }
  }

  /// Set authenticated user (for Facebook/Social login)
  void setAuthenticatedUser(Map<String, dynamic> userData) {
    try {
      _user = User.fromJson(userData);
      _state = AuthState.authenticated;
      _errorMessage = null;
      _notifyStateChanged();
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString();
      _notifyStateChanged();
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
      _notifyStateChanged();

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
      _notifyStateChanged();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _notifyStateChanged();
      return false;
    }
  }

  /// Login user
  Future<bool> login({required String email, required String password}) async {
    try {
      _state = AuthState.loading;
      _errorMessage = null;
      _notifyStateChanged();

      final authResponse = await _authService.login(
        email: email,
        password: password,
      );

      _user = authResponse.user;
      _state = AuthState.authenticated;
      _notifyStateChanged();

      return true;
    } catch (e) {
      _state = AuthState.error;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _notifyStateChanged();
      return false;
    }
  }

  /// Refresh user profile
  Future<void> refreshProfile() async {
    try {
      _user = await _authService.getProfile();
      _notifyStateChanged();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _notifyStateChanged();
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

      _notifyStateChanged();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _notifyStateChanged();
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
      _notifyStateChanged();
      return false;
    }
  }

  /// Update user data
  void updateUser(User updatedUser) {
    _user = updatedUser;
    _notifyStateChanged();
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await _authService.logout();
      _user = null;
      _state = AuthState.unauthenticated;
      _errorMessage = null;
      _notifyStateChanged();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _notifyStateChanged();
    }
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    _notifyStateChanged();
  }

  void _notifyStateChanged() {
    _emitStatus();
    notifyListeners();
  }

  void _emitStatus() {
    if (!_authStatusController.isClosed) {
      _authStatusController.add(currentStatus);
    }
  }

  @override
  void dispose() {
    _authStatusController.close();
    super.dispose();
  }
}
