import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';

class DarkTheme {
  static AppBarTheme appBarTheme = ThemeConstants.baseAppBarThemeDark;
  static CardThemeData cardTheme = ThemeConstants.baseCardTheme;

  static ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
    );
  }
}
