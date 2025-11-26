import 'package:fin_track_pro/core/widgets/skeleton.dart';
import 'package:fin_track_pro/core/widgets/shimmer_wrapper.dart';
import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class BalanceSummary extends StatelessWidget {
  final double balance;
  final bool _isLoading;

  const BalanceSummary({required this.balance, super.key}) : _isLoading = false;

  /// Loading state constructor
  const BalanceSummary.loading({super.key}) : balance = 0, _isLoading = true;

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (_isLoading)
                const Skeleton(width: 120, height: 16).shimmer(isLoading: true)
              else
                const Text(
                  'Total Balance',
                  style: TextStyle(color: ColorTheme.textPrimary, fontSize: 16),
                ),
              const Gap(8),
              if (_isLoading)
                const Skeleton(width: 200, height: 38).shimmer(isLoading: true)
              else
                Text(
                  formatter.format(balance),
                  style: TextStyle(
                    color: balanceColor,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
