import 'package:fin_track_pro/features/transactions/presentation/widgets/transaction_type_toggle.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({
    required String selectedType,
    required ValueChanged<String> onTypeChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: TransactionTypeToggle(
          selectedType: selectedType,
          onTypeChanged: onTypeChanged,
        ),
      ),
    );
  }

  testWidgets('should display Expense and Income options', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(selectedType: 'expense', onTypeChanged: (_) {}),
    );

    expect(find.text('Expense'), findsOneWidget);
    expect(find.text('Income'), findsOneWidget);
  });

  testWidgets('should call onTypeChanged when Income is tapped', (
    tester,
  ) async {
    String? newType;
    await tester.pumpWidget(
      createWidgetUnderTest(
        selectedType: 'expense',
        onTypeChanged: (type) => newType = type,
      ),
    );

    await tester.tap(find.text('Income'));
    expect(newType, 'income');
  });

  testWidgets('should call onTypeChanged when Expense is tapped', (
    tester,
  ) async {
    String? newType;
    await tester.pumpWidget(
      createWidgetUnderTest(
        selectedType: 'income',
        onTypeChanged: (type) => newType = type,
      ),
    );

    await tester.tap(find.text('Expense'));
    expect(newType, 'expense');
  });
}
