import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../core/constants/api_constants.dart';
import '../../auth/services/auth_service.dart';
import '../models/message_model.dart';

/// Service để gọi API chat với Gemini AI
class ChatService {
  final http.Client _client;
  final AuthService _authService;

  ChatService({http.Client? client, AuthService? authService})
    : _client = client ?? http.Client(),
      _authService = authService ?? AuthService();

  /// Gửi tin nhắn tới AI và nhận response
  ///
  /// [message]: Tin nhắn hiện tại của user
  /// [conversationHistory]: Lịch sử cuộc trò chuyện (để AI nhớ context)
  ///
  /// SCRUM-30: Context Chat - Giới hạn 10 tin nhắn gần nhất để tránh tốn token
  Future<String> sendMessage({
    required String message,
    List<ChatMessage>? conversationHistory,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Phiên đăng nhập đã hết hạn, vui lòng đăng nhập lại');
    }

    try {
      // SCRUM-30: Chuẩn bị conversation history (chỉ lấy 10 tin nhắn gần nhất)
      // Backend sẽ dùng history này để tạo context-aware prompt
      final history =
          conversationHistory
              ?.take(10)
              .map((msg) => {'text': msg.text, 'isUser': msg.isUser})
              .toList() ??
          [];

      final response = await _client.post(
        Uri.parse(ApiConstants.chat),
        headers: ApiConstants.getHeaders(token: token),
        body: jsonEncode({'message': message, 'conversationHistory': history}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;

        if (data['success'] == true && data['data'] != null) {
          return data['data']['message'] as String;
        } else {
          throw Exception('Lỗi từ server: ${data['message']}');
        }
      } else if (response.statusCode == 401) {
        throw Exception('Phiên đăng nhập đã hết hạn');
      } else {
        final error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Không thể kết nối với AI');
      }
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception(
          'Không thể kết nối với server. Vui lòng kiểm tra kết nối mạng.',
        );
      }
      rethrow;
    }
  }
}
