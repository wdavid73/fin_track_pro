import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_details_modal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

// Register fallback values for mocktail
class _FakeTransactionEvent extends Fake implements TransactionEvent {}

class _FakeTransactionState extends Fake implements TransactionState {}

final _incomeTransaction = Transaction(
  id: 'tx-1',
  amount: 1500.0,
  categoryId: 'cat-1',
  type: 'income',
  note: 'Monthly salary',
  date: DateTime(2025, 12, 15, 10, 30),
  createdAt: DateTime(2025, 12, 15),
);

final _expenseTransaction = Transaction(
  id: 'tx-2',
  amount: 75.50,
  categoryId: 'cat-2',
  type: 'expense',
  note: 'Lunch',
  date: DateTime(2025, 12, 16, 13, 0),
  createdAt: DateTime(2025, 12, 16),
);

Widget _buildModal({
  required Transaction transaction,
  IconData icon = Icons.work,
  Color iconColor = Colors.green,
  Color iconBackground = Colors.greenAccent,
  String? heroTag,
  required MockTransactionBloc bloc,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: BlocProvider<TransactionBloc>.value(
      value: bloc,
      child: Scaffold(
        body: TransactionDetailsModal(
          transaction: transaction,
          icon: icon,
          iconColor: iconColor,
          iconBackgroundColor: iconBackground,
          heroTag: heroTag,
        ),
      ),
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
  });

  setUp(() {
    mockBloc = MockTransactionBloc();
    when(() => mockBloc.state).thenReturn(const TransactionState());
    when(() => mockBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('TransactionDetailsModal', () {
    // ── Amount display ──────────────────────────────────────────────────────

    testWidgets('displays income amount with + prefix', (tester) async {
      await tester.pumpWidget(
        _buildModal(transaction: _incomeTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      expect(find.textContaining('+'), findsOneWidget);
      expect(find.textContaining('1,500'), findsOneWidget);
    });

    testWidgets('displays expense amount with - prefix', (tester) async {
      await tester.pumpWidget(
        _buildModal(transaction: _expenseTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      // '-$' is unique: only the amount Text combines both
      expect(find.textContaining('-\$'), findsOneWidget);
    });

    // ── Note display ────────────────────────────────────────────────────────

    testWidgets('displays transaction note', (tester) async {
      await tester.pumpWidget(
        _buildModal(transaction: _incomeTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Monthly salary'), findsOneWidget);
    });

    testWidgets('displays fallback text when note is null', (tester) async {
      // copyWith(note: null) does not work due to Dart null-safety ?? operator;
      // create a Transaction directly with note: null.
      final noNoteTransaction = Transaction(
        id: 'tx-no-note',
        amount: 500.0,
        categoryId: 'cat-1',
        type: 'income',
        note: null,
        date: DateTime(2025, 12, 15, 10, 30),
        createdAt: DateTime(2025, 12, 15),
      );
      await tester.pumpWidget(
        _buildModal(transaction: noNoteTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Transaction'), findsOneWidget);
    });

    // ── Icon display ────────────────────────────────────────────────────────

    testWidgets('renders icon without Hero when heroTag is null', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildModal(
          transaction: _incomeTransaction,
          bloc: mockBloc,
          heroTag: null,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(Hero), findsNothing);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    testWidgets('renders icon with Hero when heroTag is provided', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildModal(
          transaction: _incomeTransaction,
          bloc: mockBloc,
          heroTag: 'hero-tx-1',
        ),
      );
      await tester.pumpAndSettle();

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'hero-tx-1');
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    // ── Action buttons ──────────────────────────────────────────────────────

    // Note: The Delete button calls getIt<TransactionBloc>() directly (not the
    // injected BlocProvider). In widget tests we verify the button exists and
    // can be found — the integration of getIt is tested via bloc unit tests.
    testWidgets('shows Edit and Delete buttons', (tester) async {
      await tester.pumpWidget(
        _buildModal(transaction: _incomeTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('Delete button is an ElevatedButton.icon', (tester) async {
      await tester.pumpWidget(
        _buildModal(transaction: _incomeTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      expect(
        find.widgetWithIcon(ElevatedButton, Icons.delete_outline),
        findsOneWidget,
      );
    });

    // ── Date display ────────────────────────────────────────────────────────

    testWidgets('displays the formatted date', (tester) async {
      await tester.pumpWidget(
        _buildModal(transaction: _incomeTransaction, bloc: mockBloc),
      );
      await tester.pumpAndSettle();

      // Dec 15, 2025
      expect(find.textContaining('December'), findsOneWidget);
      expect(find.textContaining('15'), findsOneWidget);
      expect(find.textContaining('2025'), findsOneWidget);
    });
  });
}
