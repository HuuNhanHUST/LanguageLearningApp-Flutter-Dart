import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../models/grammar_question_model.dart';
import '../models/submission_model.dart';

class GrammarQuestionService {

  /// Tạo câu hỏi ngữ pháp mới (giáo viên)
  Future<GrammarQuestion> createQuestion({
    required String question,
    required List<String> options,
    required int correctAnswer,
    String? explanation,
    required String difficulty,
    required List<String> tags,
    String? classId,
    bool isPublic = false,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/grammar/teacher/questions'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'question': question,
        'options': options,
        'correctIndex': correctAnswer, // Backend expects 'correctIndex'
        'explanation': explanation,
        'difficulty': difficulty,
        'tags': tags,
        'classId': classId,
        'isPublic': isPublic,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return GrammarQuestion.fromJson(data['data']); // Backend returns 'data'
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tạo câu hỏi');
    }
  }

  /// Lấy câu hỏi của giáo viên
  Future<List<GrammarQuestion>> getTeacherQuestions({
    String? classId,
    required String token,
  }) async {
    var url = '${ApiConstants.baseUrl}/grammar/teacher/questions';
    if (classId != null) {
      url += '?classId=$classId';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final questions = (data['questions'] as List)
          .map((json) => GrammarQuestion.fromJson(json))
          .toList();
      return questions;
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải câu hỏi');
    }
  }

  /// Lấy câu hỏi của lớp học (học sinh)
  Future<List<GrammarQuestion>> getClassQuestions({
    required String classId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/grammar/class/$classId/questions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List questionsJson = data['data'];
      return questionsJson.map((json) => GrammarQuestion.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể tải câu hỏi');
    }
  }

  /// Xóa câu hỏi (giáo viên)
  Future<void> deleteQuestion(String questionId, String token) async {
    final response = await http.delete(
      Uri.parse('${ApiConstants.baseUrl}/grammar/teacher/questions/$questionId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể xóa câu hỏi');
    }
  }

  /// Cập nhật câu hỏi (giáo viên)
  Future<GrammarQuestion> updateQuestion({
    required String questionId,
    String? question,
    List<String>? options,
    int? correctAnswer,
    String? explanation,
    String? difficulty,
    List<String>? tags,
    bool? isPublic,
    required String token,
  }) async {
    final body = <String, dynamic>{};
    if (question != null) body['question'] = question;
    if (options != null) body['options'] = options;
    if (correctAnswer != null) body['correctAnswer'] = correctAnswer;
    if (explanation != null) body['explanation'] = explanation;
    if (difficulty != null) body['difficulty'] = difficulty;
    if (tags != null) body['tags'] = tags;
    if (isPublic != null) body['isPublic'] = isPublic;

    final response = await http.put(
      Uri.parse('${ApiConstants.baseUrl}/grammar/teacher/questions/$questionId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return GrammarQuestion.fromJson(data['question']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể cập nhật câu hỏi');
    }
  }

  /// Submit bài làm (học sinh)
  Future<SubmissionModel> submitAnswers({
    required String classId,
    required String assignmentId,
    required List<Map<String, dynamic>> answers,
    required String token,
  }) async {
    final response = await http.post(
      Uri.parse('${ApiConstants.baseUrl}/grammar/submit'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'classId': classId,
        'assignmentId': assignmentId,
        'answers': answers,
      }),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      return SubmissionModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể nộp bài');
    }
  }

  /// Lấy kết quả của học sinh
  Future<SubmissionModel> getSubmission({
    required String assignmentId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/grammar/submissions/$assignmentId'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return SubmissionModel.fromJson(data['data']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể lấy kết quả');
    }
  }

  /// Giáo viên xem tất cả bài làm của lớp
  Future<List<SubmissionModel>> getClassSubmissions({
    required String classId,
    required String token,
  }) async {
    final response = await http.get(
      Uri.parse('${ApiConstants.baseUrl}/grammar/class/$classId/submissions'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List submissionsJson = data['data'];
      return submissionsJson.map((json) => SubmissionModel.fromJson(json)).toList();
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['message'] ?? 'Không thể lấy danh sách bài làm');
    }
  }
}
