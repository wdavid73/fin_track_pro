import 'package:flutter/material.dart';
import '../utils/color_theme.dart';
import '../utils/sizes.dart';

/// Custom OutlinedButton theme configurations for light and dark themes.
///
/// Provides consistent outlined button styling with proper border colors,
/// text styles, and padding for both light and dark themes.
abstract class CustomOutlinedButtonTheme {
  /// Light theme OutlinedButton configuration
  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: ColorTheme.dark,
      side: const BorderSide(color: ColorTheme.borderPrimary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: ColorTheme.black,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );

  /// Dark theme OutlinedButton configuration
  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      elevation: 0,
      foregroundColor: ColorTheme.light,
      side: const BorderSide(color: ColorTheme.borderPrimary),
      textStyle: const TextStyle(
        fontSize: 16,
        color: ColorTheme.textWhite,
        fontWeight: FontWeight.w600,
      ),
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.buttonHeight,
        horizontal: 20,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );
}
