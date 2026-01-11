import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/submission_model.dart';
import '../services/grammar_question_service.dart';
import '../../auth/services/auth_service.dart';

class GradebookScreen extends StatefulWidget {
  final String classId;
  final String className;

  const GradebookScreen({
    Key? key,
    required this.classId,
    required this.className,
  }) : super(key: key);

  @override
  State<GradebookScreen> createState() => _GradebookScreenState();
}

class _GradebookScreenState extends State<GradebookScreen> {
  List<SubmissionModel>? _submissions;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadSubmissions();
  }

  Future<void> _loadSubmissions() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final token = await authService.getAccessToken();

      if (token == null) {
        throw Exception('Không tìm thấy token');
      }

      final submissions = await GrammarQuestionService().getClassSubmissions(
        classId: widget.classId,
        token: token,
      );

      setState(() {
        _submissions = submissions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bảng điểm'),
            Text(
              widget.className,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSubmissions,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Lỗi: $_error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadSubmissions,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (_submissions == null || _submissions!.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Chưa có bài nộp nào',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Calculate statistics
    final totalSubmissions = _submissions!.length;
    final averageScore = _submissions!.fold<double>(
          0,
          (sum, submission) => sum + submission.score,
        ) /
        totalSubmissions;
    final highestScore = _submissions!.fold<double>(
      0,
      (max, submission) => submission.score > max ? submission.score : max,
    );
    final lowestScore = _submissions!.fold<double>(
      10,
      (min, submission) => submission.score < min ? submission.score : min,
    );

    return Column(
      children: [
        // Statistics card
        Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).primaryColor,
                Theme.of(context).primaryColor.withOpacity(0.7),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              const Text(
                'Thống kê',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    label: 'Tổng bài nộp',
                    value: '$totalSubmissions',
                    icon: Icons.assignment_turned_in,
                  ),
                  _StatItem(
                    label: 'Điểm TB',
                    value: averageScore.toStringAsFixed(1),
                    icon: Icons.analytics,
                  ),
                  _StatItem(
                    label: 'Cao nhất',
                    value: highestScore.toStringAsFixed(1),
                    icon: Icons.trending_up,
                  ),
                  _StatItem(
                    label: 'Thấp nhất',
                    value: lowestScore.toStringAsFixed(1),
                    icon: Icons.trending_down,
                  ),
                ],
              ),
            ],
          ),
        ),
        // Submissions list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _submissions!.length,
            itemBuilder: (context, index) {
              final submission = _submissions![index];
              return _SubmissionCard(
                submission: submission,
                rank: index + 1,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    Key? key,
    required this.label,
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.white70,
          ),
        ),
      ],
    );
  }
}

class _SubmissionCard extends StatelessWidget {
  final SubmissionModel submission;
  final int rank;

  const _SubmissionCard({
    Key? key,
    required this.submission,
    required this.rank,
  }) : super(key: key);

  Color _getScoreColor(double score) {
    if (score >= 8) return Colors.green;
    if (score >= 6.5) return Colors.blue;
    if (score >= 5) return Colors.orange;
    return Colors.red;
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.emoji_events;
      case 2:
        return Icons.military_tech;
      case 3:
        return Icons.workspace_premium;
      default:
        return Icons.person;
    }
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.brown[300]!;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(submission.score);
    final rankIcon = _getRankIcon(rank);
    final rankColor = _getRankColor(rank);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(rankIcon, color: rankColor, size: 20),
                  Text(
                    '#$rank',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: rankColor,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Student info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    submission.student, // Note: Backend needs to populate this
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.check_circle_outline, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${submission.correctAnswers}/${submission.totalQuestions} câu',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(Icons.percent, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${submission.percentage.toStringAsFixed(0)}%',
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  if (submission.submittedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Nộp: ${_formatDate(submission.submittedAt!)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ],
              ),
            ),
            // Score
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: scoreColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: scoreColor, width: 2),
              ),
              child: Column(
                children: [
                  Text(
                    submission.score.toStringAsFixed(1),
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: scoreColor,
                    ),
                  ),
                  Text(
                    '/ 10',
                    style: TextStyle(
                      fontSize: 12,
                      color: scoreColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
