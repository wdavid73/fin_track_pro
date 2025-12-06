import 'package:fin_track_pro/features/transactions/presentation/widgets/date_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget createWidgetUnderTest({
    required DateTime selectedDate,
    required ValueChanged<DateTime> onDateSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: DateSelector(
          selectedDate: selectedDate,
          onDateSelected: onDateSelected,
        ),
      ),
    );
  }

  testWidgets('should display "Today" when selected date is today', (
    tester,
  ) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        selectedDate: DateTime.now(),
        onDateSelected: (_) {},
      ),
    );

    expect(find.text('Today'), findsOneWidget);
  });

  testWidgets('should display formatted date when selected date is not today', (
    tester,
  ) async {
    final date = DateTime(2023, 1, 1);
    await tester.pumpWidget(
      createWidgetUnderTest(selectedDate: date, onDateSelected: (_) {}),
    );

    expect(find.text('Jan 01, 2023'), findsOneWidget);
  });

  testWidgets('should be tappable', (tester) async {
    await tester.pumpWidget(
      createWidgetUnderTest(
        selectedDate: DateTime.now(),
        onDateSelected: (_) {},
      ),
    );

    await tester.tap(find.byType(GestureDetector));
    // We can't easily verify showDatePicker opened without integration test or mocking system channel
    // But we verified it's tappable.
  });
}
