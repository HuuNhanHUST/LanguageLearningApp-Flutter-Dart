import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/submission_model.dart';

class SubmissionService {
  /// Submit assignment
  Future<SubmissionModel> submitAssignment({
    required String assignmentId,
    required String classId,
    required List<Map<String, dynamic>> answers,
    required String token,
  }) async {
    final url = Uri.parse('${ApiConstants.baseUrl}/submissions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'assignmentId': assignmentId,
        'classId': classId,
        'answers': answers,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return SubmissionModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to submit assignment');
    }
  }

  /// Get my submission for an assignment
  Future<SubmissionModel?> getMySubmission({
    required String assignmentId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/submissions/my/$assignmentId',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SubmissionModel.fromJson(data['data']);
    } else if (response.statusCode == 404) {
      return null; // No submission found
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get submission');
    }
  }

  /// Check if student has submitted assignment
  Future<Map<String, dynamic>> checkSubmission({
    required String assignmentId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/submissions/check/$assignmentId',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data'];
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to check submission');
    }
  }

  /// Get all submissions for an assignment (Teacher only)
  Future<Map<String, dynamic>> getAssignmentSubmissions({
    required String assignmentId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConstants.baseUrl}/submissions/assignment/$assignmentId',
    );

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['data']; // Returns { submissions: [], stats: {} }
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Failed to get submissions');
    }
  }
}
