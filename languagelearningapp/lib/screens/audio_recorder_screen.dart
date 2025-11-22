import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_recorder_provider.dart';
import 'audio_files_screen.dart';

class AudioRecorderScreen extends ConsumerWidget {
  const AudioRecorderScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioState = ref.watch(audioRecorderProvider);
    final audioNotifier = ref.read(audioRecorderProvider.notifier);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Ghi Âm', style: TextStyle(fontWeight: FontWeight.bold)),
          backgroundColor: const Color(0xFF6366F1),
          foregroundColor: Colors.white,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Quay lại',
          ),
          actions: [
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AudioFilesScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.folder),
              tooltip: 'Quản lý File Ghi âm',
            ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF6366F1).withOpacity(0.1),
                Colors.white,
              ],
            ),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),
                  
                  // Recording Status Icon with Animation
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.95, end: audioState.isRecording ? 1.05 : 1.0),
                    duration: const Duration(milliseconds: 500),
                    builder: (context, value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          width: 180,
                          height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: audioState.isRecording 
                                  ? [Colors.red[400]!, Colors.red[600]!]
                                  : [Colors.indigo[400]!, Colors.indigo[600]!],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: audioState.isRecording 
                                    ? Colors.red.withOpacity(0.4)
                                    : Colors.indigo.withOpacity(0.4),
                                blurRadius: 20,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            audioState.isRecording ? Icons.mic : Icons.mic_none,
                            size: 90,
                            color: Colors.white,
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Recording Status Text
                  Text(
                    audioState.isRecording ? 'Đang ghi âm...' : 'Sẵn sàng ghi âm',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: audioState.isRecording ? Colors.red[600] : const Color(0xFF6366F1),
                    ),
                  ),
                  
                  const SizedBox(height: 50),
                  
                  // Record Button
                  SizedBox(
                    width: 280,
                    height: 70,
                    child: ElevatedButton(
                      onPressed: () async {
                        await audioNotifier.toggleRecording();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: audioState.isRecording ? Colors.red[600] : Colors.green[500],
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            audioState.isRecording ? Icons.stop_circle : Icons.fiber_manual_record,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            audioState.isRecording ? 'Dừng' : 'Bắt đầu',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Audio File Information
                  if (audioState.audioPath != null) ...[
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        border: Border.all(color: Colors.green[400]!, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green[600], size: 28),
                              const SizedBox(width: 10),
                              Text(
                                'Đã lưu thành công!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.audio_file, color: Color(0xFF6366F1), size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'File: ${audioState.audioPath!.split('/').last}',
                                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                FutureBuilder<int>(
                                  future: File(audioState.audioPath!).length(),
                                  builder: (context, snapshot) {
                                    if (snapshot.hasData) {
                                      final sizeKB = (snapshot.data! / 1024).toStringAsFixed(1);
                                      return Row(
                                        children: [
                                          const Icon(Icons.storage, color: Color(0xFF6366F1), size: 20),
                                          const SizedBox(width: 8),
                                          Text(
                                            'Kích thước: $sizeKB KB',
                                            style: const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      );
                                    }
                                    return const Text('Đang tải...');
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  // Error Message
                  if (audioState.errorMessage != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        border: Border.all(color: Colors.red[400]!, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.1),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(Icons.error_outline, color: Colors.red[600], size: 28),
                              const SizedBox(width: 10),
                              Text(
                                'Lỗi',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red[700],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            audioState.errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              audioNotifier.clearError();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[600],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: const Text(
                              'Xóa lỗi',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}