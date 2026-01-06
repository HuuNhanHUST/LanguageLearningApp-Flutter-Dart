import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/class_model.dart';

class ClassService {

  /// Tạo lớp học mới (chỉ giáo viên)
  Future<ClassModel> createClass({
    required String name,
    required String description,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/classes'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'name': name,
        'description': description,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return ClassModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tạo lớp học');
    }
  }

  /// Lấy danh sách lớp học của giáo viên
  Future<List<ClassModel>> getTeacherClasses(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/classes/teacher'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final classes = (data['data'] as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();
      return classes;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải danh sách lớp');
    }
  }

  /// Lấy danh sách lớp học của học sinh
  Future<List<ClassModel>> getStudentClasses(String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/classes/enrolled'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final classes = (data['data'] as List)
          .map((json) => ClassModel.fromJson(json))
          .toList();
      return classes;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải danh sách lớp');
    }
  }

  /// Lấy chi tiết lớp học
  Future<ClassModel> getClassById(String classId, String token) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/classes/$classId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ClassModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải thông tin lớp');
    }
  }

  /// Tham gia lớp học (học sinh)
  Future<ClassModel> joinClass({
    required String code,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/classes/join'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'classCode': code,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return ClassModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tham gia lớp');
    }
  }

  /// Xóa học sinh khỏi lớp (giáo viên)
  Future<void> removeStudent({
    required String classId,
    required String studentId,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/classes/$classId/students/$studentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể xóa học sinh');
    }
  }

  /// Xóa lớp học (giáo viên)
  Future<void> deleteClass(String classId, String token) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/classes/$classId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể xóa lớp học');
    }
  }
}
