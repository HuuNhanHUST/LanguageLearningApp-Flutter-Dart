class BadgeModel {
  final String id;
  final String title;
  final String description;
  final String icon;
  final bool isUnlocked;
  final String condition;
  final DateTime? unlockedAt;

  const BadgeModel({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isUnlocked,
    required this.condition,
    this.unlockedAt,
  });

  factory BadgeModel.fromJson(Map<String, dynamic> json) {
    return BadgeModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Badge',
      description: json['description']?.toString() ?? '',
      icon: json['icon']?.toString() ?? '🏅',
      isUnlocked: json['isUnlocked'] == true || json['earned'] == true,
      condition: json['condition']?.toString() ?? 'Hoàn thành mục tiêu để mở khóa',
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.tryParse(json['unlockedAt'].toString())
          : null,
    );
  }

  static List<BadgeModel> sampleBadges() {
    return const [
      BadgeModel(
        id: 'streak-7',
        title: 'Chuỗi 7 ngày',
        description: 'Duy trì chuỗi học 7 ngày liên tiếp',
        icon: '🔥',
        isUnlocked: true,
        condition: 'Học liên tục 7 ngày',
      ),
      BadgeModel(
        id: 'words-100',
        title: 'Từ vựng 100',
        description: 'Học 100 từ vựng mới',
        icon: '📚',
        isUnlocked: false,
        condition: 'Học đủ 100 từ vựng',
      ),
      BadgeModel(
        id: 'pronunciation-master',
        title: 'Pronunciation Master',
        description: 'Hoàn thành 10 bài phát âm',
        icon: '🎤',
        isUnlocked: true,
        condition: 'Hoàn thành 10 bài phát âm',
      ),
      BadgeModel(
        id: 'grammar-genius',
        title: 'Grammar Genius',
        description: 'Trả lời đúng 20 câu hỏi ngữ pháp',
        icon: '🧠',
        isUnlocked: false,
        condition: 'Đạt 20 câu đúng trong bài ngữ pháp',
      ),
    ];
  }
}
