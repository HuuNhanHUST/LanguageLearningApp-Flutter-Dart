// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_stats_response.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserStatsResponse _$UserStatsResponseFromJson(Map<String, dynamic> json) =>
    UserStatsResponse(
      success: json['success'] as bool,
      data: UserStatsData.fromJson(json['data'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$UserStatsResponseToJson(UserStatsResponse instance) =>
    <String, dynamic>{'success': instance.success, 'data': instance.data};

UserStatsData _$UserStatsDataFromJson(Map<String, dynamic> json) =>
    UserStatsData(
      total: (json['total'] as num).toInt(),
      byRole: RoleStats.fromJson(json['byRole'] as Map<String, dynamic>),
      byStatus: StatusStats.fromJson(json['byStatus'] as Map<String, dynamic>),
      recentRegistrations: (json['recentRegistrations'] as num).toInt(),
    );

Map<String, dynamic> _$UserStatsDataToJson(UserStatsData instance) =>
    <String, dynamic>{
      'total': instance.total,
      'byRole': instance.byRole,
      'byStatus': instance.byStatus,
      'recentRegistrations': instance.recentRegistrations,
    };

RoleStats _$RoleStatsFromJson(Map<String, dynamic> json) => RoleStats(
  users: (json['users'] as num).toInt(),
  teachers: (json['teachers'] as num).toInt(),
  admins: (json['admins'] as num).toInt(),
);

Map<String, dynamic> _$RoleStatsToJson(RoleStats instance) => <String, dynamic>{
  'users': instance.users,
  'teachers': instance.teachers,
  'admins': instance.admins,
};

StatusStats _$StatusStatsFromJson(Map<String, dynamic> json) => StatusStats(
  active: (json['active'] as num).toInt(),
  inactive: (json['inactive'] as num).toInt(),
);

Map<String, dynamic> _$StatusStatsToJson(StatusStats instance) =>
    <String, dynamic>{'active': instance.active, 'inactive': instance.inactive};
