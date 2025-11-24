class ApiConstants {
  // Base URL Configuration
  //
  // FOR EMULATOR/SIMULATOR:
  // - Android Emulator: use 'http://10.0.2.2:5000/api'
  // - iOS Simulator: use 'http://localhost:5000/api' or 'http://127.0.0.1:5000/api'
  //
  // FOR PHYSICAL DEVICE (via USB):
  // - Use your computer's local IP address
  // - Windows: Run 'ipconfig' and find your WiFi/Ethernet IPv4 address
  // - Example: 'http://192.168.1.217:5000/api'
  //
  // Change this based on your setup:
  static const String baseUrl =
      'http://172.20.10.8:5000/api'; // Physical device
  // static const String baseUrl = 'http://10.0.2.2:5000/api'; // Android Emulator
  // static const String baseUrl = 'http://localhost:5000/api'; // iOS Simulator

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

  // Word Endpoints
  static const String wordLookup = '$baseUrl/words/lookup';

  // Headers
  static Map<String, String> getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }
}
