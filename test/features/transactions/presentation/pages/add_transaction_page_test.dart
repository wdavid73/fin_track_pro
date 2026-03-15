import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_cubit.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/add_transaction_cubit/add_transaction_state.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/amount_input_widget.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/category_selector.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/date_selector.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/description_input.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Mocks
// ---------------------------------------------------------------------------

class MockAddTransactionCubit extends MockCubit<AddTransactionState>
    implements AddTransactionCubit {}

class MockTransactionBloc extends MockBloc<TransactionEvent, TransactionState>
    implements TransactionBloc {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

class FakeTransactionEvent extends Fake implements TransactionEvent {}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

final _tExpenseCategory = const Category(
  id: '1',
  name: 'Food',
  icon: 'restaurant',
  color: 0xFF000000,
  type: 'expense',
);

final _tIncomeCategory = const Category(
  id: '2',
  name: 'Salary',
  icon: 'work',
  color: 0xFF00FF00,
  type: 'income',
);

final _tDate = DateTime(2024, 1, 1);

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

Widget _buildTestWidget(
  MockAddTransactionCubit mockCubit,
  MockTransactionBloc mockTransactionBloc, {
  List<NavigatorObserver>? navigatorObservers,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: MultiBlocProvider(
      providers: [
        BlocProvider<AddTransactionCubit>.value(value: mockCubit),
        BlocProvider<TransactionBloc>.value(value: mockTransactionBloc),
      ],
      child: const Scaffold(body: AddTransactionPage()),
    ),
    navigatorObservers: navigatorObservers ?? [],
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockAddTransactionCubit mockCubit;
  late MockTransactionBloc mockTransactionBloc;
  late MockNavigatorObserver mockNavigatorObserver;

  setUpAll(() {
    registerFallbackValue(FakeRoute());
    registerFallbackValue(FakeTransactionEvent());
  });

  setUp(() {
    mockCubit = MockAddTransactionCubit();
    mockTransactionBloc = MockTransactionBloc();
    mockNavigatorObserver = MockNavigatorObserver();
    when(() => mockCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => mockTransactionBloc.stream).thenAnswer((_) => const Stream.empty());

    // Stub cubit methods
    when(() => mockCubit.updateAmount(any())).thenReturn(null);
    when(() => mockCubit.updateTransactionType(any())).thenReturn(null);
    when(() => mockCubit.updateCategory(any())).thenReturn(null);
    when(() => mockCubit.updateDescription(any())).thenReturn(null);
    when(() => mockCubit.updateDate(any())).thenReturn(null);
    when(() => mockCubit.saveTransaction()).thenAnswer((_) async {});
  });

  // ── Basic Rendering ─────────────────────────────────────────────────────

  group('Basic Rendering', () {
    testWidgets('should render all input widgets', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      expect(find.text('Add Transaction'), findsOneWidget);
      expect(find.byType(AmountInputWidget), findsOneWidget);
      expect(find.byType(CategorySelector), findsOneWidget);
      expect(find.byType(DescriptionInput), findsOneWidget);
      expect(find.byType(DateSelector), findsOneWidget);
      expect(find.byType(TransactionTypeToggle), findsOneWidget);
      expect(find.text('Save Transaction'), findsOneWidget);
    });

    testWidgets('renders close button in header', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      expect(find.byIcon(Icons.close), findsOneWidget);
    });

    testWidgets('renders Cancel button', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('should show loading indicator when categories are loading', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(isLoadingCategories: true, selectedDate: _tDate),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(CategorySelector), findsNothing);
    });

    testWidgets('shows CategorySelector when categories finished loading', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      expect(find.byType(CategorySelector), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(CategorySelector),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
      );
    });
  });

  // ── Form Validation ─────────────────────────────────────────────────────

  group('Form Validation', () {
    testWidgets('Save button is DISABLED when isFormValid is false', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          isFormValid: false,
          isSubmitting: false,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Transaction'),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('Save button is ENABLED when isFormValid is true', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          isFormValid: true,
          isSubmitting: false,
          amount: 100.0,
          selectedCategoryId: '1',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final saveButton = tester.widget<ElevatedButton>(
        find.widgetWithText(ElevatedButton, 'Save Transaction'),
      );
      expect(saveButton.onPressed, isNotNull);
    });

    testWidgets('Save button is DISABLED when isSubmitting is true', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          isFormValid: true,
          isSubmitting: true,
          amount: 100.0,
          selectedCategoryId: '1',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      // Find ElevatedButton and check if onPressed is null
      final saveButton = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(saveButton.onPressed, isNull);
    });

    testWidgets('shows CircularProgressIndicator in button when submitting', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          isFormValid: true,
          isSubmitting: true,
          amount: 100.0,
          selectedCategoryId: '1',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      // Find the CircularProgressIndicator inside the ElevatedButton
      expect(
        find.descendant(
          of: find.byType(ElevatedButton),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
    });
  });

  // ── Success Flow ────────────────────────────────────────────────────────

  group('Success Flow', () {
    testWidgets('submitSuccess triggers LoadTransactions event', (
      tester,
    ) async {
      final stateController = StreamController<AddTransactionState>.broadcast();

      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );
      when(() => mockCubit.stream).thenAnswer((_) => stateController.stream);

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));
      await tester.pump();

      // Simulate submit success
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          submitSuccess: true,
        ),
      );
      stateController.add(mockCubit.state);
      await tester.pumpAndSettle();

      verify(() => mockTransactionBloc.add(const LoadTransactions())).called(1);

      await stateController.close();
    });

  });

  // ── Error Handling ──────────────────────────────────────────────────────

  group('Error Handling', () {
    testWidgets('error SnackBar NOT shown when isLoadingCategories is true', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          isLoadingCategories: true,
          selectedDate: _tDate,
          errorMessage: 'Some error',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));
      await tester.pump();

      // Error snackbar should not appear during category loading
      expect(find.text('Some error'), findsNothing);
    });
  });

  // ── User Interactions ───────────────────────────────────────────────────

  group('User Interactions', () {
    testWidgets('should call updateAmount when amount changes', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      await tester.enterText(find.byType(TextField).first, '50');
      verify(() => mockCubit.updateAmount(50.0)).called(1);
    });

    testWidgets('tapping Save calls saveTransaction when form is valid', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          isFormValid: true,
          isSubmitting: false,
          amount: 100.0,
          selectedCategoryId: '1',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      await tester.tap(find.text('Save Transaction'));
      await tester.pump();

      verify(() => mockCubit.saveTransaction()).called(1);
    });

    testWidgets('tapping close button pops navigator', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          mockCubit,
          mockTransactionBloc,
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('tapping Cancel button pops navigator', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(
        _buildTestWidget(
          mockCubit,
          mockTransactionBloc,
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      verify(() => mockNavigatorObserver.didPop(any(), any())).called(1);
    });

    testWidgets('TransactionTypeToggle shows expense type by default', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          transactionType: 'expense',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final toggle = tester.widget<TransactionTypeToggle>(
        find.byType(TransactionTypeToggle),
      );
      expect(toggle.selectedType, 'expense');
    });

    testWidgets('TransactionTypeToggle passes correct type to widget', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tIncomeCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          transactionType: 'income',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final toggle = tester.widget<TransactionTypeToggle>(
        find.byType(TransactionTypeToggle),
      );
      expect(toggle.selectedType, 'income');
    });
  });

  // ── State-Based Rendering ───────────────────────────────────────────────

  group('State-Based Rendering', () {
    testWidgets('CategorySelector receives correct categories list', (
      tester,
    ) async {
      final categories = [_tExpenseCategory, _tIncomeCategory];

      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: categories,
          isLoadingCategories: false,
          selectedDate: _tDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final categorySelector = tester.widget<CategorySelector>(
        find.byType(CategorySelector),
      );
      expect(categorySelector.categories, equals(categories));
    });

    testWidgets('CategorySelector receives selected category ID', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          selectedCategoryId: '1',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final categorySelector = tester.widget<CategorySelector>(
        find.byType(CategorySelector),
      );
      expect(categorySelector.selectedCategoryId, '1');
    });

    testWidgets('DateSelector receives selected date', (tester) async {
      final selectedDate = DateTime(2024, 6, 15);

      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: selectedDate,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final dateSelector = tester.widget<DateSelector>(
        find.byType(DateSelector),
      );
      expect(dateSelector.selectedDate, equals(selectedDate));
    });

    testWidgets('AmountInputWidget receives initial amount', (tester) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          amount: 250.0,
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final amountInput = tester.widget<AmountInputWidget>(
        find.byType(AmountInputWidget),
      );
      expect(amountInput.initialAmount, 250.0);
    });

    testWidgets('DescriptionInput receives initial description', (
      tester,
    ) async {
      when(() => mockCubit.state).thenReturn(
        AddTransactionState(
          categories: [_tExpenseCategory],
          isLoadingCategories: false,
          selectedDate: _tDate,
          description: 'Test description',
        ),
      );

      await tester.pumpWidget(_buildTestWidget(mockCubit, mockTransactionBloc));

      final descriptionInput = tester.widget<DescriptionInput>(
        find.byType(DescriptionInput),
      );
      expect(descriptionInput.initialValue, 'Test description');
    });
  });
}
