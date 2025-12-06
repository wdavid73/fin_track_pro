import 'package:bloc_test/bloc_test.dart';

import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:fin_track_pro/features/analytics/presentation/analytics_page.dart';
import 'package:fin_track_pro/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/analytics_summary_cards.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/income_vs_expense_chart.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/time_period_selector.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/top_spending_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockAnalyticsBloc extends MockBloc<AnalyticsEvent, AnalyticsState>
    implements AnalyticsBloc {}

void main() {
  late MockAnalyticsBloc mockAnalyticsBloc;

  setUpAll(() {
    registerFallbackValue(AnalyticsPeriod.week);
    registerFallbackValue(const LoadAnalyticsData());
    registerFallbackValue(const ChangePeriod(AnalyticsPeriod.week));
  });

  setUp(() {
    mockAnalyticsBloc = MockAnalyticsBloc();

    // Setup GetIt
    final getIt = GetIt.instance;
    if (getIt.isRegistered<AnalyticsBloc>()) {
      getIt.unregister<AnalyticsBloc>();
    }
    getIt.registerFactory<AnalyticsBloc>(() => mockAnalyticsBloc);
  });

  tearDown(() {
    GetIt.instance.reset();
  });

  Widget createWidgetUnderTest() {
    return MaterialApp(
      home: BlocProvider<AnalyticsBloc>(
        create: (_) => mockAnalyticsBloc,
        child: const AnalyticsPage(),
      ),
    );
  }

  const tAnalyticsData = AnalyticsData(
    totalIncome: 1000,
    totalExpenses: 500,
    categorySpending: [],
    comparisons: [],
  );

  group('AnalyticsPage', () {
    testWidgets('renders loading state correctly', (tester) async {
      when(
        () => mockAnalyticsBloc.state,
      ).thenReturn(const AnalyticsLoading(period: AnalyticsPeriod.month));

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AnalyticsSummaryCards), findsOneWidget);
      expect(find.byType(TimePeriodSelector), findsOneWidget);
      // Charts might be hidden or showing shimmer depending on implementation
      // But SummaryCards handles its own loading state
    });

    testWidgets('renders loaded state correctly', (tester) async {
      when(() => mockAnalyticsBloc.state).thenReturn(
        const AnalyticsLoaded(
          data: tAnalyticsData,
          period: AnalyticsPeriod.month,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(AnalyticsSummaryCards), findsOneWidget);
      expect(find.byType(TimePeriodSelector), findsOneWidget);
      expect(find.byType(IncomeVsExpenseChart), findsOneWidget);
      expect(find.byType(TopSpendingCategories), findsOneWidget);

      // Verify data is displayed
      expect(find.text('Total Income'), findsOneWidget);
      expect(find.text('Total Expenses'), findsOneWidget);
    });

    testWidgets('renders error state correctly', (tester) async {
      const errorMessage = 'Something went wrong';
      when(() => mockAnalyticsBloc.state).thenReturn(
        const AnalyticsError(
          message: errorMessage,
          period: AnalyticsPeriod.month,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(); // Allow error widget to build

      expect(find.text(errorMessage), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
    });

    testWidgets('triggers ChangePeriod event when period selected', (
      tester,
    ) async {
      when(() => mockAnalyticsBloc.state).thenReturn(
        const AnalyticsLoaded(
          data: tAnalyticsData,
          period: AnalyticsPeriod.month,
        ),
      );

      await tester.pumpWidget(createWidgetUnderTest());

      // Find 'Week' button (TimePeriodSelector uses SegmentedButton or similar)
      // Assuming TimePeriodSelector renders text for periods
      await tester.tap(find.text('Week'));
      await tester.pump();

      verify(
        () => mockAnalyticsBloc.add(const ChangePeriod(AnalyticsPeriod.week)),
      ).called(1);
    });
  });
}
