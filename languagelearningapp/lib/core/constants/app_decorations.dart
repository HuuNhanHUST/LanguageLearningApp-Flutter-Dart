import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

/// App Decorations - Định nghĩa BoxDecoration và InputDecoration thống nhất
class AppDecorations {
  // Private constructor
  AppDecorations._();

  // ============================================================================
  // CARD DECORATIONS - Decoration cho Card/Container
  // ============================================================================
  
  /// Card decoration cơ bản - nền trắng, border nhẹ, shadow nhẹ
  static BoxDecoration card({
    Color? color,
    Color? borderColor,
    double? borderWidth,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: borderWidth ?? AppSpacing.borderThin,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Card với elevation cao - shadow đậm hơn
  static BoxDecoration cardElevated({
    Color? color,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: color ?? AppColors.surface,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 10,
          spreadRadius: 2,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  /// Card với primary border - dùng cho container highlight
  static BoxDecoration cardPrimary({
    double? borderWidth,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusLarge,
      ),
      border: Border.all(
        color: AppColors.primary,
        width: borderWidth ?? AppSpacing.borderMedium,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.1),
          blurRadius: 10,
          spreadRadius: 2,
        ),
      ],
    );
  }
  
  /// Card với gradient background
  static BoxDecoration cardGradient({
    Gradient? gradient,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowMedium,
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // ============================================================================
  // CONTAINER DECORATIONS - Các decoration đặc biệt
  // ============================================================================
  
  /// Container với background nhẹ (cho text container)
  static BoxDecoration containerLight({
    Color? backgroundColor,
    Color? borderColor,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: backgroundColor ?? AppColors.backgroundTertiary,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: borderColor ?? AppColors.border,
        width: AppSpacing.borderThin,
      ),
    );
  }
  
  /// Container với border highlight (success)
  static BoxDecoration containerSuccess({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.successBackground,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: AppColors.success,
        width: AppSpacing.borderMedium,
      ),
    );
  }
  
  /// Container với border highlight (warning)
  static BoxDecoration containerWarning({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.warningBackground,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: AppColors.warning,
        width: AppSpacing.borderMedium,
      ),
    );
  }
  
  /// Container với border highlight (error)
  static BoxDecoration containerError({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.errorBackground,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: AppColors.error,
        width: AppSpacing.borderMedium,
      ),
    );
  }
  
  /// Container với border highlight (info)
  static BoxDecoration containerInfo({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.infoBackground,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: AppColors.info,
        width: AppSpacing.borderMedium,
      ),
    );
  }

  // ============================================================================
  // INPUT DECORATIONS - Decoration cho TextField/TextFormField
  // ============================================================================
  
  /// Input decoration cơ bản
  static InputDecoration input({
    String? labelText,
    String? hintText,
    String? helperText,
    String? errorText,
    Widget? prefixIcon,
    Widget? suffixIcon,
    bool? enabled,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      errorText: errorText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      enabled: enabled ?? true,
      filled: true,
      fillColor: AppColors.backgroundSecondary,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppSpacing.borderThin,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.border,
          width: AppSpacing.borderThin,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.primary,
          width: AppSpacing.borderMedium,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppSpacing.borderThin,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.error,
          width: AppSpacing.borderMedium,
        ),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMedium),
        borderSide: const BorderSide(
          color: AppColors.borderDark,
          width: AppSpacing.borderThin,
        ),
      ),
    );
  }

  // ============================================================================
  // BUTTON DECORATIONS - Decoration cho Container button-like
  // ============================================================================
  
  /// Button decoration với màu primary
  static BoxDecoration buttonPrimary({
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: AppColors.primary,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  /// Button decoration với gradient
  static BoxDecoration buttonGradient({
    Gradient? gradient,
    double? borderRadius,
  }) {
    return BoxDecoration(
      gradient: gradient ?? AppColors.primaryGradient,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.primary.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
  
  /// Button decoration outlined
  static BoxDecoration buttonOutlined({
    Color? borderColor,
    double? borderRadius,
  }) {
    return BoxDecoration(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      border: Border.all(
        color: borderColor ?? AppColors.primary,
        width: AppSpacing.borderMedium,
      ),
    );
  }

  // ============================================================================
  // SPECIAL DECORATIONS
  // ============================================================================
  
  /// Decoration cho image container
  static BoxDecoration imageContainer({
    double? borderRadius,
    bool withShadow = true,
  }) {
    return BoxDecoration(
      color: AppColors.backgroundSecondary,
      borderRadius: BorderRadius.circular(
        borderRadius ?? AppSpacing.radiusMedium,
      ),
      boxShadow: withShadow
          ? [
              BoxShadow(
                color: AppColors.shadowLight,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ]
          : null,
    );
  }
  
  /// Decoration cho avatar/profile picture
  static BoxDecoration avatar({
    Color? borderColor,
    double? borderWidth,
  }) {
    return BoxDecoration(
      shape: BoxShape.circle,
      border: borderColor != null
          ? Border.all(
              color: borderColor,
              width: borderWidth ?? AppSpacing.borderMedium,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowLight,
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  /// Decoration cho bottom sheet
  static BoxDecoration bottomSheet() {
    return const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(AppSpacing.radiusExtraLarge),
        topRight: Radius.circular(AppSpacing.radiusExtraLarge),
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.shadowDark,
          blurRadius: 16,
          offset: Offset(0, -4),
        ),
      ],
    );
  }
}
