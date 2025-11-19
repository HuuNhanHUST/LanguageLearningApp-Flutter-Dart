import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Đây là một ví dụ về cách bạn có thể định nghĩa một Provider để truy cập Service này
// nếu bạn đang dùng Riverpod. Nếu dùng Provider, bạn sẽ định nghĩa khác.
// final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

class SecureStorageService {
  // 1. Khởi tạo FlutterSecureStorage
  // Dùng `const` nếu bạn muốn tạo một instance cố định.
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // 2. Định nghĩa Key để lưu trữ Token
  // Nên đặt Key là hằng số (const) để tránh gõ nhầm.
  static const String _tokenKey = 'jwt_token';
  static const String _refreshTokenKey = 'refresh_token'; // Gợi ý: Nếu cần lưu refresh token

  // --- Các Hàm Thao Tác với Token Chính (JWT) ---

  /// Lưu trữ JWT token vào bộ nhớ an toàn.
  Future<void> saveToken(String token) async {
    // Luôn luôn kiểm tra lỗi nếu cần, nhưng `write` thường an toàn.
    await _storage.write(key: _tokenKey, value: token);
    print('Token đã được lưu trữ thành công.');
  }

  /// Đọc JWT token từ bộ nhớ an toàn.
  /// Trả về String? (null nếu không tìm thấy token).
  Future<String?> readToken() async {
    final token = await _storage.read(key: _tokenKey);
    return token;
  }

  /// Xóa JWT token khỏi bộ nhớ an toàn (dùng khi đăng xuất).
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print('Token đã được xóa khỏi bộ nhớ an toàn.');
  }

  // --- Gợi ý: Các hàm hỗ trợ khác ---

  /// Xóa toàn bộ dữ liệu (tất cả keys) đã được lưu trữ bởi ứng dụng này.
  /// Cần thận trọng khi sử dụng.
  Future<void> deleteAll() async {
    await _storage.deleteAll();
    print('Tất cả dữ liệu đã được xóa.');
  }
}