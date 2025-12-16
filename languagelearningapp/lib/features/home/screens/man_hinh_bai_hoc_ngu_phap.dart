import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../learning/providers/learning_provider.dart';
import '../../learning/widgets/level_up_dialog.dart';
import '../../lessons/models/grammar_question_model.dart';
import '../../lessons/services/grammar_question_service.dart';

class ManHinhBaiHocNguPhap extends ConsumerStatefulWidget {
  final String tenBaiHoc;
  final String chuDe;

  const ManHinhBaiHocNguPhap({
    super.key,
    required this.tenBaiHoc,
    required this.chuDe,
  });

  @override
  ConsumerState<ManHinhBaiHocNguPhap> createState() => _ManHinhBaiHocNguPhapState();
}

class _ManHinhBaiHocNguPhapState extends ConsumerState<ManHinhBaiHocNguPhap> {
  final GrammarQuestionService _grammarService = GrammarQuestionService();

  bool _isLoadingWords = true;
  bool _isMarkingWord = false;
  String? _error;

  List<GrammarQuestionModel> _questions = [];
  int _currentQuestionIndex = 0;
  int? _selectedOptionIndex;
  bool _answered = false;
  bool _isAnswerCorrect = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _taiDanhSachTu();
      }
    });
  }

  Future<void> _taiDanhSachTu() async {
    setState(() {
      _isLoadingWords = true;
      _error = null;
    });

    try {
      await ref.read(learningProvider.notifier).loadProgress();
      await Future.delayed(const Duration(milliseconds: 100));
      final learningState = ref.read(learningProvider);

      // Kiểm tra daily limit grammar
      if (!learningState.canLearnGrammar) {
        if (!mounted) return;
        setState(() {
          _isLoadingWords = false;
          _error = '🎉 Đã hoàn thành ${learningState.grammarDailyLimit} câu ngữ pháp hôm nay! Quay lại vào ngày mai nhé!';
        });
        return;
      }

      // Map level to difficulty
      final userLevel = learningState.level;
      final difficulty = _getDifficultyForLevel(userLevel);
      final remainingInLimit = learningState.grammarRemaining;
      
      print('🎯 Grammar lesson - Level: $userLevel, Difficulty: $difficulty, Remaining: $remainingInLimit/${learningState.grammarDailyLimit}');

      // LUÔN LUÔN lấy 10 câu hỏi để hiển thị đầy đủ
      final questions = await _grammarService.fetchRandomQuestions(
        difficulty: difficulty,
        limit: 10,
      );
      
      if (!mounted) return;

      // Chỉ cho phép làm số câu = remainingInLimit
      final allowedQuestions = questions.take(remainingInLimit).toList();
      
      print('📝 Loaded ${questions.length} questions, allowing $remainingInLimit questions');
      
      if (allowedQuestions.isEmpty) {
        setState(() {
          _isLoadingWords = false;
          _error = 'Chưa có câu hỏi ngữ pháp nào cho level của bạn. Hệ thống đang tạo câu hỏi mới!';
        });
        return;
      }

      setState(() {
        _questions = allowedQuestions;  // Chỉ lấy số câu được phép
        _currentQuestionIndex = 0;
        _isLoadingWords = false;
      });

      print('✅ Ready to practice with ${allowedQuestions.length} questions');
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoadingWords = false;
        _error = 'Không thể tải câu hỏi: $e';
      });
    }
  }

  String _getDifficultyForLevel(int level) {
    if (level <= 3) return 'beginner';
    if (level <= 6) return 'intermediate';
    return 'advanced';
  }

  void _chonDapAn(int index) {
    if (_answered) return;
    setState(() {
      _selectedOptionIndex = index;
    });
  }

  void _kiemTraDapAn() {
    if (_selectedOptionIndex == null) {
      _showSnack('Vui lòng chọn đáp án trước nhé!');
      return;
    }

    final question = _currentQuestion;
    final isCorrect = _selectedOptionIndex == question.correctIndex;

    setState(() {
      _answered = true;
      _isAnswerCorrect = isCorrect;
    });

    _showSnack(
      isCorrect ? '🎯 Chính xác!' : '❌ Sai mất rồi, xem lời giải nhé!',
      background: isCorrect ? Colors.green : Colors.red,
    );
  }

  Future<void> _chuyenCauHoiTiepTheo() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedOptionIndex = null;
        _answered = false;
        _isAnswerCorrect = false;
      });
      return;
    }

    await _hoanThanhTuHienTai();
  }

  Future<void> _hoanThanhTuHienTai() async {
    if (_isMarkingWord) return;
    final learningNotifier = ref.read(learningProvider.notifier);

    setState(() => _isMarkingWord = true);

    // Chỉ add XP cho grammar, không đánh dấu từ là đã học
    final result = await learningNotifier.addGrammarXp(
      xpAmount: _isAnswerCorrect ? 120 : 100,
      difficulty: 'medium',
    );

    if (!mounted) return;

    setState(() => _isMarkingWord = false);

    if (result['success'] == true) {
      _showSnack(result['message'] as String? ?? 'Hoàn thành!', background: const Color(0xFF6C63FF));

      // Check grammar limit sau khi submit (state đã update trong addGrammarXp)
      final updatedState = ref.read(learningProvider);
      if (!updatedState.canLearnGrammar) {
        // Đã đạt limit 10 câu/ngày
        setState(() {
          _questions = [];
        });
        _showSnack('🎉 Đã hoàn thành ${updatedState.grammarDailyLimit} câu ngữ pháp hôm nay! Quay lại vào ngày mai nhé!', background: const Color(0xFF4CAF50));
        return;
      }

      if (result['leveledUp'] == true) {
        await Future.delayed(const Duration(milliseconds: 300));
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
    } else {
      _showSnack(result['message']?.toString() ?? 'Không thể cập nhật XP');
    }

    if (!mounted) return;
    
    // Kiểm tra xem còn câu hỏi nào không
    if (_currentQuestionIndex >= _questions.length - 1) {
      // Đã hoàn thành tất cả câu được phép trong ngày
      setState(() {
        _questions = [];
      });
      _showSnack('🎉 Đã hoàn thành ${ref.read(learningProvider).grammarDailyLimit} câu ngữ pháp hôm nay! Quay lại vào ngày mai nhé!', 
        background: const Color(0xFF4CAF50));
      return;
    }

    // Chuyển sang câu tiếp theo
    setState(() {
      _currentQuestionIndex++;
      _selectedOptionIndex = null;
      _answered = false;
      _isAnswerCorrect = false;
    });
  }

  GrammarQuestionModel get _currentQuestion => _questions[_currentQuestionIndex];

  void _showSnack(String message, {Color background = Colors.black87}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tenBaiHoc),
        backgroundColor: const Color(0xFF1F1147),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFF120836),
      body: _isLoadingWords
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : !_coTheHoc(learningState)
              ? _xayDungTrangThaiTrong(learningState)
              : _questions.isEmpty
                  ? _xayDungTrangThaiKhongCoCauHoi()
                  : SafeArea(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                            child: _xayDungNoiDungBaiHoc(learningState),
                          ),
                        ),
    );
  }

  bool _coTheHoc(LearningState state) {
    return _questions.isNotEmpty && state.canLearnGrammar;
  }

  Widget _xayDungTrangThaiTrong(LearningState state) {
    final message = state.canLearnMore
        ? 'Không tìm thấy thêm từ nào cho bài học này.'
        : '🎉 Bạn đã hoàn thành mục tiêu hôm nay, quay lại vào ngày mai nhé!';

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events, color: Colors.amber, size: 64),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.redAccent),
              ),
            ],
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _taiDanhSachTu,
              icon: const Icon(Icons.refresh),
              label: const Text('Tải lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungTrangThaiKhongCoCauHoi() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.pending_actions, color: Colors.white70, size: 64),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Chưa có câu hỏi cho level của bạn!',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _taiDanhSachTu,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _xayDungNoiDungBaiHoc(LearningState state) {
    final question = _currentQuestion;

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          _xayDungTheCauHoi(question),
          const SizedBox(height: 24),
          _xayDungDanhSachLuaChon(question),
          const SizedBox(height: 24),
          _xayDungNutHanhDong(),
        ],
      ),
    );
  }

  Widget _xayDungTheCauHoi(GrammarQuestionModel question) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.deepPurpleAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purpleAccent.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Câu hỏi ${_currentQuestionIndex + 1}/${_questions.length}',
            style: const TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 10),
          Text(
            question.question,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'Kỹ năng: ${question.targetSkill} • Độ khó: ${question.difficulty}',
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ),
          if (_answered)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                question.explanation,
                style: TextStyle(
                  color: _isAnswerCorrect ? Colors.greenAccent : Colors.orangeAccent,
                  fontSize: 14,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _xayDungDanhSachLuaChon(GrammarQuestionModel question) {
    return Column(
      children: List.generate(question.options.length, (index) {
        final optionText = _lamSachLuaChon(question.options[index]);
        final isSelected = _selectedOptionIndex == index;
        final isCorrect = index == question.correctIndex;

        Color background = Colors.white.withOpacity(0.05);
        Color border = Colors.white24;
        Color textColor = Colors.white;

        if (_answered) {
          if (isCorrect) {
            background = Colors.green.withOpacity(0.2);
            border = Colors.greenAccent;
            textColor = Colors.greenAccent;
          } else if (isSelected && !isCorrect) {
            background = Colors.red.withOpacity(0.2);
            border = Colors.redAccent;
            textColor = Colors.redAccent;
          }
        } else if (isSelected) {
          background = Colors.white.withOpacity(0.2);
          border = Colors.cyanAccent;
        }

        return GestureDetector(
          onTap: () => _chonDapAn(index),
          child: Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: border),
            ),
            child: Text(
              optionText,
              style: TextStyle(color: textColor, fontSize: 16),
            ),
          ),
        );
      }),
    );
  }

  Widget _xayDungNutHanhDong() {
    final isSubmitState = !_answered;
    final label = isSubmitState
        ? 'Kiểm tra đáp án'
        : (_currentQuestionIndex < _questions.length - 1 ? 'Câu tiếp theo' : 'Hoàn thành từ này');

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isMarkingWord
            ? null
            : (isSubmitState ? _kiemTraDapAn : _chuyenCauHoiTiepTheo),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        child: _isMarkingWord
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }

  String _lamSachLuaChon(String option) {
    final trimmed = option.trim();
    final regex = RegExp(r'^[A-Z]\)\s*');
    return trimmed.replaceFirst(regex, '');
  }
}
