import 'package:fin_track_pro/core/extensions/extensions.dart';
import 'package:fin_track_pro/core/widgets/shimmer_wrapper.dart';
import 'package:fin_track_pro/core/widgets/skeleton.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Widget displaying income vs expense comparison as a bar chart
class IncomeVsExpenseChart extends StatelessWidget {
  final List<IncomeExpenseComparison> comparisons;
  final String periodLabel;
  final bool _isLoading;

  const IncomeVsExpenseChart({
    super.key,
    required this.comparisons,
    required this.periodLabel,
  }) : _isLoading = false;

  /// Loading state constructor
  const IncomeVsExpenseChart.loading({super.key})
    : comparisons = const [],
      periodLabel = '',
      _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const Gap(20),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isLoading)
          const Skeleton(width: 180, height: 20).shimmer(isLoading: true)
        else
          Text(
            context.l10n.incomeVsExpense,
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (_isLoading)
          const Skeleton(width: 80, height: 14).shimmer(isLoading: true)
        else
          Text(
            periodLabel,
            style: context.textTheme.labelMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 12,
            ),
          ),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return const SizedBox(
        height: 200,
        child: Center(child: Skeleton(width: double.infinity, height: 180)),
      ).shimmer(isLoading: true);
    }

    if (comparisons.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            context.l10n.noDataAvailable,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      height: 200,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxValue() * 1.2, // Add 20% padding
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) =>
                  context.colorScheme.surfaceContainerHighest,
              tooltipPadding: const EdgeInsets.all(8),
              tooltipMargin: 8,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final comparison = comparisons[groupIndex];
                final isIncome = rodIndex == 0;
                return BarTooltipItem(
                  '${isIncome ? context.l10n.income : context.l10n.expense}\n',
                  context.textTheme.labelSmall!.copyWith(
                    color: context.colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(
                      text: (isIncome ? comparison.income : comparison.expense)
                          .toCurrencyInt(locale: context.locale.languageCode),
                      style: context.textTheme.labelSmall?.copyWith(
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < comparisons.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        comparisons[value.toInt()].label,
                        style: context.textTheme.labelSmall?.copyWith(
                          fontSize: 10,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: _getMaxValue() / 4,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: context.colorScheme.outlineVariant.withValues(
                  alpha: 0.2,
                ),
                strokeWidth: 1,
              );
            },
          ),
          borderData: FlBorderData(show: false),
          barGroups: _createBarGroups(context),
        ),
      ),
    );
  }

  List<BarChartGroupData> _createBarGroups(BuildContext context) {
    return List.generate(comparisons.length, (index) {
      final comparison = comparisons[index];
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: comparison.income,
            color: context.secondaryColor,
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
          BarChartRodData(
            toY: comparison.expense,
            color: context.errorColor.withValues(alpha: 0.8),
            width: 12,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    });
  }

  double _getMaxValue() {
    if (comparisons.isEmpty) return 100;

    double max = 0;
    for (final comparison in comparisons) {
      if (comparison.income > max) max = comparison.income;
      if (comparison.expense > max) max = comparison.expense;
    }

    return max > 0 ? max : 100;
  }
}
