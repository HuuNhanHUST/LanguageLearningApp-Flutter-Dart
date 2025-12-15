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
  final int xpInCurrentLevel;
  final int xpNeededForNextLevel;
  final int? xpForNextLevel;
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
    this.xpInCurrentLevel = 0,
    this.xpNeededForNextLevel = 0,
    this.xpForNextLevel,
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
    int? xpInCurrentLevel,
    int? xpNeededForNextLevel,
    int? xpForNextLevel,
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
      xpInCurrentLevel: xpInCurrentLevel ?? this.xpInCurrentLevel,
      xpNeededForNextLevel: xpNeededForNextLevel ?? this.xpNeededForNextLevel,
      xpForNextLevel: xpForNextLevel ?? this.xpForNextLevel,
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

  /// Tiến độ XP trong level hiện tại (0..1)
  double get xpProgress {
    final total = xpInCurrentLevel + xpNeededForNextLevel;
    if (total <= 0) {
      return xpInCurrentLevel > 0 ? 1 : 0;
    }
    final progress = xpInCurrentLevel / total;
    if (progress.isNaN) return 0;
    return progress.clamp(0.0, 1.0);
  }
}

/// Notifier quản lý learning state
class LearningNotifier extends StateNotifier<LearningState> {
  final LearningService _learningService;

  LearningNotifier({LearningService? learningService})
    : _learningService = learningService ?? LearningService(),
      super(LearningState());

  /// Load initial progress và learned words
  Future<void> loadProgress() async {
    print('🔄 LearningProvider: Starting loadProgress()...');
    state = state.copyWith(isLoading: true, error: null);

    try {
      // Load progress và learned words song song
      final results = await Future.wait([
        _learningService.getProgress(),
        _learningService.getLearnedWords(),
        _learningService.getGamificationStats(),
      ]);

      final progress = results[0] as Map<String, dynamic>;
      final learnedWords = results[1] as List<String>;
      final gamification = results[2] as Map<String, dynamic>;

      state = state.copyWith(
        totalWordsLearned: progress['totalWordsLearned'] as int,
        wordsLearnedToday: progress['wordsLearnedToday'] as int,
        remaining: progress['remaining'] as int,
        dailyLimit: progress['dailyLimit'] as int,
        xp: (gamification['currentXP'] ?? progress['xp']) as int,
        level: (gamification['level'] ?? progress['level']) as int,
        xpInCurrentLevel:
            (gamification['xpInCurrentLevel'] as int?) ??
            (progress['xp'] as int),
        xpNeededForNextLevel:
            (gamification['xpNeededForNextLevel'] as int?) ?? 0,
        xpForNextLevel: gamification['xpForNextLevel'] as int?,
        streak: progress['streak'] as int,
        learnedWordIds: learnedWords,
        isLoading: false,
      );

      print('✅ LearningProvider: State updated successfully!');
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Đánh dấu từ đã học và cập nhật XP
  /// Returns: { success: bool, message: String, leveledUp: bool, xpGained: int, newLevel: int }
  Future<Map<String, dynamic>> markWordLearned(
    String wordId, {
    int score = 100,
    String difficulty = 'medium',
    String activityType = 'lesson',
  }) async {
    if (!state.canLearnMore) {
      return {
        'success': false,
        'message': 'Bạn đã đạt giới hạn 30 từ/ngày rồi! 🎯',
      };
    }

    // Check xem đã học từ này chưa
    if (state.learnedWordIds.contains(wordId)) {
      return {'success': false, 'message': 'Bạn đã học từ này rồi!'};
    }

    try {
      final result = await _learningService.markWordLearned(
        wordId,
        score: score,
        difficulty: difficulty,
        activityType: activityType,
      );

      // Từ đã học rồi - không cần update state
      if (result['xpGained'] == 0) {
        return {
          'success': false,
          'message': result['message'] ?? 'Bạn đã học từ này rồi!',
        };
      }

      // Update state với data từ backend
      state = state.copyWith(
        totalWordsLearned: result['totalWordsLearned'] ?? state.totalWordsLearned,
        wordsLearnedToday: result['wordsLearnedToday'] ?? state.wordsLearnedToday,
        remaining: result['remaining'] ?? state.remaining,
        xp: result['totalXp'] ?? state.xp,
        level: result['level'] ?? state.level,
        streak: result['streak'] ?? state.streak,
        learnedWordIds: [...state.learnedWordIds, wordId],
      );

      // Return result với thông tin level up
      return {
        'success': true,
        'message': result['message'],
        'leveledUp': result['leveledUp'] ?? false,
        'xpGained': result['xpGained'] ?? 0,
        'newLevel': result['newLevel'] ?? state.level,
        'oldLevel': result['oldLevel'] ?? state.level,
      };
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return {'success': false, 'message': 'Lỗi: ${e.toString()}'};
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

  /// Reset state về mặc định (dùng khi logout)
  void reset() {
    state = LearningState();
  }
}

/// Provider cho LearningNotifier
final learningProvider = StateNotifierProvider<LearningNotifier, LearningState>(
  (ref) {
    return LearningNotifier();
  },
);
