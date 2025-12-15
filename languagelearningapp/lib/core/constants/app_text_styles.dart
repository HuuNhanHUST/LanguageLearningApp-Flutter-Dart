import 'package:flutter/material.dart';
import 'app_colors.dart';

/// App Text Styles - Định nghĩa typography thống nhất
class AppTextStyles {
  // Private constructor
  AppTextStyles._();

  // ============================================================================
  // FONT FAMILY
  // ============================================================================
  
  /// Font family chính - System default
  static const String fontFamilyPrimary = 'Roboto';
  
  /// Font family phụ - Serif (cho văn bản đọc)
  static const String fontFamilySerif = 'serif';
  
  /// Font family monospace (cho code)
  static const String fontFamilyMono = 'monospace';

  // ============================================================================
  // DISPLAY STYLES - Tiêu đề lớn
  // ============================================================================
  
  /// Display Large - 57px
  static const TextStyle displayLarge = TextStyle(
    fontSize: 57.0,
    fontWeight: FontWeight.w400,
    letterSpacing: -0.25,
    color: AppColors.textPrimary,
    height: 1.12,
  );
  
  /// Display Medium - 45px
  static const TextStyle displayMedium = TextStyle(
    fontSize: 45.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.16,
  );
  
  /// Display Small - 36px
  static const TextStyle displaySmall = TextStyle(
    fontSize: 36.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.22,
  );

  // ============================================================================
  // HEADLINE STYLES - Tiêu đề
  // ============================================================================
  
  /// Headline Large - 32px
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.25,
  );
  
  /// Headline Medium - 28px
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.29,
  );
  
  /// Headline Small - 24px
  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.33,
  );

  // ============================================================================
  // TITLE STYLES - Tiêu đề nhỏ
  // ============================================================================
  
  /// Title Large - 22px
  static const TextStyle titleLarge = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0,
    color: AppColors.textPrimary,
    height: 1.27,
  );
  
  /// Title Medium - 18px (AppBar title)
  static const TextStyle titleMedium = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.15,
    color: AppColors.textPrimary,
    height: 1.33,
  );
  
  /// Title Small - 16px
  static const TextStyle titleSmall = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.43,
  );

  // ============================================================================
  // BODY STYLES - Nội dung chính
  // ============================================================================
  
  /// Body Large - 16px
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.5,
    color: AppColors.textPrimary,
    height: 1.5,
  );
  
  /// Body Medium - 15px (Văn bản đọc)
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 15.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.2,
    wordSpacing: 1.0,
    color: AppColors.textPrimary,
    height: 2.0, // Line height lớn cho dễ đọc
    fontFamily: fontFamilySerif,
  );
  
  /// Body Small - 14px
  static const TextStyle bodySmall = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.25,
    color: AppColors.textSecondary,
    height: 1.43,
  );

  // ============================================================================
  // LABEL STYLES - Nhãn, button text
  // ============================================================================
  
  /// Label Large - 14px (Button text)
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.1,
    color: AppColors.textPrimary,
    height: 1.43,
  );
  
  /// Label Medium - 12px
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textSecondary,
    height: 1.33,
  );
  
  /// Label Small - 11px
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
    color: AppColors.textTertiary,
    height: 1.45,
  );

  // ============================================================================
  // SPECIAL STYLES - Styles đặc biệt
  // ============================================================================
  
  /// Button Text - 14px bold
  static const TextStyle button = TextStyle(
    fontSize: 14.0,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.75,
    height: 1.0,
  );
  
  /// Caption - 12px (phụ đề, ghi chú)
  static const TextStyle caption = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.w400,
    letterSpacing: 0.4,
    color: AppColors.textSecondary,
    height: 1.33,
  );
  
  /// Overline - 10px uppercase (labels trên)
  static const TextStyle overline = TextStyle(
    fontSize: 10.0,
    fontWeight: FontWeight.w500,
    letterSpacing: 1.5,
    color: AppColors.textTertiary,
    height: 1.6,
  );

  // ============================================================================
  // HELPER METHODS - Các methods hỗ trợ
  // ============================================================================
  
  /// Tạo style với màu tùy chỉnh
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }
  
  /// Tạo style với font weight tùy chỉnh
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
  
  /// Tạo style với font size tùy chỉnh
  static TextStyle withSize(TextStyle style, double size) {
    return style.copyWith(fontSize: size);
  }
  
  /// Tạo style cho text trên nền tối
  static TextStyle onDark(TextStyle style) {
    return style.copyWith(color: AppColors.textOnDark);
  }
  
  /// Tạo style cho link/hyperlink
  static TextStyle asLink(TextStyle style) {
    return style.copyWith(
      color: AppColors.primary,
      decoration: TextDecoration.underline,
    );
  }
  
  /// Tạo style cho text bị strikethrough
  static TextStyle asStrikethrough(TextStyle style) {
    return style.copyWith(
      decoration: TextDecoration.lineThrough,
      color: AppColors.textDisabled,
    );
  }
}
