import 'package:flutter/material.dart';
import '../utils/color_theme.dart';
import '../utils/sizes.dart';

/// Custom AppBar theme configurations for light and dark themes.
///
/// Provides consistent AppBar styling with transparent backgrounds,
/// zero elevation for a modern flat design, and theme-appropriate
/// icon and text colors.
abstract class CustomAppBarTheme {
  /// Light theme AppBar configuration
  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: ColorTheme.black,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: IconThemeData(
      color: ColorTheme.black,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorTheme.black,
    ),
  );

  /// Dark theme AppBar configuration
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(
      color: ColorTheme.white,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: IconThemeData(
      color: ColorTheme.white,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: ColorTheme.white,
    ),
  );
}
