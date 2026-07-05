import 'package:fin_track_pro/core/core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeTransactionTile extends StatelessWidget {
  const HomeTransactionTile({
    super.key,
    required this.emoji,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  final String emoji;
  final String title;
  final String category;
  final double amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    final isPositive = amount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const Gap(20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleMedium!),
                Text(category, style: context.textTheme.labelLarge!),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${amount.abs().toCurrency()}',
                style: context.textTheme.titleMedium!.copyWith(
                  color: isPositive
                      ? context.colorScheme.secondary
                      : context.colorScheme.onSurface,
                ),
              ),
              Text(date, style: context.textTheme.labelLarge!),
            ],
          ),
        ],
      ),
    );
  }
}
