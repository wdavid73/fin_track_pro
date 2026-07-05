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

  group('HomeBloc - Extended', () {
    group('LoadHomeData - Edge Cases', () {
      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Loaded] with zero balance and empty transactions',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => []);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 0.0);
          when(() => mockGetCategories()).thenAnswer((_) async => []);
          when(() => mockGetBudgetData()).thenAnswer(
            (_) async =>
                const BudgetData(totalBudget: 0, totalSpent: 0, categories: []),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          const HomeLoaded(
            recentTransactions: [],
            totalBalance: 0.0,
            categories: {},
            budgetData: BudgetData(
              totalBudget: 0,
              totalSpent: 0,
              categories: [],
            ),
          ),
        ],
        verify: (_) {
          verify(() => mockGetRecentTransactions(limit: 5)).called(1);
        },
      );

      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Loaded] with negative balance (more expenses than income)',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => []);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => -250.0);
          when(() => mockGetCategories()).thenAnswer((_) async => []);
          when(() => mockGetBudgetData()).thenAnswer(
            (_) async => const BudgetData(
              totalBudget: 1000,
              totalSpent: 1250,
              categories: [],
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          const HomeLoaded(
            recentTransactions: [],
            totalBalance: -250.0,
            categories: {},
            budgetData: BudgetData(
              totalBudget: 1000,
              totalSpent: 1250,
              categories: [],
            ),
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Loaded] with multiple categories correctly mapped',
        build: () {
          final tCategories = [
            Category(
              id: 'cat1',
              name: 'Food',
              icon: 'food',
              color: 1,
              type: 'expense',
              updatedAt: DateTime.now(),
            ),
            Category(
              id: 'cat2',
              name: 'Salary',
              icon: 'money',
              color: 2,
              type: 'income',
              updatedAt: DateTime.now(),
            ),
            Category(
              id: 'cat3',
              name: 'Transport',
              icon: 'car',
              color: 3,
              type: 'expense',
              updatedAt: DateTime.now(),
            ),
          ];
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => []);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 500.0);
          when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
          when(() => mockGetBudgetData()).thenAnswer(
            (_) async => const BudgetData(
              totalBudget: 500,
              totalSpent: 0,
              categories: [],
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          isA<HomeLoaded>()
              .having((s) => s.categories.length, 'categories count', 3)
              .having((s) => s.categories['cat1']?.name, 'cat1 name', 'Food')
              .having((s) => s.categories['cat2']?.name, 'cat2 name', 'Salary'),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Error] when getTotalBalance fails (not just getRecentTransactions)',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => []);
          when(
            () => mockGetTotalBalance(),
          ).thenThrow(Exception('Balance read error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          const HomeError(
            'An unexpected error occurred: Exception: Balance read error',
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Error] when getCategories fails',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => []);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 100.0);
          when(
            () => mockGetCategories(),
          ).thenThrow(Exception('Categories fetch error'));
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          const HomeError(
            'An unexpected error occurred: Exception: Categories fetch error',
          ),
        ],
      );

      blocTest<HomeBloc, HomeState>(
        'emits [Loading, Loaded] with transactions mapped to correct limit (5)',
        build: () {
          final tManyTransactions = List.generate(
            5,
            (i) => Transaction(
              id: '$i',
              amount: (i + 1) * 10.0,
              categoryId: 'cat1',
              type: 'expense',
              date: DateTime(2024, 1, i + 1),
              createdAt: DateTime(2024, 1, i + 1),
              updatedAt: DateTime(2024, 1, i + 1),
            ),
          );
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenAnswer((_) async => tManyTransactions);
          when(() => mockGetTotalBalance()).thenAnswer((_) async => 1000.0);
          when(() => mockGetCategories()).thenAnswer((_) async => []);
          when(() => mockGetBudgetData()).thenAnswer(
            (_) async => const BudgetData(
              totalBudget: 1000,
              totalSpent: 150,
              categories: [],
            ),
          );
          return bloc;
        },
        act: (bloc) => bloc.add(const LoadHomeData()),
        expect: () => [
          const HomeLoading(),
          isA<HomeLoaded>()
              .having(
                (s) => s.recentTransactions.length,
                'transactions count',
                5,
              )
              .having((s) => s.totalBalance, 'balance', 1000.0),
        ],
        verify: (_) {
          verify(() => mockGetRecentTransactions(limit: 5)).called(1);
        },
      );
    });

    group('RefreshHomeData - Edge Cases', () {
      blocTest<HomeBloc, HomeState>(
        'emits [Error] on refresh failure without emitting Loading first',
        build: () {
          when(
            () => mockGetRecentTransactions(limit: any(named: 'limit')),
          ).thenThrow(Exception('Refresh error'));
          return bloc;
        },
        seed: () => const HomeLoaded(
          recentTransactions: [],
          totalBalance: 500.0,
          categories: {},
          budgetData: BudgetData(
            totalBudget: 1000,
            totalSpent: 0,
            categories: [],
          ),
        ),
        act: (bloc) => bloc.add(const RefreshHomeData()),
        expect: () => [
          const HomeError(
            'An unexpected error occurred: Exception: Refresh error',
          ),
        ],
      );
    });
  });
}
