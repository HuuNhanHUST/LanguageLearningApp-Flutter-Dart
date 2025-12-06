import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_sound/flutter_sound.dart';
import '../../../providers/audio_recorder_provider.dart';
import '../../../widgets/audio_recorder_button.dart';
import '../../../screens/audio_files_screen.dart';
import '../../words/models/word_model.dart';
import '../../words/models/pronunciation_result_model.dart';
import '../../words/services/pronunciation_service.dart';
import '../../words/services/text_to_speech_service.dart';
import '../../words/widgets/pronunciation_result_widget.dart';
import '../../learning/providers/learning_provider.dart';
import '../../learning/widgets/level_up_dialog.dart';

/// Màn hình Bài học Phát âm
/// Cho phép học và thực hành phát âm với ghi âm
class ManHinhBaiHocPhatAm extends ConsumerStatefulWidget {
  final String tenBaiHoc;
  final String chuDe;

  const ManHinhBaiHocPhatAm({
    super.key,
    required this.tenBaiHoc,
    required this.chuDe,
  });

  @override
  ConsumerState<ManHinhBaiHocPhatAm> createState() =>
      _ManHinhBaiHocPhatAmState();
}

class _ManHinhBaiHocPhatAmState extends ConsumerState<ManHinhBaiHocPhatAm> {
  int _buocHienTai = 0;
  late FlutterSoundPlayer _player;
  bool _isPlaying = false;
  String? _previousAudioPath;

  // Dữ liệu từ database
  List<WordModel> _cacBaiTap = [];
  bool _isLoadingWords = true;
  final PronunciationService _pronunciationService = PronunciationService();
  final TextToSpeechService _ttsService = TextToSpeechService();

  // Biến lưu kết quả chấm điểm
  PronunciationResultModel? _pronunciationResult;
  bool _isScoring = false; // Đang chấm điểm

  @override
  void initState() {
    super.initState();
    _player = FlutterSoundPlayer();
    _khoiTaoPlayer();
    _taiDanhSachTu();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final audioState = ref.read(audioRecorderProvider);
      if (audioState.audioPath != null) {
        _previousAudioPath = audioState.audioPath;
      } else {
        _previousAudioPath = null;
      }
    });
  }

  /// Tải danh sách từ vựng từ database
  Future<void> _taiDanhSachTu() async {
    try {
      // Load learned words first - wrapped in Future to avoid provider modification during build
      await Future.microtask(() async {
        await ref.read(learningProvider.notifier).loadProgress();
      });
      final learningState = ref.read(learningProvider);

      // Get all words from database
      final allWords = await _pronunciationService.getWordsForPronunciation();

      // Filter out learned words
      final unlearnedWords = allWords
          .where((word) => !learningState.learnedWordIds.contains(word.id))
          .toList();

      // Shuffle again to ensure different words each time
      unlearnedWords.shuffle();

      // Limit to remaining daily words (max 30/day)
      final wordsToShow = unlearnedWords.take(learningState.remaining).toList();

      if (mounted) {
        setState(() {
          _cacBaiTap = wordsToShow;
          _isLoadingWords = false;
        });

        // Show info if no words available
        if (wordsToShow.isEmpty) {
          if (!learningState.canLearnMore) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  '🎉 Bạn đã hoàn thành 30 từ hôm nay! Quay lại vào ngày mai nhé!',
                ),
                backgroundColor: Colors.orange,
                duration: Duration(seconds: 3),
              ),
            );
          } else if (unlearnedWords.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('🎓 Bạn đã học hết tất cả từ vựng!'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWords = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải từ vựng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _khoiTaoPlayer() async {
    await _player.openPlayer();
  }

  @override
  void dispose() {
    _player.closePlayer();
    _ttsService.dispose();
    super.dispose();
  }

  /// Xóa file ghi âm (như trong audio_files_screen.dart)
  Future<void> _xoaFileGhiAm(String audioPath) async {
    // Kiểm tra file có tồn tại không
    final file = File(audioPath);
    if (!await file.exists()) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ File ghi âm không tồn tại'),
            backgroundColor: Colors.red,
          ),
        );
        // Xóa audioPath khỏi state
        ref.read(audioRecorderProvider.notifier).clearAudioPath();
        setState(() => _previousAudioPath = null);
      }
      return;
    }

    // Hiển thị dialog xác nhận
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 10),
            Text('Xác nhận xóa'),
          ],
        ),
        content: const Text(
          'Bạn có chắc muốn xóa file ghi âm này?',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    // Nếu xác nhận xóa
    if (result == true) {
      try {
        // Dừng phát nếu đang phát
        if (_isPlaying) {
          await _player.stopPlayer();
          setState(() => _isPlaying = false);
        }

        // XÓA FILE VÀ RESET STATE qua Provider (method mới)
        await ref
            .read(audioRecorderProvider.notifier)
            .deleteAudioFile(audioPath);

        // Reset local state
        setState(() {
          _previousAudioPath = null;
        });

        // Hiển thị thông báo thành công
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã xóa file ghi âm thành công'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        // Lỗi exception
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('❌ Lỗi: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// Phát audio đã ghi
  Future<void> _phatAudioDaGhi(String audioPath) async {
    try {
      // Kiểm tra file có tồn tại không
      final file = File(audioPath);
      if (!await file.exists()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('❌ File ghi âm không tồn tại'),
              backgroundColor: Colors.red,
            ),
          );
          // Xóa audioPath khỏi state
          ref.read(audioRecorderProvider.notifier).clearAudioPath();
          setState(() => _previousAudioPath = null);
        }
        return;
      }

      if (_isPlaying) {
        await _player.stopPlayer();
        setState(() => _isPlaying = false);
      } else {
        await _player.startPlayer(
          fromURI: audioPath,
          codec: Codec.aacADTS,
          whenFinished: () {
            setState(() => _isPlaying = false);
          },
        );
        setState(() => _isPlaying = true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi phát audio: $e')));
      }
    }
  }

  /// Chuyển sang bài tập tiếp theo
  Future<void> _chuyenBaiTapTiepTheo() async {
    // Mark word learned and earn XP
    if (_buocHienTai < _cacBaiTap.length) {
      final currentWord = _cacBaiTap[_buocHienTai];
      final result = await ref
          .read(learningProvider.notifier)
          .markWordLearned(currentWord.id);

      if (result['success'] == true && mounted) {
        // Show snackbar for XP gained
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    result['message'] as String,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF6C63FF),
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Show level up dialog if leveled up
        if (result['leveledUp'] == true) {
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            await showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => LevelUpDialog(
                newLevel: result['newLevel'] as int,
                xpGained: result['xpGained'] as int,
              ),
            );
          }
        }
      }
    }

    if (_buocHienTai < _cacBaiTap.length - 1) {
      // Dừng phát audio nếu đang phát
      if (_isPlaying) {
        _player.stopPlayer();
      }
      // XÓA AUDIO STATE TRƯỚC KHI setState (QUAN TRỌNG!)
      ref.read(audioRecorderProvider.notifier).clearAudioPath();

      // SAU ĐÓ mới setState để chuyển trang
      setState(() {
        _buocHienTai++;
        _isPlaying = false;
        _previousAudioPath = null; // Reset để box xanh biến mất
        _pronunciationResult = null; // Reset kết quả chấm điểm
        _isScoring = false; // Reset trạng thái chấm điểm
      });
    } else {
      // Hoàn thành bài học - chỉ pop về
      _hoanThanhBaiHoc();
    }
  }

  /// Chấm điểm phát âm khi có transcript từ STT
  Future<void> _chamDiemPhatAm({
    required String target,
    required String transcript,
  }) async {
    setState(() {
      _isScoring = true;
      _pronunciationResult = null;
    });

    try {
      final result = await _pronunciationService.comparePronunciation(
        target: target,
        transcript: transcript,
      );

      if (mounted) {
        setState(() {
          _pronunciationResult = result;
          _isScoring = false;
        });

        // Hiển thị dialog kết quả
        await _hienThiKetQuaChamDiem(result);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isScoring = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi chấm điểm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Hiển thị dialog kết quả chấm điểm
  Future<void> _hienThiKetQuaChamDiem(PronunciationResultModel result) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: SingleChildScrollView(
          child: PronunciationResultWidget(
            result: result,
            onRetry: () {
              Navigator.pop(context);
              // Reset để thử lại
              ref.read(audioRecorderProvider.notifier).clearAudioPath();
              setState(() {
                _previousAudioPath = null;
                _pronunciationResult = null;
              });
            },
            onNext: () {
              Navigator.pop(context);
              _chuyenBaiTapTiepTheo();
            },
          ),
        ),
      ),
    );
  }

  /// Quay lại bài tập trước
  void _quayLaiBaiTapTruoc() {
    if (_buocHienTai > 0) {
      // Dừng phát audio nếu đang phát
      if (_isPlaying) {
        _player.stopPlayer();
      }
      // XÓA AUDIO STATE TRƯỚC KHI setState (QUAN TRỌNG!)
      ref.read(audioRecorderProvider.notifier).clearAudioPath();

      // SAU ĐÓ mới setState để chuyển trang
      setState(() {
        _buocHienTai--;
        _isPlaying = false;
        _previousAudioPath = null; // Reset về trạng thái ban đầu
        _pronunciationResult = null; // Reset kết quả chấm điểm
        _isScoring = false; // Reset trạng thái chấm điểm
      });
    }
  }

  /// Hoàn thành bài học - quay về màn hình trước
  void _hoanThanhBaiHoc() {
    // Hiển thông báo thành công
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('✅ Chúc mừng! Bạn đã hoàn thành bài học phát âm!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    // Quay về màn hình chính
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final audioState = ref.watch(audioRecorderProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
          ),
        ),
        child: SafeArea(
          child: _isLoadingWords
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.white),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải bài học...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                )
              : _cacBaiTap.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Colors.white,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Không có bài tập nào',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Quay lại'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF4F46E5),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Header với nút back và tiến độ
                    _xayDungHeader(),

                    // Nội dung bài học
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Column(
                          children: [
                            const SizedBox(height: 10),
                            _xayDungTheTu(_cacBaiTap[_buocHienTai]),
                            const SizedBox(height: 20),
                            _xayDungHuongDan(_cacBaiTap[_buocHienTai]),
                            const SizedBox(height: 25),
                            _xayDungKhuVucGhiAm(
                              audioState,
                              _cacBaiTap[_buocHienTai],
                            ),
                            const SizedBox(height: 25),
                            _xayDungCacNutDieuKhien(),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  /// Xây dựng header với nút back, tiến độ và quản lý file
  Widget _xayDungHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          // Nút back
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Colors.white),
          ),
          const SizedBox(width: 10),
          // Tiêu đề
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.tenBaiHoc,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.chuDe,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Nút quản lý file ghi âm
          IconButton(
            onPressed: () async {
              // Navigate đến Quản lý file
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AudioFilesScreen(),
                ),
              );
              // Khi quay lại, đồng bộ state với Provider
              if (mounted) {
                final audioState = ref.read(audioRecorderProvider);
                setState(() {
                  // Nếu Provider đã clear (file đã xóa), reset local state
                  if (audioState.audioPath == null) {
                    _previousAudioPath = null;
                    _isPlaying = false;
                  } else {
                    // Nếu vẫn còn file, sync với Provider
                    _previousAudioPath = audioState.audioPath;
                  }
                });
              }
            },
            icon: const Icon(Icons.folder, color: Colors.white),
            tooltip: 'Quản lý file ghi âm',
          ),
          const SizedBox(width: 10),
          // Tiến độ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${_buocHienTai + 1}/${_cacBaiTap.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng thẻ hiển thị từ - ELSA Style
  Widget _xayDungTheTu(WordModel word) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icon và Topic
          if (word.topic != null && word.topic!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.category,
                    size: 16,
                    color: Color(0xFF6366F1),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    word.topic!,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Từ chính với icon phát âm
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                word.word,
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1F2937),
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(width: 16),
              InkWell(
                onTap: () => _ttsService.speak(word.word),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Loại từ
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _getVietnameseType(word.type),
              style: const TextStyle(
                color: Color(0xFFD97706),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Nghĩa tiếng Việt
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF9FAFB),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.meaning,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF374151),
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          // Ví dụ
          if (word.example != null && word.example!.isNotEmpty) ...[
            const SizedBox(height: 20),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF93C5FD), width: 1),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.format_quote,
                        color: Color(0xFF3B82F6),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Ví dụ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF3B82F6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      InkWell(
                        onTap: () => _ttsService.speak(word.example!),
                        child: const Icon(
                          Icons.volume_up,
                          color: Color(0xFF3B82F6),
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    word.example!,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF1F2937),
                      fontStyle: FontStyle.italic,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getVietnameseType(String type) {
    const typeMap = {
      'noun': 'Danh từ',
      'verb': 'Động từ',
      'adjective': 'Tính từ',
      'adverb': 'Trạng từ',
      'pronoun': 'Đại từ',
      'preposition': 'Giới từ',
      'conjunction': 'Liên từ',
      'interjection': 'Thán từ',
    };
    return typeMap[type.toLowerCase()] ?? type;
  }

  /// Xây dựng hướng dẫn phát âm
  Widget _xayDungHuongDan(WordModel word) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.tips_and_updates, color: Colors.white, size: 22),
              SizedBox(width: 10),
              Text(
                'Hướng dẫn',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            word.example != null && word.example!.isNotEmpty
                ? 'Hãy đọc to và rõ ràng. Tập trung vào cách phát âm từng âm tiết trong câu ví dụ.'
                : 'Hãy đọc to và rõ ràng từ "${word.word}". Chú ý đến phát âm và ngữ điệu.',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng khu vực ghi âm + gửi STT + chấm điểm
  Widget _xayDungKhuVucGhiAm(
    AudioRecorderState audioState,
    WordModel currentWord,
  ) {
    final recorderNotifier = ref.read(audioRecorderProvider.notifier);
    final targetText =
        (currentWord.example != null && currentWord.example!.trim().isNotEmpty)
        ? currentWord.example!
        : currentWord.word;

    // Hiển thông báo CHỈ KHI audioPath thay đổi từ null -> có giá trị
    if (!audioState.isRecording &&
        audioState.audioPath != null &&
        audioState.audioPath != _previousAudioPath) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Đã lưu bản ghi âm của bạn!'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          recorderNotifier.sendForTranscription(targetText: targetText);
          // Cập nhật _previousAudioPath để không hiện lại
          _previousAudioPath = audioState.audioPath;
        }
      });
    }

    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Thực hành phát âm',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 20),
          // Audio Recorder Button (không còn callback tự động)
          AudioRecorderButton(size: 100),
          const SizedBox(height: 20),
          Text(
            audioState.isRecording
                ? 'Đang ghi âm... 🎙️'
                : 'Nhấn để bắt đầu ghi âm',
            style: TextStyle(
              fontSize: 16,
              color: audioState.isRecording ? Colors.red : Colors.grey[600],
              fontWeight: audioState.isRecording
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Câu mẫu cần đọc',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  targetText,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),

          // Hiển thị thông tin file đã ghi
          if (audioState.audioPath != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.green),
              ),
              child: Column(
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text(
                        'Đã ghi âm thành công!',
                        style: TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Nút nghe lại - CÓ CHỨC NĂNG THẬT
                      TextButton.icon(
                        onPressed: () => _phatAudioDaGhi(audioState.audioPath!),
                        icon: Icon(_isPlaying ? Icons.stop : Icons.play_arrow),
                        label: Text(_isPlaying ? 'Dừng' : 'Nghe lại'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.blue,
                        ),
                      ),
                      // Nút XÓA FILE - Xóa file thật khỏi disk
                      TextButton.icon(
                        onPressed: () => _xoaFileGhiAm(audioState.audioPath!),
                        icon: const Icon(Icons.delete),
                        label: const Text('Xóa'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (audioState.isUploading) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E7FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Đang gửi lên máy chủ STT...',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ],
          if (audioState.transcript != null) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF22C55E)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Kết quả STT',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF15803D),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    audioState.transcript!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF065F46),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Nút chấm điểm
                  if (!_isScoring && _pronunciationResult == null)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _chamDiemPhatAm(
                            target: targetText,
                            transcript: audioState.transcript!,
                          );
                        },
                        icon: const Icon(Icons.grade),
                        label: const Text('Chấm điểm phát âm'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6366F1),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  // Đang chấm điểm
                  if (_isScoring)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Đang chấm điểm...',
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  // Hiển thị kết quả ngắn gọn
                  if (_pronunciationResult != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.star, color: Color(0xFFFBBF24)),
                              const SizedBox(width: 8),
                              Text(
                                'Điểm: ${_pronunciationResult!.score.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          TextButton(
                            onPressed: () {
                              _hienThiKetQuaChamDiem(_pronunciationResult!);
                            },
                            child: const Text('Xem chi tiết'),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ],
          // Hiển thị lỗi nếu có
          if (audioState.errorMessage != null) ...[
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      audioState.errorMessage!,
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Xây dựng các nút điều khiển (Quay lại / Tiếp theo)
  Widget _xayDungCacNutDieuKhien() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Nút quay lại
        if (_buocHienTai > 0)
          ElevatedButton.icon(
            onPressed: _quayLaiBaiTapTruoc,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Quay lại'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
          )
        else
          const SizedBox.shrink(),

        // Nút tiếp theo / hoàn thành
        ElevatedButton.icon(
          onPressed: _chuyenBaiTapTiepTheo,
          icon: Icon(
            _buocHienTai < _cacBaiTap.length - 1
                ? Icons.arrow_forward
                : Icons.check,
          ),
          label: Text(
            _buocHienTai < _cacBaiTap.length - 1 ? 'Tiếp theo' : 'Hoàn thành',
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
          ),
        ),
      ],
    );
  }
}
