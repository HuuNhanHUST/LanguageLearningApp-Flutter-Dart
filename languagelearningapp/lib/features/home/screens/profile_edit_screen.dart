import 'package:flutter/material.dart';
import '../../auth/services/auth_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _firstName;
  String? _lastName;
  String? _avatar;
  String? _nativeLanguage;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  void _loadUser() async {
    final user = await AuthService().getProfile();
    setState(() {
      _firstName = user.firstName;
      _lastName = user.lastName;
      _avatar = user.avatar;
      _nativeLanguage = user.nativeLanguage;
    });
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _loading = true);
    try {
      await AuthService().updateProfile(
        firstName: _firstName,
        lastName: _lastName,
        avatar: _avatar,
        nativeLanguage: _nativeLanguage,
      );
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Cập nhật thành công!')));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Chỉnh sửa hồ sơ'),
        backgroundColor: const Color(0xFF2D1B69),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
                    TextFormField(
                      initialValue: _firstName,
                      decoration: const InputDecoration(labelText: 'Tên'),
                      onSaved: (val) => _firstName = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập tên' : null,
                    ),
                    TextFormField(
                      initialValue: _lastName,
                      decoration: const InputDecoration(labelText: 'Họ'),
                      onSaved: (val) => _lastName = val,
                      validator: (val) =>
                          val == null || val.isEmpty ? 'Nhập họ' : null,
                    ),
                    TextFormField(
                      initialValue: _avatar,
                      decoration: const InputDecoration(
                        labelText: 'Avatar URL',
                      ),
                      onSaved: (val) => _avatar = val,
                    ),
                    TextFormField(
                      initialValue: _nativeLanguage,
                      decoration: const InputDecoration(
                        labelText: 'Ngôn ngữ mẹ đẻ',
                      ),
                      onSaved: (val) => _nativeLanguage = val,
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6C63FF),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Lưu', style: TextStyle(fontSize: 18)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
