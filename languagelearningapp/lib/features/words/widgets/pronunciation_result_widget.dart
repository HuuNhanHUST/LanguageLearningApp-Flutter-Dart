import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

import '../models/pronunciation_result_model.dart';
import '../services/text_to_speech_service.dart';

/// Widget hiển thị kết quả chấm điểm phát âm
class PronunciationResultWidget extends StatefulWidget {
  final PronunciationResultModel result;
  final VoidCallback? onRetry;
  final VoidCallback? onNext;

  const PronunciationResultWidget({
    super.key,
    required this.result,
    this.onRetry,
    this.onNext,
  });

  @override
  State<PronunciationResultWidget> createState() =>
      _PronunciationResultWidgetState();
}

class _PronunciationResultWidgetState extends State<PronunciationResultWidget> {
  final TextToSpeechService _ttsService = TextToSpeechService();

  @override
  void dispose() {
    _ttsService.dispose();
    super.dispose();
  }

  /// Lấy màu theo điểm số
  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  /// Lấy thông báo theo điểm số
  String _getScoreMessage(double score) {
    if (score >= 90) return 'Xuất sắc! 🎉';
    if (score >= 80) return 'Tốt lắm! 👏';
    if (score >= 70) return 'Khá tốt! 👍';
    if (score >= 60) return 'Ổn đấy! 😊';
    return 'Cố gắng thêm nhé! 💪';
  }

  /// Lấy màu theo trạng thái từ
  Color _getWordColor(WordDetail word) {
    switch (word.status) {
      case 'correct':
        return Colors.green;
      case 'close':
        return Colors.orange;
      case 'wrong':
        return Colors.red;
      case 'missing':
        return Colors.grey;
      case 'extra':
        return Colors.purple;
      default:
        return Colors.black;
    }
  }

  /// Lấy icon theo trạng thái từ
  IconData _getWordIcon(WordDetail word) {
    switch (word.status) {
      case 'correct':
        return Icons.check_circle;
      case 'close':
        return Icons.info;
      case 'wrong':
        return Icons.cancel;
      case 'missing':
        return Icons.remove_circle;
      case 'extra':
        return Icons.add_circle;
      default:
        return Icons.help;
    }
  }

  @override
  Widget build(BuildContext context) {
    final scoreColor = _getScoreColor(widget.result.score);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          const Text(
            'Kết quả chấm điểm',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 24),

          // Điểm số với CircularPercentIndicator
          Center(
            child: Column(
              children: [
                CircularPercentIndicator(
                  radius: 80.0,
                  lineWidth: 12.0,
                  percent: widget.result.score / 100,
                  center: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${widget.result.score.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: scoreColor,
                        ),
                      ),
                      Text(
                        'điểm',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                  progressColor: scoreColor,
                  backgroundColor: Colors.grey[200]!,
                  circularStrokeCap: CircularStrokeCap.round,
                  animation: true,
                  animationDuration: 1000,
                ),
                const SizedBox(height: 16),
                Text(
                  _getScoreMessage(widget.result.score),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Độ chính xác: ${widget.result.accuracy}%',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Thống kê
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                icon: Icons.check_circle,
                color: Colors.green,
                label: 'Đúng',
                value: widget.result.stats.correctWords,
              ),
              _buildStatItem(
                icon: Icons.cancel,
                color: Colors.red,
                label: 'Sai',
                value: widget.result.stats.wrongWords,
              ),
              _buildStatItem(
                icon: Icons.info,
                color: Colors.orange,
                label: 'Gần đúng',
                value: widget.result.stats.closeWords,
              ),
            ],
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // Chi tiết từng từ
          const Text(
            'Chi tiết từng từ',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2D1B69),
            ),
          ),
          const SizedBox(height: 12),

          // Hiển thị RichText với màu sắc
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: widget.result.wordDetails.map((wordDetail) {
              return _buildWordChip(wordDetail);
            }).toList(),
          ),

          const SizedBox(height: 24),

          // Các nút hành động
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (widget.onRetry != null)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: widget.onRetry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFF6366F1)),
                      foregroundColor: const Color(0xFF6366F1),
                    ),
                  ),
                ),
              if (widget.onRetry != null && widget.onNext != null)
                const SizedBox(width: 12),
              if (widget.onNext != null)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: widget.onNext,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Tiếp tục'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: const Color(0xFF4CAF50),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  /// Build thống kê item
  Widget _buildStatItem({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }

  /// Build chip từ với màu sắc và nút phát âm
  Widget _buildWordChip(WordDetail wordDetail) {
    final color = _getWordColor(wordDetail);
    final icon = _getWordIcon(wordDetail);

    return IntrinsicWidth(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 6),

            // Hiển thị từ
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  wordDetail.word,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                    decoration: wordDetail.isWrong || wordDetail.isClose
                        ? TextDecoration.underline
                        : null,
                  ),
                ),
                // Hiển thị từ đúng nếu sai
                if (wordDetail.expected != null) ...[
                  Text(
                    '→ ${wordDetail.expected}',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[700],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),

            // Nút phát âm lại (chỉ hiển thị khi sai hoặc gần đúng)
            if (wordDetail.isWrong || wordDetail.isClose) ...[
              const SizedBox(width: 6),
              InkWell(
                onTap: () {
                  // Phát âm từ đúng
                  final correctWord = wordDetail.expected ?? wordDetail.word;
                  _ttsService.speak(correctWord);
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 14,
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
