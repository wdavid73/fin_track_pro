import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/core/utils/icon_helper.dart';
import 'package:fin_track_pro/core/widgets/budget_category_item.dart';
import 'package:fin_track_pro/core/widgets/donut_chart.dart';
import 'package:fin_track_pro/core/widgets/skeleton.dart';
import 'package:fin_track_pro/core/widgets/shimmer_wrapper.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BudgetOverview extends StatelessWidget {
  final BudgetData? budgetData;
  final bool _isLoading;

  const BudgetOverview({required this.budgetData, super.key})
    : _isLoading = false;

  /// Loading state constructor
  const BudgetOverview.loading({super.key})
    : budgetData = null,
      _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context),
              const SizedBox(height: 20),
              _buildContent(context),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isLoading)
          const Skeleton(width: 140, height: 20).shimmer(isLoading: true)
        else
          Text(
            'Budget Overview',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        if (_isLoading)
          const Skeleton(width: 90, height: 16).shimmer(isLoading: true)
        else
          TextButton(
            onPressed: () {},
            child: Text(
              'View Details',
              style: context.textTheme.labelLarge?.copyWith(
                fontSize: 15,
                color: context.primaryColor,
              ),
            ),
          ),
      ],
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
                _buildSkeletonCategoryItem(),
                const Gap(12),
                _buildSkeletonCategoryItem(),
                const Gap(12),
                _buildSkeletonCategoryItem(),
              ],
            ),
          ],
        ),
      );
    }

    if (budgetData == null || budgetData!.categories.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No budget data available',
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        runSpacing: 20,
        alignment: WrapAlignment.center,
        direction: Axis.horizontal,
        children: [
          DonutChart(
            totalSpent: budgetData!.totalSpent,
            totalBudget: budgetData!.totalBudget,
            segments: budgetData!.categories.map((cat) {
              return DonutSegment(
                value: cat.spent,
                color: IconHelper.getColor(cat.category.color),
              );
            }).toList(),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: budgetData!.categories.map((categoryBudget) {
              return BudgetCategoryItem(
                color: IconHelper.getColor(categoryBudget.category.color),
                name: categoryBudget.category.name,
                spent: categoryBudget.spent,
                budget: categoryBudget.budget,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_isLoading)
          const Skeleton(width: 130, height: 16).shimmer(isLoading: true)
        else
          Text(
            'Budget Remaining',
            style: context.textTheme.titleMedium?.copyWith(fontSize: 16),
          ),
        if (_isLoading)
          const Skeleton(width: 100, height: 28).shimmer(isLoading: true)
        else
          Text(
            '\$${budgetData?.remaining.toStringAsFixed(2) ?? '0.00'}',
            style: context.textTheme.headlineMedium?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: (budgetData?.remaining ?? 0) >= 0
                  ? context.secondaryColor
                  : context.errorColor,
            ),
          ),
      ],
    );
  }

  Widget _buildSkeletonCategoryItem() {
    return const ShimmerWrapper(
      isLoading: true,
      child: Row(
        children: [
          Skeleton(width: 12, height: 12, borderRadius: 2),
          Gap(8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 100, height: 14),
              Gap(4),
              Skeleton(width: 140, height: 12),
            ],
          ),
        ],
      ),
    );
  }
}
