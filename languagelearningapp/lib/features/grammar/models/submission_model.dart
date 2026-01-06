import 'package:json_annotation/json_annotation.dart';

part 'submission_model.g.dart';

@JsonSerializable()
class SubmissionModel {
  @JsonKey(defaultValue: '')
  final String id;

  @JsonKey(defaultValue: '')
  final String student;

  @JsonKey(defaultValue: '')
  final String classId;

  @JsonKey(defaultValue: '')
  final String assignmentId;

  @JsonKey(defaultValue: [])
  final List<AnswerModel> answers;

  @JsonKey(defaultValue: 0.0)
  final double score;

  @JsonKey(defaultValue: 0)
  final int totalQuestions;

  @JsonKey(defaultValue: 0)
  final int correctAnswers;

  @JsonKey(defaultValue: 0.0)
  final double percentage;

  final DateTime? submittedAt;

  const SubmissionModel({
    required this.id,
    required this.student,
    required this.classId,
    required this.assignmentId,
    required this.answers,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
    required this.percentage,
    this.submittedAt,
  });

  factory SubmissionModel.fromJson(Map<String, dynamic> json) =>
      _$SubmissionModelFromJson(json);

  Map<String, dynamic> toJson() => _$SubmissionModelToJson(this);
}

@JsonSerializable()
class AnswerModel {
  @JsonKey(defaultValue: '')
  final String questionId;

  @JsonKey(defaultValue: 0)
  final int selectedIndex;

  @JsonKey(defaultValue: false)
  final bool isCorrect;

  const AnswerModel({
    required this.questionId,
    required this.selectedIndex,
    required this.isCorrect,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) =>
      _$AnswerModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnswerModelToJson(this);
}
