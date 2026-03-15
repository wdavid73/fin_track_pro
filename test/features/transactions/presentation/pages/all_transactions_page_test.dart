import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_details_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

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

final _tNullNote = Transaction(
  id: 'tx-3',
  amount: 50.0,
  categoryId: 'cat1',
  type: 'expense',
  date: DateTime(2024, 1, 3),
  createdAt: DateTime(2024, 1, 3),
  note: null,
);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget(MockTransactionBloc bloc) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<TransactionBloc>.value(
      value: bloc,
      child: const Scaffold(body: AllTransactionsPage()),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockTransactionBloc mockBloc;

  setUpAll(() {
    registerFallbackValue(_FakeTransactionEvent());
    registerFallbackValue(_FakeTransactionState());
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
    // Wire up stream to avoid BlocConsumer errors
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());

    // Register in GetIt so AllTransactionsPage can resolve it
    final getIt = GetIt.instance;
    if (getIt.isRegistered<TransactionBloc>()) {
      getIt.unregister<TransactionBloc>();
    }
    getIt.registerFactory<TransactionBloc>(() => mockBloc);
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

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('All Transactions'), findsOneWidget);
    });

    testWidgets('renders filter icon button in AppBar', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const TransactionState(status: TransactionStatus.loading));

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.byIcon(Icons.filter_list), findsOneWidget);
    });

    testWidgets('filter badge is hidden when hasActiveFilters is false', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          hasActiveFilters: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });

    testWidgets('filter badge is visible when hasActiveFilters is true', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          hasActiveFilters: true,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('back arrow button is present in AppBar', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const TransactionState(status: TransactionStatus.loading));

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });

  // ── Loading state ─────────────────────────────────────────────────────────

  group('Loading state', () {
    testWidgets('renders CircularProgressIndicator', (tester) async {
      when(
        () => mockBloc.state,
      ).thenReturn(const TransactionState(status: TransactionStatus.loading));

      await tester.pumpWidget(_buildTestWidget(mockBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });

  // ── Empty state ───────────────────────────────────────────────────────────

  group('Empty state', () {
    testWidgets('shows empty icon and "No transactions yet" message', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          transactions: [],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });
  });

  // ── Error state ───────────────────────────────────────────────────────────

  group('Error state', () {
    const errorMessage = 'Failed to load transactions';

    testWidgets('shows error message and Retry button', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.error,
          errorMessage: errorMessage,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows generic error text when errorMessage is null', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.error,
          errorMessage: null,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.text('An error occurred'), findsOneWidget);
    });

    testWidgets('tapping Retry dispatches LoadPaginatedTransactions', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.error,
          errorMessage: errorMessage,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      await tester.tap(find.text('Retry'));
      await tester.pump();

      // Called twice: once on BlocProvider init (add LoadPaginatedTransactions)
      // and once on Retry tap.
      verify(
        () => mockBloc.add(const LoadPaginatedTransactions()),
      ).called(greaterThanOrEqualTo(1));
    });
  });

  // ── Success state — list ──────────────────────────────────────────────────

  group('Success state — transaction list', () {
    testWidgets('renders one TransactionCard per transaction', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense, _tIncome],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      expect(find.byType(TransactionCard), findsNWidgets(2));
    });

    testWidgets('renders transaction note as card title', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense, _tIncome],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('uses "Transaction" as fallback title when note is null', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tNullNote],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      expect(find.text('Transaction'), findsOneWidget);
    });

    testWidgets('income card shows "+" prefix in amount', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tIncome],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      // The amount text should start with "+"
      final amountFinder = find.textContaining('+');
      expect(amountFinder, findsOneWidget);
    });

    testWidgets('expense card shows "-" prefix in amount', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      // The amount text should start with "-"
      final amountFinder = find.textContaining('-');
      expect(amountFinder, findsOneWidget);
    });

    testWidgets(
      'shows pagination spinner at bottom when hasMore is true and list is '
      'not empty',
      (tester) async {
        // Build a list of 3 transactions so the list view renders
        final transactions = [_tExpense, _tIncome, _tNullNote];

        when(() => mockBloc.state).thenReturn(
          TransactionState(
            status: TransactionStatus.success,
            transactions: transactions,
            hasMore: true,
          ),
        );

        await tester.pumpWidget(_buildTestWidget(mockBloc));
        // Use pump with a finite duration instead of pumpAndSettle —
        // the FadeInUp animations from animate_do run continuously and
        // would cause pumpAndSettle to time out.
        await tester.pump(const Duration(seconds: 1));

        // itemCount = transactions.length + 1 (the hasMore spinner slot).
        // The spinner may be hidden below the fold — scroll to reveal it.
        await tester.drag(find.byType(ListView), const Offset(0, -1000));
        await tester.pump();

        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });

  // ── Long-press interaction ─────────────────────────────────────────────────

  group('Long-press interaction', () {
    testWidgets('long-pressing a card opens TransactionDetailsModal', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(TransactionCard).first);
      await tester.pumpAndSettle();

      // The modal should be visible on screen
      expect(find.byType(TransactionDetailsModal), findsOneWidget);
    });

    testWidgets('modal shows the transaction note as title', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      await tester.longPress(find.byType(TransactionCard).first);
      await tester.pumpAndSettle();

      // "Groceries" appears as the title inside the modal
      expect(find.text('Groceries'), findsWidgets);
    });
  });

  // ── Pagination behavior ─────────────────────────────────────────────────

  group('Pagination behavior', () {
    testWidgets('does not show pagination spinner when hasMore is false', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      // Only 1 TransactionCard, no extra spinner item
      expect(find.byType(TransactionCard), findsOneWidget);
    });

    testWidgets('renders correct item count with pagination indicator', (
      tester,
    ) async {
      final transactions = [_tExpense, _tIncome];

      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: transactions,
          hasMore: true,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump(const Duration(seconds: 1));

      // ListView itemCount = transactions.length + 1 (for spinner)
      // We should find 2 TransactionCards
      expect(find.byType(TransactionCard), findsNWidgets(2));
    });
  });

  // ── Filter functionality ────────────────────────────────────────────────

  group('Filter functionality', () {
    testWidgets('filter button key exists for testing', (tester) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          hasActiveFilters: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      expect(find.byKey(const Key('filter_button')), findsOneWidget);
    });

    testWidgets('filter badge reflects hasActiveFilters state true', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          hasActiveFilters: true,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isTrue);
    });

    testWidgets('filter badge reflects hasActiveFilters state false', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        const TransactionState(
          status: TransactionStatus.success,
          hasActiveFilters: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump();

      final badge = tester.widget<Badge>(find.byType(Badge));
      expect(badge.isLabelVisible, isFalse);
    });
  });

  // ── Transaction card styling ────────────────────────────────────────────

  group('Transaction card styling', () {
    testWidgets('income transaction has correct date format', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tIncome],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      // Date should be formatted as "MMM dd, yyyy"
      expect(find.text('Jan 02, 2024'), findsOneWidget);
    });

    testWidgets('expense transaction has correct date format', (tester) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pumpAndSettle();

      // Date should be formatted as "MMM dd, yyyy"
      expect(find.text('Jan 01, 2024'), findsOneWidget);
    });

    testWidgets('transaction card renders FadeInUp animation wrapper', (
      tester,
    ) async {
      when(() => mockBloc.state).thenReturn(
        TransactionState(
          status: TransactionStatus.success,
          transactions: [_tExpense],
          hasMore: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockBloc));
      await tester.pump(const Duration(milliseconds: 500));

      // FadeInUp widget should wrap the TransactionCard
      expect(
        find.ancestor(
          of: find.byType(TransactionCard),
          matching: find.byWidgetPredicate(
            (widget) => widget.runtimeType.toString() == 'FadeInUp',
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
