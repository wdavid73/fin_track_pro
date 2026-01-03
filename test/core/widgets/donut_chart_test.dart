import 'package:fin_track_pro/core/widgets/donut_chart.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('DonutChart should render with correct size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        locale: Locale('en'),
        home: Scaffold(
          body: DonutChart(
            totalSpent: 500,
            totalBudget: 1000,
            segments: [],
            size: 200,
          ),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, 200);
    expect(sizedBox.height, 200);
  });

  testWidgets('DonutChart should display "Spent" label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DonutChart(totalSpent: 500, totalBudget: 1000, segments: []),
        ),
      ),
    );

    expect(find.text('Spent'), findsOneWidget);
  });

  testWidgets('DonutChart should display total spent amount', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DonutChart(totalSpent: 500, totalBudget: 1000, segments: []),
        ),
      ),
    );

    // The amount is formatted as currency
    expect(find.textContaining('500'), findsOneWidget);
  });

  testWidgets('DonutChart should render with segments', (tester) async {
    const segments = [
      DonutSegment(value: 300, color: Colors.red),
      DonutSegment(value: 200, color: Colors.blue),
    ];

    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DonutChart(
            totalSpent: 500,
            totalBudget: 1000,
            segments: segments,
          ),
        ),
      ),
    );

    expect(find.byType(DonutChart), findsOneWidget);
  });

  testWidgets('DonutChart should use default size when not specified', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: DonutChart(totalSpent: 500, totalBudget: 1000, segments: []),
        ),
      ),
    );

    final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
    expect(sizedBox.width, 160); // Default size
    expect(sizedBox.height, 160);
  });

  test('DonutSegment should store value and color', () {
    const segment = DonutSegment(value: 100, color: Colors.red);

    expect(segment.value, 100);
    expect(segment.color, Colors.red);
  });
}
