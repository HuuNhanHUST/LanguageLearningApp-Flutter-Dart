import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_recorder_provider.dart';
import '../widgets/audio_recorder_button.dart';

/// Audio Recorder Demo Screen
class AudioRecorderDemoScreen extends ConsumerWidget {
  const AudioRecorderDemoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorderState = ref.watch(audioRecorderProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Audio Recorder Demo'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Status Icon
              Icon(
                recorderState.isRecording ? Icons.mic : Icons.mic_none,
                size: 80,
                color: recorderState.isRecording ? Colors.red : Colors.grey,
              ),
              const SizedBox(height: 24),

              // Status Text
              Text(
                recorderState.isRecording
                    ? 'Recording...'
                    : 'Tap microphone to start',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: recorderState.isRecording ? Colors.red : Colors.grey,
                ),
              ),
              const SizedBox(height: 48),

              // Audio Recorder Button
              AudioRecorderButton(
                size: 120,
                onRecordingComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Recording saved successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
              const SizedBox(height: 48),

              // File Path Display
              if (recorderState.audioPath != null)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Last Recording',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Path:',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade700,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        recorderState.audioPath!,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 24),

              // Instructions
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'How to use',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildInstructionItem(
                      '1. Tap the microphone to start recording',
                    ),
                    const SizedBox(height: 8),
                    _buildInstructionItem('2. Tap the stop icon to finish'),
                    const SizedBox(height: 8),
                    _buildInstructionItem('3. Audio saved to temp directory'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Compact Button Demo
              const Divider(),
              const SizedBox(height: 16),
              Text(
                'Compact Version',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              CompactAudioRecorderButton(
                onRecordingComplete: () {
                  print('📁 Compact recorder: Recording complete');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
