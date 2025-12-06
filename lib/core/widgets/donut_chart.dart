import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/core/extensions/currency_extensions.dart'
    show CurrencyFormatter;
import 'package:fin_track_pro/core/extensions/locale_extensions.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// A donut chart widget for displaying budget data using fl_chart
class DonutChart extends StatelessWidget {
  final double totalSpent;
  final double totalBudget;
  final List<DonutSegment> segments;
  final double size;

  const DonutChart({
    super.key,
    required this.totalSpent,
    required this.totalBudget,
    required this.segments,
    this.size = 160,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(size / 2),
            child: PieChart(
              PieChartData(
                sectionsSpace: 3,
                centerSpaceRadius: size * 0.35,
                startDegreeOffset: -90,
                borderData: FlBorderData(show: false),
                sections: segments.map((segment) {
                  return PieChartSectionData(
                    color: segment.color,
                    value: segment.value,
                    title: '',
                    radius: 24,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Spent',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  totalSpent.toCurrencyInt(locale: context.locale.languageCode),
                  style: context.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Represents a segment in the donut chart
class DonutSegment {
  final double value;
  final Color color;

  const DonutSegment({required this.value, required this.color});
}
