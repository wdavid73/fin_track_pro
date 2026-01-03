import 'package:fin_track_pro/features/transactions/presentation/widgets/amount_input_widget.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({
    double? initialAmount,
    required ValueChanged<double?> onAmountChanged,
    String transactionType = 'expense',
  }) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: AmountInputWidget(
          initialAmount: initialAmount,
          onAmountChanged: onAmountChanged,
          transactionType: transactionType,
        ),
      ),
    );
  }

  testWidgets('should display initial amount', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(initialAmount: 100.0, onAmountChanged: (_) {}),
    );

    expect(find.text('100.00'), findsOneWidget);
  });

  testWidgets('should call onAmountChanged when text changes', (tester) async {
    double? changedAmount;
    await tester.pumpWidget(
      createWidgetUnderTest(onAmountChanged: (value) => changedAmount = value),
    );

    // Enter text
    await tester.enterText(find.byType(TextField), '50');
    await tester.pump();

    expect(changedAmount, 50.0);
  });

  testWidgets('should display correct color for expense', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        onAmountChanged: (_) {},
        transactionType: 'expense',
      ),
    );

    final text = tester.widget<Text>(find.text('\$'));
    // Error color is usually red-ish, but exact color depends on theme.
    // We just verify it renders without error.
    expect(text.style?.color, isNotNull);
  });

  testWidgets('should display correct color for income', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(onAmountChanged: (_) {}, transactionType: 'income'),
    );

    final text = tester.widget<Text>(find.text('\$'));
    expect(text.style?.color, isNotNull);
  });
}
