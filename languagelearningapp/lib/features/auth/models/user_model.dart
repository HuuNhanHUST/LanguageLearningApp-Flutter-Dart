import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  @JsonKey(defaultValue: '')
  final String id;  // Backend already converts _id to id in getPublicProfile()
  
  @JsonKey(defaultValue: '')
  final String username;
  
  @JsonKey(defaultValue: '')
  final String email;
  
  @JsonKey(defaultValue: '')
  final String firstName;
  
  @JsonKey(defaultValue: '')
  final String lastName;
  
  final String? avatar;
  final String? role; // NEW: user, teacher, admin
  
  @JsonKey(defaultValue: 'en')
  final String nativeLanguage;
  
  @JsonKey(defaultValue: [])
  final List<LearningLanguage> learningLanguages;
  
  @JsonKey(defaultValue: 0)
  final int xp;
  
  @JsonKey(defaultValue: 1)
  final int level;
  
  @JsonKey(defaultValue: 0)
  final int streak;
  
  final UserPreferences? preferences;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    this.role,
    required this.nativeLanguage,
    required this.learningLanguages,
    required this.xp,
    required this.level,
    required this.streak,
    this.preferences,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';
  
  bool get isTeacher => role == 'teacher' || role == 'admin';
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user' || role == null;

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LearningLanguage {
  @JsonKey(defaultValue: '')
  final String language;
  
  @JsonKey(defaultValue: 'beginner')
  final String level;
  
  final DateTime? startedAt;

  LearningLanguage({
    required this.language,
    required this.level,
    this.startedAt,
  });

  factory LearningLanguage.fromJson(Map<String, dynamic> json) =>
      _$LearningLanguageFromJson(json);
  Map<String, dynamic> toJson() => _$LearningLanguageToJson(this);
}

@JsonSerializable()
class UserPreferences {
  @JsonKey(defaultValue: 10)
  final int dailyGoal;
  
  @JsonKey(defaultValue: true)
  final bool notifications;
  
  @JsonKey(defaultValue: true)
  final bool soundEffects;

  UserPreferences({
    required this.dailyGoal,
    required this.notifications,
    required this.soundEffects,
  });

  factory UserPreferences.fromJson(Map<String, dynamic> json) =>
      _$UserPreferencesFromJson(json);
  Map<String, dynamic> toJson() => _$UserPreferencesToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final User user;
  final String accessToken;
  final String refreshToken;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
}
