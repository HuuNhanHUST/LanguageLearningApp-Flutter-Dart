import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/services/auth_service.dart';
import '../../grammar/models/grammar_question_model.dart';
import '../../grammar/services/grammar_question_service.dart';
import '../services/assignment_service.dart';

class CreateAssignmentScreen extends StatefulWidget {
  final String classId;
  final String className;

  const CreateAssignmentScreen({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  State<CreateAssignmentScreen> createState() => _CreateAssignmentScreenState();
}

class _CreateAssignmentScreenState extends State<CreateAssignmentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _authService = AuthService();
  final _grammarService = GrammarQuestionService();
  final _assignmentService = AssignmentService();

  List<GrammarQuestion>? _allQuestions;
  List<GrammarQuestion>? _availableQuestions;
  final Set<String> _selectedQuestionIds = {};
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isPublished = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadQuestions() async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      // Load all questions
      final questions = await _grammarService.getClassQuestions(
        classId: widget.classId,
        token: token,
      );

      // Load existing assignments to filter out used questions
      final assignments = await _assignmentService.getClassAssignments(
        classId: widget.classId,
        token: token,
      );

      // Get all question IDs that are already in assignments
      final Set<String> usedQuestionIds = {};
      for (var assignment in assignments) {
        final questionIds = assignment['questions'] as List<dynamic>?;
        if (questionIds != null) {
          for (var qId in questionIds) {
            if (qId is String) {
              usedQuestionIds.add(qId);
            } else if (qId is Map && qId['id'] != null) {
              usedQuestionIds.add(qId['id'].toString());
            }
          }
        }
      }

      // Filter out used questions
      final availableQuestions = questions.where((q) => !usedQuestionIds.contains(q.id)).toList();

      setState(() {
        _allQuestions = questions;
        _availableQuestions = availableQuestions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _createAssignment() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedQuestionIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất 1 câu hỏi'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      await _assignmentService.createAssignment(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        classId: widget.classId,
        questionIds: _selectedQuestionIds.toList(),
        isPublished: _isPublished,
        token: token,
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã tạo bài tập thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: ${e.toString()}'), backgroundColor: Colors.red),
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
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo bài tập'),
            Text(
              widget.className,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Tiêu đề bài tập *',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Vui lòng nhập tiêu đề';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Mô tả (tùy chọn)',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Xuất bản ngay'),
                      subtitle: const Text('Học sinh có thể thấy và làm bài'),
                      value: _isPublished,
                      onChanged: (value) {
                        setState(() {
                          _isPublished = value;
                        });
                      },
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Chọn câu hỏi (${_selectedQuestionIds.length}/${_availableQuestions?.length ?? 0})',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_availableQuestions != null && _availableQuestions!.isNotEmpty)
                          TextButton(
                            onPressed: () {
                              setState(() {
                                if (_selectedQuestionIds.length == _availableQuestions!.length) {
                                  _selectedQuestionIds.clear();
                                } else {
                                  _selectedQuestionIds.addAll(
                                    _availableQuestions!.map((q) => q.id),
                                  );
                                }
                              });
                            },
                            child: Text(
                              _selectedQuestionIds.length == _availableQuestions!.length
                                  ? 'Bỏ chọn tất cả'
                                  : 'Chọn tất cả',
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    if (_availableQuestions == null || _availableQuestions!.isEmpty)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(Icons.check_circle_outline, size: 48, color: Colors.green[400]),
                                const SizedBox(height: 12),
                                Text(
                                  _allQuestions == null || _allQuestions!.isEmpty 
                                    ? 'Chưa có câu hỏi nào'
                                    : 'Tất cả câu hỏi đã được thêm vào bài tập',
                                  style: TextStyle(color: Colors.grey[600]),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  _allQuestions == null || _allQuestions!.isEmpty
                                    ? 'Vui lòng tạo câu hỏi trước'
                                    : 'Tạo thêm câu hỏi mới hoặc xóa bài tập cũ',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    else
                      ..._availableQuestions!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final question = entry.value;
                        final isSelected = _selectedQuestionIds.contains(question.id);

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: isSelected ? 4 : 1,
                          color: isSelected
                              ? const Color(0xFF6C63FF).withOpacity(0.1)
                              : null,
                          child: CheckboxListTile(
                            value: isSelected,
                            onChanged: (value) {
                              setState(() {
                                if (value == true) {
                                  _selectedQuestionIds.add(question.id);
                                } else {
                                  _selectedQuestionIds.remove(question.id);
                                }
                              });
                            },
                            title: Text(
                              'Câu ${index + 1}: ${question.question}',
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                            subtitle: Text(
                              'Độ khó: ${_getDifficultyLabel(question.difficulty)}',
                              style: TextStyle(
                                color: _getDifficultyColor(question.difficulty),
                                fontSize: 12,
                              ),
                            ),
                            activeColor: const Color(0xFF6C63FF),
                          ),
                        );
                      }).toList(),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSubmitting ? null : _createAssignment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          padding: const EdgeInsets.symmetric(vertical: 16),
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
                                'Tạo bài tập',
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  String _getDifficultyLabel(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return 'Dễ';
      case 'intermediate':
        return 'Trung bình';
      case 'advanced':
        return 'Khó';
      default:
        return difficulty;
    }
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
