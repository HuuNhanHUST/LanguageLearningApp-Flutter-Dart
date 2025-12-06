/// Model cho kết quả chấm điểm phát âm từ Backend
class PronunciationResultModel {
  final double score;
  final int accuracy;
  final String target;
  final String transcript;
  final List<WordDetail> wordDetails;
  final PronunciationStats stats;

  const PronunciationResultModel({
    required this.score,
    required this.accuracy,
    required this.target,
    required this.transcript,
    required this.wordDetails,
    required this.stats,
  });

  factory PronunciationResultModel.fromJson(Map<String, dynamic> json) {
    return PronunciationResultModel(
      score: (json['score'] as num).toDouble(),
      accuracy: json['accuracy'] as int,
      target: json['target'] as String,
      transcript: json['transcript'] as String,
      wordDetails: (json['wordDetails'] as List<dynamic>)
          .map((item) => WordDetail.fromJson(item as Map<String, dynamic>))
          .toList(),
      stats: PronunciationStats.fromJson(json['stats'] as Map<String, dynamic>),
    );
  }
}

/// Chi tiết từng từ
class WordDetail {
  final String word;
  final String? expected; // Từ đúng (nếu status là wrong/close)
  final String status; // correct, wrong, close, missing, extra
  final double? similarity; // % tương đồng (nếu status là close/wrong)
  final int position;

  const WordDetail({
    required this.word,
    this.expected,
    required this.status,
    this.similarity,
    required this.position,
  });

  factory WordDetail.fromJson(Map<String, dynamic> json) {
    return WordDetail(
      word: json['word'] as String,
      expected: json['expected'] as String?,
      status: json['status'] as String,
      similarity: json['similarity'] != null
          ? (json['similarity'] as num).toDouble()
          : null,
      position: json['position'] as int,
    );
  }

  /// Kiểm tra từ có đúng không
  bool get isCorrect => status == 'correct';

  /// Kiểm tra từ có sai không
  bool get isWrong => status == 'wrong';

  /// Kiểm tra từ có gần đúng không
  bool get isClose => status == 'close';

  /// Kiểm tra từ bị thiếu không
  bool get isMissing => status == 'missing';

  /// Kiểm tra từ dư thừa không
  bool get isExtra => status == 'extra';
}

/// Thống kê kết quả
class PronunciationStats {
  final int totalWords;
  final int correctWords;
  final int wrongWords;
  final int closeWords;
  final int missingWords;
  final int extraWords;

  const PronunciationStats({
    required this.totalWords,
    required this.correctWords,
    required this.wrongWords,
    required this.closeWords,
    required this.missingWords,
    required this.extraWords,
  });

  factory PronunciationStats.fromJson(Map<String, dynamic> json) {
    return PronunciationStats(
      totalWords: json['totalWords'] as int,
      correctWords: json['correctWords'] as int,
      wrongWords: json['wrongWords'] as int,
      closeWords: json['closeWords'] as int,
      missingWords: json['missingWords'] as int,
      extraWords: json['extraWords'] as int,
    );
  }

  /// Tính tỷ lệ chính xác (%)
  double get accuracyRate {
    if (totalWords == 0) return 0;
    return (correctWords / totalWords) * 100;
  }
}
