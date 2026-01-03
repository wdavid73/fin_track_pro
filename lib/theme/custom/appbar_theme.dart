import 'package:fin_track_pro/theme/custom/text_theme.dart';
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
  static AppBarTheme lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: ColorTheme.light,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: ColorTheme.black,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: const IconThemeData(
      color: ColorTheme.black,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: CustomTextTheme.lightTextTheme.headlineSmall!.copyWith(
      color: ColorTheme.black,
    ),
  );

  /// Dark theme AppBar configuration
  static AppBarTheme darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: ColorTheme.white,
      size: AppSizes.iconMd,
    ),
    actionsIconTheme: const IconThemeData(
      color: ColorTheme.white,
      size: AppSizes.iconMd,
    ),
    titleTextStyle: CustomTextTheme.darkTextTheme.headlineSmall!.copyWith(
      color: ColorTheme.white,
    ),
  );
}
