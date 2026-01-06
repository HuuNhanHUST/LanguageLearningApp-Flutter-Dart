import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/services/auth_service.dart';
import '../services/assignment_service.dart';
import 'take_assignment_screen.dart';

class AssignmentListScreen extends StatefulWidget {
  final String classId;
  final String className;
  final bool isTeacher;

  const AssignmentListScreen({
    Key? key,
    required this.classId,
    required this.className,
    this.isTeacher = false,
  }) : super(key: key);

  @override
  State<AssignmentListScreen> createState() => _AssignmentListScreenState();
}

class _AssignmentListScreenState extends State<AssignmentListScreen> {
  final _assignmentService = AssignmentService();
  final _authService = AuthService();
  List<Map<String, dynamic>>? _assignments;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAssignments();
  }

  Future<void> _loadAssignments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      final assignments = await _assignmentService.getClassAssignments(
        classId: widget.classId,
        token: token,
      );

      setState(() {
        _assignments = assignments;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteAssignment(String assignmentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa bài tập'),
        content: const Text('Bạn có chắc muốn xóa bài tập này?'),
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
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      await _assignmentService.deleteAssignment(
        assignmentId: assignmentId,
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa bài tập'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAssignments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _togglePublish(String assignmentId, bool currentStatus) async {
    try {
      final token = await _authService.getAccessToken();
      if (token == null) throw Exception('Vui lòng đăng nhập');

      await _assignmentService.togglePublish(
        assignmentId: assignmentId,
        token: token,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentStatus ? 'Đã ẩn bài tập' : 'Đã xuất bản bài tập'),
            backgroundColor: Colors.green,
          ),
        );
        _loadAssignments();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
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
            const Text('Bài tập'),
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
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                      const SizedBox(height: 16),
                      Text(
                        _error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadAssignments,
                        child: const Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadAssignments,
                  child: _assignments == null || _assignments!.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(24),
                          children: [
                            const SizedBox(height: 60),
                            Icon(
                              Icons.assignment_outlined,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Chưa có bài tập nào',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              widget.isTeacher
                                  ? 'Tạo bài tập từ các câu hỏi đã có'
                                  : 'Giáo viên chưa tạo bài tập nào',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _assignments!.length,
                          itemBuilder: (context, index) {
                            final assignment = _assignments![index];
                            final isPublished = assignment['isPublished'] ?? false;
                            final questionCount = (assignment['questions'] as List?)?.length ?? 0;
                            final totalPoints = assignment['totalPoints'] ?? 10;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: InkWell(
                                onTap: widget.isTeacher
                                    ? null
                                    : isPublished
                                        ? () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => TakeAssignmentScreen(
                                                  assignmentId: assignment['id'],
                                                  assignmentTitle: assignment['title'] ?? 'Bài tập',
                                                  classId: widget.classId,
                                                ),
                                              ),
                                            ).then((_) => _loadAssignments()); // Refresh list after submission
                                          }
                                        : null,
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              color: isPublished
                                                  ? const Color(0xFF6C63FF).withOpacity(0.1)
                                                  : Colors.grey.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Icon(
                                              Icons.assignment,
                                              color: isPublished
                                                  ? const Color(0xFF6C63FF)
                                                  : Colors.grey,
                                              size: 24,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  assignment['title'] ?? 'Không có tiêu đề',
                                                  style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF2D1B69),
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Row(
                                                  children: [
                                                    Icon(
                                                      Icons.quiz,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '$questionCount câu hỏi',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                    Icon(
                                                      Icons.star,
                                                      size: 14,
                                                      color: Colors.grey[600],
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      '$totalPoints điểm',
                                                      style: TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey[600],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          if (widget.isTeacher)
                                            PopupMenuButton(
                                              icon: const Icon(Icons.more_vert),
                                              itemBuilder: (context) => [
                                                PopupMenuItem(
                                                  onTap: () => Future.delayed(
                                                    Duration.zero,
                                                    () => _togglePublish(
                                                      assignment['id'],
                                                      isPublished,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Icon(
                                                        isPublished
                                                            ? Icons.visibility_off
                                                            : Icons.visibility,
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(isPublished ? 'Ẩn' : 'Xuất bản'),
                                                    ],
                                                  ),
                                                ),
                                                PopupMenuItem(
                                                  onTap: () => Future.delayed(
                                                    Duration.zero,
                                                    () => _deleteAssignment(assignment['id']),
                                                  ),
                                                  child: const Row(
                                                    children: [
                                                      Icon(Icons.delete, color: Colors.red),
                                                      SizedBox(width: 8),
                                                      Text('Xóa', style: TextStyle(color: Colors.red)),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      if (assignment['description'] != null &&
                                          assignment['description'].toString().isNotEmpty) ...[
                                        const SizedBox(height: 12),
                                        Text(
                                          assignment['description'],
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                      ],
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: isPublished
                                                  ? Colors.green.withOpacity(0.1)
                                                  : Colors.orange.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Row(
                                              children: [
                                                Icon(
                                                  isPublished ? Icons.check_circle : Icons.schedule,
                                                  size: 14,
                                                  color: isPublished ? Colors.green : Colors.orange,
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  isPublished ? 'Đã xuất bản' : 'Nháp',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: isPublished
                                                        ? Colors.green[700]
                                                        : Colors.orange[700],
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
