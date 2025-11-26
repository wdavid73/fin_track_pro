import 'package:fin_track_pro/core/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shimmer loading state for BalanceSummary widget
class BalanceSummaryShimmer extends StatelessWidget {
  const BalanceSummaryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const ShimmerBox(width: 120, height: 16),
              const Gap(12),
              const ShimmerBox(width: 200, height: 40),
              const Gap(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [_buildStatShimmer(), _buildStatShimmer()],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatShimmer() {
    return const Column(
      children: [
        ShimmerBox(width: 80, height: 14),
        Gap(8),
        ShimmerBox(width: 100, height: 24),
      ],
    );
  }
}
