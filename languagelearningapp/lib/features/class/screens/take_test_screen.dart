import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../grammar/services/grammar_question_service.dart';
import '../../grammar/models/grammar_question_model.dart';

/// Màn hình làm bài test ngữ pháp
class TakeTestScreen extends StatefulWidget {
  final String classId;

  const TakeTestScreen({
    super.key,
    required this.classId,
  });

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen> {
  final _grammarService = GrammarQuestionService();
  final _authService = AuthService();
  List<GrammarQuestion> _questions = [];
  Map<String, int?> _answers = {}; // questionId -> selectedOption
  bool _isLoading = true;
  bool _isSubmitted = false;
  String? _error;
  int _currentQuestionIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final user = context.read<AuthProvider>().user;
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      final questions = await _grammarService.getClassQuestions(
        classId: widget.classId,
        token: token,
      );

      setState(() {
        _questions = questions;
        // Initialize answers map
        for (var question in questions) {
          _answers[question.id] = null;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _submitTest() {
    // Check if all questions are answered
    final unanswered = _answers.values.where((answer) => answer == null).length;

    if (unanswered > 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Chưa hoàn thành'),
          content: Text(
            'Bạn còn $unanswered câu chưa trả lời. Bạn có muốn nộp bài không?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tiếp tục làm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _calculateAndShowResults();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Nộp bài'),
            ),
          ],
        ),
      );
    } else {
      _calculateAndShowResults();
    }
  }

  void _calculateAndShowResults() {
    int correctCount = 0;
    for (var question in _questions) {
      if (_answers[question.id] == question.correctAnswer) {
        correctCount++;
      }
    }

    setState(() {
      _isSubmitted = true;
    });

    final score = (_questions.isNotEmpty)
        ? (correctCount / _questions.length * 100).toStringAsFixed(1)
        : '0.0';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Kết quả bài kiểm tra'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              correctCount >= _questions.length * 0.7
                  ? Icons.emoji_events
                  : Icons.sentiment_satisfied,
              size: 64,
              color: correctCount >= _questions.length * 0.7
                  ? Colors.amber
                  : Colors.blue,
            ),
            const SizedBox(height: 16),
            Text(
              '$score%',
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Đúng $correctCount/${_questions.length} câu',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Return to class detail
            },
            child: const Text('Xem lại'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Làm bài kiểm tra'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          if (!_isSubmitted && _questions.isNotEmpty)
            TextButton(
              onPressed: _submitTest,
              child: const Text(
                'Nộp bài',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadQuestions,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : _questions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có câu hỏi nào',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        // Progress indicator
                        LinearProgressIndicator(
                          value: (_currentQuestionIndex + 1) /
                              _questions.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6C63FF),
                          ),
                        ),
                        // Question counter
                        Container(
                          padding: const EdgeInsets.all(16),
                          color: const Color(0xFF6C63FF).withOpacity(0.1),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2D1B69),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: _getDifficultyColor(
                                    _questions[_currentQuestionIndex]
                                        .difficulty,
                                  ).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  _getDifficultyText(
                                    _questions[_currentQuestionIndex]
                                        .difficulty,
                                  ),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: _getDifficultyColor(
                                      _questions[_currentQuestionIndex]
                                          .difficulty,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            itemCount: _questions.length,
                            onPageChanged: (index) {
                              setState(() {
                                _currentQuestionIndex = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              final question = _questions[index];
                              return _buildQuestionCard(question);
                            },
                          ),
                        ),
                      ],
                    ),
    );
  }

  Widget _buildQuestionCard(GrammarQuestion question) {
    final selectedAnswer = _answers[question.id];
    final isCorrect = _isSubmitted && selectedAnswer == question.correctAnswer;
    final isWrong = _isSubmitted &&
        selectedAnswer != null &&
        selectedAnswer != question.correctAnswer;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Question text
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                question.question,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF2D1B69),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Options
          ...List.generate(question.options.length, (index) {
            final isSelected = selectedAnswer == index;
            final isCorrectOption =
                _isSubmitted && index == question.correctAnswer;
            final isWrongOption = _isSubmitted && isSelected && !isCorrectOption;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: _isSubmitted
                    ? null
                    : () {
                        setState(() {
                          _answers[question.id] = index;
                        });
                      },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isCorrectOption
                        ? Colors.green.withOpacity(0.1)
                        : isWrongOption
                            ? Colors.red.withOpacity(0.1)
                            : isSelected
                                ? const Color(0xFF6C63FF).withOpacity(0.1)
                                : Colors.white,
                    border: Border.all(
                      color: isCorrectOption
                          ? Colors.green
                          : isWrongOption
                              ? Colors.red
                              : isSelected
                                  ? const Color(0xFF6C63FF)
                                  : Colors.grey.shade300,
                      width: isCorrectOption || isWrongOption || isSelected
                          ? 2
                          : 1,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: isCorrectOption
                              ? Colors.green
                              : isWrongOption
                                  ? Colors.red
                                  : isSelected
                                      ? const Color(0xFF6C63FF)
                                      : Colors.grey.shade300,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            String.fromCharCode(65 + index), // A, B, C, D
                            style: TextStyle(
                              color: isSelected ||
                                      isCorrectOption ||
                                      isWrongOption
                                  ? Colors.white
                                  : Colors.grey.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          question.options[index],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF2D1B69),
                          ),
                        ),
                      ),
                      if (isCorrectOption)
                        const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      if (isWrongOption)
                        const Icon(
                          Icons.cancel,
                          color: Colors.red,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),

          // Explanation (after submission)
          if (_isSubmitted && question.explanation != null) ...[
            const SizedBox(height: 20),
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Giải thích',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      question.explanation!,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.blue.shade900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Result indicator
          if (_isSubmitted) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCorrect
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCorrect ? Colors.green : Colors.red,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    isCorrect ? Icons.check_circle : Icons.cancel,
                    color: isCorrect ? Colors.green : Colors.red,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isCorrect
                          ? 'Chính xác!'
                          : isWrong
                              ? 'Sai rồi!'
                              : 'Chưa trả lời',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
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

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'hard':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getDifficultyText(String difficulty) {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Dễ';
      case 'medium':
        return 'Trung bình';
      case 'hard':
        return 'Khó';
      default:
        return difficulty;
    }
  }
}
