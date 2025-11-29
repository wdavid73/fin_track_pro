import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';

import 'utils/color_theme.dart';

class DarkTheme {
  static AppBarTheme appBarTheme = ThemeConstants.baseAppBarThemeDark;
  static CardThemeData cardTheme = ThemeConstants.baseCardThemeDark;
  static BottomSheetThemeData bottomSheetTheme =
      ThemeConstants.baseBottomSheetThemeDark;

  static ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: ColorTheme.darkBackgroundColor,
      colorScheme: ThemeConstants.darkColorScheme,
      appBarTheme: appBarTheme,
      cardTheme: cardTheme,
      bottomSheetTheme: bottomSheetTheme,
      elevatedButtonTheme: ThemeConstants.baseElevatedButtonTheme,
      textButtonTheme: ThemeConstants.baseTextButtonTheme,
      snackBarTheme: ThemeConstants.baseSnackBarThemeDark,
    );
  }
}
