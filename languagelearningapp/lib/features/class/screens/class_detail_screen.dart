import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../services/class_service.dart';
import '../services/assignment_service.dart';
import '../models/class_model.dart';
import 'create_grammar_test_screen.dart';
import 'class_questions_screen.dart';
import 'create_assignment_screen.dart';
import 'assignment_list_screen.dart';

/// Màn hình chi tiết lớp học
class ClassDetailScreen extends StatefulWidget {
  final String classId;

  const ClassDetailScreen({
    super.key,
    required this.classId,
  });

  @override
  State<ClassDetailScreen> createState() => _ClassDetailScreenState();
}

class _ClassDetailScreenState extends State<ClassDetailScreen> {
  final _classService = ClassService();
  final _authService = AuthService();
  final _assignmentService = AssignmentService();
  ClassModel? _classData;
  int _assignmentCount = 0;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassDetails();
  }

  Future<void> _loadClassDetails() async {
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

      final classData =
          await _classService.getClassById(widget.classId, token);
      
      // Load assignments count
      final assignments = await _assignmentService.getClassAssignments(
        classId: widget.classId,
        token: token,
      );
      
      setState(() {
        _classData = classData;
        _assignmentCount = assignments.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _removeStudent(String studentId) async {
    final user = context.read<AuthProvider>().user;
    final token = await _authService.getAccessToken();
    if (token == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa học sinh'),
        content: const Text('Bạn có chắc muốn xóa học sinh này khỏi lớp?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      await _classService.removeStudent(
        classId: widget.classId,
        studentId: studentId,
        token: token,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã xóa học sinh')),
      );
      _loadClassDetails();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _copyClassCode() {
    if (_classData != null) {
      Clipboard.setData(ClipboardData(text: _classData!.code));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã sao chép mã lớp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final isTeacher = user?.isTeacher == true || user?.isAdmin == true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết lớp học'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        actions: [
          if (isTeacher && _classData != null)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateGrammarTestScreen(
                      classId: widget.classId,
                    ),
                  ),
                );
                if (result == true) {
                  _loadClassDetails();
                }
              },
              tooltip: 'Tạo bài tập',
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
                        onPressed: _loadClassDetails,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadClassDetails,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Class header card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF6C63FF)
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.class_,
                                        color: Color(0xFF6C63FF),
                                        size: 32,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _classData!.name,
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF2D1B69),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Giáo viên: ${_classData!.teacher.username}',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                if (_classData!.description.isNotEmpty) ...[
                                  const SizedBox(height: 12),
                                  Text(
                                    _classData!.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF6C63FF)
                                        .withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Mã lớp:',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF2D1B69),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            _classData!.code,
                                            style: const TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF6C63FF),
                                              letterSpacing: 2,
                                            ),
                                          ),
                                        ],
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.copy),
                                        onPressed: _copyClassCode,
                                        tooltip: 'Sao chép mã',
                                        color: const Color(0xFF6C63FF),
                                      ),
                                    ],
                                  ),
                                ),                                const SizedBox(height: 16),
                                // Action buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        onPressed: () async {
                                          await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  AssignmentListScreen(
                                                classId: widget.classId,
                                                className: _classData!.name,
                                                isTeacher: isTeacher,
                                              ),
                                            ),
                                          );
                                          // Reload when returning
                                          _loadClassDetails();
                                        },
                                        icon: const Icon(Icons.assignment),
                                        label: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            const Text('Xem bài tập'),
                                            if (_assignmentCount > 0) ...[
                                              const SizedBox(width: 8),
                                              Container(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 8,
                                                  vertical: 2,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                                child: Text(
                                                  '$_assignmentCount',
                                                  style: const TextStyle(
                                                    color: Color(0xFF6C63FF),
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ],
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF6C63FF),
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 12),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                if (isTeacher) ...[
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    ClassQuestionsScreen(
                                                  classId: widget.classId,
                                                  className: _classData!.name,
                                                  isTeacher: isTeacher,
                                                ),
                                              ),
                                            );
                                            // Reload when returning
                                            _loadClassDetails();
                                          },
                                          icon: const Icon(Icons.quiz),
                                          label: const Text('Xem câu hỏi'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF6C63FF),
                                            side: const BorderSide(
                                              color: Color(0xFF6C63FF),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    CreateAssignmentScreen(
                                                  classId: widget.classId,
                                                  className: _classData!.name,
                                                ),
                                              ),
                                            );
                                            if (result == true) {
                                              _loadClassDetails();
                                            }
                                          },
                                          icon: const Icon(Icons.add),
                                          label: const Text('Tạo bài tập'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: const Color(0xFF6C63FF),
                                            side: const BorderSide(
                                              color: Color(0xFF6C63FF),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 12),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Students section
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Học sinh',
                              style: TextStyle(
                                fontSize: 18,
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
                                color:
                                    const Color(0xFF6C63FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                '${_classData!.students.length} học sinh',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF6C63FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        if (_classData!.students.isEmpty)
                          Card(
                            elevation: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(24),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.people_outline,
                                      size: 48,
                                      color: Colors.grey[400],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Chưa có học sinh nào',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        else
                          ...(_classData!.students.map((student) {
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: CircleAvatar(
                                  backgroundColor:
                                      const Color(0xFF6C63FF).withOpacity(0.1),
                                  child: Text(
                                    student.username[0].toUpperCase(),
                                    style: const TextStyle(
                                      color: Color(0xFF6C63FF),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(student.username),
                                subtitle: Text(student.email),
                                trailing: isTeacher
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.remove_circle_outline,
                                          color: Colors.red,
                                        ),
                                        onPressed: () =>
                                            _removeStudent(student.id),
                                        tooltip: 'Xóa học sinh',
                                      )
                                    : null,
                              ),
                            );
                          }).toList()),
                      ],
                    ),
                  ),
                ),
    );
  }
}
