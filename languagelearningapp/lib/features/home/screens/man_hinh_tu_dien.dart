import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as provider;
import '../../../core/design_system.dart';

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
                        Text(
                          'Từ điển',
                          style: AppTextStyles.headlineLarge.copyWith(
                            color: AppColors.textOnDark,
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
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
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
          icon: const Icon(Icons.search, color: AppColors.primary),
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
                  icon: const Icon(Icons.send, color: AppColors.primary),
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
            Text(
              'Tra cứu từ mới',
              style: AppTextStyles.titleMedium.copyWith(
                color: AppColors.audioRecording,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Nhập từ tiếng Anh và nhấn enter để lấy nghĩa, ví dụ và chủ đề. Kết quả sẽ được lưu vào tài khoản của bạn.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
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
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.15)),
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
                            style: AppTextStyles.headlineMedium.copyWith(
                              color: AppColors.audioRecording,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        IconButton(
                          icon: const Icon(
                            Icons.volume_up,
                            color: AppColors.primary,
                            size: AppSpacing.iconMedium,
                          ),
                          onPressed: () => _ttsService.speak(word.word),
                          tooltip: 'Phát âm',
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppSpacing.radiusSmall),
                      ),
                      child: Text(
                        word.type,
                        style: AppTextStyles.labelSmall.copyWith(
                          color: AppColors.primary,
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
                  backgroundColor: AppColors.backgroundTertiary,
                  labelStyle: TextStyle(color: AppColors.audioRecording),
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
            const SizedBox(height: AppSpacing.lg),
            Row(
              children: [
                Text(
                  'Ví dụ',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: AppColors.audioRecording,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  icon: const Icon(
                    Icons.volume_up,
                    color: AppColors.primary,
                    size: AppSpacing.iconSmall,
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
        Text(
          'Tra cứu gần đây',
          style: AppTextStyles.titleMedium.copyWith(
            color: AppColors.audioRecording,
          ),
        ),
        const SizedBox(height: 12),
        ...hienThiLichSu.map((word) => _xayDungMucLichSu(word, tuDienProvider)),
      ],
    );
  }

  Widget _xayDungMucLichSu(WordModel word, WordLookupProvider providerState) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.backgroundSecondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        border: Border.all(color: AppColors.border.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, color: AppColors.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  word.word,
                  style: AppTextStyles.labelLarge,
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  word.meaning,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.volume_up, color: AppColors.primary),
            onPressed: () => _ttsService.speak(word.word),
            tooltip: 'Phát âm',
          ),
          IconButton(
            icon: const Icon(Icons.north_east, color: AppColors.primary),
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
