import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/secure_storage_service.dart'; // Giả sử file này đã có

// --- 1. Provider cho SecureStorageService (Phải có để inject) ---
final secureStorageServiceProvider = Provider((ref) => SecureStorageService());

// --- 2. Định nghĩa AuthState (Trạng thái) ---
// Chứa dữ liệu về trạng thái xác thực hiện tại
class AuthState {
  final String? token;
  final bool isAuthenticated;
  final bool isLoading;

  AuthState({this.token, this.isAuthenticated = false, this.isLoading = false});

  // Hàm copyWith giúp tạo trạng thái mới dễ dàng hơn
  AuthState copyWith({
    String? token,
    bool? isAuthenticated,
    bool? isLoading,
  }) {
    return AuthState(
      token: token ?? this.token,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// --- 3. AuthNotifier (Logic) ---
// Chứa các hàm login, logout và khôi phục trạng thái
class AuthNotifier extends StateNotifier<AuthState> {
  final SecureStorageService _storageService;

  // Khởi tạo AuthNotifier với trạng thái ban đầu là Đang tải (Loading)
  AuthNotifier(this._storageService) : super(AuthState(isLoading: true)) {
    // Gọi hàm khôi phục trạng thái ngay khi Notifier được tạo
    _initializeAuth();
  }

  /// Khôi phục trạng thái xác thực khi khởi động ứng dụng
  Future<void> _initializeAuth() async {
    final String? token = await _storageService.readToken();

    if (token != null) {
      // Giả định token hợp lệ, chuyển sang trạng thái đã đăng nhập
      state = state.copyWith(token: token, isAuthenticated: true, isLoading: false);
    } else {
      // Không có token, chuyển sang trạng thái chờ đăng nhập
      state = state.copyWith(isLoading: false);
    }
  }

  /// Xử lý logic Đăng nhập
  Future<void> login(String username, String password) async {
    state = state.copyWith(isLoading: true);

    // TODO: THỰC HIỆN GỌI API ĐĂNG NHẬP Ở ĐÂY
    // Dùng token giả định cho mục đích demo
    await Future.delayed(const Duration(seconds: 1)); // Mô phỏng độ trễ API
    const String dummyToken = "jwt_token_123456";

    // 1. Lưu token an toàn
    await _storageService.saveToken(dummyToken);

    // 2. Cập nhật trạng thái
    state = state.copyWith(
      token: dummyToken,
      isAuthenticated: true,
      isLoading: false,
    );
  }

  /// Xử lý logic Đăng xuất
  Future<void> logout() async {
    state = state.copyWith(isLoading: true);

    // 1. Xóa token khỏi bộ nhớ an toàn
    await _storageService.deleteToken();

    // 2. Cập nhật trạng thái về chưa đăng nhập
    state = AuthState(isLoading: false); // Reset toàn bộ trạng thái
  }
}

// --- 4. Provider cho AuthNotifier ---
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  // Lấy instance của SecureStorageService và truyền vào AuthNotifier
  final storageService = ref.watch(secureStorageServiceProvider);
  return AuthNotifier(storageService);
});