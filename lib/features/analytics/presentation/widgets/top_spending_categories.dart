import 'package:fin_track_pro/core/extensions/extensions.dart';
import 'package:fin_track_pro/core/utils/icon_helper.dart';
import 'package:fin_track_pro/core/widgets/shimmer_wrapper.dart';
import 'package:fin_track_pro/core/widgets/skeleton.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Widget displaying top spending categories as a list
class TopSpendingCategories extends StatelessWidget {
  final List<CategorySpending> categories;
  final bool _isLoading;

  const TopSpendingCategories({super.key, required this.categories})
    : _isLoading = false;

  /// Loading state constructor
  const TopSpendingCategories.loading({super.key})
    : categories = const [],
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
              const Skeleton(width: 200, height: 20).shimmer(isLoading: true)
            else
              Text(
                context.l10n.topSpendingCategories,
                style: context.textTheme.titleLarge?.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Gap(16),
            _buildContent(context),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    if (_isLoading) {
      return Column(
        children: [
          _buildSkeletonItem(),
          const Gap(12),
          _buildSkeletonItem(),
          const Gap(12),
          _buildSkeletonItem(),
        ],
      );
    }

    if (categories.isEmpty) {
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

    return Column(
      children: categories.map((categorySpending) {
        return _CategoryItem(
          icon: IconHelper.getIcon(categorySpending.category.icon),
          iconColor: IconHelper.getColor(categorySpending.category.color),
          name: categorySpending.category.name,
          transactionCount: categorySpending.transactionCount,
          amount: categorySpending.amount,
        );
      }).toList(),
    );
  }

  Widget _buildSkeletonItem() {
    return const Row(
      children: [
        Skeleton.circle(size: 40),
        Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Skeleton(width: 120, height: 16),
              Gap(4),
              Skeleton(width: 100, height: 12),
            ],
          ),
        ),
        Skeleton(width: 80, height: 18),
      ],
    ).shimmer(isLoading: true);
  }
}

class _CategoryItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final int transactionCount;
  final double amount;

  const _CategoryItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.transactionCount,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const Gap(12),
          Expanded(
            child: Column(
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
                  '$transactionCount ${transactionCount != 1 ? context.l10n.transactions : context.l10n.transaction}',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${amount.toCompactCurrency(locale: context.locale.languageCode)}',
            style: context.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
