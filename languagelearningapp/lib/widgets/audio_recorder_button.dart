import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_recorder_provider.dart';
import 'audio_visualizer.dart';

/// Enhanced Audio Recorder Button với Visualizer
class AudioRecorderButton extends ConsumerWidget {
  final VoidCallback? onRecordingComplete;
  final double size;
  final Color? activeColor;
  final Color? inactiveColor;

  const AudioRecorderButton({
    super.key,
    this.onRecordingComplete,
    this.size = 64.0,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorderState = ref.watch(audioRecorderProvider);
    final recorderNotifier = ref.read(audioRecorderProvider.notifier);

    // Show error snack bar if any
    if (recorderState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recorderState.errorMessage!),
            backgroundColor: Colors.red,
          ),
        );
        recorderNotifier.clearError();
      });
    }

    return GestureDetector(
      onTap: () async {
        if (!recorderState.isRecording) {
          await recorderNotifier.startRecording();
        } else {
          await recorderNotifier.stopRecording();
          onRecordingComplete?.call();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: recorderState.isRecording
              ? (activeColor ?? Colors.red.shade50)
              : (inactiveColor ?? Colors.blue.shade50),
          border: Border.all(
            color: recorderState.isRecording
                ? Colors.red.shade300
                : Colors.blue.shade300,
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: recorderState.isRecording
                  ? Colors.red.withOpacity(0.3)
                  : Colors.blue.withOpacity(0.3),
              blurRadius: 12,
              spreadRadius: recorderState.isRecording ? 4 : 2,
            ),
          ],
        ),
        child: recorderState.isRecording
            ? _buildRecordingVisualizer()
            : _buildIdleIcon(),
      ),
    );
  }

  Widget _buildRecordingVisualizer() {
    return ClipOval(
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(12),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Background circle
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            // Audio Visualizer
            const AudioVisualizer(
              height: 40,
              bars: 16,
              color: Colors.red,
              barWidth: 2,
              spacing: 1,
            ),
            // Stop icon overlay
            Positioned.fill(
              child: Center(
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdleIcon() {
    return Icon(
      Icons.mic,
      size: size * 0.4,
      color: Colors.blue.shade700,
    );
  }
}

/// Compact version cho các use case khác
class CompactAudioRecorderButton extends ConsumerWidget {
  final VoidCallback? onRecordingComplete;

  const CompactAudioRecorderButton({
    super.key,
    this.onRecordingComplete,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recorderState = ref.watch(audioRecorderProvider);
    final recorderNotifier = ref.read(audioRecorderProvider.notifier);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mic button
        GestureDetector(
          onTap: () async {
            if (!recorderState.isRecording) {
              await recorderNotifier.startRecording();
            } else {
              await recorderNotifier.stopRecording();
              onRecordingComplete?.call();
            }
          },
          child: Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: recorderState.isRecording
                  ? Colors.red.shade100
                  : Colors.blue.shade100,
              border: Border.all(
                color: recorderState.isRecording
                    ? Colors.red
                    : Colors.blue,
                width: 2,
              ),
            ),
            child: Icon(
              recorderState.isRecording ? Icons.stop : Icons.mic,
              color: recorderState.isRecording ? Colors.red : Colors.blue,
              size: 24,
            ),
          ),
        ),
        
        if (recorderState.isRecording) ...[
          const SizedBox(width: 12),
          // Inline visualizer
          const AudioVisualizer(
            height: 30,
            bars: 12,
            color: Colors.red,
            barWidth: 2,
            spacing: 1,
          ),
        ],
      ],
    );
  }
}
