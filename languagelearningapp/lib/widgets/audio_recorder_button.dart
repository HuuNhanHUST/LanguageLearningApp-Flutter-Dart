import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_recorder_provider.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

/// Audio Recorder Button Widget
class AudioRecorderButton extends ConsumerStatefulWidget {
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
  ConsumerState<AudioRecorderButton> createState() => _AudioRecorderButtonState();
}

class _AudioRecorderButtonState extends ConsumerState<AudioRecorderButton> {
  late final RecorderController _recorderController;

  @override
  void initState() {
    super.initState();
    _recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  @override
  void dispose() {
    _recorderController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recorderState = ref.watch(audioRecorderProvider);
    final recorderNotifier = ref.read(audioRecorderProvider.notifier);

    // Show error snack bar if any
    if (recorderState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(recorderState.errorMessage!), backgroundColor: Colors.red),
        );
        recorderNotifier.clearError();
      });
    }

    return GestureDetector(
      onTap: () async {
        if (!recorderState.isRecording) {
          await recorderNotifier.startRecording();
          await _recorderController.record();
        } else {
          await recorderNotifier.stopRecording();
          await _recorderController.pause();
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: widget.size,
        height: widget.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: recorderState.isRecording
              ? (widget.activeColor ?? Colors.red.shade50)
              : (widget.inactiveColor ?? Colors.blue.shade50),
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
            ? ClipRRect(
                borderRadius: BorderRadius.circular(widget.size),
                child: AudioWaveforms(
                  recorderController: _recorderController,
                  size: Size(widget.size, widget.size * 0.6),
                  waveStyle: const WaveStyle(
                    waveColor: Colors.red,
                    extendWaveform: true,
                    showMiddleLine: false,
                    waveCap: StrokeCap.round,
                  ),
                  padding: const EdgeInsets.all(10),
                ),
              )
            : Icon(
                Icons.mic,
                size: widget.size * 0.5,
                color: widget.inactiveColor != null
                    ? _getContrastColor(widget.inactiveColor!)
                    : Colors.blue,
              ),
      ),
    );
  }

  /// Get contrasting color for better visibility
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Compact Audio Recorder Button (smaller variant)
class CompactAudioRecorderButton extends ConsumerWidget {
  final VoidCallback? onRecordingComplete;

  const CompactAudioRecorderButton({super.key, this.onRecordingComplete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AudioRecorderButton(
      size: 48.0,
      onRecordingComplete: onRecordingComplete,
    );
  }
}
