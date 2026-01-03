import 'dart:ui';

/// A utility class that defines all color constants used across the app.
///
/// This includes primary colors, surface colors, text colors, and state colors
/// for both light and dark themes to maintain visual consistency.
class ColorTheme {
  ColorTheme._(); // Private constructor to prevent instantiation

  // Text colors
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textWhite = Color(0xFFFFFFFF);

  // Primary colors
  static const Color primaryColor = Color(0xFF4285F4);
  static const Color secondaryColor = Color(0xFF34A853);
  static const Color tertiaryColor = Color(0xFFFBBC05);
  static const Color errorColor = Color(0xFFEA4335);
  static const Color warning = Color(0xFFEA4335);

  // Surface colors
  static const Color surfaceColor = Color(0xFFF1F3F4);
  static const Color onSurfaceColor = Color(0xFF202124);

  // On colors (colors for content on top of primary/secondary/etc)
  static const Color onPrimaryColor = Color(0xFFEAF1FC);
  static const Color onSecondaryColor = Color(0xFFE6F4EA);
  static const Color onTertiaryColor = Color(0xFFFEF3D9);
  static const Color onErrorColor = Color(0xFFFCE8E6);

  // Border colors
  static const Color borderColor = Color(0xFFDADCE0);
  static const Color borderPrimary = Color(0xFF4285F4);

  // Base colors
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color light = Color(0xFFF6F6F6);
  static const Color dark = Color(0xFF272727);

  // Grey scale
  static const Color grey = Color(0xFFDADCE0);
  static const Color darkGrey = Color(0xFF939393);
  static const Color darkerGrey = Color(0xFF4F4F4F);

  // Button colors
  static const Color buttonDisabled = Color(0xFFC4C4C4);

  // Dark theme specific
  static const Color darkBackgroundColor = Color(0xFF121212);
}
