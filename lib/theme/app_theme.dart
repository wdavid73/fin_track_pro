import 'package:flutter/material.dart';

import 'dark_theme.dart';
import 'light_theme.dart';

/// A utility class that defines the application's theme settings.
///
/// The [AppTheme] class provides static properties and methods to configure
/// the visual appearance of the app, such as colors, typography, and other
/// theme-related options. Use this class to access and customize the global
/// theme data used throughout the application.
class AppTheme {
  static ThemeData getLightTheme(BuildContext context) =>
      LightTheme.getLightTheme(context);

  static ThemeData getDarkTheme(BuildContext context) =>
      DarkTheme.getDarkTheme(context);
}
