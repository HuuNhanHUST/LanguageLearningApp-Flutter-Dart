import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/grammar_question_model.dart';
import '../models/submission_model.dart';
import '../services/grammar_question_service.dart';
import '../../auth/services/auth_service.dart';

class TakeTestScreen extends StatefulWidget {
  final String classId;
  final String assignmentId;
  final List<GrammarQuestion> questions;

  const TakeTestScreen({
    Key? key,
    required this.classId,
    required this.assignmentId,
    required this.questions,
  }) : super(key: key);

  @override
  State<TakeTestScreen> createState() => _TakeTestScreenState();
}

class _TakeTestScreenState extends State<TakeTestScreen> {
  final Map<String, int> _selectedAnswers = {};
  bool _isSubmitting = false;

  void _selectAnswer(String questionId, int index) {
    setState(() {
      _selectedAnswers[questionId] = index;
    });
  }

  Future<void> _submitTest() async {
    // Kiểm tra đã trả lời hết chưa
    if (_selectedAnswers.length != widget.questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng trả lời tất cả câu hỏi!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAccessToken();

      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      // Chuẩn bị answers
      final answers = _selectedAnswers.entries.map((entry) {
        return {
          'questionId': entry.key,
          'selectedIndex': entry.value,
        };
      }).toList();

      final submission = await GrammarQuestionService().submitAnswers(
        classId: widget.classId,
        assignmentId: widget.assignmentId,
        answers: answers,
        token: token,
      );

      if (mounted) {
        // Chuyển đến màn hình kết quả
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => TestResultScreen(
              submission: submission,
              questions: widget.questions,
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Làm bài kiểm tra'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Tổng số câu: ${widget.questions.length}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Đã trả lời: ${_selectedAnswers.length}/${widget.questions.length}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _selectedAnswers.length == widget.questions.length
                        ? Colors.green
                        : Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          // Questions list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final question = widget.questions[index];
                return _QuestionCard(
                  questionNumber: index + 1,
                  question: question,
                  selectedIndex: _selectedAnswers[question.id],
                  onSelectAnswer: (selectedIndex) {
                    _selectAnswer(question.id, selectedIndex);
                  },
                );
              },
            ),
          ),
          // Submit button
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? null : _submitTest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Nộp bài',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final int questionNumber;
  final GrammarQuestion question;
  final int? selectedIndex;
  final Function(int) onSelectAnswer;

  const _QuestionCard({
    Key? key,
    required this.questionNumber,
    required this.question,
    required this.selectedIndex,
    required this.onSelectAnswer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question number and text
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: selectedIndex != null
                        ? Colors.green
                        : Theme.of(context).primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$questionNumber',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    question.question,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Options
            ...List.generate(question.options.length, (index) {
              final option = question.options[index];
              final isSelected = selectedIndex == index;
              final optionLabel = String.fromCharCode(65 + index); // A, B, C, D

              return InkWell(
                onTap: () => onSelectAnswer(index),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Theme.of(context).primaryColor.withOpacity(0.1)
                        : Colors.grey[100],
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey[300]!,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isSelected
                              ? Theme.of(context).primaryColor
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).primaryColor
                                : Colors.grey[400]!,
                          ),
                        ),
                        child: isSelected
                            ? const Icon(
                                Icons.check,
                                size: 16,
                                color: Colors.white,
                              )
                            : Center(
                                child: Text(
                                  optionLabel,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          option,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.normal,
                            color: isSelected ? Colors.black87 : Colors.black54,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class TestResultScreen extends StatelessWidget {
  final SubmissionModel submission;
  final List<GrammarQuestion> questions;

  const TestResultScreen({
    Key? key,
    required this.submission,
    required this.questions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = submission.percentage;
    final isPassed = percentage >= 50;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài kiểm tra'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Score card
            Card(
              elevation: 4,
              color: isPassed ? Colors.green[50] : Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      isPassed ? Icons.check_circle : Icons.cancel,
                      size: 80,
                      color: isPassed ? Colors.green : Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isPassed ? 'Đạt' : 'Chưa đạt',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: isPassed ? Colors.green : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _ScoreItem(
                          label: 'Điểm',
                          value: submission.score.toStringAsFixed(1),
                          subValue: '/ 10',
                        ),
                        _ScoreItem(
                          label: 'Phần trăm',
                          value: percentage.toStringAsFixed(0),
                          subValue: '%',
                        ),
                        _ScoreItem(
                          label: 'Đúng',
                          value: '${submission.correctAnswers}',
                          subValue: '/ ${submission.totalQuestions}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Review answers
            const Text(
              'Chi tiết câu trả lời',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...List.generate(questions.length, (index) {
              final question = questions[index];
              final answer = submission.answers.firstWhere(
                (a) => a.questionId == question.id,
              );
              
              return _AnswerReviewCard(
                questionNumber: index + 1,
                question: question,
                answer: answer,
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ScoreItem extends StatelessWidget {
  final String label;
  final String value;
  final String subValue;

  const _ScoreItem({
    Key? key,
    required this.label,
    required this.value,
    required this.subValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subValue,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnswerReviewCard extends StatelessWidget {
  final int questionNumber;
  final GrammarQuestion question;
  final AnswerModel answer;

  const _AnswerReviewCard({
    Key? key,
    required this.questionNumber,
    required this.question,
    required this.answer,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isCorrect = answer.isCorrect;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Question header
            Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: isCorrect ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isCorrect ? Icons.check : Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Câu $questionNumber',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              question.question,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 12),
            // Options
            ...List.generate(question.options.length, (index) {
              final option = question.options[index];
              final optionLabel = String.fromCharCode(65 + index);
              final isSelected = answer.selectedIndex == index;
              final isCorrectAnswer = question.correctAnswer == index;

              Color? bgColor;
              Color? borderColor;
              
              if (isCorrectAnswer) {
                bgColor = Colors.green[50];
                borderColor = Colors.green;
              } else if (isSelected && !isCorrect) {
                bgColor = Colors.red[50];
                borderColor = Colors.red;
              }

              return Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: bgColor ?? Colors.grey[50],
                  border: Border.all(
                    color: borderColor ?? Colors.grey[300]!,
                    width: borderColor != null ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Text(
                      '$optionLabel.',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: borderColor ?? Colors.black54,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        option,
                        style: TextStyle(
                          color: borderColor != null ? Colors.black87 : Colors.black54,
                        ),
                      ),
                    ),
                    if (isCorrectAnswer)
                      const Icon(Icons.check_circle, color: Colors.green, size: 20),
                    if (isSelected && !isCorrect)
                      const Icon(Icons.cancel, color: Colors.red, size: 20),
                  ],
                ),
              );
            }),
            if (question.explanation != null && question.explanation!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        question.explanation!,
                        style: const TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
