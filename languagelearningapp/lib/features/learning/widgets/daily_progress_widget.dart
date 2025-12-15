import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/design_system.dart';
import '../providers/learning_provider.dart';

/// Widget hiển thị tiến độ học tập hàng ngày
class DailyProgressWidget extends ConsumerWidget {
  const DailyProgressWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final learningState = ref.watch(learningProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: AppColors.primary,
                        size: AppSpacing.iconSmall,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tiến độ hôm nay',
                          style: AppTextStyles.titleSmall,
                        ),
                        Text(
                          '${learningState.wordsLearnedToday}/${learningState.dailyLimit} từ',
                          style: AppTextStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
                // Level badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.stars,
                        color: AppColors.textOnDark,
                        size: AppSpacing.iconXSmall,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        'Lv.${learningState.level}',
                        style: AppTextStyles.labelMedium.copyWith(
                          color: AppColors.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.lg),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
              child: LinearProgressIndicator(
                value: learningState.dailyProgress,
                minHeight: 10,
                backgroundColor: AppColors.backgroundTertiary,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
              ),
            ),

            const SizedBox(height: AppSpacing.md),

            // Stats row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Streak',
                  value: '${learningState.streak} ngày',
                  color: AppColors.warning,
                ),
                _buildStatItem(
                  icon: Icons.workspace_premium,
                  label: 'XP',
                  value: '${learningState.xp}',
                  color: AppColors.warningLight,
                ),
                _buildStatItem(
                  icon: Icons.menu_book,
                  label: 'Tổng từ',
                  value: '${learningState.totalWordsLearned}',
                  color: AppColors.success,
                ),
              ],
            ),

            // Remaining words indicator
            if (!learningState.canLearnMore) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.containerSuccess(),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: AppColors.success),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '🎉 Đã hoàn thành mục tiêu hôm nay!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.success,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ] else if (learningState.remaining <= 5) ...[
              const SizedBox(height: AppSpacing.md),
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: AppDecorations.containerInfo(),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.info),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        'Còn ${learningState.remaining} từ nữa là xong!',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.info,
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

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: AppSpacing.iconSmall),
        const SizedBox(height: AppSpacing.xs),
        Text(
          value,
          style: AppTextStyles.labelLarge,
        ),
        Text(
          label,
          style: AppTextStyles.labelSmall,
        ),
      ],
    );
  }
}
