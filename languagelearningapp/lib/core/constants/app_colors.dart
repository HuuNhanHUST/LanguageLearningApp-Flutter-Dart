import 'package:flutter/material.dart';

/// App Color Palette - Định nghĩa màu sắc thống nhất cho toàn app
class AppColors {
  // Private constructor để ngăn khởi tạo
  AppColors._();

  // ============================================================================
  // PRIMARY COLORS - Màu chính của app
  // ============================================================================
  
  /// Màu chính - Indigo 500 (dùng cho AppBar, Buttons, Borders chính)
  static const Color primary = Color(0xFF6366F1);
  
  /// Màu chính đậm hơn - Indigo 600
  static const Color primaryDark = Color(0xFF4F46E5);
  
  /// Màu chính nhạt hơn - Indigo 400
  static const Color primaryLight = Color(0xFF818CF8);
  
  /// Màu nền primary với opacity
  static const Color primaryBackground = Color(0xFFEEF2FF); // Indigo 50

  // ============================================================================
  // SECONDARY COLORS - Màu phụ
  // ============================================================================
  
  /// Màu phụ - Purple 600
  static const Color secondary = Color(0xFF9333EA);
  
  /// Màu phụ đậm hơn - Purple 700
  static const Color secondaryDark = Color(0xFF7E22CE);
  
  /// Màu phụ nhạt hơn - Purple 400
  static const Color secondaryLight = Color(0xFFC084FC);

  // ============================================================================
  // SEMANTIC COLORS - Màu theo ngữ nghĩa
  // ============================================================================
  
  /// Màu thành công - Green 600
  static const Color success = Color(0xFF16A34A);
  static const Color successLight = Color(0xFF22C55E);
  static const Color successBackground = Color(0xFFDCFCE7); // Green 100
  
  /// Màu cảnh báo - Orange 600
  static const Color warning = Color(0xFFEA580C);
  static const Color warningLight = Color(0xFFF97316);
  static const Color warningBackground = Color(0xFFFFEDD5); // Orange 100
  
  /// Màu lỗi - Red 600
  static const Color error = Color(0xFFDC2626);
  static const Color errorLight = Color(0xFFEF4444);
  static const Color errorBackground = Color(0xFFFEE2E2); // Red 100
  
  /// Màu thông tin - Blue 600
  static const Color info = Color(0xFF2563EB);
  static const Color infoLight = Color(0xFF3B82F6);
  static const Color infoBackground = Color(0xFFDBEAFE); // Blue 100

  // ============================================================================
  // NEUTRAL COLORS - Màu trung tính (Text, Backgrounds, Borders)
  // ============================================================================
  
  /// Màu text chính
  static const Color textPrimary = Color(0xFF1F2937); // Gray 800
  
  /// Màu text phụ
  static const Color textSecondary = Color(0xFF6B7280); // Gray 500
  
  /// Màu text mờ
  static const Color textTertiary = Color(0xFF9CA3AF); // Gray 400
  
  /// Màu text disabled
  static const Color textDisabled = Color(0xFFD1D5DB); // Gray 300
  
  /// Màu text trên nền tối
  static const Color textOnDark = Color(0xFFFFFFFF);
  
  /// Màu nền chính
  static const Color background = Color(0xFFFFFFFF);
  
  /// Màu nền phụ
  static const Color backgroundSecondary = Color(0xFFF9FAFB); // Gray 50
  
  /// Màu nền tertiary
  static const Color backgroundTertiary = Color(0xFFF3F4F6); // Gray 100
  
  /// Màu surface (cards, containers)
  static const Color surface = Color(0xFFFFFFFF);
  
  /// Màu surface với elevation
  static const Color surfaceElevated = Color(0xFFFAFAFA);
  
  /// Màu border
  static const Color border = Color(0xFFE5E7EB); // Gray 200
  
  /// Màu border đậm
  static const Color borderDark = Color(0xFFD1D5DB); // Gray 300
  
  /// Màu divider
  static const Color divider = Color(0xFFE5E7EB); // Gray 200

  // ============================================================================
  // OVERLAY COLORS - Màu phủ (Shadows, Overlays)
  // ============================================================================
  
  /// Shadow nhẹ
  static const Color shadowLight = Color(0x0A000000);
  
  /// Shadow trung bình
  static const Color shadowMedium = Color(0x14000000);
  
  /// Shadow đậm
  static const Color shadowDark = Color(0x1F000000);
  
  /// Overlay tối (cho modal, bottom sheet)
  static const Color overlayDark = Color(0x80000000);
  
  /// Overlay nhẹ
  static const Color overlayLight = Color(0x0D000000);

  // ============================================================================
  // GRADIENT COLORS - Màu gradient
  // ============================================================================
  
  /// Gradient chính (Primary)
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1), // Indigo 500
      Color(0xFF8B5CF6), // Purple 500
    ],
  );
  
  /// Gradient thành công (Success)
  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF10B981), // Green 500
      Color(0xFF059669), // Green 600
    ],
  );
  
  /// Gradient cảnh báo (Warning)
  static const LinearGradient warningGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF59E0B), // Amber 500
      Color(0xFFF97316), // Orange 500
    ],
  );

  // ============================================================================
  // FEATURE SPECIFIC COLORS - Màu đặc thù cho từng feature
  // ============================================================================
  
  /// Màu cho Text Recognition feature
  static const Color textRecognition = primary;
  
  /// Màu cho Audio Recording feature
  static const Color audioRecording = Color(0xFF2D1B69); // Deep Purple
  
  /// Màu cho Translation feature
  static const Color translation = Color(0xFFEA580C); // Orange
  
  /// Màu cho Word Learning feature
  static const Color wordLearning = Color(0xFF10B981); // Green

  // ============================================================================
  // HELPER METHODS
  // ============================================================================
  
  /// Tạo màu với opacity
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  /// Làm sáng màu
  static Color lighten(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness + amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
  
  /// Làm tối màu
  static Color darken(Color color, [double amount = 0.1]) {
    final hsl = HSLColor.fromColor(color);
    final lightness = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(lightness).toColor();
  }
}
