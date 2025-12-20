import 'package:flutter/material.dart';
import '../utils/color_theme.dart';
import '../utils/sizes.dart';

/// Custom Checkbox theme configurations for light and dark themes.
///
/// Provides consistent checkbox styling with proper state handling
/// for selected/unselected states in both light and dark themes.
abstract class CustomCheckboxTheme {
  /// Light theme Checkbox configuration
  static CheckboxThemeData lightCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.xs),
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorTheme.white;
      } else {
        return ColorTheme.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorTheme.primaryColor;
      } else {
        return Colors.transparent;
      }
    }),
  );

  /// Dark theme Checkbox configuration
  static CheckboxThemeData darkCheckboxTheme = CheckboxThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(AppSizes.xs),
    ),
    checkColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorTheme.white;
      } else {
        return ColorTheme.black;
      }
    }),
    fillColor: WidgetStateProperty.resolveWith((states) {
      if (states.contains(WidgetState.selected)) {
        return ColorTheme.primaryColor;
      } else {
        return Colors.transparent;
      }
    }),
  );
}
