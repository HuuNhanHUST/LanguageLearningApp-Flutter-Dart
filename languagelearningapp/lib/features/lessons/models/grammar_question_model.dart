class GrammarQuestionModel {
  final String id;
  final String wordId;
  final String word;
  final String question;
  final List<String> options;
  final int correctIndex;
  final String explanation;
  final String targetSkill;
  final String difficulty;

  const GrammarQuestionModel({
    required this.id,
    required this.wordId,
    required this.word,
    required this.question,
    required this.options,
    required this.correctIndex,
    required this.explanation,
    required this.targetSkill,
    required this.difficulty,
  });

  factory GrammarQuestionModel.fromJson(Map<String, dynamic> json) {
    final rawOptions = (json['options'] as List?) ?? const [];
    final normalizedOptions = rawOptions
        .map((option) => option?.toString() ?? '')
        .where((option) => option.isNotEmpty)
        .toList(growable: false);

    return GrammarQuestionModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      wordId: json['wordId']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      question: json['question']?.toString() ?? '',
      options: normalizedOptions,
      correctIndex: (json['correctIndex'] as num?)?.toInt() ?? 0,
      explanation: json['explanation']?.toString() ?? '',
      targetSkill: json['targetSkill']?.toString() ?? 'grammar',
      difficulty: json['difficulty']?.toString() ?? 'beginner',
    );
  }
}
