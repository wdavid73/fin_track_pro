import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/analytics_summary_cards.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/income_vs_expense_chart.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/spending_by_category_chart.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/time_period_selector.dart';
import 'package:fin_track_pro/features/analytics/presentation/widgets/top_spending_categories.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<AnalyticsBloc>()..add(const LoadAnalyticsData()),
      child: Scaffold(
        key: const Key('analytics_page'),
        appBar: _appBar(context),
        body: SafeArea(child: _body()),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Text(context.l10n.analytics, style: context.textTheme.titleLarge),
      centerTitle: false,
    );
  }

  Widget _body() {
    return BlocBuilder<AnalyticsBloc, AnalyticsState>(
      builder: (context, state) {
        if (state.status == AnalyticsStatus.error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48, color: context.errorColor),
                const Gap(16),
                Text('${state.errorMessage}'),
                const Gap(16),
                ElevatedButton(
                  onPressed: () {
                    context.read<AnalyticsBloc>().add(
                      const RefreshAnalyticsData(),
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state.status == AnalyticsStatus.loading) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimePeriodSelector(
                    selectedPeriod: state.period,
                    onPeriodChanged: (_) {},
                  ),
                  const Gap(20),
                  const AnalyticsSummaryCards.loading(),
                  const Gap(20),
                  const SpendingByCategoryChart.loading(),
                  const Gap(20),
                  const IncomeVsExpenseChart.loading(),
                  const Gap(20),
                  const TopSpendingCategories.loading(),
                ],
              ),
            ),
          );
        }

        if (state.status == AnalyticsStatus.success && state.data != null) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TimePeriodSelector(
                    selectedPeriod: state.period,
                    onPeriodChanged: (period) {
                      context.read<AnalyticsBloc>().add(ChangePeriod(period));
                    },
                  ),
                  const Gap(20),
                  AnalyticsSummaryCards(
                    totalIncome: state.data!.totalIncome,
                    totalExpenses: state.data!.totalExpenses,
                    netSavings: state.data!.netSavings,
                  ),
                  const Gap(20),
                  SpendingByCategoryChart(
                    categorySpending: state.data!.categorySpending,
                  ),
                  const Gap(20),
                  IncomeVsExpenseChart(
                    comparisons: state.data!.comparisons,
                    periodLabel: _getPeriodLabel(state),
                  ),
                  const Gap(20),
                  TopSpendingCategories(
                    categories: state.data!.topSpendingCategories,
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  String _getPeriodLabel(AnalyticsState state) {
    if (state.data!.comparisons.isEmpty) {
      return 'This ${state.period.label} · 0%';
    }

    // Avoid division by zero
    if (state.data!.totalIncome == 0) {
      return 'This ${state.period.label} · 0%';
    }

    final percentage =
        ((state.data!.totalExpenses / state.data!.totalIncome) * 100)
            .toStringAsFixed(0);
    return 'This ${state.period.label} · -$percentage%';
  }
}
