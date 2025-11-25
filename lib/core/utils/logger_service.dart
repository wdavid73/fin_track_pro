import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';

//// Application logger service wrapper
///
/// Wraps the logger package for dependency injection
/// and provides environment-aware logging
@singleton
class LoggerService {
  late final Logger _logger;

  LoggerService() {
    final enableLogging = FlavorConfig.isInitialized
        ? FlavorConfig.instance.enableLogging
        : false;

    _logger = Logger(
      filter: enableLogging ? ProductionFilter() : _NoLogFilter(),

      printer: PrettyPrinter(
        methodCount: 0,
        errorMethodCount: 5,
        lineLength: 80,
        colors: false,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    );
  }

  /// Log a debug message
  void debug(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.d(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// Log an info message
  void info(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.i(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// Log a warning message
  void warning(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.w(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// Log an error message
  void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.e(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// Log a fatal error
  void fatal(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    final taggedMessage = tag != null ? '[$tag] $message' : message;
    _logger.f(taggedMessage, error: error, stackTrace: stackTrace);
  }

  /// Get the underlying logger instance
  Logger get logger => _logger;
}

/// Custom filter that blocks all logs
class _NoLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    // Only log errors, even when logging is disabled
    return event.level == Level.error;
  }
}
