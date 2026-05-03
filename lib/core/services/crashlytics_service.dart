import 'dart:async';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CrashlyticsService {
  final FirebaseCrashlytics _crashlytics = FirebaseCrashlytics.instance;

  /// Call once at app startup to wire Flutter and zone errors into Crashlytics.
  /// Must be called after [Firebase.initializeApp].
  void initialize() {
    FlutterError.onError = _crashlytics.recordFlutterFatalError;

    // Non-Flutter async errors (e.g. thrown in dart:async zones)
    PlatformDispatcher.instance.onError = (error, stack) {
      _crashlytics.recordError(error, stack, fatal: true);
      return true;
    };
  }

  /// Record a non-fatal error (e.g. caught exceptions worth tracking).
  Future<void> recordError(
    Object error,
    StackTrace? stackTrace, {
    bool fatal = false,
    String? reason,
  }) {
    return _crashlytics.recordError(
      error,
      stackTrace,
      fatal: fatal,
      reason: reason,
    );
  }

  /// Attach a user identifier to future crash reports (set after login).
  Future<void> setUserId(String userId) => _crashlytics.setUserIdentifier(userId);

  /// Clear the user identifier (set on logout).
  Future<void> clearUserId() => _crashlytics.setUserIdentifier('');

  /// Log a message that will appear in the crash report breadcrumbs.
  void log(String message) => _crashlytics.log(message);
}
