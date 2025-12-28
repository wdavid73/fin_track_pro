import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/theme/utils/resposive.dart';
import 'package:flutter/material.dart';

/// Widget displaying summary cards for Total Income, Total Expenses, and Net Savings
class AnalyticsSummaryCards extends StatelessWidget {
  final double totalIncome;
  final double totalExpenses;
  final double netSavings;
  final bool _isLoading;

  const AnalyticsSummaryCards({
    super.key,
    required this.totalIncome,
    required this.totalExpenses,
    required this.netSavings,
  }) : _isLoading = false;

  /// Loading state constructor
  const AnalyticsSummaryCards.loading({super.key})
    : totalIncome = 0,
      totalExpenses = 0,
      netSavings = 0,
      _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.start,
      spacing: 12,
      runSpacing: 12,
      children: [
        SizedBox(
          width: context.wp(44),
          child: _SummaryCard(
            title: context.l10n.totalIncome,
            amount: totalIncome,
            icon: Icons.arrow_upward_rounded,
            iconColor: context.secondaryColor,
            iconBackgroundColor: context.secondaryColor.withValues(alpha: 0.1),
            isLoading: _isLoading,
          ),
        ),
        SizedBox(
          width: context.wp(44),
          child: _SummaryCard(
            title: context.l10n.totalExpenses,
            amount: totalExpenses,
            icon: Icons.arrow_downward_rounded,
            iconColor: context.errorColor,
            iconBackgroundColor: context.errorColor.withValues(alpha: 0.1),
            isLoading: _isLoading,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: _SummaryCard(
            title: context.l10n.netSavings,
            amount: netSavings,
            icon: Icons.account_balance_wallet_outlined,
            iconColor: context.primaryColor,
            iconBackgroundColor: context.primaryColor.withValues(alpha: 0.1),
            isLoading: _isLoading,
          ),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final double amount;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final bool isLoading;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate card width to fit 3 cards with spacing
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = (screenWidth - 32 - 24) / 3; // padding + spacing

    return Container(
      width: cardWidth,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        alignment: WrapAlignment.start,
        crossAxisAlignment: WrapCrossAlignment.center,
        runAlignment: WrapAlignment.start,
        spacing: 12,
        runSpacing: 12,
        children: [
          if (isLoading)
            const Skeleton.circle(size: 40).shimmer(isLoading: true)
          else
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
          if (isLoading)
            const Skeleton(width: 60, height: 12).shimmer(isLoading: true)
          else
            SizedBox(
              width: 60,
              child: Text(
                title,
                style: context.textTheme.labelMedium?.copyWith(
                  color: context.colorScheme.onSurfaceVariant,
                  fontSize: 12,
                ),
              ),
            ),
          if (isLoading)
            const Skeleton(width: 80, height: 20).shimmer(isLoading: true)
          else
            Text(
              amount.toCompactCurrency(locale: context.locale.languageCode),
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        ],
      ),
    );
  }
}
