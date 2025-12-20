import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

/// Custom SnackBar theme configurations for light and dark themes.
///
/// Provides consistent snackbar styling with proper colors, behavior,
/// and shapes for both light and dark themes.
abstract class CustomSnackBarTheme {
  /// Light theme SnackBar configuration
  static const lightSnackBarTheme = SnackBarThemeData(
    backgroundColor: ColorTheme.onSurfaceColor,
    behavior: SnackBarBehavior.floating,
    insetPadding: EdgeInsets.all(10),
    actionBackgroundColor: Colors.transparent,
    disabledActionBackgroundColor: Colors.transparent,
    disabledActionTextColor: Colors.white,
    contentTextStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
  );

  /// Dark theme SnackBar configuration
  static const darkSnackBarTheme = SnackBarThemeData(
    backgroundColor: ColorTheme.surfaceColor,
    behavior: SnackBarBehavior.floating,
    insetPadding: EdgeInsets.all(10),
    actionBackgroundColor: Colors.transparent,
    disabledActionBackgroundColor: Colors.transparent,
    disabledActionTextColor: Colors.white,
    contentTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: ColorTheme.light,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(12),
        topRight: Radius.circular(12),
      ),
    ),
  );
}
