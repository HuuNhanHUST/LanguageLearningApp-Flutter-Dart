import 'package:json_annotation/json_annotation.dart';

part 'user_stats_response.g.dart';

@JsonSerializable()
class UserStatsResponse {
  final bool success;
  final UserStatsData data;

  UserStatsResponse({
    required this.success,
    required this.data,
  });

  factory UserStatsResponse.fromJson(Map<String, dynamic> json) =>
      _$UserStatsResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsResponseToJson(this);
}

@JsonSerializable()
class UserStatsData {
  final int total;
  final RoleStats byRole;
  final StatusStats byStatus;
  final int recentRegistrations;

  UserStatsData({
    required this.total,
    required this.byRole,
    required this.byStatus,
    required this.recentRegistrations,
  });

  factory UserStatsData.fromJson(Map<String, dynamic> json) =>
      _$UserStatsDataFromJson(json);
  Map<String, dynamic> toJson() => _$UserStatsDataToJson(this);
}

@JsonSerializable()
class RoleStats {
  final int users;
  final int teachers;
  final int admins;

  RoleStats({
    required this.users,
    required this.teachers,
    required this.admins,
  });

  factory RoleStats.fromJson(Map<String, dynamic> json) =>
      _$RoleStatsFromJson(json);
  Map<String, dynamic> toJson() => _$RoleStatsToJson(this);
}

@JsonSerializable()
class StatusStats {
  final int active;
  final int inactive;

  StatusStats({
    required this.active,
    required this.inactive,
  });

  factory StatusStats.fromJson(Map<String, dynamic> json) =>
      _$StatusStatsFromJson(json);
  Map<String, dynamic> toJson() => _$StatusStatsToJson(this);
}
