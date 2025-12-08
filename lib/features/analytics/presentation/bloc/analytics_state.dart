part of 'analytics_bloc.dart';

enum AnalyticsStatus {
  initial,
  loading,
  success,
  error,
}

class AnalyticsState extends Equatable {
  final AnalyticsStatus status;
  final AnalyticsPeriod period;
  final AnalyticsData? data;
  final String? errorMessage;

  const AnalyticsState({
    this.status = AnalyticsStatus.initial,
    this.period = AnalyticsPeriod.month,
    this.data,
    this.errorMessage,
  });

  AnalyticsState copyWith({
    AnalyticsStatus? status,
    AnalyticsPeriod? period,
    AnalyticsData? data,
    String? errorMessage,
  }) {
    return AnalyticsState(
      status: status ?? this.status,
      period: period ?? this.period,
      data: data ?? this.data,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, period, data, errorMessage];
}
