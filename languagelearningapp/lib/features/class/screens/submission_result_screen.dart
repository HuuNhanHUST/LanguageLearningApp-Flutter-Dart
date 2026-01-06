import 'package:flutter/material.dart';
import '../models/submission_model.dart';

class SubmissionResultScreen extends StatelessWidget {
  final SubmissionModel submission;
  final String assignmentTitle;

  const SubmissionResultScreen({
    Key? key,
    required this.submission,
    required this.assignmentTitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = submission.percentage;
    final isPassed = submission.score >= 5.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kết quả bài tập'),
        backgroundColor: const Color(0xFF6C63FF),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Result card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Score icon
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isPassed
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                      ),
                      child: Icon(
                        isPassed ? Icons.check_circle : Icons.info,
                        size: 60,
                        color: isPassed ? Colors.green : Colors.orange,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Status text
                    Text(
                      isPassed ? 'Chúc mừng!' : 'Cần cố gắng thêm!',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1B69),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      assignmentTitle,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),

                    // Score display
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6C63FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Text(
                            '${submission.score.toStringAsFixed(1)}',
                            style: const TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                          const Text(
                            'điểm',
                            style: TextStyle(
                              fontSize: 18,
                              color: Color(0xFF6C63FF),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Statistics
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
                    const Text(
                      'Thống kê',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2D1B69),
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildStatRow(
                      icon: Icons.check_circle,
                      label: 'Số câu đúng',
                      value:
                          '${submission.correctAnswers}/${submission.totalQuestions}',
                      color: Colors.green,
                    ),
                    const Divider(),

                    _buildStatRow(
                      icon: Icons.cancel,
                      label: 'Số câu sai',
                      value:
                          '${submission.totalQuestions - submission.correctAnswers}/${submission.totalQuestions}',
                      color: Colors.red,
                    ),
                    const Divider(),

                    _buildStatRow(
                      icon: Icons.percent,
                      label: 'Tỷ lệ đúng',
                      value: '${percentage.toStringAsFixed(1)}%',
                      color: const Color(0xFF6C63FF),
                    ),
                    const Divider(),

                    _buildStatRow(
                      icon: Icons.access_time,
                      label: 'Thời gian nộp',
                      value: submission.submittedAt != null 
                          ? _formatDate(submission.submittedAt!)
                          : 'Chưa rõ',
                      color: Colors.grey,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            ElevatedButton(
              onPressed: () {
                // Pop back to class detail or assignment list
                Navigator.of(context).popUntil(
                  (route) => route.isFirst || route.settings.name == '/class-detail',
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Quay lại lớp học',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
