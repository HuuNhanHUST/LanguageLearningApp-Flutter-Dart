import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:languagelearningapp/services/audio_service.dart';

/// State class for Audio Recorder
class AudioRecorderState {
  final bool isRecording;
  final String? audioPath;
  final String? errorMessage;

  const AudioRecorderState({
    this.isRecording = false,
    this.audioPath,
    this.errorMessage,
  });

  AudioRecorderState copyWith({
    bool? isRecording,
    String? audioPath,
    String? errorMessage,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      audioPath: audioPath ?? this.audioPath,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Audio Recorder Notifier (delegates to AudioService)
class AudioRecorderNotifier extends StateNotifier<AudioRecorderState> {
  final AudioService _audio = AudioService.instance;

  AudioRecorderNotifier() : super(const AudioRecorderState()) {
    _audio.initRecorder();
  }

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      await _audio.startRecording();
      state = state.copyWith(isRecording: true, audioPath: null, errorMessage: null);
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to start recording: $e');
    }
  }

  /// Stop recording audio
  Future<void> stopRecording() async {
    try {
      final path = await _audio.stopRecording();
      state = state.copyWith(isRecording: false, audioPath: path, errorMessage: null);
    } catch (e) {
      state = state.copyWith(isRecording: false, errorMessage: 'Failed to stop recording: $e');
    }
  }

  /// Toggle recording (start/stop)
  Future<void> toggleRecording() async {
    if (state.isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  /// Clear error message
  void clearError() {
    state = state.copyWith(errorMessage: null);
  }

  /// Clear audio path (for re-recording)
  void clearAudioPath() {
    state = const AudioRecorderState(
      isRecording: false,
      audioPath: null,
      errorMessage: null,
    );
  }

  /// Delete audio file and clear state
  Future<void> deleteAudioFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      clearAudioPath();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete audio file: $e');
    }
  }

  @override
  void dispose() {
    // Do not dispose the singleton service here to allow reuse across screens.
    super.dispose();
  }
}

/// Provider for Audio Recorder
final audioRecorderProvider =
    StateNotifierProvider<AudioRecorderNotifier, AudioRecorderState>(
  (ref) => AudioRecorderNotifier(),
);

/// Stream provider for realtime amplitude (0..1) to drive visualizers
final amplitudeStreamProvider = StreamProvider<double>((ref) {
  return AudioService.instance.amplitudeStream;
});
