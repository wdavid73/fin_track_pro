import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockCategoryBloc extends MockBloc<CategoryEvent, CategoryState>
    implements CategoryBloc {}

class _FakeTransactionEvent extends Fake implements TransactionEvent {}

class _FakeTransactionState extends Fake implements TransactionState {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _tExpense = Transaction(
  id: 'tx-1',
  amount: 100.0,
  categoryId: 'cat1',
  type: 'expense',
  date: DateTime(2024, 1, 1),
  createdAt: DateTime(2024, 1, 1),
  note: 'Groceries',
);

final _tIncome = Transaction(
  id: 'tx-2',
  amount: 2000.0,
  categoryId: 'cat2',
  type: 'income',
  date: DateTime(2024, 1, 2),
  createdAt: DateTime(2024, 1, 2),
  note: 'Salary',
);

final _tCategory1 = const Category(
  id: 'cat1',
  name: 'Food',
  icon: 'food',
  color: 0xFF000000,
  type: 'expense',
);

final _tCategory2 = const Category(
  id: 'cat2',
  name: 'Income',
  icon: 'money',
  color: 0xFF000000,
  type: 'income',
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget() {
  return const MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: AllTransactionsPage(),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockTransactionBloc mockBloc;
  late MockCategoryBloc mockCategoryBloc;

  setUpAll(() {
    registerFallbackValue(_FakeTransactionEvent());
    registerFallbackValue(_FakeTransactionState());
    registerFallbackValue(LoadCategoriesEvent());
    registerFallbackValue(const CategoryState());
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
  });

  setUp(() {
    mockBloc = MockTransactionBloc();
    mockCategoryBloc = MockCategoryBloc();

    // Wire up stream to avoid BlocConsumer/Provider errors
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockCategoryBloc.stream).thenAnswer((_) => const Stream.empty());

    when(() => mockCategoryBloc.state).thenReturn(
      CategoryState(
        status: CategoryStatus.success,
        categories: [_tCategory1, _tCategory2],
      ),
    );

    // Register in GetIt so AllTransactionsPage can resolve it
    final getIt = GetIt.instance;
    if (getIt.isRegistered<TransactionBloc>()) {
      getIt.unregister<TransactionBloc>();
    }
    if (getIt.isRegistered<CategoryBloc>()) {
      getIt.unregister<CategoryBloc>();
    }
    getIt.registerFactory<TransactionBloc>(() => mockBloc);
    getIt.registerFactory<CategoryBloc>(() => mockCategoryBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  // ── AppBar ────────────────────────────────────────────────────────────────

  group('AppBar', () {
    testWidgets('renders "All Transactions" title', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const TransactionState(status: TransactionStatus.loading));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.text('All Transactions'), findsOneWidget);
    });

    testWidgets('renders filter layout button in AppBar', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const TransactionState(status: TransactionStatus.loading));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byIcon(Icons.filter_list_rounded), findsOneWidget);
    });
  });

  // ── Loading state ─────────────────────────────────────────────────────────

  group('Loading state', () {
    testWidgets('renders Shimmer placeholders', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const TransactionState(status: TransactionStatus.loading));

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      expect(find.byType(ShimmerCircle), findsWidgets);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('Empty state', () {
    testWidgets('shows empty layout with message', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          transactions: [],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget());
      await tester.pump();

      // "No transactions" depending on locale
      expect(find.text('No transactions'), findsOneWidget);
    });
  });

  // ── Success state — list ──────────────────────────────────────────────────

  group('Success state — transaction list', () {
    testWidgets('renders transactions with their names', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense, _tIncome],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsWidgets);
      expect(find.text('Income'), findsWidgets);
    });

    testWidgets('renders Income and Expenses summary totals', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense, _tIncome],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      // The widgets include Income and Expenses
      expect(find.text('Total Income'), findsOneWidget);
      expect(find.text('Total Expenses'), findsOneWidget);
      // Amounts
      expect(find.textContaining('100'), findsWidgets);
      expect(find.textContaining('2,000'), findsWidgets);
    });
  });

  // ── Interaction ─────────────────────────────────────────────────────────

  group('Filter usage', () {
    testWidgets('Tap expense chip adds FilterTransactions', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          transactions: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expense'));
      await tester.pump();

      verify(
        () => mockBloc.add(const FilterTransactions(type: 'expense')),
      ).called(1);
    });

    testWidgets('Tap Income chip adds FilterTransactions', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          transactions: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Income'));
      await tester.pump();

      verify(
        () => mockBloc.add(const FilterTransactions(type: 'income')),
      ).called(1);
    });

    testWidgets('Tap category button invokes show modal with categories', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          transactions: [],
        ),
      );

      await tester.pumpWidget(_buildTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.filter_list_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Filter by Category'), findsOneWidget);
      expect(find.textContaining('Food'), findsOneWidget);
    });
  });
}
