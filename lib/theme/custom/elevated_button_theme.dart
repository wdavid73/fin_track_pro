import 'package:flutter/material.dart';
import '../utils/color_theme.dart';
import '../utils/sizes.dart';

/// Custom ElevatedButton theme configurations for light and dark themes.
///
/// Provides consistent elevated button styling with proper colors,
/// elevation, padding, and text styles for both light and dark themes.
/// Uses a unified style for both themes as the primary button appearance
/// remains consistent across light and dark modes.
abstract class CustomElevatedButtonTheme {
  /// Shared ElevatedButton configuration for both light and dark themes
  static final elevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: ColorTheme.textWhite,
      backgroundColor: ColorTheme.primaryColor,
      disabledForegroundColor: ColorTheme.darkGrey,
      disabledBackgroundColor: ColorTheme.buttonDisabled,
      side: const BorderSide(color: ColorTheme.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.buttonHeight),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );

  /// Light theme specific configuration (if needed in the future)
  static final lightElevatedButtonTheme = elevatedButtonTheme;

  /// Dark theme specific configuration (if needed in the future)
  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: ColorTheme.textWhite,
      backgroundColor: ColorTheme.primaryColor,
      disabledForegroundColor: ColorTheme.darkGrey,
      disabledBackgroundColor: ColorTheme.buttonDisabled,
      side: const BorderSide(color: ColorTheme.primaryColor),
      padding: const EdgeInsets.symmetric(vertical: AppSizes.buttonHeight),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.buttonRadius),
      ),
    ),
  );
}
