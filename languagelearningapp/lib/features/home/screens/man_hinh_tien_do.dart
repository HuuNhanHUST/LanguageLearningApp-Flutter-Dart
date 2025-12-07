import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;
import '../../learning/providers/learning_provider.dart';

/// Màn hình Tiến độ
/// Hiển thị biểu đồ radar (pentagon), thống kê học tập
class ManHinhTienDo extends ConsumerStatefulWidget {
  const ManHinhTienDo({super.key});

  @override
  ConsumerState<ManHinhTienDo> createState() => _ManHinhTienDoState();
}

class _ManHinhTienDoState extends ConsumerState<ManHinhTienDo> {
  @override
  void initState() {
    super.initState();
    // Load progress when screen opens
    Future.microtask(() {
      ref.read(learningProvider.notifier).loadProgress();
    });
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningProvider);
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF2D1B69), Color(0xFF1A0F3E)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Text(
                  'Tiến độ học tập',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Theo dõi sự tiến bộ của bạn',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 30),
                
                // Biểu đồ radar (pentagon)
                _xayDungBieuDoRadar(learningState),
                const SizedBox(height: 30),
                
                // Thống kê chi tiết
                _xayDungThongKe(learningState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Xây dựng biểu đồ radar 5 chiều (giống ELSA)
  Widget _xayDungBieuDoRadar(LearningState learningState) {
    // Dữ liệu 5 kỹ năng (0.0 - 1.0) - tính từ XP và words learned
    final progress = learningState.totalWordsLearned / 100; // Tỷ lệ hoàn thành
    final Map<String, double> kyNang = {
      'Phát âm': (progress * 0.84).clamp(0.0, 1.0),
      'Nghe': (progress * 0.97).clamp(0.0, 1.0),
      'Lưu loát': (progress * 0.91).clamp(0.0, 1.0),
      'Nhấn âm': (progress * 0.99).clamp(0.0, 1.0),
      'Ngữ điệu': (progress * 0.83).clamp(0.0, 1.0),
    };

    return Container(
      padding: const EdgeInsets.all(30),
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
        children: [
          // Điểm ELSA tổng thể
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Điểm ELSA của bạn',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Trình độ: Native',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              Text(
                '${((learningState.totalWordsLearned / 500) * 100).clamp(0, 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF6C63FF),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Biểu đồ pentagon (placeholder - cần custom painter thật)
          SizedBox(
            height: 250,
            child: CustomPaint(
              size: const Size(250, 250),
              painter: _BieuDoRadarPainter(kyNang),
            ),
          ),
          const SizedBox(height: 20),
          
          // Legend các kỹ năng
          Wrap(
            spacing: 15,
            runSpacing: 10,
            children: kyNang.entries.map((entry) {
              return _xayDungNhanKyNang(entry.key, entry.value);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Xây dựng nhãn kỹ năng với phần trăm
  Widget _xayDungNhanKyNang(String ten, double giaTri) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF6C63FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$ten: ${(giaTri * 100).toInt()}%',
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF2D1B69),
            ),
          ),
        ],
      ),
    );
  }

  /// Xây dựng các thống kê chi tiết
  Widget _xayDungThongKe(LearningState learningState) {
    final cacThongKe = [
      {'tieu_de': 'Level hiện tại', 'gia_tri': 'Level ${learningState.level}', 'icon': Icons.stars, 'mau': const Color(0xFF6C63FF)},
      {'tieu_de': 'Điểm kinh nghiệm', 'gia_tri': '${learningState.xp} XP', 'icon': Icons.emoji_events, 'mau': const Color(0xFF4CAF50)},
      {'tieu_de': 'Từ vựng đã học', 'gia_tri': '${learningState.totalWordsLearned} từ', 'icon': Icons.library_books, 'mau': const Color(0xFFFF9800)},
      {'tieu_de': 'Chuỗi ngày học', 'gia_tri': '${learningState.streak} ngày', 'icon': Icons.local_fire_department, 'mau': const Color(0xFFE91E63)},
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.5,
      ),
      itemCount: cacThongKe.length,
      itemBuilder: (context, index) {
        final thongKe = cacThongKe[index];
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (thongKe['mau'] as Color).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  thongKe['icon'] as IconData,
                  color: thongKe['mau'] as Color,
                  size: 24,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    thongKe['gia_tri'] as String,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D1B69),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    thongKe['tieu_de'] as String,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Custom Painter để vẽ biểu đồ radar (pentagon)
class _BieuDoRadarPainter extends CustomPainter {
  final Map<String, double> duLieu;

  _BieuDoRadarPainter(this.duLieu);

  @override
  void paint(Canvas canvas, Size size) {
    final trungTam = Offset(size.width / 2, size.height / 2);
    final banKinh = size.width / 2 * 0.8;
    final soCanh = duLieu.length;

    // Vẽ lưới nền (5 vòng đồng tâm)
    final paintLuoi = Paint()
      ..color = Colors.grey.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (int i = 1; i <= 5; i++) {
      _veNgonSao(canvas, trungTam, banKinh * i / 5, soCanh, paintLuoi);
    }

    // Vẽ các đường kẻ từ tâm ra ngoài
    for (int i = 0; i < soCanh; i++) {
      final goc = -math.pi / 2 + (2 * math.pi * i / soCanh);
      final diem = Offset(
        trungTam.dx + banKinh * math.cos(goc),
        trungTam.dy + banKinh * math.sin(goc),
      );
      canvas.drawLine(trungTam, diem, paintLuoi);
    }

    // Vẽ dữ liệu thực tế
    final paintDuLieu = Paint()
      ..color = const Color(0xFF6C63FF).withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final paintDuongVien = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    final cacDiem = <Offset>[];
    int index = 0;
    for (final entry in duLieu.entries) {
      final goc = -math.pi / 2 + (2 * math.pi * index / soCanh);
      final khoangCach = banKinh * entry.value;
      final diem = Offset(
        trungTam.dx + khoangCach * math.cos(goc),
        trungTam.dy + khoangCach * math.sin(goc),
      );
      cacDiem.add(diem);
      index++;
    }

    // Vẽ polygon từ các điểm
    final path = Path()..moveTo(cacDiem[0].dx, cacDiem[0].dy);
    for (int i = 1; i < cacDiem.length; i++) {
      path.lineTo(cacDiem[i].dx, cacDiem[i].dy);
    }
    path.close();

    canvas.drawPath(path, paintDuLieu);
    canvas.drawPath(path, paintDuongVien);

    // Vẽ các điểm dữ liệu
    final paintDiem = Paint()
      ..color = const Color(0xFF6C63FF)
      ..style = PaintingStyle.fill;

    for (final diem in cacDiem) {
      canvas.drawCircle(diem, 4, paintDiem);
    }

    // Vẽ nhãn kỹ năng
    final cacNhan = duLieu.keys.toList();
    for (int i = 0; i < cacNhan.length; i++) {
      final goc = -math.pi / 2 + (2 * math.pi * i / soCanh);
      final khoangCach = banKinh + 20;
      final viTri = Offset(
        trungTam.dx + khoangCach * math.cos(goc),
        trungTam.dy + khoangCach * math.sin(goc),
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: cacNhan[i],
          style: const TextStyle(
            color: Color(0xFF2D1B69),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(
          viTri.dx - textPainter.width / 2,
          viTri.dy - textPainter.height / 2,
        ),
      );
    }
  }

  /// Vẽ một ngôi sao (polygon) đều
  void _veNgonSao(Canvas canvas, Offset trungTam, double banKinh, int soCanh, Paint paint) {
    final path = Path();
    for (int i = 0; i <= soCanh; i++) {
      final goc = -math.pi / 2 + (2 * math.pi * i / soCanh);
      final x = trungTam.dx + banKinh * math.cos(goc);
      final y = trungTam.dy + banKinh * math.sin(goc);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
