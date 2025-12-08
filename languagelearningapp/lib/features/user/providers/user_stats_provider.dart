import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_stats.dart';
import '../services/user_service.dart';

/// State cho user statistics
class UserStatsState {
  final UserStats? stats;
  final bool isLoading;
  final String? error;

  UserStatsState({
    this.stats,
    this.isLoading = false,
    this.error,
  });

  UserStatsState copyWith({
    UserStats? stats,
    bool? isLoading,
    String? error,
  }) {
    return UserStatsState(
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// Notifier quản lý user statistics state
class UserStatsNotifier extends StateNotifier<UserStatsState> {
  final UserService _userService;

  UserStatsNotifier({UserService? userService})
      : _userService = userService ?? UserService(),
        super(UserStatsState());

  /// Load user statistics từ API
  Future<void> loadStats() async {
    print('🔄 UserStatsProvider: Starting loadStats()...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      final stats = await _userService.getUserStats();
      
      print('✅ UserStatsProvider: Stats loaded successfully');
      print('   - Streak: ${stats.streak} days');
      print('   - Total Words: ${stats.totalWords}');
      print('   - Accuracy: ${stats.accuracy}%');
      print('   - XP: ${stats.xp} (Level ${stats.level})');
      print('   - Progress: ${stats.xpProgress}/${stats.xpNeeded} to next level');
      
      state = state.copyWith(
        stats: stats,
        isLoading: false,
      );
    } catch (e) {
      print('❌ UserStatsProvider: Error loading stats: $e');
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update daily goal
  Future<void> updateDailyGoal(int minutes) async {
    try {
      await _userService.updateDailyGoal(minutes);
      // Reload stats after update
      await loadStats();
    } catch (e) {
      print('❌ UserStatsProvider: Error updating daily goal: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Reset state (e.g., on logout)
  void reset() {
    state = UserStatsState();
  }
}

/// Provider cho user statistics
final userStatsProvider =
    StateNotifierProvider<UserStatsNotifier, UserStatsState>((ref) {
  return UserStatsNotifier();
});
