import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:flutter/material.dart';

/// A utility class that centralizes all constant values and base theme data
/// used across both light and dark themes in the application.
///
/// This class ensures consistency in styling by providing a single source
/// for [ColorScheme] definitions, base [ThemeData] components, and
/// utility functions for resolving widget states.
class ThemeConstants {
  /// Color Schemes
  ///
  /// Light Theme
  ///
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
  );

  static const ColorScheme darkColorScheme = ColorScheme(
    brightness: Brightness.dark,
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
  );

  /// Icon Theme
  ///
  static final baseIconTheme = const IconThemeData(
    color: ColorTheme.onSurfaceColor,
    size: 24,
  );

  /// Text Theme
  ///
  static final baseTextTheme = const TextTheme(
    displayLarge: TextStyle(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    displayMedium: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    displaySmall: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    headlineLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    headlineMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    headlineSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    titleLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    titleMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    titleSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    bodyLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.normal,
      color: ColorTheme.onSurfaceColor,
    ),
    bodyMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.normal,
      color: ColorTheme.onSurfaceColor,
    ),
    bodySmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.normal,
      color: ColorTheme.onSurfaceColor,
    ),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
    labelSmall: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: ColorTheme.onSurfaceColor,
    ),
  );

  static final baseInputDecorationTheme = const InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(4)),
    ),
  );

  static final baseButtonTheme = const ButtonThemeData();

  static final baseCardTheme = const CardTheme();

  static final baseAppBarTheme = const AppBarTheme();

  static final baseBottomSheetTheme = const BottomSheetThemeData();

  static final baseDialogTheme = const DialogTheme();

  static final baseSnackBarTheme = const SnackBarThemeData();

  static final baseTooltipTheme = const TooltipThemeData();

  static final baseTabBarTheme = const TabBarTheme();

  static final baseBottomNavigationBarTheme =
      const BottomNavigationBarThemeData();

  /// Dark Theme
  ///
  static final baseAppBarThemeDark = const AppBarTheme();
  static final baseBottomSheetThemeDark = const BottomSheetThemeData();
  static final baseDialogThemeDark = const DialogTheme();
  static final baseSnackBarThemeDark = const SnackBarThemeData();
  static final baseTooltipThemeDark = const TooltipThemeData();
  static final baseTabBarThemeDark = const TabBarTheme();
  static final baseBottomNavigationBarThemeDark =
      const BottomNavigationBarThemeData();
}
