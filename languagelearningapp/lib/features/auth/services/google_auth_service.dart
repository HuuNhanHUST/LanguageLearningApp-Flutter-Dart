import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/constants/api_constants.dart';

class GoogleAuthService {
  // Use your Web client ID here so Android returns an idToken
  // Replace with your actual Web client id if different
  static const String _webClientId =
      '585456694594-elums4flgqih85m820rrq3ncs37042bs.apps.googleusercontent.com';

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: _webClientId,
  );
  static const _storage = FlutterSecureStorage();

  /// Đăng nhập bằng Google: lấy idToken và gửi về backend để verify
  static Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled

      final auth = await account.authentication;
      final idToken = auth.idToken;
      // Debug info: print returned tokens
      print('Google Authentication debug -> idToken: ${auth.idToken}, accessToken: ${auth.accessToken}, serverAuthCode: ${auth.serverAuthCode}');

      if (idToken == null) {
        // If idToken is missing, provide clearer message including serverAuthCode (if available)
        throw Exception('Missing idToken from Google. serverAuthCode: ${auth.serverAuthCode}');
      }

      // Gửi idToken tới backend
      final response = await http.post(
        Uri.parse('${ApiConstants.baseUrl}/users/auth/google'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'googleToken': idToken}),
      ).timeout(const Duration(seconds: 30), onTimeout: () => throw Exception('Backend request timeout'));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final token = data['data']?['accessToken'];
        if (token != null) await _storage.write(key: 'jwt_token', value: token);
        return data['data'];
      } else {
        throw Exception('Google auth failed: ${response.statusCode}');
      }
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _storage.delete(key: 'jwt_token');
    } catch (e) {
      print('Google Sign Out Error: $e');
      rethrow;
    }
  }
}
