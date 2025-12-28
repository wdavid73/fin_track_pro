import 'package:fin_track_pro/theme/custom/text_theme.dart';
import 'package:flutter/material.dart';
import '../utils/color_theme.dart';
import '../utils/sizes.dart';

/// Custom TextField/TextFormField theme configurations for light and dark themes.
///
/// Provides consistent input field styling with proper border states,
/// color adaptations, and error handling for both light and dark themes.
abstract class CustomTextFormFieldTheme {
  /// Light theme TextField configuration
  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: ColorTheme.darkGrey,
    suffixIconColor: ColorTheme.darkGrey,
    labelStyle: CustomTextTheme.lightTextTheme.bodyMedium!.copyWith(
      fontSize: AppSizes.fontSizeMd,
      color: ColorTheme.black,
    ),
    hintStyle: CustomTextTheme.lightTextTheme.bodyMedium!.copyWith(
      fontSize: AppSizes.fontSizeSm,
      color: ColorTheme.black,
    ),
    errorStyle: CustomTextTheme.lightTextTheme.bodyMedium!.copyWith(
      fontSize: AppSizes.fontSizeSm,
    ),
    floatingLabelStyle: CustomTextTheme.lightTextTheme.bodyMedium!.copyWith(
      color: ColorTheme.black.withValues(alpha: 0.8),
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.grey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.grey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.dark),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: ColorTheme.warning),
    ),
  );

  /// Dark theme TextField configuration
  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 2,
    prefixIconColor: ColorTheme.darkGrey,
    suffixIconColor: ColorTheme.darkGrey,
    labelStyle: CustomTextTheme.darkTextTheme.bodyMedium!.copyWith(
      fontSize: AppSizes.fontSizeMd,
      color: ColorTheme.white,
    ),
    hintStyle: CustomTextTheme.darkTextTheme.bodyMedium!.copyWith(
      fontSize: AppSizes.fontSizeSm,
      color: ColorTheme.white,
    ),
    errorStyle: CustomTextTheme.darkTextTheme.bodyMedium!.copyWith(
      fontSize: AppSizes.fontSizeSm,
    ),
    floatingLabelStyle: CustomTextTheme.darkTextTheme.bodyMedium!.copyWith(
      color: ColorTheme.white.withValues(alpha: 0.8),
    ),
    border: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.darkGrey),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.darkGrey),
    ),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.white),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 1, color: ColorTheme.warning),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: BorderRadius.circular(AppSizes.inputFieldRadius),
      borderSide: const BorderSide(width: 2, color: ColorTheme.warning),
    ),
  );
}
