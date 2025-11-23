import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

/// Audio Recorder Notifier
class AudioRecorderNotifier extends StateNotifier<AudioRecorderState> {
  late final FlutterSoundRecorder _recorder;

  AudioRecorderNotifier() : super(const AudioRecorderState()) {
    _recorder = FlutterSoundRecorder();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await _recorder.openRecorder();
  }

  /// Check and request microphone permission
  Future<bool> _requestPermission() async {
    final status = await Permission.microphone.status;

    if (status.isGranted) {
      return true;
    }

    if (status.isDenied) {
      final result = await Permission.microphone.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      state = state.copyWith(
        errorMessage:
            'Microphone permission is permanently denied. Please enable it in settings.',
      );
      return false;
    }

    return false;
  }

  /// Start recording audio
  Future<void> startRecording() async {
    try {
      // Check permission
      final hasPermission = await _requestPermission();
      if (!hasPermission) {
        print('❌ Microphone permission denied');
        return;
      }

      // Check if already recording
      if (_recorder.isRecording) {
        print('⚠️ Already recording');
        return;
      }

      // Get temporary directory
      final directory = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final filePath = '${directory.path}/audio_$timestamp.aac';

      // Start recording
      await _recorder.startRecorder(toFile: filePath, codec: Codec.aacADTS);

      state = state.copyWith(
        isRecording: true,
        audioPath: null,
        errorMessage: null,
      );

      print('🎤 Recording started: $filePath');
    } catch (e) {
      print('❌ Error starting recording: $e');
      state = state.copyWith(errorMessage: 'Failed to start recording: $e');
    }
  }

  /// Stop recording audio
  Future<void> stopRecording() async {
    try {
      // Check if recording
      if (!_recorder.isRecording) {
        print('⚠️ Not recording');
        return;
      }

      // Stop recording and get the path
      final path = await _recorder.stopRecorder();

      if (path != null) {
        final file = File(path);
        final exists = await file.exists();

        if (exists) {
          final fileSize = await file.length();
          print('✅ Recording stopped');
          print('📁 File path: $path');
          print('📊 File size: ${fileSize / 1024} KB');

          state = state.copyWith(
            isRecording: false,
            audioPath: path,
            errorMessage: null,
          );
        } else {
          print('❌ Recording file does not exist');
          state = state.copyWith(
            isRecording: false,
            errorMessage: 'Recording file was not created',
          );
        }
      } else {
        print('❌ Recording path is null');
        state = state.copyWith(
          isRecording: false,
          errorMessage: 'Failed to save recording',
        );
      }
    } catch (e) {
      print('❌ Error stopping recording: $e');
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
    state = state.copyWith(errorMessage: null);
  }

  /// Clear audio path (for re-recording)
  void clearAudioPath() {
    // Reset về trạng thái ban đầu hoàn toàn
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
      // Reset state hoàn toàn
      clearAudioPath();
    } catch (e) {
      state = state.copyWith(errorMessage: 'Failed to delete audio file: $e');
    }
  }

  /// Dispose recorder
  @override
  void dispose() {
    _recorder.closeRecorder();
    super.dispose();
  }
}

/// Provider for Audio Recorder
final audioRecorderProvider =
    StateNotifierProvider<AudioRecorderNotifier, AudioRecorderState>(
      (ref) => AudioRecorderNotifier(),
    );
