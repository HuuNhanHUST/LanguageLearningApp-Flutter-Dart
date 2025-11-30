import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:http/http.dart' as http;
import 'text_analysis_screen.dart';
import '../core/constants/api_constants.dart';
import '../features/auth/services/auth_service.dart';

class TextScanScreen extends StatefulWidget {
  const TextScanScreen({super.key});

  @override
  State<TextScanScreen> createState() => _TextScanScreenState();
}

class _TextScanScreenState extends State<TextScanScreen> {
  final List<File> _scannedImages = [];
  String _recognizedText = '';
  String _translatedText = '';
  bool _isProcessing = false;
  bool _isTranslating = false;
  final ImagePicker _picker = ImagePicker();
  final TextRecognizer _textRecognizer = TextRecognizer();

  @override
  void dispose() {
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 100,
      );

      if (image != null) {
        final croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
              toolbarTitle: 'Chọn vùng cần quét',
              toolbarColor: const Color(0xFF6366F1),
              toolbarWidgetColor: Colors.white,
              initAspectRatio: CropAspectRatioPreset.original,
              lockAspectRatio: false,
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
            IOSUiSettings(
              title: 'Chọn vùng cần quét',
              aspectRatioPresets: [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9,
              ],
            ),
          ],
        );

        if (croppedFile != null) {
          setState(() {
            _scannedImages.add(File(croppedFile.path));
            _isProcessing = true;
          });

          await _recognizeAllImages();
        }
      }
    } catch (e) {
      _showError('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _recognizeAllImages() async {
    if (_scannedImages.isEmpty) return;

    try {
      String combinedText = '';

      for (int i = 0; i < _scannedImages.length; i++) {
        final inputImage = InputImage.fromFile(_scannedImages[i]);
        final RecognizedText recognizedText = await _textRecognizer
            .processImage(inputImage);

        String text = '';
        for (TextBlock block in recognizedText.blocks) {
          for (TextLine line in block.lines) {
            text += '${line.text}\n';
          }
        }

        combinedText += text;
        if (i < _scannedImages.length - 1) {
          combinedText += '\n--- Trang ${i + 2} ---\n';
        }
      }

      setState(() {
        _recognizedText = combinedText.trim();
        _isProcessing = false;
      });

      if (_recognizedText.isEmpty) {
        _showError('Không tìm thấy văn bản trong ảnh');
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Lỗi khi nhận dạng văn bản: $e');
    }
  }

  Future<void> _translateText() async {
    if (_recognizedText.isEmpty) return;

    setState(() {
      _isTranslating = true;
    });

    try {
      final authService = AuthService();
      final token = await authService.getAccessToken();

      if (token == null) {
        throw Exception('Vui lòng đăng nhập để sử dụng tính năng dịch');
      }

      // Giới hạn độ dài text để dịch nhanh hơn
      String textToTranslate = _recognizedText;
      bool isTruncated = false;

      if (_recognizedText.length > 1000) {
        textToTranslate = _recognizedText.substring(0, 1000);
        isTruncated = true;
      }

      final response = await http
          .post(
            Uri.parse(ApiConstants.translate),
            headers: ApiConstants.getHeaders(token: token),
            body: json.encode({'text': textToTranslate}),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception('Timeout: Dịch quá lâu, vui lòng thử lại');
            },
          );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          setState(() {
            _translatedText = data['data']['translatedText'];
            if (isTruncated) {
              _translatedText +=
                  '\n\n[📝 Chỉ dịch 1000 ký tự đầu tiên để tăng tốc độ]';
            }
            _isTranslating = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã dịch văn bản'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          throw Exception(data['message'] ?? 'Không thể dịch văn bản');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        _isTranslating = false;
      });
      _showError('Lỗi khi dịch: $e');
    }
  }

  void _clearAllImages() {
    setState(() {
      _scannedImages.clear();
      _recognizedText = '';
      _translatedText = '';
      _isProcessing = false;
    });
  }

  void _removeImage(int index) {
    setState(() {
      _scannedImages.removeAt(index);
    });
    if (_scannedImages.isNotEmpty) {
      _recognizeAllImages();
    } else {
      setState(() {
        _recognizedText = '';
        _translatedText = '';
      });
    }
  }

  void _copyToClipboard() {
    if (_recognizedText.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: _recognizedText));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã sao chép văn bản'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _scannedImages.isEmpty
              ? 'Quét văn bản'
              : 'Quét văn bản (${_scannedImages.length} ảnh)',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        actions: [
          if (_scannedImages.isNotEmpty)
            IconButton(
              onPressed: _clearAllImages,
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Xóa tất cả',
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_scannedImages.isNotEmpty) ...[
                  SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _scannedImages.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 120,
                          margin: const EdgeInsets.only(right: 10),
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: Image.file(
                                  _scannedImages[index],
                                  fit: BoxFit.cover,
                                  width: 120,
                                  height: 150,
                                ),
                              ),
                              Positioned(
                                top: 5,
                                right: 5,
                                child: CircleAvatar(
                                  radius: 15,
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    padding: EdgeInsets.zero,
                                    icon: const Icon(
                                      Icons.close,
                                      size: 16,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => _removeImage(index),
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 5,
                                left: 5,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    'Ảnh ${index + 1}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ] else ...[
                  Container(
                    height: 300,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey[400]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.image_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có ảnh nào được chọn',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Chọn ảnh hoặc chụp ảnh để bắt đầu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _pickImage(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt, size: 24),
                        label: const Text(
                          'Chụp ảnh',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isProcessing
                            ? null
                            : () => _pickImage(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library, size: 24),
                        label: const Text(
                          'Thư viện',
                          style: TextStyle(fontSize: 16),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple[600],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (_isProcessing)
                  const Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Đang nhận dạng văn bản...',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                if (_recognizedText.isNotEmpty && !_isProcessing) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF6366F1),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.1),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Văn bản nhận dạng:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF6366F1),
                              ),
                            ),
                            IconButton(
                              onPressed: _copyToClipboard,
                              icon: const Icon(
                                Icons.copy,
                                color: Color(0xFF6366F1),
                              ),
                              tooltip: 'Sao chép',
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _recognizedText,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _copyToClipboard,
                                icon: const Icon(Icons.content_copy),
                                label: const Text('Sao chép'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF6366F1),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _isTranslating
                                    ? null
                                    : _translateText,
                                icon: _isTranslating
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.translate),
                                label: Text(
                                  _isTranslating ? 'Đang dịch...' : 'Dịch',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TextAnalysisScreen(
                                        recognizedText: _recognizedText,
                                        imagePath: _scannedImages.isNotEmpty
                                            ? _scannedImages.first.path
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.analytics),
                                label: const Text('Phân tích'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green[600],
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                if (_translatedText.isNotEmpty && !_isTranslating) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.translate, color: Colors.orange),
                            const SizedBox(width: 8),
                            const Text(
                              'Bản dịch:',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const Divider(),
                        const SizedBox(height: 8),
                        Container(
                          constraints: const BoxConstraints(maxHeight: 200),
                          child: SingleChildScrollView(
                            child: SelectableText(
                              _translatedText,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.5,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                if (_scannedImages.isEmpty && !_isProcessing) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Color(0xFF6366F1),
                          size: 32,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'Hướng dẫn sử dụng:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          '✂️ Crop vùng cần scan: Sau khi chọn ảnh, bạn có thể cắt vùng cần quét\n\n'
                          '📸 Scan nhiều trang: Chụp/chọn nhiều ảnh để ghép văn bản dài\n\n'
                          '🌐 Dịch văn bản: Nhấn nút "Dịch" để dịch sang tiếng Việt\n\n'
                          '📊 Phân tích: Xem thống kê từ vựng và tạo flashcards',
                          style: TextStyle(fontSize: 14, height: 1.6),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
