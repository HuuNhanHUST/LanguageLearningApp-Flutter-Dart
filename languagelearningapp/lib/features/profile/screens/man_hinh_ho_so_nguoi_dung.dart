import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart' as provider;

import '../../../widgets/cached_avatar.dart';
import '../../auth/models/user_model.dart';
import '../../auth/providers/auth_provider.dart';
import '../../learning/providers/learning_provider.dart';
import '../models/badge_model.dart';
import '../services/profile_service.dart';
import '../widgets/badge_card.dart';

class ManHinhHoSoNguoiDung extends ConsumerStatefulWidget {
  const ManHinhHoSoNguoiDung({super.key});

  @override
  ConsumerState<ManHinhHoSoNguoiDung> createState() =>
      _ManHinhHoSoNguoiDungState();
}

class _ManHinhHoSoNguoiDungState extends ConsumerState<ManHinhHoSoNguoiDung> {
  final ProfileService _profileService = ProfileService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _stats;
  Map<String, dynamic>? _vocabStats;
  List<BadgeModel> _badges = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _taiDuLieu();
    });
  }

  Future<void> _taiDuLieu() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await Future.wait([
        _profileService.fetchUserStats(),
        _profileService.fetchBadges(),
        _profileService.fetchVocabularyStats(),
      ]);

      if (!mounted) return;
      setState(() {
        _stats = results[0] as Map<String, dynamic>;
        _badges = results[1] as List<BadgeModel>;
        _vocabStats = results[2] as Map<String, dynamic>;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Không thể tải dữ liệu hồ sơ: $e';
        _badges = BadgeModel.sampleBadges();
        _vocabStats = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningProvider);
    final authProvider = provider.Provider.of<AuthProvider>(context);
    final User? user = authProvider.user;

    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Hồ sơ cá nhân'),
        backgroundColor: const Color(0xFF1F1147),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : RefreshIndicator(
              onRefresh: _taiDuLieu,
              color: const Color(0xFF6C63FF),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _xayDungHeader(user, learningState, _stats),
                    const SizedBox(height: 20),
                    _buildStatsGrid(learningState, _stats, _vocabStats, user),
                    const SizedBox(height: 28),
                    _buildBadgesSection(),
                    if (_error != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  ],
                ),
              ),
            ),
    );
  }

  Widget _xayDungHeader(
    User? user,
    LearningState learningState,
    Map<String, dynamic>? stats,
  ) {
    int? _asInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    final xpTotal = _asInt(stats?['xp']) ?? user?.xp ?? learningState.xp;
    final xpNeededFromStats =
        _asInt(stats?['xpNeeded']) ?? _asInt(stats?['nextLevelXp']);
    final fallbackNeeded = _xpNeededForLevel(learningState.level);
    final xpNeeded = (xpNeededFromStats != null && xpNeededFromStats > 0)
        ? xpNeededFromStats
        : fallbackNeeded;

    final xpProgressFromStats = _asInt(stats?['xpProgress']);
    int xpProgress;
    if (xpProgressFromStats != null) {
      xpProgress = xpProgressFromStats;
      if (xpProgress < 0) xpProgress = 0;
      if (xpNeeded > 0 && xpProgress > xpNeeded) {
        xpProgress = xpNeeded;
      }
    } else {
      xpProgress = _fallbackXpProgress(learningState, xpNeeded);
    }

    final progress = xpNeeded == 0
        ? 0.0
        : (xpProgress / xpNeeded).clamp(0.0, 1.0);
    final xpLabel = xpNeeded > 0
        ? '$xpProgress/$xpNeeded XP'
        : '${xpTotal ?? 0} XP';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF423074)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CachedAvatar(
                imageUrl: user?.avatar,
                radius: 36,
                fallbackText: user?.firstName ?? 'U',
                backgroundColor: Colors.white,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.fullName ?? 'Học viên',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '@${user?.username ?? 'learner'}',
                      style: TextStyle(color: Colors.white.withOpacity(0.8)),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Level ${learningState.level}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Chức năng chỉnh sửa đang phát triển.'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit, color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            'Tiến độ level',
            style: TextStyle(color: Colors.white.withOpacity(0.8)),
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 14,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Colors.cyanAccent,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'XP hiện tại: $xpLabel',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
              Text(
                'Lv.${learningState.level + 1}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'XP tích lũy: ${_formatPlainNumber(xpTotal)}',
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  int _fallbackXpProgress(LearningState learningState, int xpNeeded) {
    if (xpNeeded <= 0) {
      return learningState.xp;
    }
    final remainder = learningState.xp % xpNeeded;
    return remainder;
  }

  int _xpNeededForLevel(int level) {
    const base = 150;
    const step = 50;
    if (level <= 1) return base;
    return base + (level - 1) * step;
  }

  String _formatPlainNumber(int? value) {
    if (value == null) return '--';
    return value.toString();
  }

  String _valueWithUnit(int? value, {String suffix = ''}) {
    if (value == null) return '--';
    return suffix.isEmpty ? value.toString() : '$value$suffix';
  }

  Widget _buildStatsGrid(
    LearningState learningState,
    Map<String, dynamic>? stats,
    Map<String, dynamic>? vocabStats,
    User? user,
  ) {
    int? _asInt(dynamic value) {
      if (value is int) return value;
      if (value is double) return value.round();
      if (value is num) return value.toInt();
      if (value is String) return int.tryParse(value);
      return null;
    }

    final streakValue =
        _asInt(stats?['streak']) ?? user?.streak ?? learningState.streak;
    final xpValue = _asInt(stats?['xp']) ?? user?.xp ?? learningState.xp;
    final vocabValue =
        _asInt(vocabStats?['total']) ??
        _asInt(stats?['totalWords']) ??
        _asInt(stats?['totalWordsLearned']) ??
        learningState.totalWordsLearned;
    final minutesValue =
        _asInt(stats?['minutes']) ??
        _asInt(stats?['minutesStudied']) ??
        _asInt(stats?['studyMinutes']);

    final data = [
      _StatItem(
        icon: Icons.local_fire_department,
        label: 'Chuỗi ngày',
        value: _valueWithUnit(streakValue, suffix: ' ngày'),
        color: Colors.orangeAccent,
      ),
      _StatItem(
        icon: Icons.workspace_premium,
        label: 'XP',
        value: _valueWithUnit(xpValue, suffix: ' XP'),
        color: Colors.amber,
      ),
      _StatItem(
        icon: Icons.menu_book,
        label: 'Từ vựng',
        value: _valueWithUnit(vocabValue, suffix: ' từ'),
        color: Colors.lightBlueAccent,
      ),
      _StatItem(
        icon: Icons.access_time,
        label: 'Thời gian',
        value: _valueWithUnit(minutesValue, suffix: ' phút'),
        color: Colors.purpleAccent,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: data.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (context, index) {
        final item = data[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.06),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: item.color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(item.icon, color: item.color),
              ),
              Text(
                item.value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                item.label,
                style: TextStyle(color: Colors.white.withOpacity(0.7)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBadgesSection() {
    if (_badges.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white10),
        ),
        child: const Center(
          child: Text(
            'Chưa có huy hiệu nào. Hãy tiếp tục luyện tập để mở khóa!',
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Huy hiệu của bạn',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${_badges.where((b) => b.isUnlocked).length}/${_badges.length} đã mở khóa',
              style: const TextStyle(color: Colors.white70),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _badges.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, index) {
            return BadgeCard(badge: _badges[index]);
          },
        ),
      ],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}
