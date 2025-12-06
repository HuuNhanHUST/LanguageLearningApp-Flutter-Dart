import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:languagelearningapp/services/audio_service.dart';
import 'package:languagelearningapp/services/stt_service.dart';

/// State class for Audio Recorder
class AudioRecorderState {
  final bool isRecording;
  final bool isUploading;
  final String? audioPath;
  final String? transcript;
  final String? errorMessage;

  const AudioRecorderState({
    this.isRecording = false,
    this.isUploading = false,
    this.audioPath,
    this.transcript,
    this.errorMessage,
  });

  AudioRecorderState copyWith({
    bool? isRecording,
    bool? isUploading,
    String? audioPath,
    String? transcript,
    String? errorMessage,
    bool clearAudioPath = false,
    bool clearTranscript = false,
    bool clearError = false,
  }) {
    return AudioRecorderState(
      isRecording: isRecording ?? this.isRecording,
      isUploading: isUploading ?? this.isUploading,
      audioPath: clearAudioPath ? null : (audioPath ?? this.audioPath),
      transcript: clearTranscript ? null : (transcript ?? this.transcript),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

/// Audio Recorder Notifier (delegates to AudioService)
class AudioRecorderNotifier extends StateNotifier<AudioRecorderState> {
  final AudioService _audio = AudioService.instance;
  final SttService _sttService = SttService();

  AudioRecorderNotifier() : super(const AudioRecorderState()) {
    _audio.initRecorder();
  }

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      await _audio.startRecording();
      state = state.copyWith(
        isRecording: true,
        clearAudioPath: true,
        clearTranscript: true,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to start recording: $e');
    }
  }

  /// Stop recording audio
  Future<void> stopRecording() async {
    try {
      final path = await _audio.stopRecording();
      state = state.copyWith(
        isRecording: false,
        audioPath: path,
        clearError: true,
      );
    } catch (e) {
      state = state.copyWith(
        isRecording: false,
        errorMessage: 'Failed to stop recording: $e',
      );
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
    state = state.copyWith(clearError: true);
  }

  /// Clear audio path (for re-recording)
  void clearAudioPath() {
    state = const AudioRecorderState(
      isRecording: false,
      audioPath: null,
      transcript: null,
      errorMessage: null,
    );
  }

  /// Clear transcript without affecting current audio
  void clearTranscript() {
    state = state.copyWith(clearTranscript: true);
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

  /// Upload bản ghi hiện tại lên server STT và nhận transcript
  Future<void> sendForTranscription({String? targetText}) async {
    final path = state.audioPath;
    if (path == null) {
      state = state.copyWith(errorMessage: 'Chưa có bản ghi để gửi');
      return;
    }

    state = state.copyWith(isUploading: true, clearError: true);
    try {
      final transcript = await _sttService.transcribe(
        audioPath: path,
        targetText: targetText,
      );
      state = state.copyWith(isUploading: false, transcript: transcript);
    } catch (e) {
      state = state.copyWith(
        isUploading: false,
        errorMessage: 'Gửi STT thất bại: $e',
      );
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
