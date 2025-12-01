import 'dart:async';

import 'package:google_mlkit_translation/google_mlkit_translation.dart';

class OfflineTranslationException implements Exception {
  OfflineTranslationException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Singleton service quản lý model dịch ngoại tuyến và thực hiện dịch.
class OfflineTranslationService {
  OfflineTranslationService._();

  static final OfflineTranslationService _instance =
      OfflineTranslationService._();

  factory OfflineTranslationService() => _instance;

  final OnDeviceTranslatorModelManager _modelManager =
      OnDeviceTranslatorModelManager();

  OnDeviceTranslator? _translator;
  bool _modelReady = false;
  bool _isDownloading = false;

  /// Kiểm tra model tiếng Việt đã tải chưa.
  Future<bool> isModelDownloaded() {
    return _modelManager.isModelDownloaded(TranslateLanguage.vietnamese.bcpCode);
  }

  /// Đảm bảo model đã sẵn sàng; nếu chưa sẽ tự tải về.
  Future<void> ensureModelDownloaded() async {
    if (_modelReady) {
      return;
    }

    final alreadyDownloaded = await isModelDownloaded();
    if (alreadyDownloaded) {
      _modelReady = true;
      return;
    }

    if (_isDownloading) {
      // Đợi quá trình tải hiện tại hoàn tất.
      while (_isDownloading) {
        await Future.delayed(const Duration(milliseconds: 200));
      }
      if (_modelReady) {
        return;
      }
    }

    _isDownloading = true;
    try {
      await _modelManager.downloadModel(TranslateLanguage.vietnamese.bcpCode);
      _modelReady = true;
    } catch (error) {
      throw OfflineTranslationException(
        'Không thể tải model dịch. Hãy kiểm tra kết nối mạng và thử lại.',
      );
    } finally {
      _isDownloading = false;
    }
  }

  /// Dịch văn bản từ tiếng Anh sang tiếng Việt (offline).
  Future<String> translate(String text) async {
    if (text.trim().isEmpty) {
      return '';
    }

    await ensureModelDownloaded();

    _translator ??= OnDeviceTranslator(
      sourceLanguage: TranslateLanguage.english,
      targetLanguage: TranslateLanguage.vietnamese,
    );

    return _translator!.translateText(text);
  }

  Future<void> dispose() async {
    await _translator?.close();
    _translator = null;
  }
}
