import 'package:json_annotation/json_annotation.dart';

part 'grammar_question_model.g.dart';

@JsonSerializable()
class GrammarQuestion {
  @JsonKey(defaultValue: '')
  final String id;
  
  @JsonKey(defaultValue: '')
  final String question;
  
  @JsonKey(defaultValue: [])
  final List<String> options;
  
  @JsonKey(defaultValue: 0)
  final int correctAnswer;
  
  final String? explanation;
  
  @JsonKey(defaultValue: '')
  final String difficulty;
  
  @JsonKey(defaultValue: [])
  final List<String> tags;
  
  // createdBy can be either String (ObjectId) or Object
  @JsonKey(fromJson: _createdByFromJson)
  final CreatorInfo? createdBy;
  
  final String? classId;
  
  @JsonKey(defaultValue: false)
  final bool isPublic;
  
  final DateTime? createdAt;
  
  final DateTime? updatedAt;

  GrammarQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.difficulty,
    required this.tags,
    this.createdBy,
    this.classId,
    required this.isPublic,
    this.createdAt,
    this.updatedAt,
  });

  factory GrammarQuestion.fromJson(Map<String, dynamic> json) =>
      _$GrammarQuestionFromJson(json);

  Map<String, dynamic> toJson() => _$GrammarQuestionToJson(this);
  
  // Helper to handle createdBy as String or Object
  static CreatorInfo? _createdByFromJson(dynamic value) {
    if (value == null) return null;
    if (value is String) return null; // If it's just an ID string, return null
    if (value is Map<String, dynamic>) return CreatorInfo.fromJson(value);
    return null;
  }
}

@JsonSerializable()
class CreatorInfo {
  @JsonKey(defaultValue: '')
  final String id;
  
  @JsonKey(defaultValue: '')
  final String username;

  CreatorInfo({
    required this.id,
    required this.username,
  });

  factory CreatorInfo.fromJson(Map<String, dynamic> json) =>
      _$CreatorInfoFromJson(json);

  Map<String, dynamic> toJson() => _$CreatorInfoToJson(this);
}

@JsonSerializable()
class CreateGrammarQuestionRequest {
  final String question;
  final List<String> options;
  final int correctAnswer;
  final String? explanation;
  final String difficulty;
  final List<String> tags;
  final String? classId;
  final bool isPublic;

  CreateGrammarQuestionRequest({
    required this.question,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    required this.difficulty,
    required this.tags,
    this.classId,
    this.isPublic = false,
  });

  Map<String, dynamic> toJson() => _$CreateGrammarQuestionRequestToJson(this);
}
