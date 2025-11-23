import 'package:flutter/material.dart';

class LightTheme {
  static ThemeData getLightTheme(BuildContext context) {
    return ThemeData(useMaterial3: true, brightness: Brightness.light);
  }
}
