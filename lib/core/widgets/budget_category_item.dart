import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Widget to display a budget category item with color indicator
class BudgetCategoryItem extends StatelessWidget {
  final Color color;
  final String name;
  final double spent;
  final double budget;

  const BudgetCategoryItem({
    super.key,
    required this.color,
    required this.name,
    required this.spent,
    required this.budget,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Color indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: context.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: context.colorScheme.onSurface,
                ),
              ),
              Text(
                '${formatter.format(spent)} / ${formatter.format(budget)}',
                style: context.textTheme.bodyMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
