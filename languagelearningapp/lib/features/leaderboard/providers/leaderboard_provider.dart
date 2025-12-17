import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/leaderboard_entry.dart';
import '../services/leaderboard_service.dart';

/// State cho leaderboard
class LeaderboardState {
  final List<LeaderboardEntry> entries;
  final int? currentUserRank;
  final int totalUsers;
  final bool isLoading;
  final String? error;
  final DateTime? lastUpdated;

  const LeaderboardState({
    this.entries = const [],
    this.currentUserRank,
    this.totalUsers = 0,
    this.isLoading = false,
    this.error,
    this.lastUpdated,
  });

  LeaderboardState copyWith({
    List<LeaderboardEntry>? entries,
    int? currentUserRank,
    int? totalUsers,
    bool? isLoading,
    String? error,
    DateTime? lastUpdated,
  }) {
    return LeaderboardState(
      entries: entries ?? this.entries,
      currentUserRank: currentUserRank ?? this.currentUserRank,
      totalUsers: totalUsers ?? this.totalUsers,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  /// Tìm current user trong leaderboard
  LeaderboardEntry? findCurrentUserEntry(String? currentUserId) {
    if (currentUserId == null) return null;
    try {
      return entries.firstWhere((entry) => entry.userId == currentUserId);
    } catch (e) {
      return null;
    }
  }

  /// Check nếu current user nằm trong top hiển thị
  bool isCurrentUserInTopList(String? currentUserId) {
    return findCurrentUserEntry(currentUserId) != null;
  }
}

/// Notifier quản lý leaderboard state
class LeaderboardNotifier extends StateNotifier<LeaderboardState> {
  final LeaderboardService _service;

  LeaderboardNotifier({LeaderboardService? service})
    : _service = service ?? LeaderboardService(),
      super(const LeaderboardState());

  /// Load leaderboard data
  Future<void> loadLeaderboard() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final data = await _service.getTop100();

      state = state.copyWith(
        entries: data['leaderboard'] as List<LeaderboardEntry>,
        currentUserRank: data['currentUserRank'] as int?,
        totalUsers: data['totalUsers'] as int,
        isLoading: false,
        lastUpdated: DateTime.now(),
      );

      print('✅ Leaderboard loaded: ${state.entries.length} entries');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      print('❌ Error loading leaderboard: $e');
    }
  }

  /// Refresh leaderboard (for pull-to-refresh)
  Future<void> refresh() async {
    await loadLeaderboard();
  }

  /// Reset state
  void reset() {
    state = const LeaderboardState();
  }
}

/// Provider cho leaderboard
final leaderboardProvider =
    StateNotifierProvider<LeaderboardNotifier, LeaderboardState>((ref) {
      return LeaderboardNotifier();
    });
