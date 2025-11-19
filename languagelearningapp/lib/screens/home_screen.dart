import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_notifier.dart';

// HomeScreen phải là ConsumerWidget để tương tác với Riverpod
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lấy thông tin token (chỉ để hiển thị)
    final token = ref.watch(authNotifierProvider.select((state) => state.token));
    final isLoading = ref.watch(authNotifierProvider.select((state) => state.isLoading));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trang Chủ'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 20),
              const Text(
                'Bạn đã đăng nhập thành công!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              // ĐÃ XÓA dòng Text hiển thị token ở đây
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: isLoading
                    ? null
                    : () async {
                  // Gọi hàm logout từ AuthNotifier
                  await ref.read(authNotifierProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.redAccent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('ĐĂNG XUẤT', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}