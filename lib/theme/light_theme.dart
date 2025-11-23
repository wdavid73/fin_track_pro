import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';

class LightTheme {
  static AppBarTheme appBarTheme = ThemeConstants.baseAppBarTheme;
  static CardThemeData cardTheme = ThemeConstants.baseCardTheme;

  static ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
    );
  }
}
