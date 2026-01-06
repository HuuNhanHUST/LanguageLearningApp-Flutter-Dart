import 'package:json_annotation/json_annotation.dart';

part 'class_model.g.dart';

@JsonSerializable()
class ClassModel {
  @JsonKey(defaultValue: '')
  final String id;
  
  @JsonKey(defaultValue: '')
  final String name;
  
  @JsonKey(defaultValue: '')
  final String description;
  
  @JsonKey(name: 'classCode', defaultValue: '')
  final String code;
  
  final TeacherInfo teacher;
  @JsonKey(defaultValue: [])
  final List<StudentInfo> students;
  @JsonKey(defaultValue: [], fromJson: _assignmentsFromJson)
  final List<String> assignments;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassModel({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.teacher,
    required this.students,
    required this.assignments,
    required this.createdAt,
    required this.updatedAt,
  });

  // Custom converter for assignments that can be either array of strings or array of objects
  static List<String> _assignmentsFromJson(dynamic json) {
    if (json == null) return [];
    if (json is! List) return [];
    
    return json.map((item) {
      if (item is String) {
        return item;
      } else if (item is Map) {
        // If it's an object with grammarQuestionSetId, extract that
        if (item['grammarQuestionSetId'] != null) {
          return item['grammarQuestionSetId'].toString();
        }
        // Otherwise try to get an id field
        return item['id']?.toString() ?? item['_id']?.toString() ?? '';
      }
      return item.toString();
    }).where((id) => id.isNotEmpty).toList();
  }

  factory ClassModel.fromJson(Map<String, dynamic> json) =>
      _$ClassModelFromJson(json);

  Map<String, dynamic> toJson() => _$ClassModelToJson(this);
}

@JsonSerializable()
class TeacherInfo {
  @JsonKey(defaultValue: '')
  final String id;
  
  @JsonKey(defaultValue: '')
  final String username;
  
  @JsonKey(defaultValue: '')
  final String email;

  TeacherInfo({
    required this.id,
    required this.username,
    required this.email,
  });

  factory TeacherInfo.fromJson(Map<String, dynamic> json) =>
      _$TeacherInfoFromJson(json);

  Map<String, dynamic> toJson() => _$TeacherInfoToJson(this);
}

@JsonSerializable()
class StudentInfo {
  @JsonKey(defaultValue: '')
  final String id;
  
  @JsonKey(defaultValue: '')
  final String username;
  
  @JsonKey(defaultValue: '')
  final String email;
  
  final DateTime? joinedAt;

  StudentInfo({
    required this.id,
    required this.username,
    required this.email,
    this.joinedAt,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) =>
      _$StudentInfoFromJson(json);

  Map<String, dynamic> toJson() => _$StudentInfoToJson(this);
}

@JsonSerializable()
class CreateClassRequest {
  final String name;
  final String description;

  CreateClassRequest({
    required this.name,
    required this.description,
  });

  Map<String, dynamic> toJson() => _$CreateClassRequestToJson(this);
}

@JsonSerializable()
class JoinClassRequest {
  final String code;

  JoinClassRequest({
    required this.code,
  });

  Map<String, dynamic> toJson() => _$JoinClassRequestToJson(this);
}
