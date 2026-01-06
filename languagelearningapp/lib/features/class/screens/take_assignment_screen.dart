import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../services/assignment_service.dart';
import '../services/submission_service.dart';
import 'submission_result_screen.dart';

class TakeAssignmentScreen extends StatefulWidget {
  final String assignmentId;
  final String classId;
  final String assignmentTitle;

  const TakeAssignmentScreen({
    Key? key,
    required this.assignmentId,
    required this.classId,
    required this.assignmentTitle,
  }) : super(key: key);

  @override
  State<TakeAssignmentScreen> createState() => _TakeAssignmentScreenState();
}

class _TakeAssignmentScreenState extends State<TakeAssignmentScreen> {
  final _assignmentService = AssignmentService();
  final _submissionService = SubmissionService();
  final _authService = AuthService();

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _assignment;
  List<dynamic> _questions = [];
  int _currentQuestionIndex = 0;
  Map<String, int> _selectedAnswers = {}; // questionId -> selectedIndex

  @override
  void initState() {
    super.initState();
    _loadAssignment();
  }

  Future<void> _loadAssignment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      // Check if already submitted
      final checkResult = await _submissionService.checkSubmission(
        assignmentId: widget.assignmentId,
        token: token,
      );

      final hasSubmitted = checkResult['hasSubmitted'] as bool? ?? false;
      
      if (hasSubmitted) {
        // Already submitted, load and show result
        final submission = await _submissionService.getMySubmission(
          assignmentId: widget.assignmentId,
          token: token,
        );
        
        if (mounted && submission != null) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SubmissionResultScreen(
                submission: submission,
                assignmentTitle: widget.assignmentTitle,
              ),
            ),
          );
        }
        return;
      }

      final assignment = await _assignmentService.getAssignmentById(
        assignmentId: widget.assignmentId,
        token: token,
      );

      setState(() {
        _assignment = assignment;
        _questions = assignment['questions'] ?? [];
        _isLoading = false;
        
        // Debug: Print first question structure
        if (_questions.isNotEmpty) {
          print('DEBUG - First question structure: ${_questions[0]}');
          print('DEBUG - Question keys: ${_questions[0].keys}');
        }
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _selectAnswer(int index) {
    final questionId = _questions[_currentQuestionIndex]['id']?.toString();
    if (questionId == null) {
      print('Error: Question ID is null');
      return;
    }
    setState(() {
      _selectedAnswers[questionId] = index;
      print('Answer saved: question=$questionId, answer=$index');
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
      });
    }
  }

  Future<void> _submitAssignment() async {
    // Check if all questions are answered
    if (_selectedAnswers.length < _questions.length) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng trả lời tất cả các câu hỏi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận nộp bài'),
        content: const Text(
          'Bạn có chắc chắn muốn nộp bài? Bạn không thể thay đổi đáp án sau khi nộp.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6C63FF),
            ),
            child: const Text('Nộp bài'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      setState(() => _isLoading = true);

      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      // Prepare answers
      final answers = _selectedAnswers.entries.map((entry) {
        return {
          'questionId': entry.key,
          'selectedIndex': entry.value,
        };
      }).toList();

      // Submit
      final submission = await _submissionService.submitAssignment(
        assignmentId: widget.assignmentId,
        classId: widget.classId,
        answers: answers,
        token: token,
      );

      // Navigate to result screen
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SubmissionResultScreen(
              submission: submission,
              assignmentTitle: widget.assignmentTitle,
            ),
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.assignmentTitle),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.assignmentTitle),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(_error!),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadAssignment,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.assignmentTitle),
          backgroundColor: const Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Text('Không có câu hỏi nào trong bài tập này'),
        ),
      );
    }

    final question = _questions[_currentQuestionIndex];
    final questionId = question['id']?.toString();
    final selectedIndex = questionId != null ? _selectedAnswers[questionId] : null;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.assignmentTitle),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Câu ${_currentQuestionIndex + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_selectedAnswers.length}/${_questions.length} đã trả lời',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: (_currentQuestionIndex + 1) / _questions.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C63FF),
                  ),
                ),
              ],
            ),
          ),

          // Question content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      question['question'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Answer options
                  const Text(
                    'Chọn đáp án:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  ...List.generate(
                    (question['options'] as List?)?.length ?? 0,
                    (index) {
                      final options = question['options'] as List;
                      final option = options[index];
                      final isSelected = selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          print('Selected option $index');
                          _selectAnswer(index);
                        },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFF6C63FF).withOpacity(0.1)
                              : Colors.white,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF6C63FF)
                                : Colors.grey[300]!,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFF6C63FF)
                                    : Colors.grey[200],
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Text(
                                  String.fromCharCode(65 + index),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.black87,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                option,
                                style: const TextStyle(fontSize: 16),
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
          ),

          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              children: [
                if (_currentQuestionIndex > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _previousQuestion,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Câu trước'),
                    ),
                  ),
                if (_currentQuestionIndex > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentQuestionIndex < _questions.length - 1
                        ? _nextQuestion
                        : _submitAssignment,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C63FF),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      _currentQuestionIndex < _questions.length - 1
                          ? 'Câu tiếp'
                          : 'Nộp bài',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
