// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'grammar_question_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GrammarQuestion _$GrammarQuestionFromJson(
  Map<String, dynamic> json,
) => GrammarQuestion(
  id: json['id'] as String? ?? '',
  question: json['question'] as String? ?? '',
  options:
      (json['options'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      [],
  correctAnswer: (json['correctAnswer'] as num?)?.toInt() ?? 0,
  explanation: json['explanation'] as String?,
  difficulty: json['difficulty'] as String? ?? '',
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
  createdBy: GrammarQuestion._createdByFromJson(json['createdBy']),
  classId: json['classId'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$GrammarQuestionToJson(GrammarQuestion instance) =>
    <String, dynamic>{
      'id': instance.id,
      'question': instance.question,
      'options': instance.options,
      'correctAnswer': instance.correctAnswer,
      'explanation': instance.explanation,
      'difficulty': instance.difficulty,
      'tags': instance.tags,
      'createdBy': instance.createdBy,
      'classId': instance.classId,
      'isPublic': instance.isPublic,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

CreatorInfo _$CreatorInfoFromJson(Map<String, dynamic> json) => CreatorInfo(
  id: json['id'] as String? ?? '',
  username: json['username'] as String? ?? '',
);

Map<String, dynamic> _$CreatorInfoToJson(CreatorInfo instance) =>
    <String, dynamic>{'id': instance.id, 'username': instance.username};

CreateGrammarQuestionRequest _$CreateGrammarQuestionRequestFromJson(
  Map<String, dynamic> json,
) => CreateGrammarQuestionRequest(
  question: json['question'] as String,
  options: (json['options'] as List<dynamic>).map((e) => e as String).toList(),
  correctAnswer: (json['correctAnswer'] as num).toInt(),
  explanation: json['explanation'] as String?,
  difficulty: json['difficulty'] as String,
  tags: (json['tags'] as List<dynamic>).map((e) => e as String).toList(),
  classId: json['classId'] as String?,
  isPublic: json['isPublic'] as bool? ?? false,
);

Map<String, dynamic> _$CreateGrammarQuestionRequestToJson(
  CreateGrammarQuestionRequest instance,
) => <String, dynamic>{
  'question': instance.question,
  'options': instance.options,
  'correctAnswer': instance.correctAnswer,
  'explanation': instance.explanation,
  'difficulty': instance.difficulty,
  'tags': instance.tags,
  'classId': instance.classId,
  'isPublic': instance.isPublic,
};
