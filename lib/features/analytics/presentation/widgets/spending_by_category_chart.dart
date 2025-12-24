import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Widget displaying spending breakdown by category with donut chart and legend
class SpendingByCategoryChart extends StatelessWidget {
  final List<CategorySpending> categorySpending;
  final bool _isLoading;

  const SpendingByCategoryChart({super.key, required this.categorySpending})
    : _isLoading = false;

  /// Loading state constructor
  const SpendingByCategoryChart.loading({super.key})
    : categorySpending = const [],
      _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              const Skeleton(width: 180, height: 20).shimmer(isLoading: true)
            else
              Text(
                context.l10n.spendingByCategory,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Gap(20),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        width: double.infinity,
        child: Wrap(
          runSpacing: 20,
          alignment: WrapAlignment.center,
          direction: Axis.horizontal,
          children: [
            const Skeleton.circle(size: 160).shimmer(isLoading: true),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSkeletonLegendItem(),
                const Gap(12),
                _buildSkeletonLegendItem(),
                const Gap(12),
                _buildSkeletonLegendItem(),
                const Gap(12),
                _buildSkeletonLegendItem(),
              ],
            ),
          ],
        ),
      );
    }

    if (categorySpending.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            context.l10n.noSpendingDataAvailable,
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    // Calculate total spending for percentages
    final totalSpending = categorySpending.fold<double>(
      0,
      (sum, item) => sum + item.amount,
    );

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runSpacing: 20,
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        children: [
          DonutChart(
            totalSpent: totalSpending,
            totalBudget: totalSpending,
            segments: categorySpending.map((cat) {
              return DonutSegment(
                value: cat.amount,
                color: IconHelper.getColor(cat.category.color),
              );
            }).toList(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: categorySpending.map((cat) {
              final percentage = cat.getPercentage(totalSpending);
              return _CategoryLegendItem(
                color: IconHelper.getColor(cat.category.color),
                name: cat.category.name,
                percentage: percentage,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSkeletonLegendItem() {
    return const Row(
      children: [
        Skeleton(width: 12, height: 12, borderRadius: 2),
        Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Skeleton(width: 100, height: 14),
            Gap(4),
            Skeleton(width: 60, height: 12),
          ],
        ),
      ],
    ).shimmer(isLoading: true);
  }
}

class _CategoryLegendItem extends StatelessWidget {
  final Color color;
  final String name;
  final double percentage;

  const _CategoryLegendItem({
    required this.color,
    required this.name,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: context.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
