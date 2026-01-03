import 'package:fin_track_pro/core/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shimmer loading state for Transactions widget
class TransactionsShimmer extends StatelessWidget {
  const TransactionsShimmer({super.key});

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
              // Header
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 150, height: 20),
                  ShimmerBox(width: 70, height: 16),
                ],
              ),
              const Gap(16),

              // Transaction items
              _buildTransactionItemShimmer(),
              const Gap(12),
              _buildTransactionItemShimmer(),
              const Gap(12),
              _buildTransactionItemShimmer(),
              const Gap(12),
              _buildTransactionItemShimmer(),
              const Gap(12),
              _buildTransactionItemShimmer(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionItemShimmer() {
    return const Row(
      children: [
        ShimmerCircle(size: 48),
        Gap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox(width: 120, height: 16),
              Gap(4),
              ShimmerBox(width: 80, height: 12),
            ],
          ),
        ),
        Gap(12),
        ShimmerBox(width: 70, height: 18),
      ],
    );
  }
}
