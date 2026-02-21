import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:fin_track_pro/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/analytics_mocks.dart';

void main() {
  late AnalyticsBloc bloc;
  late MockGetAnalyticsData mockGetAnalyticsData;
  late MockTransactionBloc mockTransactionBloc;

  const tAnalyticsData = AnalyticsData(
    totalIncome: 1500,
    totalExpenses: 750,
    categorySpending: [],
    comparisons: [],
  );

  setUpAll(() {
    registerFallbackValue(AnalyticsPeriod.week);
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
  });

  setUp(() {
    mockGetAnalyticsData = MockGetAnalyticsData();
    mockTransactionBloc = MockTransactionBloc();
    whenListen(
      mockTransactionBloc,
      const Stream<TransactionState>.empty(),
      initialState: const TransactionState(),
    );
    bloc = AnalyticsBloc(mockGetAnalyticsData, mockTransactionBloc);
  });

  tearDown(() {
    bloc.close();
  });

  group('AnalyticsBloc - Extended', () {
    group('ChangePeriod - week', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading(week), Success(week)] when change to week succeeds',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangePeriod(AnalyticsPeriod.week)),
        expect: () => [
          const AnalyticsState(
            status: AnalyticsStatus.loading,
            period: AnalyticsPeriod.week,
          ),
          const AnalyticsState(
            status: AnalyticsStatus.success,
            period: AnalyticsPeriod.week,
            data: tAnalyticsData,
          ),
        ],
        verify: (_) {
          verify(() => mockGetAnalyticsData(AnalyticsPeriod.week)).called(1);
        },
      );
    });

    group('ChangePeriod - month', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading(month), Success(month)] when change to month succeeds',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangePeriod(AnalyticsPeriod.month)),
        expect: () => [
          const AnalyticsState(
            status: AnalyticsStatus.loading,
            period: AnalyticsPeriod.month,
          ),
          const AnalyticsState(
            status: AnalyticsStatus.success,
            period: AnalyticsPeriod.month,
            data: tAnalyticsData,
          ),
        ],
        verify: (_) {
          verify(() => mockGetAnalyticsData(AnalyticsPeriod.month)).called(1);
        },
      );
    });

    group('ChangePeriod - error', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading, Error] with period preserved when ChangePeriod fails',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenThrow(Exception('Network failure'));
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangePeriod(AnalyticsPeriod.year)),
        expect: () => [
          const AnalyticsState(
            status: AnalyticsStatus.loading,
            period: AnalyticsPeriod.year,
          ),
          const AnalyticsState(
            status: AnalyticsStatus.error,
            period: AnalyticsPeriod.year,
            errorMessage:
                'Failed to load analytics data: Exception: Network failure',
          ),
        ],
      );
    });

    group('RefreshAnalyticsData - error', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Error] preserving current period when refresh fails',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenThrow(Exception('DB error'));
          return bloc;
        },
        seed: () => const AnalyticsState(
          status: AnalyticsStatus.success,
          period: AnalyticsPeriod.week,
          data: tAnalyticsData,
        ),
        act: (bloc) => bloc.add(const RefreshAnalyticsData()),
        expect: () => [
          const AnalyticsState(
            status: AnalyticsStatus.error,
            period: AnalyticsPeriod.week,
            data: tAnalyticsData,
            errorMessage: 'Failed to load analytics data: Exception: DB error',
          ),
        ],
      );
    });

    group('ChangePeriod sequence', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'handles consecutive period changes correctly',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) async {
          bloc.add(const ChangePeriod(AnalyticsPeriod.week));
          await Future.delayed(Duration.zero);
          bloc.add(const ChangePeriod(AnalyticsPeriod.year));
        },
        verify: (_) {
          verify(() => mockGetAnalyticsData(any())).called(2);
        },
      );
    });
  });
}
