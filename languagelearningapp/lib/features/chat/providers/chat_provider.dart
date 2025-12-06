import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/message_model.dart';
import '../services/chat_service.dart';

/// State cho chat
class ChatState {
  final List<ChatMessage> messages;
  final bool isTyping;
  final String? error;

  const ChatState({
    this.messages = const [],
    this.isTyping = false,
    this.error,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isTyping,
    String? error,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isTyping: isTyping ?? this.isTyping,
      error: error,
    );
  }
}

/// Notifier quản lý chat
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatService _chatService;

  ChatNotifier({ChatService? chatService})
    : _chatService = chatService ?? ChatService(),
      super(const ChatState()) {
    _initializeChat();
  }

  /// Khởi tạo chat với tin nhắn chào
  void _initializeChat() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text:
          'Xin chào! Tôi là AI Tutor của bạn. Tôi có thể giúp bạn học tiếng Anh. Hãy hỏi tôi bất cứ điều gì!',
      isUser: false,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(messages: [welcomeMessage]);
  }

  /// Gửi tin nhắn từ user
  ///
  /// SCRUM-30: Gửi tin nhắn kèm conversation history để AI nhớ ngữ cảnh
  /// - AI có thể hiểu khi user hỏi "Nó là gì?" dựa trên tin nhắn trước
  /// - Chỉ gửi toàn bộ messages, ChatService sẽ giới hạn 10 tin nhắn gần nhất
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Tạo tin nhắn user
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: text.trim(),
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Thêm tin nhắn user vào danh sách
    state = state.copyWith(
      messages: [...state.messages, userMessage],
      isTyping: true,
      error: null,
    );

    try {
      // SCRUM-30: Gọi API với conversation history
      // Backend sẽ tích hợp history vào system prompt để AI nhớ context
      final aiResponse = await _chatService.sendMessage(
        message: text.trim(),
        conversationHistory: state.messages, // Gửi toàn bộ history
      );

      // Tạo tin nhắn bot từ API response
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: aiResponse,
        isUser: false,
        timestamp: DateTime.now(),
      );

      // Thêm tin nhắn bot vào danh sách
      state = state.copyWith(
        messages: [...state.messages, botMessage],
        isTyping: false,
      );
    } catch (e) {
      // Xử lý lỗi
      state = state.copyWith(isLoading: false, error: e.toString());

      // Thêm tin nhắn lỗi vào chat
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text:
            '❌ Xin lỗi, đã có lỗi xảy ra: ${e.toString()}\n\nVui lòng thử lại sau.',
        isUser: false,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(messages: [...state.messages, errorMessage]);
    }
  }

  /// Generate mock response (sẽ thay bằng API thật sau)
  String _generateMockResponse(String userText) {
    final lowerText = userText.toLowerCase();

    // Chào hỏi
    if (lowerText.contains('hello') || lowerText.contains('hi')) {
      return 'Hello! 👋 How can I help you learn English today?';
    }
    if (lowerText.contains('xin chào') || lowerText.contains('chào')) {
      return 'Xin chào! 👋 Tôi có thể giúp gì cho bạn hôm nay?';
    }

    // Tạm biệt
    if (lowerText.contains('bye') || lowerText.contains('goodbye')) {
      return 'Goodbye! 👋 See you next time! Keep practicing English!';
    }
    if (lowerText.contains('tạm biệt')) {
      return 'Tạm biệt! 👋 Hẹn gặp lại bạn lần sau!';
    }

    // Dịch thuật - Phát hiện pattern và dịch thẳng
    if (lowerText.contains('dịch') && lowerText.contains('sang tiếng anh')) {
      final textToDich = _extractTextBetweenQuotes(userText);
      if (textToDich.isNotEmpty) {
        return _translateToEnglish(textToDich);
      }
    }

    if (lowerText.contains('translate') &&
        lowerText.contains('to vietnamese')) {
      final textToTranslate = _extractTextBetweenQuotes(userText);
      if (textToTranslate.isNotEmpty) {
        return _translateToVietnamese(textToTranslate);
      }
    }

    // Dịch chung chung
    if (lowerText.contains('translate')) {
      return 'Sure! I can translate for you. 🌐\n\n'
          'Please use this format:\n'
          'Translate "your text" to Vietnamese\n\n'
          'Example: Translate "Hello" to Vietnamese';
    }
    if (lowerText.contains('dịch')) {
      return 'Được! Tôi có thể dịch cho bạn. 🌐\n\n'
          'Vui lòng dùng định dạng:\n'
          'Dịch "văn bản của bạn" sang tiếng Anh\n\n'
          'Ví dụ: Dịch "Xin chào" sang tiếng Anh';
    }

    // Ngữ pháp
    if (lowerText.contains('grammar')) {
      return 'I\'d be happy to help with grammar! 📖\n\n'
          'Which topic do you want to learn?\n'
          '• Tenses (Present, Past, Future)\n'
          '• Articles (a, an, the)\n'
          '• Prepositions (in, on, at)\n'
          '• Question forms\n'
          '• Or ask me about a specific grammar rule!';
    }
    if (lowerText.contains('ngữ pháp')) {
      return 'Tôi rất vui được giúp bạn về ngữ pháp! 📖\n\n'
          'Bạn muốn học chủ đề nào?\n'
          '• Các thì (Present, Past, Future)\n'
          '• Mạo từ (a, an, the)\n'
          '• Giới từ (in, on, at)\n'
          '• Câu hỏi\n'
          '• Hoặc hỏi tôi về một quy tắc ngữ pháp cụ thể!';
    }

    // Từ vựng
    if (lowerText.contains('vocabulary') || lowerText.contains('words')) {
      return 'Great! Let\'s learn some vocabulary! 📚\n\n'
          'Which topic interests you?\n'
          '• Daily life\n'
          '• Food & Drinks\n'
          '• Travel\n'
          '• Work & Study\n'
          '• Or tell me a specific topic!';
    }
    if (lowerText.contains('từ vựng') || lowerText.contains('từ')) {
      return 'Tuyệt! Cùng học từ vựng nào! 📚\n\n'
          'Bạn quan tâm chủ đề nào?\n'
          '• Cuộc sống hàng ngày\n'
          '• Đồ ăn & Thức uống\n'
          '• Du lịch\n'
          '• Công việc & Học tập\n'
          '• Hoặc cho tôi biết chủ đề cụ thể!';
    }

    // Phát âm
    if (lowerText.contains('pronunciation') ||
        lowerText.contains('pronounce')) {
      return 'I can help you with pronunciation! 🗣️\n\n'
          'Please tell me which word you want to learn how to pronounce.\n\n'
          'Example: "How to pronounce \'comfortable\'?"';
    }
    if (lowerText.contains('phát âm')) {
      return 'Tôi có thể giúp bạn về phát âm! 🗣️\n\n'
          'Vui lòng cho tôi biết từ nào bạn muốn học cách phát âm.\n\n'
          'Ví dụ: "Cách phát âm từ \'comfortable\'"';
    }

    // Học nói
    if (lowerText.contains('conversation') || lowerText.contains('speak')) {
      return 'Let\'s practice conversation! 💬\n\n'
          'Which situation do you want to practice?\n'
          '• At a restaurant\n'
          '• Shopping\n'
          '• Asking for directions\n'
          '• Making friends\n'
          '• Job interview';
    }
    if (lowerText.contains('hội thoại') || lowerText.contains('nói chuyện')) {
      return 'Cùng luyện hội thoại nào! 💬\n\n'
          'Bạn muốn luyện tập tình huống nào?\n'
          '• Ở nhà hàng\n'
          '• Mua sắm\n'
          '• Hỏi đường\n'
          '• Kết bạn\n'
          '• Phỏng vấn xin việc';
    }

    // Mặc định (phát hiện ngôn ngữ)
    final isVietnamese = _containsVietnamese(userText);
    if (isVietnamese) {
      return 'Câu hỏi thú vị đấy! 🤔\n\n'
          'Tôi là AI Tutor, có thể giúp bạn:\n'
          '• Dịch thuật\n'
          '• Học ngữ pháp\n'
          '• Học từ vựng\n'
          '• Luyện phát âm\n'
          '• Luyện hội thoại\n\n'
          'Bạn muốn học gì hôm nay?';
    } else {
      return 'That\'s interesting! 🤔\n\n'
          'I\'m your AI English Tutor. I can help you with:\n'
          '• Translation\n'
          '• Grammar\n'
          '• Vocabulary\n'
          '• Pronunciation\n'
          '• Conversation practice\n\n'
          'What would you like to learn today?';
    }
  }

  /// Kiểm tra có phải tiếng Việt không
  bool _containsVietnamese(String text) {
    final vietnameseChars = RegExp(
      r'[àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ]',
    );
    return vietnameseChars.hasMatch(text.toLowerCase());
  }

  /// Trích xuất text trong dấu ngoặc kép
  String _extractTextBetweenQuotes(String text) {
    // Tìm text trong dấu ngoặc kép "" hoặc ''
    final regexDouble = RegExp(r'"([^"]*)"');
    final regexSingle = RegExp(r"'([^']*)'");

    final matchDouble = regexDouble.firstMatch(text);
    if (matchDouble != null && matchDouble.group(1) != null) {
      return matchDouble.group(1)!;
    }

    final matchSingle = regexSingle.firstMatch(text);
    if (matchSingle != null && matchSingle.group(1) != null) {
      return matchSingle.group(1)!;
    }

    return '';
  }

  /// Mock translation Tiếng Việt -> English
  String _translateToEnglish(String vietnameseText) {
    final mockDict = {
      'xin chào': 'hello',
      'chào': 'hello / hi',
      'tạm biệt': 'goodbye / bye',
      'cảm ơn': 'thank you',
      'tôi yêu bạn': 'I love you',
      'bạn khỏe không': 'how are you',
      'tôi khỏe': 'I\'m fine',
      'học tiếng anh': 'learn English',
      'nhà': 'house / home',
      'gia đình': 'family',
      'bạn bè': 'friend / friends',
      'sách': 'book',
      'trường học': 'school',
      'giáo viên': 'teacher',
      'học sinh': 'student',
    };

    final lower = vietnameseText.toLowerCase().trim();
    final translation = mockDict[lower];

    if (translation != null) {
      return '🇬🇧 Translation:\n\n'
          '📝 Vietnamese: "$vietnameseText"\n'
          '✅ English: "$translation"\n\n'
          'Example: "${_getExampleSentence(translation)}"';
    } else {
      return '🤔 I don\'t have this word in my database yet.\n\n'
          '📝 Vietnamese: "$vietnameseText"\n\n'
          'But I can help you with common words like:\n'
          '• Xin chào → Hello\n'
          '• Cảm ơn → Thank you\n'
          '• Tạm biệt → Goodbye';
    }
  }

  /// Mock translation English -> Tiếng Việt
  String _translateToVietnamese(String englishText) {
    final mockDict = {
      'hello': 'xin chào',
      'hi': 'chào',
      'goodbye': 'tạm biệt',
      'bye': 'tạm biệt',
      'thank you': 'cảm ơn',
      'thanks': 'cảm ơn',
      'i love you': 'tôi yêu bạn',
      'how are you': 'bạn khỏe không',
      'i\'m fine': 'tôi khỏe',
      'learn english': 'học tiếng anh',
      'house': 'nhà',
      'home': 'nhà',
      'family': 'gia đình',
      'friend': 'bạn bè',
      'book': 'sách',
      'school': 'trường học',
      'teacher': 'giáo viên',
      'student': 'học sinh',
    };

    final lower = englishText.toLowerCase().trim();
    final translation = mockDict[lower];

    if (translation != null) {
      return '🇻🇳 Bản dịch:\n\n'
          '📝 English: "$englishText"\n'
          '✅ Tiếng Việt: "$translation"\n\n'
          'Ví dụ: "${_getVietnameseExample(translation)}"';
    } else {
      return '🤔 Tôi chưa có từ này trong database.\n\n'
          '📝 English: "$englishText"\n\n'
          'Nhưng tôi có thể dịch các từ phổ biến như:\n'
          '• Hello → Xin chào\n'
          '• Thank you → Cảm ơn\n'
          '• Goodbye → Tạm biệt';
    }
  }

  /// Tạo câu ví dụ tiếng Anh
  String _getExampleSentence(String word) {
    final examples = {
      'hello': 'Hello! How are you today?',
      'hi': 'Hi, nice to meet you!',
      'goodbye': 'Goodbye! See you tomorrow.',
      'thank you': 'Thank you for your help!',
      'I love you': 'I love you so much!',
      'how are you': 'Hello! How are you?',
      'I\'m fine': 'I\'m fine, thank you.',
      'learn English': 'I want to learn English.',
      'house': 'This is my house.',
      'home': 'Welcome to my home!',
      'family': 'I love my family.',
      'friend': 'She is my best friend.',
      'book': 'I\'m reading a book.',
      'school': 'I go to school every day.',
      'teacher': 'My teacher is very kind.',
      'student': 'I am a student.',
    };
    return examples[word] ?? 'Example not available.';
  }

  /// Tạo câu ví dụ tiếng Việt
  String _getVietnameseExample(String word) {
    final examples = {
      'xin chào': 'Xin chào! Bạn khỏe không?',
      'chào': 'Chào bạn, rất vui được gặp!',
      'tạm biệt': 'Tạm biệt! Hẹn gặp lại.',
      'cảm ơn': 'Cảm ơn bạn rất nhiều!',
      'tôi yêu bạn': 'Tôi yêu bạn lắm!',
      'bạn khỏe không': 'Chào bạn! Bạn khỏe không?',
      'tôi khỏe': 'Tôi khỏe, cảm ơn bạn.',
      'học tiếng anh': 'Tôi muốn học tiếng Anh.',
      'nhà': 'Đây là nhà của tôi.',
      'gia đình': 'Tôi yêu gia đình mình.',
      'bạn bè': 'Cô ấy là bạn thân của tôi.',
      'sách': 'Tôi đang đọc sách.',
      'trường học': 'Tôi đi học mỗi ngày.',
      'giáo viên': 'Giáo viên của tôi rất tốt.',
      'học sinh': 'Tôi là học sinh.',
    };
    return examples[word] ?? 'Chưa có ví dụ.';
  }

  /// Xóa tất cả tin nhắn
  void clearChat() {
    _initializeChat();
  }

  /// Xóa tin nhắn cụ thể
  void deleteMessage(String messageId) {
    state = state.copyWith(
      messages: state.messages.where((m) => m.id != messageId).toList(),
    );
  }
}

/// Provider cho chat
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier();
});
