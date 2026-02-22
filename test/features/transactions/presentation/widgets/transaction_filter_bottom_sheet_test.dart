import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_filter_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

final _expenseCategory = const Category(
  id: 'cat-1',
  name: 'Food',
  icon: 'restaurant',
  color: 0xFF4CAF50,
  type: 'expense',
);

final _incomeCategory = const Category(
  id: 'cat-2',
  name: 'Salary',
  icon: 'work',
  color: 0xFF2196F3,
  type: 'income',
);

Widget _buildSheet({
  String? selectedType,
  String? selectedCategoryId,
  DateTime? startDate,
  DateTime? endDate,
  String? searchQuery,
  List<Category> categories = const [],
  Function(String?, String?, DateTime?, DateTime?, String?)? onApplyFilters,
  VoidCallback? onClearFilters,
}) {
  return MaterialApp(
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: TransactionFilterBottomSheet(
        selectedType: selectedType,
        selectedCategoryId: selectedCategoryId,
        startDate: startDate,
        endDate: endDate,
        searchQuery: searchQuery,
        categories: categories,
        onApplyFilters: onApplyFilters ?? (type, catId, start, end, query) {},
        onClearFilters: onClearFilters ?? () {},
      ),
    ),
  );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('TransactionFilterBottomSheet', () {
    // ── Rendering ──────────────────────────────────────────────────────────

    testWidgets('renders without error with no categories', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(find.text('Filter Transactions'), findsOneWidget);
    });

    testWidgets('shows search text field with search icon', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('shows transaction type toggle with All / Expense / Income', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(find.text('All'), findsOneWidget);
      expect(find.text('Expense'), findsOneWidget);
      expect(find.text('Income'), findsOneWidget);
    });

    testWidgets('shows Apply Filters and Clear All buttons', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(find.text('Apply Filters'), findsOneWidget);
      expect(find.text('Clear All'), findsOneWidget);
    });

    testWidgets('shows close (X) icon button in header', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(find.widgetWithIcon(IconButton, Icons.close), findsOneWidget);
    });

    // ── Initial state ──────────────────────────────────────────────────────

    testWidgets('initializes search field with provided searchQuery', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet(searchQuery: 'groceries'));
      await tester.pumpAndSettle();

      expect(find.text('groceries'), findsOneWidget);
    });

    testWidgets('shows Start Date and End Date placeholder buttons', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
    });

    testWidgets('shows formatted start date when startDate provided', (
      tester,
    ) async {
      final date = DateTime(2025, 12, 15);
      await tester.pumpWidget(_buildSheet(startDate: date));
      await tester.pumpAndSettle();

      expect(find.text('Dec 15, 2025'), findsOneWidget);
    });

    // ── Search field interactions ───────────────────────────────────────────

    testWidgets('clear icon appears in search field after typing', (
      tester,
    ) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      // Initially no clear button
      expect(find.widgetWithIcon(IconButton, Icons.clear), findsNothing);

      await tester.enterText(find.byType(TextField), 'coffee');
      await tester.pump();

      expect(find.widgetWithIcon(IconButton, Icons.clear), findsOneWidget);
    });

    testWidgets('clear icon in search field clears the text', (tester) async {
      await tester.pumpWidget(_buildSheet());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'coffee');
      await tester.pump();

      await tester.tap(find.widgetWithIcon(IconButton, Icons.clear));
      await tester.pump();

      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller?.text, isEmpty);
    });

    // ── Type toggle interactions ────────────────────────────────────────────

    testWidgets('tapping Expense changes selected type', (tester) async {
      String? capturedType;
      await tester.pumpWidget(
        _buildSheet(
          onApplyFilters: (type, catId, start, end, query) {
            capturedType = type;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Expense'));
      await tester.pump();

      await tester.tap(find.text('Apply Filters'));
      await tester.pump();

      expect(capturedType, 'expense');
    });

    testWidgets('tapping Income changes selected type', (tester) async {
      String? capturedType;
      await tester.pumpWidget(
        _buildSheet(
          onApplyFilters: (type, catId, start, end, query) {
            capturedType = type;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Income'));
      await tester.pump();

      await tester.tap(find.text('Apply Filters'));
      await tester.pump();

      expect(capturedType, 'income');
    });

    testWidgets('tapping All resets type to null', (tester) async {
      String? capturedType = 'sentinel'; // Non-null start
      await tester.pumpWidget(
        _buildSheet(
          selectedType: 'expense',
          onApplyFilters: (type, catId, start, end, query) {
            capturedType = type;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('All'));
      await tester.pump();

      await tester.tap(find.text('Apply Filters'));
      await tester.pump();

      expect(capturedType, isNull);
    });

    // ── Apply Filters callback ──────────────────────────────────────────────

    testWidgets('Apply Filters passes null for empty search query', (
      tester,
    ) async {
      String? capturedQuery = 'sentinel';
      await tester.pumpWidget(
        _buildSheet(
          onApplyFilters: (type, catId, start, end, query) {
            capturedQuery = query;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Apply Filters'));
      await tester.pump();

      expect(capturedQuery, isNull);
    });

    testWidgets('Apply Filters passes search text when non-empty', (
      tester,
    ) async {
      String? capturedQuery;
      await tester.pumpWidget(
        _buildSheet(
          onApplyFilters: (type, catId, start, end, query) {
            capturedQuery = query;
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'rent');
      await tester.pump();

      await tester.tap(find.text('Apply Filters'));
      await tester.pump();

      expect(capturedQuery, 'rent');
    });

    // ── Clear Filters callback ──────────────────────────────────────────────

    testWidgets('Clear All invokes onClearFilters callback', (tester) async {
      var clearCalled = false;
      await tester.pumpWidget(
        _buildSheet(onClearFilters: () => clearCalled = true),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Clear All'));
      await tester.pump();

      expect(clearCalled, isTrue);
    });

    // ── Category dropdown ───────────────────────────────────────────────────

    testWidgets('shows categories in dropdown', (tester) async {
      await tester.pumpWidget(
        _buildSheet(categories: [_expenseCategory, _incomeCategory]),
      );
      await tester.pumpAndSettle();

      // Open the dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();

      expect(find.text('Food'), findsWidgets);
      expect(find.text('Salary'), findsWidgets);
    });

    testWidgets('category dropdown filters by selected type', (tester) async {
      await tester.pumpWidget(
        _buildSheet(
          selectedType: 'expense',
          categories: [_expenseCategory, _incomeCategory],
        ),
      );
      await tester.pumpAndSettle();

      // Open the dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String?>));
      await tester.pumpAndSettle();

      // Only expense category should appear (income is filtered out)
      expect(find.text('Food'), findsWidgets);
      expect(find.text('Salary'), findsNothing);
    });
  });
}
