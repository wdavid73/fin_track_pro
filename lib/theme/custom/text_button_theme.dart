import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

/// Custom TextButton theme configurations for light and dark themes.
///
/// Provides consistent text button styling with proper colors,
/// padding, and text styles. Uses the same configuration for both
/// light and dark themes.
abstract class CustomTextButtonTheme {
  /// TextButton theme (shared for both light and dark themes)
  static final textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      foregroundColor: ColorTheme.textSecondary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  /// Light theme TextButton configuration (alias)
  static final lightTextButtonTheme = textButtonTheme;

  /// Dark theme TextButton configuration (alias)
  static final darkTextButtonTheme = textButtonTheme;
}
