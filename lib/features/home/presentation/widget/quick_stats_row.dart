import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/home/presentation/widget/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class QuickStatsRow extends StatelessWidget {
  const QuickStatsRow({
    super.key,
    required this.income,
    required this.expenses,
  });

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.arrow_upward_rounded,
            iconBg: context.colorScheme.surface,
            iconColor: context.colorScheme.secondary,
            label: context.l10n.income,
            value: income.toCurrency(),
          ),
        ),
        const Gap(14.0),
        Expanded(
          child: StatCard(
            icon: Icons.arrow_downward_rounded,
            iconBg: context.colorScheme.surface,
            iconColor: context.colorScheme.error,
            label: context.l10n.expense,
            value: expenses.toCurrency(),
          ),
        ),
      ],
    );
  }
}
