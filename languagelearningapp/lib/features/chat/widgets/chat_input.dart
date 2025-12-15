import 'package:flutter/material.dart';
import '../../../core/design_system.dart';

/// Widget nhập liệu chat với nút gửi
class ChatInput extends StatefulWidget {
  final Function(String) onSendMessage;
  final bool isEnabled;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.isEnabled = true,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _hasText = _controller.text.trim().isNotEmpty;
    });
  }

  void _handleSend() {
    final text = _controller.text.trim();
    if (text.isNotEmpty && widget.isEnabled) {
      widget.onSendMessage(text);
      _controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: AppSpacing.md + MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Text field
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.backgroundSecondary,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
                  border: Border.all(color: AppColors.border),
                ),
                child: TextField(
                  controller: _controller,
                  enabled: widget.isEnabled,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  decoration: const InputDecoration(
                    hintText: 'Nhập tin nhắn...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  ),
                  style: AppTextStyles.bodyMedium,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            
            // Send button
            Material(
              color: _hasText && widget.isEnabled
                  ? AppColors.primary
                  : AppColors.backgroundTertiary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
              child: InkWell(
                onTap: _hasText && widget.isEnabled ? _handleSend : null,
                borderRadius: BorderRadius.circular(AppSpacing.radiusCircular),
                child: Container(
                  width: AppSpacing.buttonHeightLarge,
                  height: AppSpacing.buttonHeightLarge,
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.send,
                    color: _hasText && widget.isEnabled
                        ? AppColors.textOnDark
                        : AppColors.textTertiary,
                    size: AppSpacing.iconSmall,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
