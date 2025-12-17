import 'package:flutter/material.dart';
import '../../../widgets/cached_avatar.dart';
import '../models/leaderboard_entry.dart';

/// Widget hiển thị một entry trong leaderboard
class LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const LeaderboardTile({
    super.key,
    required this.entry,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isTopThree = entry.isTopThree;
    final medal = entry.medalEmoji;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentUser
            ? Border.all(color: const Color(0xFF6C63FF), width: 2)
            : null,
        boxShadow: isTopThree
            ? [
                BoxShadow(
                  color: _getRankColor().withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Rank number hoặc medal
                _buildRankIndicator(medal),
                const SizedBox(width: 12),

                // Avatar
                CachedAvatar(
                  imageUrl: entry.avatar,
                  radius: 24,
                  fallbackText: entry.username,
                ),
                const SizedBox(width: 12),

                // User info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.username,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isTopThree || isCurrentUser
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isCurrentUser
                                    ? const Color(0xFF6C63FF)
                                    : const Color(0xFF1F2937),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (isCurrentUser) ...[
                            const SizedBox(width: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF6C63FF),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'YOU',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            size: 14,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Level ${entry.level}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.local_fire_department,
                            size: 14,
                            color: Colors.orange[700],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${entry.streak} days',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // XP
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${entry.xp}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isTopThree
                            ? _getRankColor()
                            : const Color(0xFF6C63FF),
                      ),
                    ),
                    Text(
                      'XP',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankIndicator(String? medal) {
    if (medal != null) {
      // Top 3 - Show medal
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: _getRankColor().withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Center(child: Text(medal, style: const TextStyle(fontSize: 24))),
      );
    } else {
      // Rank > 3 - Show number
      return Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '${entry.rank}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ),
      );
    }
  }

  Color _getBackgroundColor() {
    if (isCurrentUser) {
      return const Color(0xFFEDE7F6); // Light purple for current user
    }

    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFF9C4); // Light gold
      case 2:
        return const Color(0xFFE0E0E0); // Light silver
      case 3:
        return const Color(0xFFFFE0B2); // Light bronze
      default:
        return Colors.white;
    }
  }

  Color _getRankColor() {
    switch (entry.rank) {
      case 1:
        return const Color(0xFFFFD700); // Gold
      case 2:
        return const Color(0xFFC0C0C0); // Silver
      case 3:
        return const Color(0xFFCD7F32); // Bronze
      default:
        return const Color(0xFF6C63FF);
    }
  }
}
