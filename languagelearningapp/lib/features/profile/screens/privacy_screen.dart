import 'package:flutter/material.dart';

/// Màn hình Chính sách bảo mật
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Chính Sách Bảo Mật'),
        backgroundColor: const Color(0xFF1F1147),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF423074)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.privacy_tip, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Chính Sách Bảo Mật',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Cập nhật lần cuối: 10 Tháng 12, 2024',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Content
            _buildSection(
              title: '1. Thông Tin Chúng Tôi Thu Thập',
              content: 'Chúng tôi thu thập các loại thông tin sau để cung cấp và cải thiện dịch vụ của mình:\n\n• Thông tin tài khoản: Tên, email, mật khẩu (được mã hóa)\n• Thông tin học tập: Tiến độ học tập, từ vựng đã học, điểm số, chuỗi ngày học\n• Thông tin thiết bị: Loại thiết bị, hệ điều hành, địa chỉ IP\n• Thông tin sử dụng: Thời gian sử dụng, tính năng được truy cập, tương tác với ứng dụng',
            ),
            _buildSection(
              title: '2. Cách Chúng Tôi Sử Dụng Thông Tin',
              content: 'Thông tin của bạn được sử dụng cho các mục đích sau:\n\n• Cung cấp và duy trì dịch vụ\n• Cá nhân hóa trải nghiệm học tập\n• Theo dõi tiến độ và tạo báo cáo\n• Gửi thông báo và cập nhật quan trọng\n• Cải thiện và phát triển tính năng mới\n• Phân tích xu hướng sử dụng\n• Phát hiện và ngăn chặn gian lận',
            ),
            _buildSection(
              title: '3. Bảo Mật Dữ Liệu',
              content: 'Chúng tôi thực hiện các biện pháp bảo mật kỹ thuật và tổ chức phù hợp để bảo vệ dữ liệu của bạn:\n\n• Mã hóa dữ liệu trong quá trình truyền tải (SSL/TLS)\n• Mã hóa mật khẩu bằng thuật toán bcrypt\n• Lưu trữ dữ liệu trên máy chủ được bảo mật\n• Giới hạn quyền truy cập chỉ cho nhân viên được ủy quyền\n• Sao lưu dữ liệu định kỳ\n• Kiểm tra bảo mật thường xuyên',
            ),
            _buildSection(
              title: '4. Chia Sẻ Thông Tin',
              content: 'Chúng tôi không bán thông tin cá nhân của bạn cho bên thứ ba. Chúng tôi chỉ chia sẻ thông tin trong các trường hợp sau:\n\n• Với nhà cung cấp dịch vụ đáng tin cậy (lưu trữ đám mây, phân tích)\n• Khi được yêu cầu bởi pháp luật hoặc cơ quan có thẩm quyền\n• Để bảo vệ quyền lợi và an toàn của chúng tôi và người dùng\n• Với sự đồng ý rõ ràng của bạn',
            ),
            _buildSection(
              title: '5. Cookies và Công Nghệ Theo Dõi',
              content: 'Chúng tôi sử dụng cookies và các công nghệ tương tự để:\n\n• Ghi nhớ phiên đăng nhập của bạn\n• Lưu trữ tùy chọn và cài đặt\n• Phân tích lưu lượng truy cập\n• Cải thiện trải nghiệm người dùng\n\nBạn có thể quản lý cookies thông qua cài đặt trình duyệt của mình.',
            ),
            _buildSection(
              title: '6. Quyền Của Người Dùng',
              content: 'Bạn có các quyền sau đối với dữ liệu cá nhân của mình:\n\n• Truy cập: Xem dữ liệu cá nhân chúng tôi lưu trữ\n• Chỉnh sửa: Cập nhật thông tin không chính xác\n• Xóa: Yêu cầu xóa tài khoản và dữ liệu\n• Tải xuống: Nhận bản sao dữ liệu của bạn\n• Phản đối: Từ chối một số hoạt động xử lý dữ liệu\n• Khiếu nại: Gửi khiếu nại đến cơ quan quản lý',
            ),
            _buildSection(
              title: '7. Lưu Trữ Dữ Liệu',
              content: 'Chúng tôi lưu trữ dữ liệu của bạn miễn là tài khoản của bạn còn hoạt động hoặc khi cần thiết để cung cấp dịch vụ. Khi bạn xóa tài khoản:\n\n• Dữ liệu cá nhân sẽ bị xóa trong vòng 30 ngày\n• Một số dữ liệu có thể được giữ lại để tuân thủ pháp luật\n• Dữ liệu đã ẩn danh có thể được giữ lại cho mục đích phân tích',
            ),
            _buildSection(
              title: '8. Chuyển Giao Dữ Liệu Quốc Tế',
              content: 'Dữ liệu của bạn có thể được xử lý và lưu trữ trên các máy chủ đặt tại các quốc gia khác nhau. Chúng tôi đảm bảo rằng việc chuyển giao này tuân thủ các tiêu chuẩn bảo mật phù hợp và các quy định bảo vệ dữ liệu hiện hành.',
            ),
            _buildSection(
              title: '9. Quyền Riêng Tư Của Trẻ Em',
              content: 'Dịch vụ của chúng tôi không nhắm đến trẻ em dưới 13 tuổi. Chúng tôi không cố ý thu thập thông tin cá nhân từ trẻ em. Nếu bạn tin rằng chúng tôi đã vô tình thu thập thông tin từ trẻ em, vui lòng liên hệ với chúng tôi để xóa thông tin đó.',
            ),
            _buildSection(
              title: '10. Thay Đổi Chính Sách',
              content: 'Chúng tôi có thể cập nhật chính sách bảo mật này theo thời gian. Chúng tôi sẽ thông báo cho bạn về các thay đổi quan trọng bằng cách đăng chính sách mới trên ứng dụng và/hoặc gửi email thông báo.',
            ),
            _buildSection(
              title: '11. Liên Hệ',
              content: 'Nếu bạn có bất kỳ câu hỏi hoặc thắc mắc nào về chính sách bảo mật này, vui lòng liên hệ:\n\nEmail: privacy@languagelearning.app\nĐịa chỉ: Tầng 10, Tòa nhà A, 123 Đường ABC, Quận 1, TP.HCM\nĐiện thoại: +84 123 456 789\n\nChúng tôi cam kết phản hồi trong vòng 48 giờ làm việc.',
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.shield, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chúng tôi cam kết bảo vệ quyền riêng tư và dữ liệu cá nhân của bạn. Sự tin tưởng của bạn là ưu tiên hàng đầu của chúng tôi.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 13,
                      ),
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

  Widget _buildSection({required String title, required String content}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
