import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/learning_service.dart';

/// State cho learning progress
class LearningState {
  final int totalWordsLearned;
  final int wordsLearnedToday;
  final int remaining;
  final int dailyLimit;
  final int xp;
  final int level;
  final int streak;
  final List<String> learnedWordIds;
  final bool isLoading;
  final String? error;

  LearningState({
    this.totalWordsLearned = 0,
    this.wordsLearnedToday = 0,
    this.remaining = 30,
    this.dailyLimit = 30,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.learnedWordIds = const [],
    this.isLoading = false,
    this.error,
  });

  LearningState copyWith({
    int? totalWordsLearned,
    int? wordsLearnedToday,
    int? remaining,
    int? dailyLimit,
    int? xp,
    int? level,
    int? streak,
    List<String>? learnedWordIds,
    bool? isLoading,
    String? error,
  }) {
    return LearningState(
      totalWordsLearned: totalWordsLearned ?? this.totalWordsLearned,
      wordsLearnedToday: wordsLearnedToday ?? this.wordsLearnedToday,
      remaining: remaining ?? this.remaining,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      learnedWordIds: learnedWordIds ?? this.learnedWordIds,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Tính % progress trong ngày
  double get dailyProgress {
    if (dailyLimit == 0) return 0;
    return (wordsLearnedToday / dailyLimit).clamp(0.0, 1.0);
  }

  /// Check xem còn học được không
  bool get canLearnMore => remaining > 0;
}

/// Notifier quản lý learning state
class LearningNotifier extends StateNotifier<LearningState> {
  final LearningService _learningService;

  LearningNotifier({LearningService? learningService})
      : _learningService = learningService ?? LearningService(),
        super(LearningState());

  /// Load initial progress và learned words
  Future<void> loadProgress() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load progress và learned words song song
      final results = await Future.wait([
        _learningService.getProgress(),
        _learningService.getLearnedWords(),
      ]);

      final progress = results[0] as Map<String, dynamic>;
      final learnedWords = results[1] as List<String>;

      state = state.copyWith(
        totalWordsLearned: progress['totalWordsLearned'] as int,
        wordsLearnedToday: progress['wordsLearnedToday'] as int,
        remaining: progress['remaining'] as int,
        dailyLimit: progress['dailyLimit'] as int,
        xp: progress['xp'] as int,
        level: progress['level'] as int,
        streak: progress['streak'] as int,
        learnedWordIds: learnedWords,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Đánh dấu từ đã học và cập nhật XP
  /// Returns: { success: bool, message: String, leveledUp: bool, xpGained: int, newLevel: int }
  Future<Map<String, dynamic>> markWordLearned(String wordId) async {
    if (!state.canLearnMore) {
      return {
        'success': false,
        'message': 'Bạn đã đạt giới hạn 30 từ/ngày rồi! 🎯',
      };
    }

    // Check xem đã học từ này chưa
    if (state.learnedWordIds.contains(wordId)) {
      return {
        'success': false,
        'message': 'Bạn đã học từ này rồi!',
      };
    }

    try {
      final result = await _learningService.markWordLearned(wordId);

      // Update state với data mới
      state = state.copyWith(
        totalWordsLearned: result['totalWordsLearned'] as int,
        wordsLearnedToday: result['wordsLearnedToday'] as int,
        remaining: result['remaining'] as int,
        xp: result['xp'] as int,
        level: result['level'] as int,
        learnedWordIds: [...state.learnedWordIds, wordId],
      );

      // Return result với thông tin level up
      final xpGained = result['xpGained'] as int;
      final leveledUp = result['leveledUp'] as bool;

      return {
        'success': true,
        'message': leveledUp
            ? '🎉 Level Up! Bạn lên Level ${state.level}!'
            : '✅ Đã học! +$xpGained XP',
        'leveledUp': leveledUp,
        'xpGained': xpGained,
        'newLevel': state.level,
      };
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return {
        'success': false,
        'message': 'Lỗi: ${e.toString()}',
      };
    }
  }

  /// Check xem một từ đã được học chưa
  bool isWordLearned(String wordId) {
    return state.learnedWordIds.contains(wordId);
  }

  /// Reset error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider cho LearningNotifier
final learningProvider =
    StateNotifierProvider<LearningNotifier, LearningState>((ref) {
  return LearningNotifier();
});
