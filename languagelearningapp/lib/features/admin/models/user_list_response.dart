import 'package:json_annotation/json_annotation.dart';
import '../../auth/models/user_model.dart';

part 'user_list_response.g.dart';

@JsonSerializable()
class UserListResponse {
  final bool success;
  final List<User> data;
  final PaginationInfo pagination;

  UserListResponse({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory UserListResponse.fromJson(Map<String, dynamic> json) =>
      _$UserListResponseFromJson(json);
  Map<String, dynamic> toJson() => _$UserListResponseToJson(this);
}

@JsonSerializable()
class PaginationInfo {
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginationInfo({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) =>
      _$PaginationInfoFromJson(json);
  Map<String, dynamic> toJson() => _$PaginationInfoToJson(this);
}
