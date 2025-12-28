import 'package:flutter/material.dart';
import 'package:fin_track_pro/theme/utils/color_theme.dart' show ColorTheme;

import 'text_theme.dart';

class CustomBottomNavigationBarTheme {
  static BottomNavigationBarThemeData lightBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: ColorTheme.surfaceColor,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.darkGrey,
        selectedLabelStyle: CustomTextTheme.lightTextTheme.labelMedium
            ?.copyWith(color: ColorTheme.primaryColor),
        unselectedLabelStyle: CustomTextTheme.lightTextTheme.labelMedium
            ?.copyWith(color: ColorTheme.darkGrey),
        selectedIconTheme: const IconThemeData(color: ColorTheme.primaryColor),
        unselectedIconTheme: const IconThemeData(color: ColorTheme.darkGrey),
      );

  static BottomNavigationBarThemeData darkBottomNavigationBarTheme =
      BottomNavigationBarThemeData(
        backgroundColor: ColorTheme.onSurfaceColor,
        selectedItemColor: ColorTheme.primaryColor,
        unselectedItemColor: ColorTheme.grey,
        selectedLabelStyle: CustomTextTheme.lightTextTheme.labelMedium
            ?.copyWith(color: ColorTheme.primaryColor),
        unselectedLabelStyle: CustomTextTheme.lightTextTheme.labelMedium
            ?.copyWith(color: ColorTheme.grey),
        selectedIconTheme: const IconThemeData(color: ColorTheme.primaryColor),
        unselectedIconTheme: const IconThemeData(color: ColorTheme.grey),
      );
}
