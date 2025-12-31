import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../learning/providers/learning_provider.dart';

/// Màn hình bài học cho 1 thì ngữ pháp
/// 5 câu hỏi trắc nghiệm + giải thích
class ManHinhBaiHocThi extends ConsumerStatefulWidget {
  final String tenseName; // Present Simple, Past Simple, ...
  final String tenseNameVi; // Hiện tại đơn, Quá khứ đơn, ...

  const ManHinhBaiHocThi({
    super.key,
    required this.tenseName,
    required this.tenseNameVi,
  });

  @override
  ConsumerState<ManHinhBaiHocThi> createState() => _ManHinhBaiHocThiState();
}

class _ManHinhBaiHocThiState extends ConsumerState<ManHinhBaiHocThi> {
  int _currentQuestionIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _showExplanation = false;
  List<Map<String, dynamic>> _questions = [];

  @override
  void initState() {
    super.initState();
    _generateQuestions();
  }

  void _generateQuestions() {
    final tenseData = _getTenseData(widget.tenseName);
    _questions = _generateQuestionsForTense(tenseData);
  }

  Map<String, dynamic> _getTenseData(String tenseName) {
    // Database 12 thì với công thức và ví dụ
    final tenses = {
      'Present Simple': {
        'affirmative': 'S + V(s/es)',
        'negative': 'S + do/does + not + V',
        'question': 'Do/Does + S + V?',
        'usage': 'Diễn tả thói quen, sự thật hiển nhiên, lịch trình',
        'examples': [
          {'sentence': 'She ___ to school every day.', 'answer': 'goes', 'options': ['go', 'goes', 'going', 'gone'], 'explanation': 'Chủ ngữ "She" là ngôi thứ 3 số ít, động từ thêm "es"'},
          {'sentence': 'They ___ football on weekends.', 'answer': 'play', 'options': ['plays', 'play', 'playing', 'played'], 'explanation': 'Chủ ngữ "They" số nhiều, động từ giữ nguyên'},
          {'sentence': 'He ___ not like coffee.', 'answer': 'does', 'options': ['do', 'does', 'is', 'are'], 'explanation': 'Câu phủ định với "he" dùng "does not"'},
          {'sentence': '___ you speak English?', 'answer': 'Do', 'options': ['Do', 'Does', 'Is', 'Are'], 'explanation': 'Câu hỏi với "you" dùng "Do"'},
          {'sentence': 'The sun ___ in the east.', 'answer': 'rises', 'options': ['rise', 'rises', 'rising', 'risen'], 'explanation': 'Sự thật hiển nhiên, "the sun" là số ít'},
        ],
      },
      'Present Continuous': {
        'affirmative': 'S + am/is/are + V-ing',
        'negative': 'S + am/is/are + not + V-ing',
        'question': 'Am/Is/Are + S + V-ing?',
        'usage': 'Diễn tả hành động đang xảy ra tại thời điểm nói',
        'examples': [
          {'sentence': 'She ___ reading a book now.', 'answer': 'is', 'options': ['am', 'is', 'are', 'be'], 'explanation': 'Chủ ngữ "She" dùng "is" + V-ing'},
          {'sentence': 'They ___ playing tennis.', 'answer': 'are', 'options': ['am', 'is', 'are', 'be'], 'explanation': 'Chủ ngữ "They" dùng "are" + V-ing'},
          {'sentence': 'I ___ not working today.', 'answer': 'am', 'options': ['am', 'is', 'are', 'be'], 'explanation': 'Câu phủ định với "I" dùng "am not"'},
          {'sentence': '___ he studying now?', 'answer': 'Is', 'options': ['Am', 'Is', 'Are', 'Be'], 'explanation': 'Câu hỏi với "he" dùng "Is"'},
          {'sentence': 'We ___ having dinner.', 'answer': 'are', 'options': ['am', 'is', 'are', 'be'], 'explanation': 'Chủ ngữ "We" dùng "are" + V-ing'},
        ],
      },
      'Present Perfect': {
        'affirmative': 'S + have/has + V3/ed',
        'negative': 'S + have/has + not + V3/ed',
        'question': 'Have/Has + S + V3/ed?',
        'usage': 'Diễn tả hành động đã hoàn thành nhưng còn liên quan đến hiện tại',
        'examples': [
          {'sentence': 'She ___ finished her homework.', 'answer': 'has', 'options': ['have', 'has', 'had', 'having'], 'explanation': 'Chủ ngữ "She" dùng "has" + V3'},
          {'sentence': 'They ___ visited Paris twice.', 'answer': 'have', 'options': ['have', 'has', 'had', 'having'], 'explanation': 'Chủ ngữ "They" dùng "have" + V3'},
          {'sentence': 'I ___ not seen that movie.', 'answer': 'have', 'options': ['have', 'has', 'had', 'am'], 'explanation': 'Câu phủ định với "I" dùng "have not"'},
          {'sentence': '___ you ever been to Japan?', 'answer': 'Have', 'options': ['Have', 'Has', 'Had', 'Do'], 'explanation': 'Câu hỏi với "you" dùng "Have"'},
          {'sentence': 'He ___ just arrived.', 'answer': 'has', 'options': ['have', 'has', 'had', 'is'], 'explanation': 'Với "just", "he" dùng "has"'},
        ],
      },
      'Past Simple': {
        'affirmative': 'S + V2/ed',
        'negative': 'S + did + not + V',
        'question': 'Did + S + V?',
        'usage': 'Diễn tả hành động đã hoàn thành trong quá khứ',
        'examples': [
          {'sentence': 'She ___ to school yesterday.', 'answer': 'went', 'options': ['go', 'goes', 'went', 'gone'], 'explanation': 'Quá khứ của "go" là "went"'},
          {'sentence': 'They ___ football last week.', 'answer': 'played', 'options': ['play', 'plays', 'played', 'playing'], 'explanation': 'Động từ có quy tắc thêm "-ed"'},
          {'sentence': 'He ___ not come yesterday.', 'answer': 'did', 'options': ['do', 'does', 'did', 'done'], 'explanation': 'Câu phủ định quá khứ dùng "did not"'},
          {'sentence': '___ you see him yesterday?', 'answer': 'Did', 'options': ['Do', 'Does', 'Did', 'Done'], 'explanation': 'Câu hỏi quá khứ dùng "Did"'},
          {'sentence': 'I ___ at home last night.', 'answer': 'was', 'options': ['am', 'is', 'was', 'were'], 'explanation': 'Quá khứ của "be" với "I" là "was"'},
        ],
      },
    };

    // Trả về data cho thì được chọn, nếu không có thì trả về template
    return tenses[tenseName] ?? {
      'affirmative': 'S + V',
      'negative': 'S + not + V',
      'question': 'V + S?',
      'usage': 'Đang phát triển',
      'examples': [
        {'sentence': 'Câu hỏi mẫu', 'answer': 'answer', 'options': ['answer', 'wrong1', 'wrong2', 'wrong3'], 'explanation': 'Giải thích mẫu'},
      ],
    };
  }

  List<Map<String, dynamic>> _generateQuestionsForTense(Map<String, dynamic> tenseData) {
    // Lấy 5 câu hỏi từ examples
    final examples = List<Map<String, dynamic>>.from(tenseData['examples']);
    examples.shuffle(Random());
    return examples.take(5).toList();
  }

  void _selectAnswer(String answer) {
    if (_showExplanation) return;

    setState(() {
      _selectedAnswer = answer;
      _showExplanation = true;
      if (answer == _questions[_currentQuestionIndex]['answer']) {
        _score++;
      }
    });
  }

  Future<void> _nextQuestion() async {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      // Hoàn thành bài học - cộng XP
      await _completeLesson();
    }
  }

  Future<void> _completeLesson() async {
    // Gọi API cộng XP (5 XP per question)
    final xpEarned = _score * 5;
    
    // Call addXP API
    try {
      final result = await ref.read(learningProvider.notifier).addXP(xpEarned);
      
      if (!mounted) return;

      // Hiển thị kết quả
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('🎉 Hoàn thành!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Điểm: $_score/5', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text('+$xpEarned XP', style: const TextStyle(fontSize: 18, color: Colors.green)),
              if (result['leveledUp'] == true) ...[
                const SizedBox(height: 10),
                Text('🎉 Level Up! Level ${result['newLevel']}', style: const TextStyle(fontSize: 16, color: Colors.orange)),
              ],
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.tenseNameVi)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final tenseData = _getTenseData(widget.tenseName);
    final currentQuestion = _questions[_currentQuestionIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF2D1B69),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(widget.tenseNameVi, style: const TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Công thức
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.white.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('📖 Công thức:', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Text('✅ Khẳng định: ${tenseData['affirmative']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text('❌ Phủ định: ${tenseData['negative']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  Text('❓ Nghi vấn: ${tenseData['question']}', style: const TextStyle(color: Colors.white, fontSize: 14)),
                  const SizedBox(height: 10),
                  Text('💡 ${tenseData['usage']}', style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 13, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Progress
            Text('Câu ${_currentQuestionIndex + 1}/5', style: const TextStyle(color: Colors.white70, fontSize: 16)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: (_currentQuestionIndex + 1) / 5,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
            ),
            const SizedBox(height: 30),

            // Câu hỏi
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Text(
                currentQuestion['sentence'],
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 20),

            // Đáp án
            ...List.generate(
              currentQuestion['options'].length,
              (index) {
                final option = currentQuestion['options'][index];
                final isSelected = _selectedAnswer == option;
                final isCorrect = option == currentQuestion['answer'];
                
                Color? bgColor;
                if (_showExplanation) {
                  if (isCorrect) {
                    bgColor = Colors.green;
                  } else if (isSelected && !isCorrect) {
                    bgColor = Colors.red;
                  }
                }

                return GestureDetector(
                  onTap: () => _selectAnswer(option),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: bgColor ?? Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.white : Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: bgColor ?? Colors.white.withOpacity(0.2),
                          ),
                          child: Center(
                            child: Text(
                              String.fromCharCode(65 + index), // A, B, C, D
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            option,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            // Giải thích
            if (_showExplanation) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: (_selectedAnswer == currentQuestion['answer']) 
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(
                    color: (_selectedAnswer == currentQuestion['answer']) 
                      ? Colors.green
                      : Colors.red,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          (_selectedAnswer == currentQuestion['answer']) ? Icons.check_circle : Icons.cancel,
                          color: (_selectedAnswer == currentQuestion['answer']) ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          (_selectedAnswer == currentQuestion['answer']) ? 'Đúng rồi!' : 'Sai rồi!',
                          style: TextStyle(
                            color: (_selectedAnswer == currentQuestion['answer']) ? Colors.green : Colors.red,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentQuestion['explanation'],
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4CAF50),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    _currentQuestionIndex < _questions.length - 1 ? 'Câu tiếp theo' : 'Hoàn thành',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
