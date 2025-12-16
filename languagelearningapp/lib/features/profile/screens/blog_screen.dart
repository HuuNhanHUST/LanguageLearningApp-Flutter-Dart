import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Màn hình Blog học tập
class BlogScreen extends StatelessWidget {
  const BlogScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Blog Học Tập'),
        backgroundColor: const Color(0xFF1F1147),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildBlogPost(
            context,
            title: '10 Mẹo Học Từ Vựng Hiệu Quả',
            excerpt: 'Khám phá các phương pháp học từ vựng được chứng minh khoa học giúp bạn ghi nhớ lâu hơn và ứng dụng tốt hơn trong giao tiếp.',
            imageUrl: 'https://images.unsplash.com/photo-1456513080510-7bf3a84b82f8?w=400',
            date: '10 Tháng 12, 2024',
            readTime: '5 phút đọc',
            url: 'https://www.fluentu.com/blog/best-way-to-learn-vocabulary/',
          ),
          const SizedBox(height: 16),
          _buildBlogPost(
            context,
            title: 'Phương Pháp Shadowing - Học Phát Âm Như Người Bản Xứ',
            excerpt: 'Shadowing là kỹ thuật lặp lại đồng thời với người nói bản ngữ, giúp cải thiện phát âm, ngữ điệu và khả năng nghe hiểu.',
            imageUrl: 'https://images.unsplash.com/photo-1590650153855-d9e808231d41?w=400',
            date: '5 Tháng 12, 2024',
            readTime: '7 phút đọc',
            url: 'https://www.fluentin3months.com/shadowing/',
          ),
          const SizedBox(height: 16),
          _buildBlogPost(
            context,
            title: 'Cách Duy Trì Động Lực Học Ngoại Ngữ Dài Hạn',
            excerpt: 'Bí quyết giữ vững tinh thần học tập, vượt qua giai đoạn trì trệ và biến việc học thành thói quen hàng ngày.',
            imageUrl: 'https://images.unsplash.com/photo-1503676260728-1c00da094a0b?w=400',
            date: '1 Tháng 12, 2024',
            readTime: '6 phút đọc',
            url: 'https://www.theguardian.com/education/2014/oct/30/learn-language-stay-motivated',
          ),
          const SizedBox(height: 16),
          _buildBlogPost(
            context,
            title: 'Ứng Dụng Công Nghệ AI Trong Học Ngoại Ngữ',
            excerpt: 'Tìm hiểu cách AI và machine learning đang cách mạng hóa cách chúng ta học và thực hành ngoại ngữ.',
            imageUrl: 'https://images.unsplash.com/photo-1677442136019-21780ecad995?w=400',
            date: '25 Tháng 11, 2024',
            readTime: '8 phút đọc',
            url: 'https://www.britishcouncil.org/voices-magazine/how-artificial-intelligence-transforming-language-learning',
          ),
          const SizedBox(height: 16),
          _buildBlogPost(
            context,
            title: 'Lộ Trình Học Tiếng Anh Từ Zero Đến Hero',
            excerpt: 'Kế hoạch chi tiết từng giai đoạn, giúp người mới bắt đầu xây dựng nền tảng vững chắc và phát triển toàn diện 4 kỹ năng.',
            imageUrl: 'https://images.unsplash.com/photo-1434030216411-0b793f4b4173?w=400',
            date: '20 Tháng 11, 2024',
            readTime: '10 phút đọc',
            url: 'https://www.ef.com/wwen/blog/language/the-ultimate-guide-to-learning-english/',
          ),
        ],
      ),
    );
  }

  Widget _buildBlogPost(
    BuildContext context, {
    required String title,
    required String excerpt,
    required String imageUrl,
    required String date,
    required String readTime,
    required String url,
  }) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Không thể mở liên kết')),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.1)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                imageUrl,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 180,
                    color: const Color(0xFF6C63FF).withOpacity(0.2),
                    child: const Icon(
                      Icons.image,
                      size: 64,
                      color: Colors.white30,
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Excerpt
                  Text(
                    excerpt,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Meta info
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        date,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.white.withOpacity(0.5),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        readTime,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.5),
                          fontSize: 12,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.arrow_forward,
                        size: 20,
                        color: const Color(0xFF6C63FF),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
