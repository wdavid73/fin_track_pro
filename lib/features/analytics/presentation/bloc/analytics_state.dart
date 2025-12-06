part of 'analytics_bloc.dart';

/// Base class for all Analytics states
abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

/// Initial state before any data is loaded
class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

/// State while loading analytics data
class AnalyticsLoading extends AnalyticsState {
  final AnalyticsPeriod period;

  const AnalyticsLoading({required this.period});

  @override
  List<Object?> get props => [period];
}

/// State when analytics data is successfully loaded
class AnalyticsLoaded extends AnalyticsState {
  final AnalyticsPeriod period;
  final AnalyticsData data;

  const AnalyticsLoaded({required this.period, required this.data});

  @override
  List<Object?> get props => [period, data];
}

/// State when an error occurs
class AnalyticsError extends AnalyticsState {
  final String message;
  final AnalyticsPeriod period;

  const AnalyticsError({required this.message, required this.period});

  @override
  List<Object?> get props => [message, period];
}
