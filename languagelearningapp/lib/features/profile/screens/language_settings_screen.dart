import 'package:flutter/material.dart';

/// Màn hình cài đặt ngôn ngữ học
class LanguageSettingsScreen extends StatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  State<LanguageSettingsScreen> createState() => _LanguageSettingsScreenState();
}

class _LanguageSettingsScreenState extends State<LanguageSettingsScreen> {
  String _appLanguage = 'vi'; // vi or en
  final List<String> _learningLanguages = ['en']; // User's learning languages
  
  bool _isLoading = false;

  final List<Map<String, dynamic>> _availableLearningLanguages = [
    {'code': 'en', 'name': 'Tiếng Anh', 'flag': '🇬🇧', 'level': 'Intermediate'},
    {'code': 'ko', 'name': 'Tiếng Hàn', 'flag': '🇰🇷', 'level': 'Beginner'},
    {'code': 'ja', 'name': 'Tiếng Nhật', 'flag': '🇯🇵', 'level': 'Beginner'},
    {'code': 'zh', 'name': 'Tiếng Trung', 'flag': '🇨🇳', 'level': 'Beginner'},
    {'code': 'fr', 'name': 'Tiếng Pháp', 'flag': '🇫🇷', 'level': 'Beginner'},
    {'code': 'es', 'name': 'Tiếng Tây Ban Nha', 'flag': '🇪🇸', 'level': 'Beginner'},
    {'code': 'de', 'name': 'Tiếng Đức', 'flag': '🇩🇪', 'level': 'Beginner'},
  ];

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Call API to save language settings
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Lưu cài đặt thành công!'),
              ],
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _toggleLearningLanguage(String code) {
    setState(() {
      if (_learningLanguages.contains(code)) {
        if (_learningLanguages.length > 1) {
          _learningLanguages.remove(code);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Bạn phải chọn ít nhất một ngôn ngữ học'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        _learningLanguages.add(code);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Ngôn ngữ'),
        backgroundColor: const Color(0xFF1F1147),
        elevation: 0,
        actions: [
          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _saveSettings,
              icon: const Icon(Icons.check, color: Colors.white),
              label: const Text(
                'Lưu',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // App Language Section
          _buildSectionTitle('Ngôn ngữ ứng dụng', Icons.language),
          const SizedBox(height: 16),
          
          _buildLanguageTile(
            flag: '🇻🇳',
            title: 'Tiếng Việt',
            subtitle: 'Vietnamese',
            isSelected: _appLanguage == 'vi',
            onTap: () {
              setState(() => _appLanguage = 'vi');
            },
          ),
          
          _buildLanguageTile(
            flag: '🇬🇧',
            title: 'English',
            subtitle: 'Tiếng Anh',
            isSelected: _appLanguage == 'en',
            onTap: () {
              setState(() => _appLanguage = 'en');
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Chức năng đang phát triển')),
              );
            },
          ),
          
          const SizedBox(height: 32),
          
          // Learning Languages Section
          _buildSectionTitle('Ngôn ngữ bạn đang học', Icons.school),
          const SizedBox(height: 8),
          Text(
            'Chọn ngôn ngữ bạn muốn học (có thể chọn nhiều)',
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          
          ..._availableLearningLanguages.map((lang) {
            final isSelected = _learningLanguages.contains(lang['code']);
            return _buildLearningLanguageTile(
              flag: lang['flag'],
              title: lang['name'],
              subtitle: lang['level'],
              isSelected: isSelected,
              onTap: () => _toggleLearningLanguage(lang['code']),
            );
          }).toList(),
          
          const SizedBox(height: 32),
          
          // Add new language button
          OutlinedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Sẽ có thêm ngôn ngữ trong tương lai')),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Thêm ngôn ngữ mới'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF6C63FF),
              side: const BorderSide(color: Color(0xFF6C63FF)),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // Info card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF6C63FF).withOpacity(0.3),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: Color(0xFF6C63FF),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Bạn có thể học nhiều ngôn ngữ cùng lúc. Tiến trình của mỗi ngôn ngữ được theo dõi riêng biệt.',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Widget _buildLanguageTile({
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? const Color(0xFF6C63FF).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFF6C63FF)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Text(flag, style: const TextStyle(fontSize: 32)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
        trailing: isSelected
            ? const Icon(Icons.check_circle, color: Color(0xFF6C63FF))
            : const Icon(Icons.circle_outlined, color: Colors.white54),
      ),
    );
  }

  Widget _buildLearningLanguageTile({
    required String flag,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isSelected 
            ? const Color(0xFF6C63FF).withOpacity(0.2)
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected 
              ? const Color(0xFF6C63FF)
              : Colors.white.withOpacity(0.1),
          width: isSelected ? 2 : 1,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Text(flag, style: const TextStyle(fontSize: 32)),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: _getLevelColor(subtitle).withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  color: _getLevelColor(subtitle),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        trailing: Checkbox(
          value: isSelected,
          onChanged: (_) => onTap(),
          activeColor: const Color(0xFF6C63FF),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
        ),
      ),
    );
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
