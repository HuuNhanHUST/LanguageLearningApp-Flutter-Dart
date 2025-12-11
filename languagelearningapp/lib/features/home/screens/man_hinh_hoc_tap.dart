import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart' as provider;
import 'man_hinh_bai_hoc_phat_am.dart';
import 'man_hinh_bai_hoc_ngu_phap.dart';
import '../../../screens/text_scan_screen.dart';
import '../../learning/widgets/daily_progress_widget.dart';
import '../../learning/providers/learning_provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../auth/models/user_model.dart';

/// Màn hình Dashboard - Tab Học tập chính
/// Hiển thị các bài học, categories, tiến độ giống ELSA
class ManHinhHocTap extends ConsumerStatefulWidget {
  const ManHinhHocTap({super.key});

  @override
  ConsumerState<ManHinhHocTap> createState() => _ManHinhHocTapState();
}

class _ManHinhHocTapState extends ConsumerState<ManHinhHocTap> {
  @override
  void initState() {
    super.initState();
    // Load learning progress khi màn hình được khởi tạo
    Future.microtask(() => ref.read(learningProvider.notifier).loadProgress());
  }

  @override
  Widget build(BuildContext context) {
    final learningState = ref.watch(learningProvider);
    final authProvider = provider.Provider.of<AuthProvider>(context);
    final user = authProvider.user;

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
          child: learningState.isLoading
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header với avatar và greeting
                      _xayDungHeader(user, learningState),
                      const SizedBox(height: 16),

                      // XP Progress Bar
                      _xayDungThanhXp(learningState),
                      const SizedBox(height: 20),

                      // Daily Progress Widget (NEW)
                      const DailyProgressWidget(),
                      const SizedBox(height: 20),

                      // Danh sách bài học
                      _xayDungTieuDe('Bài học của bạn'),
                      const SizedBox(height: 15),
                      _xayDungDanhSachBaiHoc(),
                      const SizedBox(height: 30),

                      // Categories
                      _xayDungTieuDe('Chủ đề học tập'),
                      const SizedBox(height: 15),
                      _xayDungDanhSachChuDe(),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  /// Xây dựng header với avatar và lời chào
  Widget _xayDungHeader(User? user, LearningState learningState) {
    final displayName = user?.firstName?.isNotEmpty == true
        ? user!.firstName
        : user?.fullName ?? 'Học viên';
    final subtitle = user?.username != null ? '@${user!.username}' : '';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào 👋',
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
        // Avatar + level badge
        Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.white,
              backgroundImage: user?.avatar != null
                  ? NetworkImage(user!.avatar!)
                  : null,
              child: user?.avatar == null
                  ? Text(
                      (user?.firstName.isNotEmpty == true
                              ? user!.firstName[0]
                              : 'L')
                          .toUpperCase(),
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6C63FF),
                      ),
                    )
                  : null,
            ),
            Positioned(
              bottom: -4,
              right: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, size: 14, color: Colors.white),
                    const SizedBox(width: 4),
                    Text(
                      'Lv.${learningState.level}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Thanh tiến trình XP
  Widget _xayDungThanhXp(LearningState learningState) {
    final current = learningState.xpInCurrentLevel;
    final needed = learningState.xpNeededForNextLevel;
    final totalInLevel = current + needed;
    final isMaxLevel = needed <= 0 && learningState.xpForNextLevel == null;
    final nextLevelLabel = isMaxLevel ? 'MAX' : 'Lv.${learningState.level + 1}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tiến độ Level',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                isMaxLevel
                    ? 'Đã đạt cấp tối đa'
                    : '${current.toString()} / ${totalInLevel.toString()} XP',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: learningState.xpProgress),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            builder: (context, value, child) {
              return ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: LinearProgressIndicator(
                  value: value,
                  minHeight: 14,
                  backgroundColor: Colors.white.withOpacity(0.12),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF00E0FF),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Lv.${learningState.level}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                nextLevelLabel,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng vòng tròn hiển thị tiến độ tổng thể
  Widget _xayDungVongTronTienDo() {
    return Container(
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6C63FF), Color(0xFF4CAF50)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6C63FF).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Vòng tròn tiến độ
          SizedBox(
            width: 120,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CircularProgressIndicator(
                    value: 0.86, // 86%
                    strokeWidth: 12,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Colors.white,
                    ),
                  ),
                ),
                const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '86%',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Hoàn thành',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Thông tin thống kê
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _xayDungThongKe('🎯', 'Mục tiêu', '5/7 ngày'),
              const SizedBox(height: 15),
              _xayDungThongKe('🔥', 'Chuỗi ngày', '12 ngày'),
              const SizedBox(height: 15),
              _xayDungThongKe('⏱️', 'Thời gian', '2.5 giờ'),
            ],
          ),
        ],
      ),
    );
  }

  /// Xây dựng một dòng thống kê (icon + label + value)
  Widget _xayDungThongKe(String icon, String nhan, String giaTri) {
    return Row(
      children: [
        Text(icon, style: const TextStyle(fontSize: 20)),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              nhan,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            Text(
              giaTri,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Xây dựng tiêu đề section
  Widget _xayDungTieuDe(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Xây dựng danh sách các bài học
  Widget _xayDungDanhSachBaiHoc() {
    final cacBaiHoc = [
      {
        'ten': 'Bài học 1',
        'chuDe': 'Phát âm ',
        'tienDo': 0.8,
        'mau': const Color(0xFF6C63FF),
        'loai': 'pronunciation',
      },
      {
        'ten': 'Bài học 2',
        'chuDe': 'Trắc nghiệm ngữ pháp',
        'tienDo': 0.5,
        'mau': const Color(0xFF4CAF50),
        'loai': 'grammar',
      },
      {
        'ten': 'Bài học 3',
        'chuDe': 'Từ vựng hàng ngày',
        'tienDo': 0.3,
        'mau': const Color(0xFFFF9800),
        'loai': 'coming-soon',
      },
    ];

    return Column(
      children: cacBaiHoc.map((baiHoc) {
        return Container(
          margin: const EdgeInsets.only(bottom: 15),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: Row(
            children: [
              // Icon bài học
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: baiHoc['mau'] as Color,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 15),
              // Thông tin bài học
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      baiHoc['ten'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      baiHoc['chuDe'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: LinearProgressIndicator(
                        value: baiHoc['tienDo'] as double,
                        backgroundColor: Colors.white.withOpacity(0.2),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          baiHoc['mau'] as Color,
                        ),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Nút bắt đầu
              GestureDetector(
                onTap: () {
                  final loai = baiHoc['loai'];
                  Widget? manHinh;

                  if (loai == 'grammar') {
                    manHinh = ManHinhBaiHocNguPhap(
                      tenBaiHoc: baiHoc['ten'] as String,
                      chuDe: baiHoc['chuDe'] as String,
                    );
                  } else if (loai == 'pronunciation') {
                    manHinh = ManHinhBaiHocPhatAm(
                      tenBaiHoc: baiHoc['ten'] as String,
                      chuDe: baiHoc['chuDe'] as String,
                    );
                  }

                  if (manHinh != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => manHinh!),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Bài học ${baiHoc['ten']} đang phát triển'),
                      ),
                    );
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: baiHoc['mau'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.play_arrow, color: Colors.white),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Xây dựng grid các chủ đề học tập
  Widget _xayDungDanhSachChuDe() {
    final cacChuDe = [
      {
        'ten': 'Phát âm',
        'soLuong': '24 bài',
        'icon': Icons.mic,
        'mau': const Color(0xFF6C63FF),
      },
      {
        'ten': 'Ngữ pháp',
        'soLuong': '18 bài',
        'icon': Icons.book,
        'mau': const Color(0xFF4CAF50),
      },
      {
        'ten': 'Từ vựng',
        'soLuong': '32 bài',
        'icon': Icons.library_books,
        'mau': const Color(0xFFFF9800),
      },
      {
        'ten': 'Giao tiếp',
        'soLuong': '15 bài',
        'icon': Icons.chat,
        'mau': const Color(0xFFE91E63),
      },
      {
        'ten': 'Quét văn bản',
        'soLuong': 'OCR',
        'icon': Icons.document_scanner,
        'mau': const Color(0xFF00BCD4),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 1.3,
      ),
      itemCount: cacChuDe.length,
      itemBuilder: (context, index) {
        final chuDe = cacChuDe[index];
        return GestureDetector(
          onTap: () {
            // Nếu là chủ đề Phát âm -> chuyển thẳng đến bài học
            if (chuDe['ten'] == 'Phát âm') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ManHinhBaiHocPhatAm(
                    tenBaiHoc: 'Luyện phát âm cơ bản',
                    chuDe: 'Phát âm',
                  ),
                ),
              );
            }
            // Nếu là Từ vựng -> chuyển đến Vocabulary List Screen
            else if (chuDe['ten'] == 'Từ vựng') {
              context.push('/vocabulary');
            }
            // Nếu là Quét văn bản -> chuyển đến Text Scan Screen
            else if (chuDe['ten'] == 'Quét văn bản') {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TextScanScreen()),
              );
            }
            // Các chủ đề khác hiển thị thông báo
            else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chức năng ${chuDe['ten']} đang phát triển'),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  chuDe['mau'] as Color,
                  (chuDe['mau'] as Color).withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: (chuDe['mau'] as Color).withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(chuDe['icon'] as IconData, color: Colors.white, size: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      chuDe['ten'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      chuDe['soLuong'] as String,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
