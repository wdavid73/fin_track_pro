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

  setUpAll(() {
    registerFallbackValue(AnalyticsPeriod.week);
    FlavorConfig.initialize(
      flavor: Flavor.prod, // Use prod to avoid artificial delay
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
  });

  setUp(() {
    mockGetAnalyticsData = MockGetAnalyticsData();
    mockTransactionBloc = MockTransactionBloc();

    // Default stream behavior for TransactionBloc
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

  const tAnalyticsData = AnalyticsData(
    totalIncome: 1000,
    totalExpenses: 500,
    categorySpending: [],
    comparisons: [],
  );

  group('AnalyticsBloc', () {
    test('initial state should have initial status', () {
      expect(bloc.state.status, AnalyticsStatus.initial);
      expect(bloc.state.period, AnalyticsPeriod.month);
      expect(bloc.state.data, null);
    });

    group('LoadAnalyticsData', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading, Success] when LoadAnalyticsData succeeds',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalyticsData()),
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

      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading, Error] when LoadAnalyticsData fails',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenThrow(Exception('Data error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalyticsData()),
        expect: () => [
          const AnalyticsState(
            status: AnalyticsStatus.loading,
            period: AnalyticsPeriod.month,
          ),
          const AnalyticsState(
            status: AnalyticsStatus.error,
            period: AnalyticsPeriod.month,
            errorMessage: 'Failed to load analytics data: Exception: Data error',
          ),
        ],
      );
    });

    group('ChangePeriod', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading, Success] with new period when ChangePeriod is added',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangePeriod(AnalyticsPeriod.year)),
        expect: () => [
          const AnalyticsState(
            status: AnalyticsStatus.loading,
            period: AnalyticsPeriod.year,
          ),
          const AnalyticsState(
            status: AnalyticsStatus.success,
            period: AnalyticsPeriod.year,
            data: tAnalyticsData,
          ),
        ],
        verify: (_) {
          verify(() => mockGetAnalyticsData(AnalyticsPeriod.year)).called(1);
        },
      );
    });

    group('RefreshAnalyticsData', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Success] with new data when RefreshAnalyticsData is added',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        seed: () => const AnalyticsState(
          status: AnalyticsStatus.success,
          period: AnalyticsPeriod.week,
          data: AnalyticsData(
            totalIncome: 0,
            totalExpenses: 0,
            categorySpending: [],
            comparisons: [],
          ),
        ),
        act: (bloc) => bloc.add(const RefreshAnalyticsData()),
        expect: () => [
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

    group('TransactionBloc Listener', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'reloads data when Transaction operation succeeds',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);

          whenListen(
            mockTransactionBloc,
            Stream.fromIterable([
              const TransactionState(
                status: TransactionStatus.success,
                successMessage: 'Transaction created successfully',
              ),
            ]),
            initialState: const TransactionState(),
          );

          return AnalyticsBloc(mockGetAnalyticsData, mockTransactionBloc);
        },
        expect: () => [
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
  });
}
