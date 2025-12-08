import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/home_mocks.dart';

void main() {
  late HomeBloc bloc;
  late MockGetRecentTransactions mockGetRecentTransactions;
  late MockGetTotalBalance mockGetTotalBalance;
  late MockGetCategories mockGetCategories;
  late MockGetBudgetData mockGetBudgetData;
  late MockTransactionBloc mockTransactionBloc;

  setUpAll(() {
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
  });

  setUp(() {
    mockGetRecentTransactions = MockGetRecentTransactions();
    mockGetTotalBalance = MockGetTotalBalance();
    mockGetCategories = MockGetCategories();
    mockGetBudgetData = MockGetBudgetData();
    mockTransactionBloc = MockTransactionBloc();

    whenListen(
      mockTransactionBloc,
      const Stream<TransactionState>.empty(),
      initialState: const TransactionState(),
    );

    bloc = HomeBloc(
      mockGetRecentTransactions,
      mockGetTotalBalance,
      mockGetCategories,
      mockGetBudgetData,
      mockTransactionBloc,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final tTransactions = [
    Transaction(
      id: '1',
      amount: 100.0,
      categoryId: 'cat1',
      type: 'expense',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  final tCategories = [
    const Category(
      id: 'cat1',
      name: 'Food',
      icon: 'food_icon',
      color: 123,
      type: 'expense',
    ),
  ];

  final tBudgetData = const BudgetData(
    totalBudget: 1000,
    totalSpent: 500,
    categories: [],
  );

  group('HomeBloc', () {
    test('initial state should be HomeInitial', () {
      expect(bloc.state, const HomeInitial());
    });

    group('LoadHomeData', () {
      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Loaded] when LoadHomeData succeeds',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => tTransactions);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 1000.0);
          when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
          when(() => mockGetBudgetData()).thenAnswer((_) async => tBudgetData);
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          HomeLoaded(
            recentTransactions: tTransactions,
            totalBalance: 1000.0,
            categories: {'cat1': tCategories[0]},
            budgetData: tBudgetData,
          ),
        ],
        verify: (_) {
          verify(() => mockGetRecentTransactions(limit: 5)).called(1);
          verify(() => mockGetTotalBalance()).called(1);
          verify(() => mockGetCategories()).called(1);
          verify(() => mockGetBudgetData()).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Error] when LoadHomeData fails',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenThrow(Exception('Data error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          const HomeError(
            'An unexpected error occurred: Exception: Data error',
          ),
        ],
      );
    });

    group('RefreshHomeData', () {
      blocTest<HomeBloc, HomeState>(
        'emits [Loaded] when RefreshHomeData is added',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => tTransactions);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 1000.0);
          when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
          when(() => mockGetBudgetData()).thenAnswer((_) async => tBudgetData);
          return bloc;
        },
        seed: () => const HomeLoaded(
          recentTransactions: [],
          totalBalance: 0,
          categories: {},
          budgetData: BudgetData(totalBudget: 0, totalSpent: 0, categories: []),
        ),
        act: (bloc) => bloc.add(const RefreshHomeData()),
        expect: () => [
          HomeLoaded(
            recentTransactions: tTransactions,
            totalBalance: 1000.0,
            categories: {'cat1': tCategories[0]},
            budgetData: tBudgetData,
          ),
        ],
      );
    });

    group('TransactionBloc Listener', () {
      blocTest<HomeBloc, HomeState>(
        'reloads data when Transaction operation succeeds',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => tTransactions);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 1000.0);
          when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
          when(() => mockGetBudgetData()).thenAnswer((_) async => tBudgetData);

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

          return HomeBloc(
            mockGetRecentTransactions,
            mockGetTotalBalance,
            mockGetCategories,
            mockGetBudgetData,
            mockTransactionBloc,
          );
        },
        expect: () => [
          HomeLoaded(
            recentTransactions: tTransactions,
            totalBalance: 1000.0,
            categories: {'cat1': tCategories[0]},
            budgetData: tBudgetData,
          ),
        ],
      );
    });
  });
}
