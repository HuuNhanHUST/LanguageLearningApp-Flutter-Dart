import 'package:flutter/material.dart';

/// Màn hình Điều khoản dịch vụ
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Điều Khoản Dịch Vụ'),
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
                  const Icon(Icons.policy, color: Colors.white, size: 48),
                  const SizedBox(height: 16),
                  const Text(
                    'Điều Khoản Sử Dụng',
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
              title: '1. Chấp Nhận Điều Khoản',
              content: 'Bằng việc truy cập và sử dụng ứng dụng Language Learning App, bạn đồng ý tuân thủ và bị ràng buộc bởi các điều khoản và điều kiện sau đây. Nếu bạn không đồng ý với bất kỳ phần nào của các điều khoản này, vui lòng không sử dụng dịch vụ của chúng tôi.',
            ),
            _buildSection(
              title: '2. Tài Khoản Người Dùng',
              content: 'Khi đăng ký tài khoản, bạn đồng ý cung cấp thông tin chính xác, đầy đủ và cập nhật. Bạn có trách nhiệm duy trì tính bảo mật của tài khoản và mật khẩu của mình. Bạn chấp nhận chịu trách nhiệm cho tất cả các hoạt động diễn ra dưới tài khoản của bạn.',
            ),
            _buildSection(
              title: '3. Nội Dung và Quyền Sở Hữu Trí Tuệ',
              content: 'Tất cả nội dung trong ứng dụng, bao gồm văn bản, đồ họa, logo, biểu tượng, hình ảnh, âm thanh, video và phần mềm, đều thuộc sở hữu của Language Learning App hoặc các nhà cung cấp nội dung của chúng tôi và được bảo vệ bởi luật bản quyền quốc tế.',
            ),
            _buildSection(
              title: '4. Sử Dụng Dịch Vụ',
              content: 'Bạn đồng ý sử dụng dịch vụ của chúng tôi chỉ cho các mục đích hợp pháp và theo cách không xâm phạm quyền của bên thứ ba hoặc hạn chế hoặc cản trở việc sử dụng và hưởng thụ dịch vụ của họ. Việc sử dụng không hợp lý bao gồm:\n\n• Sao chép, phân phối hoặc sửa đổi bất kỳ phần nào của dịch vụ mà không có sự cho phép\n• Sử dụng dịch vụ cho mục đích bất hợp pháp hoặc gian lận\n• Can thiệp vào hoạt động bình thường của dịch vụ\n• Cố gắng truy cập trái phép vào bất kỳ phần nào của dịch vụ',
            ),
            _buildSection(
              title: '5. Gói Dịch Vụ và Thanh Toán',
              content: 'Chúng tôi cung cấp cả dịch vụ miễn phí và các gói trả phí. Đối với các gói trả phí, bạn đồng ý thanh toán đầy đủ các khoản phí được nêu rõ. Các khoản phí không được hoàn lại trừ khi có quy định khác trong chính sách hoàn tiền của chúng tôi.',
            ),
            _buildSection(
              title: '6. Chấm Dứt Dịch Vụ',
              content: 'Chúng tôi có quyền tạm ngừng hoặc chấm dứt quyền truy cập của bạn vào dịch vụ ngay lập tức, mà không cần thông báo trước, nếu chúng tôi tin rằng bạn đã vi phạm các điều khoản này hoặc tham gia vào hành vi gian lận hoặc bất hợp pháp.',
            ),
            _buildSection(
              title: '7. Giới Hạn Trách Nhiệm',
              content: 'Trong phạm vi tối đa được pháp luật cho phép, Language Learning App không chịu trách nhiệm cho bất kỳ thiệt hại trực tiếp, gián tiếp, ngẫu nhiên, đặc biệt hoặc hậu quả nào phát sinh từ việc sử dụng hoặc không thể sử dụng dịch vụ của chúng tôi.',
            ),
            _buildSection(
              title: '8. Thay Đổi Điều Khoản',
              content: 'Chúng tôi có quyền sửa đổi các điều khoản này bất kỳ lúc nào. Chúng tôi sẽ thông báo cho người dùng về các thay đổi quan trọng. Việc tiếp tục sử dụng dịch vụ sau khi các thay đổi được công bố có nghĩa là bạn chấp nhận các điều khoản đã được sửa đổi.',
            ),
            _buildSection(
              title: '9. Luật Áp Dụng',
              content: 'Các điều khoản này được điều chỉnh và hiểu theo luật pháp của Việt Nam. Mọi tranh chấp phát sinh từ hoặc liên quan đến các điều khoản này sẽ được giải quyết tại các tòa án có thẩm quyền tại Việt Nam.',
            ),
            _buildSection(
              title: '10. Liên Hệ',
              content: 'Nếu bạn có bất kỳ câu hỏi nào về các điều khoản này, vui lòng liên hệ với chúng tôi qua:\n\nEmail: support@languagelearning.app\nĐịa chỉ: Tầng 10, Tòa nhà A, 123 Đường ABC, Quận 1, TP.HCM\nĐiện thoại: +84 123 456 789',
            ),

            const SizedBox(height: 32),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Color(0xFF6C63FF)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Bằng cách tiếp tục sử dụng ứng dụng, bạn xác nhận rằng bạn đã đọc, hiểu và đồng ý với các điều khoản này.',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.7),
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
