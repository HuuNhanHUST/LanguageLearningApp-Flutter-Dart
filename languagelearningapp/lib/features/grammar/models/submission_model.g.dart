// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmissionModel _$SubmissionModelFromJson(Map<String, dynamic> json) =>
    SubmissionModel(
      id: json['id'] as String? ?? '',
      student: json['student'] as String? ?? '',
      classId: json['classId'] as String? ?? '',
      assignmentId: json['assignmentId'] as String? ?? '',
      answers:
          (json['answers'] as List<dynamic>?)
              ?.map((e) => AnswerModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      totalQuestions: (json['totalQuestions'] as num?)?.toInt() ?? 0,
      correctAnswers: (json['correctAnswers'] as num?)?.toInt() ?? 0,
      percentage: (json['percentage'] as num?)?.toDouble() ?? 0.0,
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
    );

Map<String, dynamic> _$SubmissionModelToJson(SubmissionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student': instance.student,
      'classId': instance.classId,
      'assignmentId': instance.assignmentId,
      'answers': instance.answers,
      'score': instance.score,
      'totalQuestions': instance.totalQuestions,
      'correctAnswers': instance.correctAnswers,
      'percentage': instance.percentage,
      'submittedAt': instance.submittedAt?.toIso8601String(),
    };

AnswerModel _$AnswerModelFromJson(Map<String, dynamic> json) => AnswerModel(
  questionId: json['questionId'] as String? ?? '',
  selectedIndex: (json['selectedIndex'] as num?)?.toInt() ?? 0,
  isCorrect: json['isCorrect'] as bool? ?? false,
);

Map<String, dynamic> _$AnswerModelToJson(AnswerModel instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'selectedIndex': instance.selectedIndex,
      'isCorrect': instance.isCorrect,
    };
