/// Model cho mỗi entry trong bảng xếp hạng
class LeaderboardEntry {
  final int rank;
  final String userId;
  final String username;
  final String? avatar;
  final int xp;
  final int level;
  final int streak;
  final DateTime joinedAt;

  const LeaderboardEntry({
    required this.rank,
    required this.userId,
    required this.username,
    this.avatar,
    required this.xp,
    required this.level,
    required this.streak,
    required this.joinedAt,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      rank: json['rank'] as int? ?? 0,
      userId: json['userId']?.toString() ?? '',
      username: json['username']?.toString() ?? 'Unknown',
      avatar: json['avatar']?.toString(),
      xp: json['xp'] as int? ?? 0,
      level: json['level'] as int? ?? 1,
      streak: json['streak'] as int? ?? 0,
      joinedAt: json['joinedAt'] != null
          ? DateTime.parse(json['joinedAt'] as String)
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'userId': userId,
      'username': username,
      'avatar': avatar,
      'xp': xp,
      'level': level,
      'streak': streak,
      'joinedAt': joinedAt.toIso8601String(),
    };
  }

  /// Check if this is current user
  bool isCurrentUser(String? currentUserId) {
    return currentUserId != null && userId == currentUserId;
  }

  /// Get medal emoji for top 3
  String? get medalEmoji {
    switch (rank) {
      case 1:
        return '🥇';
      case 2:
        return '🥈';
      case 3:
        return '🥉';
      default:
        return null;
    }
  }

  /// Get background color for top 3
  bool get isTopThree => rank <= 3;
}
