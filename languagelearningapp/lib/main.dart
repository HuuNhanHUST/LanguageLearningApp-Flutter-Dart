import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/home_screen.dart'; // Đã tạo: Home Screen
import 'screens/login_screen.dart'; // Đã tạo: Login Screen
import 'providers/auth_notifier.dart'; // Đã tạo: Auth Notifier

void main() {
  // Bắt buộc bọc MyApp bằng ProviderScope
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Learning App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // AuthGate sẽ là widget quyết định hiển thị màn hình nào
      home: const AuthGate(),
    );
  }
}

/// Widget trung gian xử lý luồng điều hướng (Routing) dựa trên trạng thái AuthState.
class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theo dõi trạng thái xác thực
    final authState = ref.watch(authNotifierProvider);

    if (authState.isLoading) {
      // 1. Đang tải: Hiển thị màn hình chờ khi kiểm tra token lúc khởi động
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 10),
              Text('Đang kiểm tra phiên đăng nhập...'),
            ],
          ),
        ),
      );
    }

    if (authState.isAuthenticated) {
      // 2. Đã xác thực: Chuyển đến Trang Chủ
      return const HomeScreen();
    } else {
      // 3. Chưa xác thực: Chuyển đến Trang Đăng nhập
      return const LoginScreen();
    }
  }
}

// **LƯU Ý:** // Các widget cũ như GoRouter, MyHomePage, và DetailsPage đã được loại bỏ
// để giữ cho file main.dart tập trung vào luồng xác thực mới.