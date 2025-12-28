import 'package:fin_track_pro/core/widgets/budget_category_item.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('BudgetCategoryItem should display category name', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.red,
            name: 'Food',
            spent: 150,
            budget: 500,
          ),
        ),
      ),
    );

    expect(find.text('Food'), findsOneWidget);
  });

  testWidgets('BudgetCategoryItem should display spent and budget amounts', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.red,
            name: 'Food',
            spent: 150,
            budget: 500,
          ),
        ),
      ),
    );

    // Should display as "$150 / $500"
    expect(find.text('\$150 / \$500'), findsOneWidget);
  });

  testWidgets('BudgetCategoryItem should render color indicator', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.blue,
            name: 'Transport',
            spent: 50,
            budget: 200,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(BudgetCategoryItem),
        matching: find.byType(Container),
      ),
    );

    final decoration = container.decoration as BoxDecoration;
    expect(decoration.color, Colors.blue);
    expect(decoration.shape, BoxShape.circle);
  });

  testWidgets('BudgetCategoryItem should format large amounts correctly', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.green,
            name: 'Salary',
            spent: 1500,
            budget: 2000,
          ),
        ),
      ),
    );

    expect(find.text('\$1,500 / \$2,000'), findsOneWidget);
  });

  testWidgets('BudgetCategoryItem should handle zero values', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.orange,
            name: 'Entertainment',
            spent: 0,
            budget: 100,
          ),
        ),
      ),
    );

    expect(find.text('\$0 / \$100'), findsOneWidget);
  });

  testWidgets('BudgetCategoryItem should have correct padding', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.red,
            name: 'Food',
            spent: 150,
            budget: 500,
          ),
        ),
      ),
    );

    final padding = tester.widget<Padding>(find.byType(Padding).first);
    expect(padding.padding, const EdgeInsets.symmetric(vertical: 8.0));
  });

  testWidgets('BudgetCategoryItem color indicator should have correct size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: BudgetCategoryItem(
            color: Colors.purple,
            name: 'Shopping',
            spent: 75,
            budget: 150,
          ),
        ),
      ),
    );

    final container = tester.widget<Container>(
      find.descendant(
        of: find.byType(BudgetCategoryItem),
        matching: find.byType(Container),
      ),
    );

    expect(container.constraints?.maxWidth, 12);
    expect(container.constraints?.maxHeight, 12);
  });
}
