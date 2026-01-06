// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'submission_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SubmissionModel _$SubmissionModelFromJson(Map<String, dynamic> json) =>
    SubmissionModel(
      id: json['_id'] as String?,
      student: SubmissionModel._idFromJson(json['student']),
      assignmentId: SubmissionModel._idFromJson(json['assignmentId']),
      classId: SubmissionModel._idFromJson(json['classId']),
      answers: (json['answers'] as List<dynamic>)
          .map((e) => SubmissionAnswer.fromJson(e as Map<String, dynamic>))
          .toList(),
      score: (json['score'] as num).toDouble(),
      correctAnswers: (json['correctAnswers'] as num).toInt(),
      totalQuestions: (json['totalQuestions'] as num).toInt(),
      submittedAt: json['submittedAt'] == null
          ? null
          : DateTime.parse(json['submittedAt'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SubmissionModelToJson(SubmissionModel instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'student': instance.student,
      'assignmentId': instance.assignmentId,
      'classId': instance.classId,
      'answers': instance.answers,
      'score': instance.score,
      'correctAnswers': instance.correctAnswers,
      'totalQuestions': instance.totalQuestions,
      'submittedAt': instance.submittedAt?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

SubmissionAnswer _$SubmissionAnswerFromJson(Map<String, dynamic> json) =>
    SubmissionAnswer(
      questionId: SubmissionAnswer._questionIdFromJson(json['questionId']),
      selectedIndex: (json['selectedIndex'] as num).toInt(),
      isCorrect: json['isCorrect'] as bool,
    );

Map<String, dynamic> _$SubmissionAnswerToJson(SubmissionAnswer instance) =>
    <String, dynamic>{
      'questionId': instance.questionId,
      'selectedIndex': instance.selectedIndex,
      'isCorrect': instance.isCorrect,
    };
