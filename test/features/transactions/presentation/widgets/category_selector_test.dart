import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/category_selector.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/category_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tCategories = [
    const Category(
      id: '1',
      name: 'Food',
      icon: 'restaurant',
      color: 0xFF000000,
      type: 'expense',
    ),
    const Category(
      id: '2',
      name: 'Salary',
      icon: 'work',
      color: 0xFF000000,
      type: 'income',
    ),
  ];

  Widget createWidgetUnderTest({
    required List<Category> categories,
    String? selectedCategoryId,
    required ValueChanged<String> onCategorySelected,
    String transactionType = 'expense',
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CategorySelector(
          categories: categories,
          selectedCategoryId: selectedCategoryId,
          onCategorySelected: onCategorySelected,
          transactionType: transactionType,
        ),
      ),
    );
  }

  testWidgets('should display only categories matching transaction type', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        categories: tCategories,
        onCategorySelected: (_) {},
        transactionType: 'expense',
      ),
    );

    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Salary'), findsNothing);
  });

  testWidgets('should call onCategorySelected when chip is tapped', (
    tester,
  ) async {
    String? selectedId;
    await tester.pumpWidget(
      createWidgetUnderTest(
        categories: tCategories,
        onCategorySelected: (id) => selectedId = id,
        transactionType: 'expense',
      ),
    );

    await tester.tap(find.text('Food'));
    expect(selectedId, '1');
  });

  testWidgets('should show selected state', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        categories: tCategories,
        selectedCategoryId: '1',
        onCategorySelected: (_) {},
        transactionType: 'expense',
      ),
    );

    final chip = tester.widget<CategoryChip>(find.byType(CategoryChip).first);
    expect(chip.isSelected, true);
  });
}
