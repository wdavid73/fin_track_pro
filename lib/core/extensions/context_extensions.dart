import 'package:flutter/material.dart';

extension ThemeContext on BuildContext {
  /// Returns the [TextTheme] from the current [Theme].
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Returns the [ColorScheme] from the current [Theme].
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Returns the primary color from the current [ColorScheme].
  Color get primaryColor => colorScheme.primary;

  /// Returns the secondary color from the current [ColorScheme].
  Color get secondaryColor => colorScheme.secondary;

  /// Returns the surface color from the current [ColorScheme].
  Color get surfaceColor => colorScheme.surface;

  /// Returns the error color from the current [ColorScheme].
  Color get errorColor => colorScheme.error;

  Brightness get brightness => Theme.of(this).brightness;
}
