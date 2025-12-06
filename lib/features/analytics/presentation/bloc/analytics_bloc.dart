import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:fin_track_pro/features/analytics/domain/usecases/get_analytics_data.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';

/// BLoC for managing analytics page state
@injectable
class AnalyticsBloc extends Bloc<AnalyticsEvent, AnalyticsState> {
  final GetAnalyticsData _getAnalyticsData;
  final TransactionBloc _transactionBloc;
  StreamSubscription? _transactionSubscription;

  AnalyticsBloc(this._getAnalyticsData, this._transactionBloc)
    : super(const AnalyticsInitial()) {
    on<LoadAnalyticsData>(_onLoadAnalyticsData);
    on<ChangePeriod>(_onChangePeriod);
    on<RefreshAnalyticsData>(_onRefreshAnalyticsData);

    // Listen to TransactionBloc changes to refresh analytics
    _transactionSubscription = _transactionBloc.stream.listen((state) {
      if (state is TransactionOperationSuccess) {
        add(const RefreshAnalyticsData());
      }
    });
  }

  @override
  Future<void> close() {
    _transactionSubscription?.cancel();
    return super.close();
  }

  Future<void> _onLoadAnalyticsData(
    LoadAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(const AnalyticsLoading(period: AnalyticsPeriod.month));
    await _loadData(AnalyticsPeriod.month, emit);
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<AnalyticsState> emit,
  ) async {
    emit(AnalyticsLoading(period: event.period));
    await _loadData(event.period, emit);
  }

  Future<void> _onRefreshAnalyticsData(
    RefreshAnalyticsData event,
    Emitter<AnalyticsState> emit,
  ) async {
    // Get current period from state
    final currentPeriod = state is AnalyticsLoaded
        ? (state as AnalyticsLoaded).period
        : AnalyticsPeriod.month;

    await _loadData(currentPeriod, emit);
  }

  Future<void> _loadData(
    AnalyticsPeriod period,
    Emitter<AnalyticsState> emit,
  ) async {
    try {
      // Add delay in dev mode to show loading state
      if (FlavorConfig.instance.isDev) {
        await Future.delayed(const Duration(seconds: 1));
      }

      final analyticsData = await _getAnalyticsData(period);

      emit(AnalyticsLoaded(period: period, data: analyticsData));
    } catch (e) {
      emit(
        AnalyticsError(
          message: 'Failed to load analytics data: $e',
          period: period,
        ),
      );
    }
  }
}
