class ApiConstants {
  // Cấu hình Base URL
  //
  // CHO EMULATOR/SIMULATOR:
  // - Android Emulator: sử dụng 'http://10.0.2.2:5000/api'
  // - iOS Simulator: sử dụng 'http://localhost:5000/api' hoặc 'http://127.0.0.1:5000/api'
  //
  // CHO THIẾT BỊ VẬT LÝ (qua USB):
  // - Sử dụng địa chỉ IP cục bộ của máy tính
  // - Windows: Chạy lệnh 'ipconfig' và tìm địa chỉ IPv4 WiFi/Ethernet
  // - Ví dụ: 'http://192.168.1.217:5000/api'
  //
  // Thay đổi dựa trên thiết lập của bạn:
  //static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  // static const String baseUrl = 'http://192.168.1.5:5000/api'; // Thiết bị vật lý
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator

  static const String baseUrl = 'http://172.16.0.57:5000/api';
  // Auth Endpoints
  static const String register = '$baseUrl/users/register';
  static const String login = '$baseUrl/users/login';
  static const String profile = '$baseUrl/users/profile';
  static const String updateProfile = '$baseUrl/users/profile';
  static const String changePassword = '$baseUrl/users/change-password';
  static const String deleteAccount = '$baseUrl/users/account';

  // User Endpoints
  static const String addLearningLanguage = '$baseUrl/users/learning-languages';
  static String removeLearningLanguage(String language) =>
      '$baseUrl/users/learning-languages/$language';
  static const String updatePreferences = '$baseUrl/users/preferences';
  static const String getUserStats = '$baseUrl/users/stats';
  static const String updateDailyGoal = '$baseUrl/users/daily-goal';

  // Word endpoints
  static const String wordLookup = '$baseUrl/words/lookup';
  static const String getWords = '$baseUrl/words';
  static const String searchWords = '$baseUrl/words/search';
  static const String vocabularyStats = '$baseUrl/words/stats';
  static String deleteWord(String wordId) => '$baseUrl/words/$wordId';
  static String updateWord(String wordId) => '$baseUrl/words/$wordId';
  static String toggleMemorized(String wordId) =>
      '$baseUrl/words/$wordId/memorize';

  // Chat endpoints
  static const String chat = '$baseUrl/chat';
  static const String translate = '$baseUrl/chat/translate';

  // Pronunciation endpoints
  static const String pronunciationCompare = '$baseUrl/pronunciation/compare';
  static const String pronunciationScore = '$baseUrl/pronunciation/score';
  static const String pronunciationErrors = '$baseUrl/pronunciation/errors';

  // Gamification / Profile endpoints
  static const String gamificationStats = '$baseUrl/gamification/stats';
  static const String gamificationBadges = '$baseUrl/gamification/badges';

  // Grammar lesson endpoints
  static const String grammarQuestions = '$baseUrl/grammar/questions';
  static const String grammarGenerate = '$baseUrl/grammar/questions/generate';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
