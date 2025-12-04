import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';

import '../core/constants/api_constants.dart';
import '../features/auth/services/auth_service.dart';

/// Service phụ trách upload file audio lên endpoint STT và trả transcript.
class SttService {
  SttService({Dio? dio, AuthService? authService})
      : _dio = dio ?? Dio(_defaultOptions),
        _authService = authService ?? AuthService();

  final Dio _dio;
  final AuthService _authService;

  static final _defaultOptions = BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 30),
    sendTimeout: const Duration(seconds: 30),
  );

  /// Upload audio và nhận transcript text từ server.
  Future<String> transcribe({
    required String audioPath,
    String? targetText,
  }) async {
    final file = File(audioPath);
    if (!await file.exists()) {
      throw Exception('Không tìm thấy file audio để gửi');
    }

    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Vui lòng đăng nhập để sử dụng STT');
    }

    final fileName = _extractFileName(audioPath);

    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(
        file.path,
        filename: fileName,
        contentType: _detectContentType(fileName),
      ),
      if (targetText != null && targetText.trim().isNotEmpty)
        'targetText': targetText.trim(),
    });

    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/ai/stt',
        data: formData,
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          contentType: 'multipart/form-data',
        ),
      );

      final data = response.data as Map<String, dynamic>?;
      if (response.statusCode != 200 ||
          data == null ||
          data['success'] != true) {
        throw Exception(data?['message'] ?? 'Không thể nhận phản hồi STT');
      }

      final transcript = (data['data']?['transcript'] as String?)?.trim();
      if (transcript == null || transcript.isEmpty) {
        throw Exception('Server không trả về transcript');
      }

      return transcript;
    } on DioException catch (error) {
      print('>>> STT ERROR RESPONSE DATA: ${error.response?.data}');
      print('>>> STT ERROR STATUS CODE: ${error.response?.statusCode}');
      print('>>> STT ERROR TYPE: ${error.type}');

      final responseData = error.response?.data;
      String? message;
      if (responseData is Map<String, dynamic>) {
        message =
            responseData['message'] as String? ??
                responseData['error'] as String?;
      } else if (responseData is String) {
        message = responseData;
      }
      message ??= error.message;
      throw Exception(message ?? 'Không thể kết nối server STT');
    }
  }

  String _extractFileName(String path) {
    final separator = Platform.pathSeparator;
    if (path.contains(separator)) {
      return path.split(separator).last;
    }
    // fallback cho trường hợp dùng dấu gạch chéo khác
    if (path.contains('/')) {
      return path.split('/').last;
    }
    if (path.contains('\\')) {
      return path.split('\\').last;
    }
    return path;
  }

  MediaType _detectContentType(String fileName) {
    final ext = fileName.split('.').last.toLowerCase();
    switch (ext) {
      case 'wav':
        return MediaType('audio', 'wav');
      case 'mp3':
        return MediaType('audio', 'mpeg');
      case 'aac':
        return MediaType('audio', 'aac');
      case 'm4a':
        return MediaType('audio', 'm4a');
      case 'ogg':
        return MediaType('audio', 'ogg');
      case 'webm':
        return MediaType('audio', 'webm');
      default:
        return MediaType('audio', 'mpeg');
    }
  }
}
