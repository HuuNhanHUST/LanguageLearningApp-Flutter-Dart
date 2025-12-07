import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String nativeLanguage;
  final List<LearningLanguage> learningLanguages;
  final int xp;
  final int level;
  final int streak;
  final UserPreferences preferences;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.avatar,
    required this.nativeLanguage,
    required this.learningLanguages,
    required this.xp,
    required this.level,
    required this.streak,
    required this.preferences,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class LearningLanguage {
  final String language;
  final String level;
  final DateTime startedAt;

  LearningLanguage({
    required this.language,
    required this.level,
    required this.startedAt,
  });

  factory LearningLanguage.fromJson(Map<String, dynamic> json) =>
      _$LearningLanguageFromJson(json);
  Map<String, dynamic> toJson() => _$LearningLanguageToJson(this);
}

@JsonSerializable()
class UserPreferences {
  final int dailyGoal;
  final bool notifications;
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
