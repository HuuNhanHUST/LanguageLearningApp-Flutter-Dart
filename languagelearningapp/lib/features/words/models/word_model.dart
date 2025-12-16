class WordModel {
  final String id;
  final String word;
  final String meaning;
  final String type;
  final String? example;
  final String? topic;
  final String? difficulty; // beginner, intermediate, advanced
  final bool isMemorized;

  const WordModel({
    required this.id,
    required this.word,
    required this.meaning,
    required this.type,
    this.example,
    this.topic,
    this.difficulty,
    this.isMemorized = false,
  });

  factory WordModel.fromJson(Map<String, dynamic> json) {
    return WordModel(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      word: json['word']?.toString() ?? '',
      meaning: json['meaning']?.toString() ?? '',
      type: json['type']?.toString() ?? 'other',
      example: json['example']?.toString(),
      topic: json['topic']?.toString(),
      difficulty: json['difficulty']?.toString(),
      isMemorized: json['isMemorized'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'type': type,
      'example': example,
      'topic': topic,
      'difficulty': difficulty,
      'isMemorized': isMemorized,
    };
  }
}
