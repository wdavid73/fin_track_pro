import 'dart:async';

import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/edit_transaction_cubit/edit_transaction_state.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/edit_transaction_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/category_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

class _FakeTransactionEvent extends Fake implements TransactionEvent {}

class _FakeTransactionState extends Fake implements TransactionState {}

class _FakeEditTransactionState extends Fake implements EditTransactionState {}

final _transaction = Transaction(
  id: 'tx-1',
  amount: 120.0,
  categoryId: 'cat-1',
  type: 'expense',
  note: 'Groceries',
  date: DateTime(2025, 12, 15, 10, 0),
  createdAt: DateTime(2025, 12, 15),
);

final _testCategories = [
  const Category(
    id: 'cat-1',
    name: 'Food',
    icon: 'restaurant',
    color: 0xFF4CAF50,
    type: 'expense',
  ),
  const Category(
    id: 'cat-2',
    name: 'Salary',
    icon: 'work',
    color: 0xFF2196F3,
    type: 'income',
  ),
];

// The default state that represents a loaded, valid expense form
EditTransactionState _loadedState({
  bool isLoadingCategories = false,
  bool isFormValid = true,
  bool isSubmitting = false,
  bool submitSuccess = false,
  String? errorMessage,
  String transactionType = 'expense',
  List<Category>? categories,
}) {
  return EditTransactionState(
    transaction: _transaction,
    transactionType: transactionType,
    amount: _transaction.amount,
    selectedCategoryId: _transaction.categoryId,
    description: _transaction.note ?? '',
    selectedDate: _transaction.date,
    categories: categories ?? _testCategories,
    isLoadingCategories: isLoadingCategories,
    isFormValid: isFormValid,
    isSubmitting: isSubmitting,
    submitSuccess: submitSuccess,
    errorMessage: errorMessage,
  );
}

// ---------------------------------------------------------------------------
// Widget builder
// ---------------------------------------------------------------------------

Widget _buildPage({
  required MockEditTransactionCubit cubit,
  required MockTransactionBloc transactionBloc,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: MultiBlocProvider(
        providers: [
          BlocProvider<EditTransactionCubit>.value(value: cubit),
          BlocProvider<TransactionBloc>.value(value: transactionBloc),
        ],
        child: const EditTransactionPage(),
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockEditTransactionCubit cubit;
  late MockTransactionBloc transactionBloc;

  setUpAll(() {
    registerFallbackValue(_FakeTransactionEvent());
    registerFallbackValue(_FakeTransactionState());
    registerFallbackValue(_FakeEditTransactionState());
  });

  setUp(() {
    cubit = MockEditTransactionCubit();
    transactionBloc = MockTransactionBloc();

    // Default mock wiring
    when(() => cubit.state).thenReturn(_loadedState());
    when(() => cubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => transactionBloc.state).thenReturn(const TransactionState());
    when(() => transactionBloc.stream).thenAnswer((_) => const Stream.empty());
  });

  group('EditTransactionPage', () {
    // ── Rendering ───────────────────────────────────────────────────────────

    testWidgets('renders header with "Edit Transaction" title', (tester) async {
      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Edit Transaction'), findsOneWidget);
    });

    testWidgets('renders close icon button in header', (tester) async {
      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.close), findsOneWidget);
    });

    testWidgets('renders Cancel and Update Transaction buttons', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Update Transaction'), findsOneWidget);
    });

    testWidgets('renders CategorySelector when not loading categories', (
      tester,
    ) async {
      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('renders CircularProgressIndicator when loading categories', (
      tester,
    ) async {
      when(
        () => cubit.state,
      ).thenReturn(_loadedState(isLoadingCategories: true));

      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CategorySelector), findsNothing);
    });

    // ── Update Transaction button state ────────────────────────────────────

    testWidgets('Update Transaction button is enabled when form is valid', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(_loadedState(isFormValid: true));

      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Update Transaction'),
      );
      expect(btn.onPressed, isNotNull);
    });

    testWidgets('Update Transaction button is disabled when form is invalid', (
      tester,
    ) async {
      when(() => cubit.state).thenReturn(_loadedState(isFormValid: false));

      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      final btn = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Update Transaction'),
      );
      expect(btn.onPressed, isNull);
    });

    testWidgets(
      'shows CircularProgressIndicator inside button when submitting',
      (tester) async {
        when(
          () => cubit.state,
        ).thenReturn(_loadedState(isSubmitting: true, isFormValid: true));

        await tester.pumpWidget(
          _buildPage(cubit: cubit, transactionBloc: transactionBloc),
        );
        await tester.pump();

        // Text replaced by spinner → no 'Update Transaction' text
        expect(find.text('Update Transaction'), findsNothing);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    // ── BlocConsumer listener tests ─────────────────────────────────────────

    // Note: Testing BlocConsumer listener side-effects (SnackBar, pop) via
    // broadcast streams requires careful setup. These are better covered by
    // integration tests. We instead verify the income type renders correctly.
    testWidgets('renders correctly when transactionType is income', (
      tester,
    ) async {
      when(
        () => cubit.state,
      ).thenReturn(_loadedState(transactionType: 'income'));

      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      // Header still shows 'Edit Transaction'
      expect(find.text('Edit Transaction'), findsOneWidget);
      // CategorySelector is rendered (not loading)
      expect(find.byType(CategorySelector), findsOneWidget);
    });

    // ── Interactions ────────────────────────────────────────────────────────

    testWidgets('tapping Update Transaction calls saveTransaction()', (
      tester,
    ) async {
      when(() => cubit.saveTransaction()).thenAnswer((_) async {});

      await tester.pumpWidget(
        _buildPage(cubit: cubit, transactionBloc: transactionBloc),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Update Transaction'));
      await tester.pump();

      verify(() => cubit.saveTransaction()).called(1);
    });
  });
}
