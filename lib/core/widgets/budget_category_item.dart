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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF1C1C1E),
                ),
              ),
              Text(
                '${formatter.format(spent)} / ${formatter.format(budget)}',
                style: TextStyle(fontSize: 15, color: Colors.grey[600]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
