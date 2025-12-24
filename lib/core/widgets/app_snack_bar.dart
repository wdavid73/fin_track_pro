import 'package:fin_track_pro/core/extensions/extensions.dart';
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
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Color? textColor,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final snackBar = SnackBar(
      content: Text(
        message,
        style: context.textTheme.bodyMedium?.copyWith(color: textColor),
      ),
      duration: duration,
      action: action,
      behavior: SnackBarBehavior.floating,
      backgroundColor: backgroundColor,
    );

    messengerKey.currentState!
      ..clearSnackBars()
      ..showSnackBar(snackBar);
  }

  /// Default snackbar
  void show(BuildContext context, String message) {
    _show(context, message);
  }

  /// Success snackbar
  void success(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.green,
      textColor: Colors.white,
    );
  }

  /// Error snackbar
  void error(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  /// Warning snackbar
  void warning(BuildContext context, String message) {
    _show(
      context,
      message,
      backgroundColor: Colors.orange.shade700,
      textColor: Colors.white,
    );
  }

  /// Custom snackbar
  void custom({
    required BuildContext context,
    required String message,
    required Color background,
    required Color textColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    _show(
      context,
      message,
      backgroundColor: background,
      textColor: textColor,
      duration: duration,
    );
  }
}
