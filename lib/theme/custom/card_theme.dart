import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

/// Custom Card theme configurations for light and dark themes.
///
/// Provides consistent card styling with proper elevation, colors,
/// and border radius for both light and dark themes.
abstract class CustomCardTheme {
  /// Light theme Card configuration
  static const lightCardTheme = CardThemeData(
    elevation: 0,
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      side: BorderSide(width: 1, color: ColorTheme.borderColor),
    ),
  );

  /// Dark theme Card configuration
  static const darkCardTheme = CardThemeData(
    elevation: 0,
    color: ColorTheme.onSurfaceColor,
    surfaceTintColor: ColorTheme.onSurfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      side: BorderSide(width: 1, color: Colors.white12),
    ),
  );
}
