import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

void main() {
  late MockTransactionBloc mockTransactionBloc;

  setUpAll(() {
    registerFallbackValue(const LoadPaginatedTransactions());
    registerFallbackValue(const LoadMoreTransactions());
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'FinTrack Pro Test',
      bundleId: 'com.example.fintrackpro.test',
      enableLogging: false,
      showDebugBanner: false,
    );
  });

  setUp(() {
    mockTransactionBloc = MockTransactionBloc();

    // Setup GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<TransactionBloc>()) {
      getIt.unregister<TransactionBloc>();
    }
    getIt.registerFactory<TransactionBloc>(() => mockTransactionBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(home: const AllTransactionsPage());
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
    Transaction(
      id: '2',
      amount: 2000.0,
      categoryId: 'cat2',
      type: 'income',
      date: DateTime(2024, 1, 2),
      createdAt: DateTime(2024, 1, 2),
      note: 'Salary',
    ),
  ];

  group('AllTransactionsPage', () {
    testWidgets('renders loading state correctly', (tester) async {
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionLoading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders loaded state with transactions correctly', (
      tester,
    ) async {
      when(() => mockTransactionBloc.state).thenReturn(
        TransactionPaginatedLoaded(
          transactions: tTransactions,
          hasMore: false,
          currentOffset: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(TransactionCard), findsNWidgets(2));
      expect(find.text('Groceries'), findsOneWidget);
      expect(find.text('Salary'), findsOneWidget);
    });

    testWidgets('renders empty state correctly', (tester) async {
      when(() => mockTransactionBloc.state).thenReturn(
        const TransactionPaginatedLoaded(
          transactions: [],
          hasMore: false,
          currentOffset: 0,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('No transactions yet'), findsOneWidget);
      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
    });

    testWidgets('renders error state correctly', (tester) async {
      const errorMessage = 'Failed to load transactions';
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionError(errorMessage));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow error widget to build

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('triggers LoadPaginatedTransactions on retry', (tester) async {
      const errorMessage = 'Failed to load transactions';
      when(
        () => mockTransactionBloc.state,
      ).thenReturn(const TransactionError(errorMessage));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text('Retry'));

      verify(
        () => mockTransactionBloc.add(const LoadPaginatedTransactions()),
      ).called(2);
    });
  });
}
