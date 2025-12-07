// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: json['id'] as String,
  username: json['username'] as String,
  email: json['email'] as String,
  firstName: json['firstName'] as String,
  lastName: json['lastName'] as String,
  avatar: json['avatar'] as String?,
  nativeLanguage: json['nativeLanguage'] as String,
  learningLanguages: (json['learningLanguages'] as List<dynamic>)
      .map((e) => LearningLanguage.fromJson(e as Map<String, dynamic>))
      .toList(),
  xp: (json['xp'] as num).toInt(),
  level: (json['level'] as num).toInt(),
  streak: (json['streak'] as num).toInt(),
  preferences: UserPreferences.fromJson(
    json['preferences'] as Map<String, dynamic>,
  ),
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'email': instance.email,
  'firstName': instance.firstName,
  'lastName': instance.lastName,
  'avatar': instance.avatar,
  'nativeLanguage': instance.nativeLanguage,
  'learningLanguages': instance.learningLanguages,
  'xp': instance.xp,
  'level': instance.level,
  'streak': instance.streak,
  'preferences': instance.preferences,
  'createdAt': instance.createdAt.toIso8601String(),
};

LearningLanguage _$LearningLanguageFromJson(Map<String, dynamic> json) =>
    LearningLanguage(
      language: json['language'] as String,
      level: json['level'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
    );

Map<String, dynamic> _$LearningLanguageToJson(LearningLanguage instance) =>
    <String, dynamic>{
      'language': instance.language,
      'level': instance.level,
      'startedAt': instance.startedAt.toIso8601String(),
    };

UserPreferences _$UserPreferencesFromJson(Map<String, dynamic> json) =>
    UserPreferences(
      dailyGoal: (json['dailyGoal'] as num).toInt(),
      notifications: json['notifications'] as bool,
      soundEffects: json['soundEffects'] as bool,
    );

Map<String, dynamic> _$UserPreferencesToJson(UserPreferences instance) =>
    <String, dynamic>{
      'dailyGoal': instance.dailyGoal,
      'notifications': instance.notifications,
      'soundEffects': instance.soundEffects,
    };

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  accessToken: json['accessToken'] as String,
  refreshToken: json['refreshToken'] as String,
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'user': instance.user,
      'accessToken': instance.accessToken,
      'refreshToken': instance.refreshToken,
    };
