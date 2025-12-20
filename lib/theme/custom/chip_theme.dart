import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

/// Custom Chip theme configurations for light and dark themes.
///
/// Provides consistent chip styling with proper colors for
/// selected/disabled states in both light and dark themes.
abstract class CustomChipTheme {
  /// Light theme Chip configuration
  static ChipThemeData lightChipTheme = ChipThemeData(
    disabledColor: ColorTheme.grey.withOpacity(0.4),
    labelStyle: const TextStyle(color: ColorTheme.black),
    selectedColor: ColorTheme.primaryColor,
    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: ColorTheme.white,
  );

  /// Dark theme Chip configuration
  static ChipThemeData darkChipTheme = const ChipThemeData(
    disabledColor: ColorTheme.darkerGrey,
    labelStyle: TextStyle(color: ColorTheme.white),
    selectedColor: ColorTheme.primaryColor,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
    checkmarkColor: ColorTheme.white,
  );
}
