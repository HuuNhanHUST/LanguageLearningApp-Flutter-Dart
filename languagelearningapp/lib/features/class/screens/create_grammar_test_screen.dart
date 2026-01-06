import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../../grammar/services/grammar_question_service.dart';

/// Màn hình tạo bài tập ngữ pháp
class CreateGrammarTestScreen extends StatefulWidget {
  final String classId;

  const CreateGrammarTestScreen({
    super.key,
    required this.classId,
  });

  @override
  State<CreateGrammarTestScreen> createState() =>
      _CreateGrammarTestScreenState();
}

class _CreateGrammarTestScreenState
    extends State<CreateGrammarTestScreen> {
  final _formKey = GlobalKey<FormState>();
  final _questionController = TextEditingController();
  final _optionAController = TextEditingController();
  final _optionBController = TextEditingController();
  final _optionCController = TextEditingController();
  final _optionDController = TextEditingController();
  final _explanationController = TextEditingController();
  final _grammarService = GrammarQuestionService();
  final _authService = AuthService();

  String _difficulty = 'easy';
  int _correctAnswer = 0;
  bool _isPublic = false;
  bool _isLoading = false;

  // Map Flutter difficulty to backend enum
  String get _backendDifficulty {
    switch (_difficulty) {
      case 'easy':
        return 'beginner';
      case 'medium':
        return 'intermediate';
      case 'hard':
        return 'advanced';
      default:
        return 'beginner';
    }
  }

  @override
  void dispose() {
    _questionController.dispose();
    _optionAController.dispose();
    _optionBController.dispose();
    _optionCController.dispose();
    _optionDController.dispose();
    _explanationController.dispose();
    super.dispose();
  }

  Future<void> _createQuestion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<AuthProvider>().user;
      final token = await _authService.getAccessToken();
      if (token == null) {
        throw Exception('Vui lòng đăng nhập');
      }

      await _grammarService.createQuestion(
        question: _questionController.text.trim(),
        options: [
          _optionAController.text.trim(),
          _optionBController.text.trim(),
          _optionCController.text.trim(),
          _optionDController.text.trim(),
        ],
        correctAnswer: _correctAnswer,
        explanation: _explanationController.text.trim().isEmpty
            ? null
            : _explanationController.text.trim(),
        difficulty: _backendDifficulty, // Use mapped difficulty
        tags: ['grammar'],
        classId: widget.classId,
        isPublic: _isPublic,
        token: token,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã tạo câu hỏi thành công'),
          backgroundColor: Colors.green,
        ),
      );

      // Show dialog asking if user wants to add more
      final addMore = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Thêm câu hỏi khác?'),
          content: const Text('Bạn có muốn tiếp tục thêm câu hỏi nữa không?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Xong'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              style: TextButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
              ),
              child: const Text('Thêm tiếp'),
            ),
          ],
        ),
      );

      if (addMore == true) {
        // Clear form for next question
        _questionController.clear();
        _optionAController.clear();
        _optionBController.clear();
        _optionCController.clear();
        _optionDController.clear();
        _explanationController.clear();
        setState(() {
          _correctAnswer = 0;
          _difficulty = 'easy';
        });
      } else {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tạo câu hỏi ngữ pháp'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question field
              const Text(
                'Câu hỏi',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi của bạn',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập câu hỏi';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Options
              const Text(
                'Các lựa chọn',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 8),

              // Option A
              _buildOptionField(
                controller: _optionAController,
                label: 'A',
                isCorrect: _correctAnswer == 0,
                onTap: () => setState(() => _correctAnswer = 0),
              ),
              const SizedBox(height: 12),

              // Option B
              _buildOptionField(
                controller: _optionBController,
                label: 'B',
                isCorrect: _correctAnswer == 1,
                onTap: () => setState(() => _correctAnswer = 1),
              ),
              const SizedBox(height: 12),

              // Option C
              _buildOptionField(
                controller: _optionCController,
                label: 'C',
                isCorrect: _correctAnswer == 2,
                onTap: () => setState(() => _correctAnswer = 2),
              ),
              const SizedBox(height: 12),

              // Option D
              _buildOptionField(
                controller: _optionDController,
                label: 'D',
                isCorrect: _correctAnswer == 3,
                onTap: () => setState(() => _correctAnswer = 3),
              ),
              const SizedBox(height: 24),

              // Difficulty
              const Text(
                'Độ khó',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(
                    value: 'easy',
                    label: Text('Dễ'),
                    icon: Icon(Icons.sentiment_satisfied),
                  ),
                  ButtonSegment(
                    value: 'medium',
                    label: Text('Trung bình'),
                    icon: Icon(Icons.sentiment_neutral),
                  ),
                  ButtonSegment(
                    value: 'hard',
                    label: Text('Khó'),
                    icon: Icon(Icons.sentiment_dissatisfied),
                  ),
                ],
                selected: {_difficulty},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _difficulty = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Explanation (optional)
              const Text(
                'Giải thích (tùy chọn)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2D1B69),
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _explanationController,
                decoration: InputDecoration(
                  hintText: 'Giải thích đáp án đúng',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: Color(0xFF6C63FF),
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Public toggle
              Card(
                child: SwitchListTile(
                  title: const Text('Công khai'),
                  subtitle: const Text(
                    'Cho phép tất cả giáo viên sử dụng câu hỏi này',
                  ),
                  value: _isPublic,
                  onChanged: (value) {
                    setState(() {
                      _isPublic = value;
                    });
                  },
                  activeColor: const Color(0xFF6C63FF),
                ),
              ),
              const SizedBox(height: 32),

              // Submit button
              ElevatedButton(
                onPressed: _isLoading ? null : _createQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Tạo câu hỏi',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionField({
    required TextEditingController controller,
    required String label,
    required bool isCorrect,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Radio<bool>(
          value: true,
          groupValue: isCorrect,
          onChanged: (_) => onTap(),
          activeColor: const Color(0xFF6C63FF),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'Đáp án $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: isCorrect
                      ? const Color(0xFF6C63FF)
                      : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              filled: isCorrect,
              fillColor:
                  isCorrect ? const Color(0xFF6C63FF).withOpacity(0.1) : null,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Vui lòng nhập đáp án $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
