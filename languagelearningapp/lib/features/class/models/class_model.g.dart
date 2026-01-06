// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ClassModel _$ClassModelFromJson(Map<String, dynamic> json) => ClassModel(
  id: json['id'] as String? ?? '',
  name: json['name'] as String? ?? '',
  description: json['description'] as String? ?? '',
  code: json['classCode'] as String? ?? '',
  teacher: TeacherInfo.fromJson(json['teacher'] as Map<String, dynamic>),
  students:
      (json['students'] as List<dynamic>?)
          ?.map((e) => StudentInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  assignments: json['assignments'] == null
      ? []
      : ClassModel._assignmentsFromJson(json['assignments']),
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ClassModelToJson(ClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'classCode': instance.code,
      'teacher': instance.teacher,
      'students': instance.students,
      'assignments': instance.assignments,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

TeacherInfo _$TeacherInfoFromJson(Map<String, dynamic> json) => TeacherInfo(
  id: json['id'] as String? ?? '',
  username: json['username'] as String? ?? '',
  email: json['email'] as String? ?? '',
);

Map<String, dynamic> _$TeacherInfoToJson(TeacherInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
    };

StudentInfo _$StudentInfoFromJson(Map<String, dynamic> json) => StudentInfo(
  id: json['id'] as String? ?? '',
  username: json['username'] as String? ?? '',
  email: json['email'] as String? ?? '',
  joinedAt: json['joinedAt'] == null
      ? null
      : DateTime.parse(json['joinedAt'] as String),
);

Map<String, dynamic> _$StudentInfoToJson(StudentInfo instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'email': instance.email,
      'joinedAt': instance.joinedAt?.toIso8601String(),
    };

CreateClassRequest _$CreateClassRequestFromJson(Map<String, dynamic> json) =>
    CreateClassRequest(
      name: json['name'] as String,
      description: json['description'] as String,
    );

Map<String, dynamic> _$CreateClassRequestToJson(CreateClassRequest instance) =>
    <String, dynamic>{
      'name': instance.name,
      'description': instance.description,
    };

JoinClassRequest _$JoinClassRequestFromJson(Map<String, dynamic> json) =>
    JoinClassRequest(code: json['code'] as String);

Map<String, dynamic> _$JoinClassRequestToJson(JoinClassRequest instance) =>
    <String, dynamic>{'code': instance.code};
