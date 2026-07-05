import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  FirebaseAnalyticsObserver get observer =>
      FirebaseAnalyticsObserver(analytics: _analytics);

  // ── Screen tracking ────────────────────────────────────────────────────────

  Future<void> logScreenView({
    required String screenName,
    String? screenClass,
  }) =>
      _analytics.logScreenView(
        screenName: screenName,
        screenClass: screenClass ?? screenName,
      );

  // ── User ───────────────────────────────────────────────────────────────────

  Future<void> setUserId(String userId) => _analytics.setUserId(id: userId);

  Future<void> clearUserId() => _analytics.setUserId(id: null);

  // ── Finance events ─────────────────────────────────────────────────────────

  Future<void> logTransactionCreated({required String type}) =>
      _analytics.logEvent(
        name: 'transaction_created',
        parameters: {'type': type},
      );

  Future<void> logBudgetCreated() =>
      _analytics.logEvent(name: 'budget_created');

  Future<void> logDataExported() =>
      _analytics.logEvent(name: 'data_exported');

  // ── Generic ────────────────────────────────────────────────────────────────

  Future<void> logEvent(
    String name, {
    Map<String, Object>? parameters,
  }) =>
      _analytics.logEvent(name: name, parameters: parameters);
}
