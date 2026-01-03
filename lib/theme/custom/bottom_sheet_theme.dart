import 'package:flutter/material.dart';
import '../utils/color_theme.dart';

/// Custom BottomSheet theme configurations for light and dark themes.
///
/// Provides consistent bottom sheet styling with proper colors,
/// drag handle, and shape for both light and dark themes.
abstract class CustomBottomSheetTheme {
  /// Light theme BottomSheet configuration
  static const lightBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: ColorTheme.white,
    modalBackgroundColor: ColorTheme.white,
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  );

  /// Dark theme BottomSheet configuration
  static const darkBottomSheetTheme = BottomSheetThemeData(
    showDragHandle: true,
    backgroundColor: ColorTheme.dark,
    modalBackgroundColor: ColorTheme.dark,
    constraints: BoxConstraints(minWidth: double.infinity),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
  );
}
