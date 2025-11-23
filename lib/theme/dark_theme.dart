import 'package:flutter/material.dart';

class DarkTheme {
  static ThemeData getDarkTheme(BuildContext context) {
    return ThemeData(useMaterial3: true, brightness: Brightness.dark);
  }
}
