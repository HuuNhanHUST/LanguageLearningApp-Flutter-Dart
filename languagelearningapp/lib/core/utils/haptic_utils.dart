import 'package:flutter/services.dart';

/// Utility class for Haptic Feedback throughout the app
class HapticUtils {
  /// Light haptic feedback for general interactions
  /// Use for: button taps, card selections, toggles
  static Future<void> lightImpact() async {
    await HapticFeedback.lightImpact();
  }

  /// Medium haptic feedback for important actions
  /// Use for: recording button, submit button, like button
  static Future<void> mediumImpact() async {
    await HapticFeedback.mediumImpact();
  }

  /// Heavy haptic feedback for critical actions or errors
  /// Use for: errors, warnings, delete actions
  static Future<void> heavyImpact() async {
    await HapticFeedback.heavyImpact();
  }

  /// Selection haptic feedback for picker/scrolling
  static Future<void> selectionClick() async {
    await HapticFeedback.selectionClick();
  }

  /// Vibrate pattern for success
  static Future<void> success() async {
    await HapticFeedback.lightImpact();
    await Future.delayed(const Duration(milliseconds: 50));
    await HapticFeedback.lightImpact();
  }

  /// Vibrate pattern for error
  static Future<void> error() async {
    await HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    await HapticFeedback.heavyImpact();
  }
}
