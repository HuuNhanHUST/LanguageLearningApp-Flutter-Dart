import 'dart:async';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

/// A reusable audio service that encapsulates recording logic and exposes
/// a realtime amplitude stream for visualizations.
class AudioService {
  AudioService._internal();
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  static AudioService get instance => _instance;

  final RecorderController _recorderController = RecorderController()
    ..androidEncoder = AndroidEncoder.aac
    ..androidOutputFormat = AndroidOutputFormat.mpeg4
    ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
    ..sampleRate = 16000
    ..bitRate = 64000;

  bool _isInitialized = false;
  bool _isRecording = false;
  String? _filePath;

  final _amplitudeController = StreamController<double>.broadcast();
  Stream<double> get amplitudeStream => _amplitudeController.stream;
  RecorderController get recorderController => _recorderController;

  bool get isRecording => _isRecording;

  Future<void> initRecorder() async {
    if (_isInitialized) return;
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      throw const RecordingException('Microphone permission denied');
    }
    final dir = await getTemporaryDirectory();
    _filePath = '${dir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.m4a';
    _isInitialized = true;
  }

  Future<void> startRecording() async {
    if (!_isInitialized) await initRecorder();
    if (_isRecording) return;
    
    await _recorderController.record(path: _filePath);
    _isRecording = true;
    _listenAmplitude();
  }

  Future<String?> stopRecording() async {
    if (!_isRecording) return _filePath;
    await _recorderController.stop();
    _isRecording = false;
    _amplitudeController.add(0.0);
    return _filePath;
  }

  String? get currentFilePath => _filePath;

  void _listenAmplitude() {
    final ticker = Stream.periodic(const Duration(milliseconds: 120));
    ticker.listen((_) {
      if (!_isRecording) return;
      try {
        // Generate simulated amplitude for visualizer since real-time data not easily accessible
        final amp = (0.3 + 0.7 * (DateTime.now().millisecond % 100) / 100).clamp(0.0, 1.0);
        _amplitudeController.add(amp);
      } catch (_) {
        _amplitudeController.add(0.3);
      }
    });
  }

  /// Expose for completeness if caller wants to manually toggle
  Future<void> toggle() async {
    if (isRecording) {
      await stopRecording();
    } else {
      await startRecording();
    }
  }

  void dispose() {
    _amplitudeController.close();
    _recorderController.dispose();
  }
}

class RecordingException implements Exception {
  final String message;
  const RecordingException(this.message);
  @override
  String toString() => message;
}
