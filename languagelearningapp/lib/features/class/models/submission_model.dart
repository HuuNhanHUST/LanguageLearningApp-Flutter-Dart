import 'package:json_annotation/json_annotation.dart';

part 'submission_model.g.dart';

@JsonSerializable()
class SubmissionModel {
  @JsonKey(name: '_id')
  final String? id;
  
  @JsonKey(fromJson: _idFromJson)
  final String? student;
  
  @JsonKey(fromJson: _idFromJson)
  final String? assignmentId;
  
  @JsonKey(fromJson: _idFromJson)
  final String? classId;
  
  final List<SubmissionAnswer> answers;
  final double score;
  final int correctAnswers;
  final int totalQuestions;
  final DateTime? submittedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  SubmissionModel({
    this.id,
    this.student,
    this.assignmentId,
    this.classId,
    required this.answers,
    required this.score,
    required this.correctAnswers,
    required this.totalQuestions,
    this.submittedAt,
    this.createdAt,
    this.updatedAt,
  });

  static String? _idFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    return value.toString();
  }

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionModelToJson(this);

  double get percentage => (correctAnswers / totalQuestions) * 100;
}

@JsonSerializable()
class SubmissionAnswer {
  @JsonKey(fromJson: _questionIdFromJson)
  final String? questionId;
  final int selectedIndex;
  final bool isCorrect;

  SubmissionAnswer({
    this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  static String? _questionIdFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is Map<String, dynamic>) {
      return value['_id']?.toString() ?? value['id']?.toString();
    }
    return value.toString();
  }

  factory SubmissionAnswer.fromJson(Map<String, dynamic> json) =>
      _$SubmissionAnswerFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionAnswerToJson(this);
}
