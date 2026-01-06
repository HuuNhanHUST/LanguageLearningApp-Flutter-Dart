import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';

class AssignmentService {
  Future<Map<String, dynamic>> createAssignment({
    required String title,
    required String description,
    required String classId,
    required List<String> questionIds,
    required bool isPublished,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/assignments'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'title': title,
        'description': description,
        'classId': classId,
        'questionIds': questionIds,
        'isPublished': isPublished,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tạo bài tập');
    }
  }

  Future<List<Map<String, dynamic>>> getClassAssignments({
    required String classId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/assignments/class/$classId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể lấy danh sách bài tập');
    }
  }

  Future<Map<String, dynamic>> getAssignmentById({
    required String assignmentId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/assignments/$assignmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể lấy bài tập');
    }
  }

  Future<void> deleteAssignment({
    required String assignmentId,
    required String token,
  }) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/assignments/$assignmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể xóa bài tập');
    }
  }

  Future<void> togglePublish({
    required String assignmentId,
    required String token,
  }) async {
    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/assignments/$assignmentId/publish'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể cập nhật bài tập');
    }
  }
}
