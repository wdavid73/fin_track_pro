import 'package:fin_track_pro/theme/custom/bottom_navigation_bar_theme.dart';
import 'package:flutter/material.dart';
import 'theme_constants.dart';
import 'custom/appbar_theme.dart';
import 'custom/bottom_sheet_theme.dart';
import 'custom/card_theme.dart';
import 'custom/checkbox_theme.dart';
import 'custom/chip_theme.dart';
import 'custom/elevated_button_theme.dart';
import 'custom/outlined_button_theme.dart';
import 'custom/snackbar_theme.dart';
import 'custom/text_button_theme.dart';
import 'custom/text_field_theme.dart';
import 'custom/text_theme.dart';
import 'utils/color_theme.dart';

/// Light theme configuration for the application.
///
/// Provides a complete Material 3 light theme with custom configurations
/// for all major widget types including AppBar, buttons, text fields,
/// checkboxes, chips, and more. All widget themes are modular and can be
/// customized independently.
abstract class LightTheme {
  static ThemeData getLightTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      primaryColor: ColorTheme.primaryColor,
      disabledColor: ColorTheme.grey,
      scaffoldBackgroundColor: ColorTheme.white,
      colorScheme: ThemeConstants.colorScheme,

      // Text theme
      textTheme: CustomTextTheme.lightTextTheme,

      // AppBar theme
      appBarTheme: CustomAppBarTheme.lightAppBarTheme,

      // Card theme
      cardTheme: CustomCardTheme.lightCardTheme,

      // Bottom sheet theme
      bottomSheetTheme: CustomBottomSheetTheme.lightBottomSheetTheme,

      // Button themes
      elevatedButtonTheme: CustomElevatedButtonTheme.lightElevatedButtonTheme,
      outlinedButtonTheme: CustomOutlinedButtonTheme.lightOutlinedButtonTheme,
      textButtonTheme: CustomTextButtonTheme.lightTextButtonTheme,

      // Input field theme
      inputDecorationTheme: CustomTextFormFieldTheme.lightInputDecorationTheme,

      // Checkbox theme
      checkboxTheme: CustomCheckboxTheme.lightCheckboxTheme,

      // Chip theme
      chipTheme: CustomChipTheme.lightChipTheme,

      // Snackbar theme
      snackBarTheme: CustomSnackBarTheme.lightSnackBarTheme,

      // Bottom navigation bar theme
      bottomNavigationBarTheme:
          CustomBottomNavigationBarTheme.lightBottomNavigationBarTheme,
    );
  }
}
