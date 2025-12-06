import 'package:fin_track_pro/features/transactions/presentation/widgets/description_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({
    String? initialValue,
    ValueChanged<String>? onChanged,
    String? hintText,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DescriptionInput(
          initialValue: initialValue,
          onChanged: onChanged,
          hintText: hintText,
        ),
      ),
    );
  }

  testWidgets('should display initial value', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        initialValue: 'Test Description',
        onChanged: (_) {},
      ),
    );

    expect(find.text('Test Description'), findsOneWidget);
  });

  testWidgets('should display hint text', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(hintText: 'Enter description', onChanged: (_) {}),
    );

    expect(find.text('Enter description'), findsOneWidget);
  });

  testWidgets('should call onChanged when text changes', (tester) async {
    String? changedText;
    await tester.pumpWidget(
      createWidgetUnderTest(onChanged: (value) => changedText = value),
    );

    await tester.enterText(find.byType(TextField), 'New Description');
    expect(changedText, 'New Description');
  });
}
