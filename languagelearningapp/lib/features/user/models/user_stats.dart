/// Model cho user statistics từ API GET /api/users/stats
class UserStats {
  final int streak;
  final int totalWords;
  final double accuracy;
  final int xp;
  final int level;
  final int nextLevelXp;
  final int xpProgress;
  final int xpNeeded;
  final int wordsLearnedToday;

  UserStats({
    required this.streak,
    required this.totalWords,
    required this.accuracy,
    required this.xp,
    required this.level,
    required this.nextLevelXp,
    required this.xpProgress,
    required this.xpNeeded,
    required this.wordsLearnedToday,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      streak: json['streak'] as int? ?? 0,
      totalWords: json['totalWords'] as int? ?? 0,
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0.0,
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      nextLevelXp: json['nextLevelXp'] as int? ?? 100,
      xpProgress: json['xpProgress'] as int? ?? 0,
      xpNeeded: json['xpNeeded'] as int? ?? 100,
      wordsLearnedToday: json['wordsLearnedToday'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streak': streak,
      'totalWords': totalWords,
      'accuracy': accuracy,
      'xp': xp,
      'level': level,
      'nextLevelXp': nextLevelXp,
      'xpProgress': xpProgress,
      'xpNeeded': xpNeeded,
      'wordsLearnedToday': wordsLearnedToday,
    };
  }

  /// Tính % tiến độ đến level tiếp theo
  double get progressPercentage {
    if (xpNeeded == 0) return 1.0;
    return (xpProgress / xpNeeded).clamp(0.0, 1.0);
  }

  /// Format XP progress string (e.g., "150/300 XP")
  String get xpProgressString => '$xpProgress/$xpNeeded XP';

  /// XP còn thiếu để lên level
  int get xpRemaining => xpNeeded - xpProgress;

  @override
  String toString() {
    return 'UserStats(streak: $streak, totalWords: $totalWords, accuracy: $accuracy, xp: $xp, level: $level)';
  }
}
