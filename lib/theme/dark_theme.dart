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

/// Dark theme configuration for the application.
///
/// Provides a complete Material 3 dark theme with custom configurations
/// for all major widget types including AppBar, buttons, text fields,
/// checkboxes, chips, and more. All widget themes are modular and can be
/// customized independently.
abstract class DarkTheme {
  static ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Poppins',
      primaryColor: ColorTheme.primaryColor,
      disabledColor: ColorTheme.grey,
      scaffoldBackgroundColor: ColorTheme.darkBackgroundColor,
      colorScheme: ThemeConstants.darkColorScheme,

      // Text theme
      textTheme: CustomTextTheme.darkTextTheme,

      // AppBar theme
      appBarTheme: CustomAppBarTheme.darkAppBarTheme,

      // Card theme
      cardTheme: CustomCardTheme.darkCardTheme,

      // Bottom sheet theme
      bottomSheetTheme: CustomBottomSheetTheme.darkBottomSheetTheme,

      // Button themes
      elevatedButtonTheme: CustomElevatedButtonTheme.darkElevatedButtonTheme,
      outlinedButtonTheme: CustomOutlinedButtonTheme.darkOutlinedButtonTheme,
      textButtonTheme: CustomTextButtonTheme.darkTextButtonTheme,

      // Input field theme
      inputDecorationTheme: CustomTextFormFieldTheme.darkInputDecorationTheme,

      // Checkbox theme
      checkboxTheme: CustomCheckboxTheme.darkCheckboxTheme,

      // Chip theme
      chipTheme: CustomChipTheme.darkChipTheme,

      // Snackbar theme
      snackBarTheme: CustomSnackBarTheme.darkSnackBarTheme,
    );
  }
}
