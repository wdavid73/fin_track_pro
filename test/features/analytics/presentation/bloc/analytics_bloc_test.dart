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
      Stream<TransactionState>.empty(),
      initialState: const TransactionInitial(),
    );

    bloc = AnalyticsBloc(mockGetAnalyticsData, mockTransactionBloc);
  });

  tearDown(() {
    bloc.close();
  });

  final tAnalyticsData = AnalyticsData(
    totalIncome: 1000,
    totalExpenses: 500,
    categorySpending: [],
    comparisons: [],
  );

  group('AnalyticsBloc', () {
    test('initial state should be AnalyticsInitial', () {
      expect(bloc.state, const AnalyticsInitial());
    });

    group('LoadAnalyticsData', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading, Loaded] when LoadAnalyticsData succeeds',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadAnalyticsData()),
        expect: () => [
          const AnalyticsLoading(period: AnalyticsPeriod.month),
          AnalyticsLoaded(data: tAnalyticsData, period: AnalyticsPeriod.month),
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
          const AnalyticsLoading(period: AnalyticsPeriod.month),
          const AnalyticsError(
            message: 'Failed to load analytics data: Exception: Data error',
            period: AnalyticsPeriod.month,
          ),
        ],
      );
    });

    group('ChangePeriod', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loading, Loaded] with new period when ChangePeriod is added',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangePeriod(AnalyticsPeriod.year)),
        expect: () => [
          const AnalyticsLoading(period: AnalyticsPeriod.year),
          AnalyticsLoaded(data: tAnalyticsData, period: AnalyticsPeriod.year),
        ],
        verify: (_) {
          verify(() => mockGetAnalyticsData(AnalyticsPeriod.year)).called(1);
        },
      );
    });

    group('RefreshAnalyticsData', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'emits [Loaded] with new data when RefreshAnalyticsData is added',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);
          return bloc;
        },
        // Seed with different data so the new state is not equal to the old state
        seed: () => AnalyticsLoaded(
          data: AnalyticsData(
            totalIncome: 0,
            totalExpenses: 0,
            categorySpending: [],
            comparisons: [],
          ),
          period: AnalyticsPeriod.week,
        ),
        act: (bloc) => bloc.add(const RefreshAnalyticsData()),
        expect: () => [
          AnalyticsLoaded(data: tAnalyticsData, period: AnalyticsPeriod.week),
        ],
        verify: (_) {
          verify(() => mockGetAnalyticsData(AnalyticsPeriod.week)).called(1);
        },
      );
    });

    group('TransactionBloc Listener', () {
      blocTest<AnalyticsBloc, AnalyticsState>(
        'reloads data when TransactionOperationSuccess is emitted',
        build: () {
          when(
            () => mockGetAnalyticsData(any()),
          ).thenAnswer((_) async => tAnalyticsData);

          whenListen(
            mockTransactionBloc,
            Stream.fromIterable([const TransactionOperationSuccess('Success')]),
            initialState: const TransactionInitial(),
          );

          return AnalyticsBloc(mockGetAnalyticsData, mockTransactionBloc);
        },
        expect: () => [
          // AnalyticsLoading is not emitted during refresh triggered by listener
          AnalyticsLoaded(data: tAnalyticsData, period: AnalyticsPeriod.month),
        ],
        verify: (_) {
          verify(() => mockGetAnalyticsData(AnalyticsPeriod.month)).called(1);
        },
      );
    });
  });
}
