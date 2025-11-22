import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_recorder_provider.dart';

/// Audio Recorder Button Widget
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

    // Show error if any
    if (recorderState.errorMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(recorderState.errorMessage!),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        recorderNotifier.clearError();
      });
    }

    // Removed automatic callback to prevent spam notifications
    // Parent widget will handle notification manually

    return GestureDetector(
      onTap: () async {
        await recorderNotifier.toggleRecording();
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
            ? _buildRecordingIcon(context)
            : _buildMicrophoneIcon(context),
      ),
    );
  }

  /// Build microphone icon (not recording)
  Widget _buildMicrophoneIcon(BuildContext context) {
    return Icon(
      Icons.mic,
      size: size * 0.5,
      color: inactiveColor != null
          ? _getContrastColor(inactiveColor!)
          : Colors.blue,
    );
  }

  /// Build stop icon with pulsing animation (recording)
  Widget _buildRecordingIcon(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing circle animation
        _PulsingCircle(size: size, color: activeColor ?? Colors.red),
        // Stop icon
        Icon(
          Icons.stop,
          size: size * 0.4,
          color: activeColor != null
              ? _getContrastColor(activeColor!)
              : Colors.red,
        ),
      ],
    );
  }

  /// Get contrasting color for better visibility
  Color _getContrastColor(Color backgroundColor) {
    final luminance = backgroundColor.computeLuminance();
    return luminance > 0.5 ? Colors.black87 : Colors.white;
  }
}

/// Pulsing Circle Animation Widget
class _PulsingCircle extends StatefulWidget {
  final double size;
  final Color color;

  const _PulsingCircle({required this.size, required this.color});

  @override
  State<_PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<_PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.size * _animation.value,
          height: widget.size * _animation.value,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: widget.color.withOpacity(0.5), width: 2),
          ),
        );
      },
    );
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
