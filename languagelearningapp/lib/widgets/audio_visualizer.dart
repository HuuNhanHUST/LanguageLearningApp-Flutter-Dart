import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/audio_recorder_provider.dart';

/// A simple smooth bar visualizer driven by amplitudeStreamProvider (0..1)
class AudioVisualizer extends ConsumerWidget {
  final double height;
  final int bars;
  final Color color;
  final double barWidth;
  final double spacing;

  const AudioVisualizer({
    super.key,
    this.height = 60,
    this.bars = 24,
    this.color = const Color(0xFF6366F1),
    this.barWidth = 3,
    this.spacing = 2,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncAmp = ref.watch(amplitudeStreamProvider);
    final amp = asyncAmp.asData?.value ?? 0.0; // 0..1

    return SizedBox(
      height: height,
      child: CustomPaint(
        painter: _BarsPainter(
          amplitude: amp,
          bars: bars,
          color: color,
          barWidth: barWidth,
          spacing: spacing,
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}

class _BarsPainter extends CustomPainter {
  final double amplitude; // 0..1
  final int bars;
  final Color color;
  final double barWidth;
  final double spacing;

  _BarsPainter({
    required this.amplitude,
    required this.bars,
    required this.color,
    required this.barWidth,
    required this.spacing,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final totalWidth = bars * barWidth + (bars - 1) * spacing;
    final startX = (size.width - totalWidth) / 2.0;

    for (int i = 0; i < bars; i++) {
      // Create a gentle curve across bars with the current amplitude
      final t = i / (bars - 1);
      final envelope = (1 - (2 * t - 1) * (2 * t - 1)); // bell shape 0..1
      final barH = (size.height * (0.1 + 0.9 * amplitude) * envelope).clamp(2.0, size.height);

      final x = startX + i * (barWidth + spacing);
      final rect = Rect.fromLTWH(x, (size.height - barH) / 2, barWidth, barH);
      final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rrect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BarsPainter oldDelegate) {
    return oldDelegate.amplitude != amplitude ||
        oldDelegate.bars != bars ||
        oldDelegate.color != color ||
        oldDelegate.barWidth != barWidth ||
        oldDelegate.spacing != spacing;
  }
}
