import 'package:flutter/material.dart';

class AppSnackbar {
  AppSnackbar._internal();
  static final AppSnackbar _instance = AppSnackbar._internal();
  factory AppSnackbar() => _instance;

  late GlobalKey<ScaffoldMessengerState> messengerKey;

  void init(GlobalKey<ScaffoldMessengerState> key) {
    messengerKey = key;
  }

  void _show(
    String message, {
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
    );

    messengerKey.currentState!
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  /// Default snackbar
  void show(String message) {
    _show(message);
  }

  /// Success snackbar
  void success(String message) {
    _show(message, backgroundColor: Colors.green, textColor: Colors.white);
  }

  /// Error snackbar
  void error(String message) {
    _show(message, backgroundColor: Colors.red, textColor: Colors.white);
  }

  /// Warning snackbar
  void warning(String message) {
    _show(
      message,
      backgroundColor: Colors.orange.shade700,
      textColor: Colors.white,
    );
  }

  /// Custom snackbar
  void custom({
    required String message,
    required Color background,
    required Color textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      message,
      backgroundColor: background,
      textColor: textColor,
      duration: duration,
    );
  }
}
