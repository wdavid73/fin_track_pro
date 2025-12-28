import 'package:fin_track_pro/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

/// Custom TextButton theme configurations for light and dark themes.
///
/// Provides consistent text button styling with proper colors,
/// padding, and text styles. Uses the same configuration for both
/// light and dark themes.
abstract class CustomTextButtonTheme {
  /// TextButton theme (shared for both light and dark themes)
  static TextButtonThemeData textButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      foregroundColor: ColorTheme.textSecondary,
      textStyle: CustomTextTheme.lightTextTheme.bodyMedium!,
    ),
  );

  /// Light theme TextButton configuration (alias)
  static TextButtonThemeData lightTextButtonTheme = textButtonTheme;

  /// Dark theme TextButton configuration (alias)
  static TextButtonThemeData darkTextButtonTheme = textButtonTheme;
}
