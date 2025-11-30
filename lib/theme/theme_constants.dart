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
    surfaceContainerHighest: Color(0xFFE0E0E0),
  );

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

  static final baseElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: ColorTheme.primaryColor,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(100)),
      ),
      elevation: 0,
      disabledBackgroundColor: ColorTheme.borderColor,
      disabledForegroundColor: ColorTheme.textSecondary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static final baseTextButtonTheme = TextButtonThemeData(
    style: TextButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      foregroundColor: ColorTheme.textSecondary,
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  );

  static final baseCardTheme = const CardThemeData(
    elevation: 0,
    color: Colors.white,
    surfaceTintColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      side: BorderSide(width: 1, color: ColorTheme.borderColor),
    ),
  );

  static final baseCardThemeDark = const CardThemeData(
    elevation: 0,
    color: ColorTheme.onSurfaceColor,
    surfaceTintColor: ColorTheme.onSurfaceColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
      side: BorderSide(width: 1, color: Colors.white12),
    ),
  );

  static final baseAppBarTheme = const AppBarTheme(centerTitle: false);

  static final baseBottomSheetTheme = const BottomSheetThemeData(
    showDragHandle: true,
  );

  static final baseDialogTheme = const DialogTheme();

  static final baseSnackBarTheme = const SnackBarThemeData(
    backgroundColor: ColorTheme.onSurfaceColor,
    contentTextStyle: TextStyle(color: ColorTheme.surfaceColor),
    behavior: SnackBarBehavior.floating,
  );

  static final baseTooltipTheme = const TooltipThemeData();

  static final baseTabBarTheme = const TabBarTheme();

  static final baseBottomNavigationBarTheme =
      const BottomNavigationBarThemeData();

  /// Dark Theme
  ///
  static final baseAppBarThemeDark = baseAppBarTheme.copyWith(
    backgroundColor: ColorTheme.onSurfaceColor,
    iconTheme: const IconThemeData(color: ColorTheme.surfaceColor),
    titleTextStyle: const TextStyle(
      color: ColorTheme.surfaceColor,
      fontSize: 20,
      fontWeight: FontWeight.w500,
    ),
  );

  static final baseBottomSheetThemeDark = baseBottomSheetTheme.copyWith(
    backgroundColor: ColorTheme.onSurfaceColor,
    dragHandleColor: ColorTheme.surfaceColor,
    showDragHandle: true,
  );

  static final baseDialogThemeDark = baseDialogTheme.copyWith(
    backgroundColor: ColorTheme.surfaceColor,
  );

  static final baseSnackBarThemeDark = baseSnackBarTheme.copyWith(
    backgroundColor: ColorTheme.surfaceColor,
  );

  static final baseTooltipThemeDark = baseTooltipTheme.copyWith();

  static final baseTabBarThemeDark = baseTabBarTheme.copyWith();

  static final baseBottomNavigationBarThemeDark = baseBottomNavigationBarTheme
      .copyWith(backgroundColor: ColorTheme.surfaceColor);
}
