import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:flutter/material.dart';

/// A utility class that centralizes all constant values and base theme data
/// used across both light and dark themes in the application.
///
/// This class provides shared theme configurations for widgets that don't
/// have dedicated custom theme files. Widget-specific themes are located in
/// the `custom/` directory for better modularity.
///
/// **Modular Themes (defined in custom/ directory):**
/// - AppBarTheme → custom/appbar_theme.dart
/// - BottomSheetTheme → custom/bottom_sheet_theme.dart
/// - CardTheme → custom/card_theme.dart
/// - CheckboxTheme → custom/checkbox_theme.dart
/// - ChipTheme → custom/chip_theme.dart
/// - ElevatedButtonTheme → custom/elevated_button_theme.dart
/// - InputDecorationTheme → custom/text_field_theme.dart
/// - OutlinedButtonTheme → custom/outlined_button_theme.dart
/// - SnackBarTheme → custom/snackbar_theme.dart
/// - TextButtonTheme → custom/text_button_theme.dart
/// - TextTheme → custom/text_theme.dart
class ThemeConstants {
  ThemeConstants._(); // Private constructor to prevent instantiation

  // ============================================================================
  // COLOR SCHEMES
  // ============================================================================

  /// Light theme color scheme
  static const ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.light,
    primary: ColorTheme.primaryColor,
    onPrimary: ColorTheme.onPrimaryColor,
    secondary: ColorTheme.secondaryColor,
    onSecondary: ColorTheme.onSecondaryColor,
    tertiary: ColorTheme.tertiaryColor,
    onTertiary: ColorTheme.onTertiaryColor,
    error: ColorTheme.errorColor,
    onError: ColorTheme.onErrorColor,
    surface: ColorTheme.surfaceColor,
    onSurface: ColorTheme.onSurfaceColor,
    surfaceContainerHighest: Color(0xFFE0E0E0),
  );

  /// Dark theme color scheme
  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: ColorTheme.primaryColor,
    onPrimary: Colors.white,
    secondary: ColorTheme.secondaryColor,
    onSecondary: ColorTheme.onSecondaryColor,
    tertiary: ColorTheme.tertiaryColor,
    onTertiary: ColorTheme.onTertiaryColor,
    error: ColorTheme.errorColor,
    onError: ColorTheme.onErrorColor,
    surface: ColorTheme.onSurfaceColor,
    onSurface: ColorTheme.surfaceColor,
    surfaceContainerHighest: Color(0xFF303134),
  );

  // ============================================================================
  // GRADIENTS
  // ============================================================================

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [ColorTheme.primaryColor, Color(0xFF6FA8F5)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient heroCardGradient = LinearGradient(
    colors: [Color(0xFF1A56C4), ColorTheme.primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============================================================================
  // DIALOG THEME
  // ============================================================================

  /// Light theme Dialog configuration
  static const baseDialogTheme = DialogTheme();

  /// Dark theme Dialog configuration
  static final baseDialogThemeDark = baseDialogTheme.copyWith(
    backgroundColor: ColorTheme.surfaceColor,
  );

  // ============================================================================
  // TOOLTIP THEME
  // ============================================================================

  /// Tooltip theme (shared for light and dark)
  static const baseTooltipTheme = TooltipThemeData();

  /// Dark theme Tooltip configuration
  static final baseTooltipThemeDark = baseTooltipTheme.copyWith();

  // ============================================================================
  // TAB BAR THEME
  // ============================================================================

  /// TabBar theme (shared for light and dark)
  static const baseTabBarTheme = TabBarTheme();

  /// Dark theme TabBar configuration
  static final baseTabBarThemeDark = baseTabBarTheme.copyWith();

  // ============================================================================
  // BOTTOM NAVIGATION BAR THEME
  // ============================================================================

  /// Light theme BottomNavigationBar configuration
  static const baseBottomNavigationBarTheme = BottomNavigationBarThemeData();

  /// Dark theme BottomNavigationBar configuration
  static final baseBottomNavigationBarThemeDark = baseBottomNavigationBarTheme
      .copyWith(backgroundColor: ColorTheme.surfaceColor);
}
