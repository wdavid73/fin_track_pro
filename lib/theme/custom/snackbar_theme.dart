import 'package:flutter/material.dart';
import '../utils/color_theme.dart';
import '../utils/sizes.dart';
import 'text_theme.dart';

/// Custom SnackBar theme configurations for light and dark themes.
///
/// Provides consistent snackbar styling with proper colors, behavior,
/// and shapes for both light and dark themes.
abstract class CustomSnackBarTheme {
  /// Light theme SnackBar configuration
  static SnackBarThemeData lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: ColorTheme.surfaceColor,
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(AppSizes.sm),
    actionBackgroundColor: Colors.transparent,
    disabledActionBackgroundColor: Colors.transparent,
    disabledActionTextColor: Colors.white,
    contentTextStyle: CustomTextTheme.lightTextTheme.bodyLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
    ),
  );

  /// Dark theme SnackBar configuration
  static SnackBarThemeData darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: ColorTheme.dark,
    behavior: SnackBarBehavior.floating,
    insetPadding: const EdgeInsets.all(AppSizes.sm),
    actionBackgroundColor: Colors.transparent,
    disabledActionBackgroundColor: Colors.transparent,
    disabledActionTextColor: Colors.white,
    contentTextStyle: CustomTextTheme.darkTextTheme.bodyLarge,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
    ),
  );
}
