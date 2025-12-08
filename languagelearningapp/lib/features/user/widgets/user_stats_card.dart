import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/user_stats_provider.dart';

/// Widget hiển thị user statistics chi tiết
/// Sử dụng API GET /api/users/stats
class UserStatsCard extends ConsumerStatefulWidget {
  const UserStatsCard({super.key});

  @override
  ConsumerState<UserStatsCard> createState() => _UserStatsCardState();
}

class _UserStatsCardState extends ConsumerState<UserStatsCard> {
  @override
  void initState() {
    super.initState();
    // Load stats when widget initializes
    Future.microtask(() {
      ref.read(userStatsProvider.notifier).loadStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final statsState = ref.watch(userStatsProvider);

    if (statsState.isLoading) {
      return const Card(
        elevation: 4,
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    if (statsState.error != null) {
      return Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 10),
              Text(
                'Không thể tải thống kê',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 5),
              Text(
                statsState.error!,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                onPressed: () {
                  ref.read(userStatsProvider.notifier).loadStats();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final stats = statsState.stats;
    if (stats == null) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Thống kê học tập',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF2D1B69),
                      ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: () {
                    ref.read(userStatsProvider.notifier).loadStats();
                  },
                  tooltip: 'Làm mới',
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Stats Grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 15,
              crossAxisSpacing: 15,
              childAspectRatio: 1.5,
              children: [
                _buildStatItem(
                  context,
                  icon: Icons.local_fire_department,
                  iconColor: Colors.orange,
                  label: 'Streak',
                  value: '${stats.streak}',
                  unit: 'ngày',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.book_rounded,
                  iconColor: Colors.blue,
                  label: 'Tổng từ',
                  value: '${stats.totalWords}',
                  unit: 'từ',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.stars_rounded,
                  iconColor: Colors.amber,
                  label: 'XP',
                  value: '${stats.xp}',
                  unit: 'điểm',
                ),
                _buildStatItem(
                  context,
                  icon: Icons.military_tech_rounded,
                  iconColor: Colors.purple,
                  label: 'Level',
                  value: '${stats.level}',
                  unit: '',
                ),
              ],
            ),

            const SizedBox(height: 20),

            // XP Progress to next level
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Tiến độ Level ${stats.level + 1}',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Text(
                      stats.xpProgressString,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: stats.progressPercentage,
                    minHeight: 12,
                    backgroundColor: Colors.grey[200],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF2D1B69),
                    ),
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Còn ${stats.xpRemaining} XP để lên level',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
              ],
            ),

            const SizedBox(height: 15),

            // Today's progress
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.today_rounded, color: Colors.blue),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Hôm nay đã học ${stats.wordsLearnedToday} từ',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ),
                ],
              ),
            ),

            // Accuracy (if available)
            if (stats.accuracy > 0) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.green),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Độ chính xác: ${stats.accuracy.toStringAsFixed(1)}%',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: iconColor.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: iconColor, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            unit.isNotEmpty ? unit : label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
