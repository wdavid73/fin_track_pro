import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/home/presentation/home_page.dart';
import 'package:fin_track_pro/features/home/presentation/widget/balance_summary.dart';
import 'package:fin_track_pro/features/home/presentation/widget/budget_overview.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transactions.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockHomeBloc extends MockBloc<HomeEvent, HomeState> implements HomeBloc {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

void main() {
  late MockHomeBloc mockHomeBloc;
  late MockTransactionBloc mockTransactionBloc;

  setUpAll(() {
    registerFallbackValue(const LoadHomeData());
    registerFallbackValue(const RefreshHomeData());
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
  });

  setUp(() {
    mockHomeBloc = MockHomeBloc();
    mockTransactionBloc = MockTransactionBloc();

    // Setup GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<HomeBloc>()) {
      getIt.unregister<HomeBloc>();
    }
    if (getIt.isRegistered<TransactionBloc>()) {
      getIt.unregister<TransactionBloc>();
    }
    getIt.registerFactory<HomeBloc>(() => mockHomeBloc);
    getIt.registerFactory<TransactionBloc>(() => mockTransactionBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return const MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: HomePage(),
    );
  }

  final tTransactions = [
    Transaction(
      id: '1',
      amount: 100.0,
      categoryId: 'cat1',
      type: 'expense',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
      note: 'Groceries',
    ),
  ];

  final tCategories = {
    'cat1': const Category(
      id: 'cat1',
      name: 'Food',
      icon: 'food_icon',
      color: 123,
      type: 'expense',
    ),
  };

  final tBudgetData = const BudgetData(
    totalBudget: 1000,
    totalSpent: 500,
    categories: [],
  );

  group('HomePage', () {
    testWidgets('renders loading state correctly', (tester) async {
      when(() => mockHomeBloc.state).thenReturn(const HomeLoading());
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(
        const Duration(seconds: 1),
      ); // Wait for entrance animations, ignore shimmers

      expect(
        find.byType(BalanceSummary),
        findsOneWidget,
      ); // Loading state is internal
      expect(
        find.byType(BudgetOverview),
        findsOneWidget,
      ); // Loading state is internal
      expect(
        find.byType(Transactions),
        findsOneWidget,
      ); // Loading state is internal
    });

    testWidgets('renders loaded state correctly', (tester) async {
      when(() => mockHomeBloc.state).thenReturn(
        HomeLoaded(
          recentTransactions: tTransactions,
          totalBalance: 1000.0,
          categories: tCategories,
          budgetData: tBudgetData,
        ),
      );
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('FinTrack Pro'), findsOneWidget);
      expect(find.byType(BalanceSummary), findsOneWidget);
      expect(find.byType(BudgetOverview), findsOneWidget);
      expect(find.byType(Transactions), findsOneWidget);
    });

    testWidgets('renders error state correctly', (tester) async {
      const errorMessage = 'Failed to load home data';
      when(() => mockHomeBloc.state).thenReturn(const HomeError(errorMessage));
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester
          .pumpAndSettle(); // Allow error widget to build and animations to finish

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('triggers RefreshHomeData on retry', (tester) async {
      const errorMessage = 'Failed to load home data';
      when(() => mockHomeBloc.state).thenReturn(const HomeError(errorMessage));
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Retry'));

      verify(() => mockHomeBloc.add(const RefreshHomeData())).called(1);
    });

    testWidgets('triggers LoadHomeData on init', (tester) async {
      when(() => mockHomeBloc.state).thenReturn(const HomeLoading());
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionState());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(
        const Duration(seconds: 1),
      ); // Wait for entrance animations, ignore shimmers

      verify(() => mockHomeBloc.add(const LoadHomeData())).called(1);
    });
  });
}
