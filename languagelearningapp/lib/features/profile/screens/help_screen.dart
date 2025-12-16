import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'blog_screen.dart';
import 'terms_screen.dart';
import 'privacy_screen.dart';

/// Màn hình trợ giúp và hỗ trợ
class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  Future<void> _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể mở liên kết'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Trợ giúp & Hỗ trợ'),
        backgroundColor: const Color(0xFF1F1147),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // FAQ Section
          _buildSectionTitle('Câu hỏi thường gặp', Icons.help_outline),
          const SizedBox(height: 16),
          
          _buildFAQItem(
            question: 'Làm thế nào để bắt đầu học?',
            answer: 'Chọn một bài học từ màn hình chính và bắt đầu học các từ mới. Bạn có thể học tối đa 30 từ mỗi ngày.',
          ),
          
          _buildFAQItem(
            question: 'Chuỗi ngày học hoạt động như thế nào?',
            answer: 'Chuỗi ngày học tăng lên mỗi ngày bạn học ít nhất 1 từ. Nếu bạn bỏ lỡ một ngày, chuỗi sẽ bị đặt lại về 0.',
          ),
          
          _buildFAQItem(
            question: 'Làm sao để nhận huy chương?',
            answer: 'Hoàn thành các thử thách và mốc quan trọng như học liên tiếp 7 ngày, đạt 1000 XP, hoặc hoàn thành 100 từ.',
          ),
          
          _buildFAQItem(
            question: 'Tôi có thể học nhiều ngôn ngữ cùng lúc không?',
            answer: 'Có! Bạn có thể học nhiều ngôn ngữ. Tiến trình của mỗi ngôn ngữ được theo dõi riêng biệt.',
          ),
          
          _buildFAQItem(
            question: 'Làm thế nào để nâng cấp lên Premium?',
            answer: 'Truy cập phần Cài đặt > Nâng cấp Premium để xem các gói và quyền lợi. Hiện tại chức năng đang phát triển.',
          ),
          
          const SizedBox(height: 32),
          
          // Resources Section
          _buildSectionTitle('Tài nguyên', Icons.menu_book_outlined),
          const SizedBox(height: 16),
          
          _buildActionTile(
            icon: Icons.article_outlined,
            title: 'Blog học tập',
            subtitle: 'Mẹo và hướng dẫn học ngoại ngữ',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const BlogScreen()),
              );
            },
          ),
          
          _buildActionTile(
            icon: Icons.policy_outlined,
            title: 'Điều khoản dịch vụ',
            subtitle: 'Xem điều khoản sử dụng',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TermsScreen()),
              );
            },
          ),
          
          _buildActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Chính sách bảo mật',
            subtitle: 'Cách chúng tôi bảo vệ dữ liệu của bạn',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PrivacyScreen()),
              );
            },
          ),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF), size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildFAQItem({
    required String question,
    required String answer,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Theme(
        data: ThemeData(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          title: Text(
            question,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
          iconColor: const Color(0xFF6C63FF),
          collapsedIconColor: Colors.white54,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                answer,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF6C63FF).withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF6C63FF)),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.white54),
      ),
    );
  }

}
