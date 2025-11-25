import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;

import '../../words/models/word_model.dart';
import '../../words/providers/word_lookup_provider.dart';
import '../../words/services/text_to_speech_service.dart';

/// Màn hình Từ điển
/// Cho phép tìm kiếm và học từ vựng được trả về từ backend
class ManHinhTuDien extends StatelessWidget {
  const ManHinhTuDien({super.key});

  @override
  Widget build(BuildContext context) {
    return provider.ChangeNotifierProvider(
      create: (_) => WordLookupProvider(),
      child: const _ManHinhTuDienView(),
    );
  }
}

class _ManHinhTuDienView extends StatefulWidget {
  const _ManHinhTuDienView();

  @override
  State<_ManHinhTuDienView> createState() => _ManHinhTuDienViewState();
}

class _ManHinhTuDienViewState extends State<_ManHinhTuDienView> {
  final TextEditingController _boTimKiem = TextEditingController();
  final TextToSpeechService _ttsService = TextToSpeechService();

  @override
  void dispose() {
    _boTimKiem.dispose();
    _ttsService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return provider.Consumer<WordLookupProvider>(
      builder: (context, tuDienProvider, _) {
        return Scaffold(
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF2D1B69), Color(0xFF1A0F3E)],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Từ điển',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _xayDungThanhTimKiem(tuDienProvider),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(30),
                          topRight: Radius.circular(30),
                        ),
                      ),
                      child: _xayDungNoiDung(tuDienProvider),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _xayDungThanhTimKiem(WordLookupProvider tuDienProvider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: _boTimKiem,
        textInputAction: TextInputAction.search,
        onSubmitted: (_) => _thucHienTraCuu(tuDienProvider),
        decoration: InputDecoration(
          hintText: 'Nhập từ tiếng Anh cần tra...',
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFF6C63FF)),
          suffixIcon: tuDienProvider.isLoading
              ? const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  icon: const Icon(Icons.send, color: Color(0xFF6C63FF)),
                  onPressed: () => _thucHienTraCuu(tuDienProvider),
                ),
        ),
      ),
    );
  }

  Widget _xayDungNoiDung(WordLookupProvider tuDienProvider) {
    if (tuDienProvider.isLoading && tuDienProvider.currentWord == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (tuDienProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            tuDienProvider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.red,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (tuDienProvider.currentWord != null) ...[
            _xayDungTheTuVung(tuDienProvider.currentWord!),
            const SizedBox(height: 25),
          ] else ...[
            const Text(
              'Tra cứu từ mới',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D1B69),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Nhập từ tiếng Anh và nhấn enter để lấy nghĩa, ví dụ và chủ đề. Kết quả sẽ được lưu vào tài khoản của bạn.',
              style: TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 25),
          ],
          if (tuDienProvider.history.isNotEmpty) _xayDungLichSu(tuDienProvider),
        ],
      ),
    );
  }

  Widget _xayDungTheTuVung(WordModel word) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: const Color(0xFF6C63FF).withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            word.word,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D1B69),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: Color(0xFF6C63FF),
                            size: 28,
                          ),
                          onPressed: () => _ttsService.speak(word.word),
                          tooltip: 'Phát âm',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        word.type,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF6C63FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (word.topic != null && word.topic!.isNotEmpty)
                Chip(
                  label: Text(word.topic!),
                  backgroundColor: const Color(0xFFEFF0FF),
                  labelStyle: const TextStyle(color: Color(0xFF2D1B69)),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            word.meaning,
            style: const TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.black87,
            ),
          ),
          if (word.example != null && word.example!.isNotEmpty) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                const Text(
                  'Ví dụ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2D1B69),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: Color(0xFF6C63FF),
                    size: 20,
                  ),
                  onPressed: () => _ttsService.speak(word.example!),
                  tooltip: 'Phát âm ví dụ',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              word.example!,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.black87,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _xayDungLichSu(WordLookupProvider tuDienProvider) {
    final lichSu = tuDienProvider.history;
    final hienThiLichSu = tuDienProvider.currentWord != null
        ? lichSu.skip(1).toList()
        : lichSu;

    if (hienThiLichSu.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tra cứu gần đây',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D1B69),
          ),
        ),
        const SizedBox(height: 12),
        ...hienThiLichSu.map((word) => _xayDungMucLichSu(word, tuDienProvider)),
      ],
    );
  }

  Widget _xayDungMucLichSu(WordModel word, WordLookupProvider providerState) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: Color(0xFF6C63FF)),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  word.meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 14, color: Colors.black54),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: Color(0xFF6C63FF)),
            onPressed: () => _ttsService.speak(word.word),
            tooltip: 'Phát âm',
          ),
          IconButton(
            icon: const Icon(Icons.north_east, color: Color(0xFF6C63FF)),
            onPressed: () {
              _boTimKiem.text = word.word;
              _thucHienTraCuu(providerState);
            },
          ),
        ],
      ),
    );
  }

  void _thucHienTraCuu(WordLookupProvider tuDienProvider) {
    if (tuDienProvider.isLoading) {
      return;
    }

    FocusScope.of(context).unfocus();
    tuDienProvider.lookupWord(_boTimKiem.text);
  }
}
