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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder'),
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Recording Status Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: audioState.isRecording 
                    ? Colors.red.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
                border: Border.all(
                  color: audioState.isRecording ? Colors.red : Colors.grey,
                  width: 4,
                ),
              ),
              child: Icon(
                audioState.isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: audioState.isRecording ? Colors.red : Colors.grey,
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Recording Status Text
            Text(
              audioState.isRecording ? 'Recording...' : 'Ready to Record',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: audioState.isRecording ? Colors.red : Colors.grey[700],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Record Button
            ElevatedButton(
              onPressed: () async {
                await audioNotifier.toggleRecording();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: audioState.isRecording ? Colors.red : Colors.green,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    audioState.isRecording ? Icons.stop : Icons.fiber_manual_record,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    audioState.isRecording ? 'Stop Recording' : 'Start Recording',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Audio File Information
            if (audioState.audioPath != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  border: Border.all(color: Colors.green),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.audiotrack, color: Colors.green),
                        SizedBox(width: 8),
                        Text(
                          'Recording Saved!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'File: ${audioState.audioPath!.split('/').last}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<int>(
                      future: File(audioState.audioPath!).length(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final sizeKB = (snapshot.data! / 1024).toStringAsFixed(1);
                          return Text(
                            'Size: $sizeKB KB',
                            style: const TextStyle(fontSize: 14),
                          );
                        }
                        return const Text('Loading size...');
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Path: ${audioState.audioPath}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
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
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 8),
                        Text(
                          'Error',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      audioState.errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        audioNotifier.clearError();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                      ),
                      child: const Text(
                        'Clear Error',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 30),
            
            // Instructions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Column(
                children: [
                  Icon(Icons.info, color: Colors.blue),
                  SizedBox(height: 8),
                  Text(
                    'Instructions:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '1. Tap "Start Recording" to begin\n'
                    '2. Speak into your microphone\n'
                    '3. Tap "Stop Recording" to save\n'
                    '4. Audio files are saved temporarily on your device',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}