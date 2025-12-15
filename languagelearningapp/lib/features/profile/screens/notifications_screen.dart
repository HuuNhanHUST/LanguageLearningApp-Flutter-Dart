import 'package:flutter/material.dart';

/// Màn hình cài đặt thông báo
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _pushNotifications = true;
  bool _emailNotifications = false;
  bool _dailyReminder = true;
  bool _weeklyReport = true;
  bool _achievementAlerts = true;
  bool _streakReminder = true;
  
  TimeOfDay _reminderTime = const TimeOfDay(hour: 19, minute: 0);
  
  bool _isLoading = false;

  Future<void> _saveSettings() async {
    setState(() => _isLoading = true);
    
    try {
      // TODO: Call API to save notification settings
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

  Future<void> _pickTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF6C63FF),
              surface: Color(0xFF1F1147),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _reminderTime) {
      setState(() {
        _reminderTime = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0E0A24),
      appBar: AppBar(
        title: const Text('Thông báo'),
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
          // General Notifications Section
          _buildSectionTitle('Thông báo chung', Icons.notifications_outlined),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            icon: Icons.notifications_active,
            title: 'Thông báo đẩy',
            subtitle: 'Nhận thông báo đẩy trên thiết bị',
            value: _pushNotifications,
            onChanged: (value) {
              setState(() => _pushNotifications = value);
            },
          ),
          
          _buildSwitchTile(
            icon: Icons.email_outlined,
            title: 'Thông báo email',
            subtitle: 'Nhận thông báo qua email',
            value: _emailNotifications,
            onChanged: (value) {
              setState(() => _emailNotifications = value);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Learning Reminders Section
          _buildSectionTitle('Nhắc nhở học tập', Icons.school_outlined),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            icon: Icons.alarm,
            title: 'Nhắc nhở hàng ngày',
            subtitle: _dailyReminder 
                ? 'Lúc ${_reminderTime.format(context)}'
                : 'Tắt nhắc nhở',
            value: _dailyReminder,
            onChanged: (value) {
              setState(() => _dailyReminder = value);
            },
            trailing: _dailyReminder 
                ? IconButton(
                    icon: const Icon(Icons.access_time, color: Color(0xFF6C63FF)),
                    onPressed: _pickTime,
                  )
                : null,
          ),
          
          _buildSwitchTile(
            icon: Icons.bar_chart,
            title: 'Báo cáo tuần',
            subtitle: 'Tổng kết tiến trình học tập hàng tuần',
            value: _weeklyReport,
            onChanged: (value) {
              setState(() => _weeklyReport = value);
            },
          ),
          
          const SizedBox(height: 32),
          
          // Achievements Section
          _buildSectionTitle('Thành tích', Icons.emoji_events_outlined),
          const SizedBox(height: 16),
          
          _buildSwitchTile(
            icon: Icons.stars,
            title: 'Thông báo thành tích',
            subtitle: 'Khi đạt huy chương mới',
            value: _achievementAlerts,
            onChanged: (value) {
              setState(() => _achievementAlerts = value);
            },
          ),
          
          _buildSwitchTile(
            icon: Icons.local_fire_department,
            title: 'Nhắc chuỗi ngày học',
            subtitle: 'Khi có nguy cơ mất chuỗi ngày học',
            value: _streakReminder,
            onChanged: (value) {
              setState(() => _streakReminder = value);
            },
          ),
          
          const SizedBox(height: 32),
          
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
                    'Thông báo giúp bạn duy trì thói quen học tập hiệu quả hơn',
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

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
    Widget? trailing,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: ListTile(
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
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 13,
          ),
        ),
        trailing: trailing ?? Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFF6C63FF),
        ),
      ),
    );
  }
}
