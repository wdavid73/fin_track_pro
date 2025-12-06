part of 'analytics_bloc.dart';

/// Base class for all Analytics events
abstract class AnalyticsEvent extends Equatable {
  const AnalyticsEvent();

  @override
  List<Object?> get props => [];
}

/// Event to load analytics data with default period (month)
class LoadAnalyticsData extends AnalyticsEvent {
  const LoadAnalyticsData();
}

/// Event to change the time period
class ChangePeriod extends AnalyticsEvent {
  final AnalyticsPeriod period;

  const ChangePeriod(this.period);

  @override
  List<Object?> get props => [period];
}

/// Event to refresh analytics data for current period
class RefreshAnalyticsData extends AnalyticsEvent {
  const RefreshAnalyticsData();
}
