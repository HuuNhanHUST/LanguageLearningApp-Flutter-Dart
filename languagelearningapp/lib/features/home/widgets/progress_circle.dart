import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProgressCircle extends StatelessWidget {
  final double percentage;
  final double size;
  final double strokeWidth;
  final Color? color;

  const ProgressCircle({
    super.key,
    required this.percentage,
    this.size = 100,
    this.strokeWidth = 10,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _ProgressCirclePainter(
          percentage: percentage,
          strokeWidth: strokeWidth,
          color: color ?? const Color(0xFF00D4FF),
        ),
        child: Center(
          child: Text(
            '${percentage.toInt()}%',
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.25,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressCirclePainter extends CustomPainter {
  final double percentage;
  final double strokeWidth;
  final Color color;

  _ProgressCirclePainter({
    required this.percentage,
    required this.strokeWidth,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, bgPaint);

    // Progress arc
    final progressPaint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final sweepAngle = 2 * math.pi * (percentage / 100);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
