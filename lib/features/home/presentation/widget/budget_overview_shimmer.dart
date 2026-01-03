import 'package:fin_track_pro/core/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

/// Shimmer loading state for BudgetOverview widget
class BudgetOverviewShimmer extends StatelessWidget {
  const BudgetOverviewShimmer({super.key});

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
                  ShimmerBox(width: 140, height: 20),
                  ShimmerBox(width: 90, height: 16),
                ],
              ),
              const Gap(20),

              // Chart and Categories
              SizedBox(
                width: double.infinity,
                child: Wrap(
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: [
                    // Donut Chart Shimmer
                    const ShimmerCircle(size: 160),

                    // Categories List Shimmer
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildCategoryItemShimmer(),
                        const Gap(12),
                        _buildCategoryItemShimmer(),
                        const Gap(12),
                        _buildCategoryItemShimmer(),
                      ],
                    ),
                  ],
                ),
              ),
              const Gap(20),
              const Divider(),
              const Gap(12),

              // Budget Remaining Shimmer
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 130, height: 16),
                  ShimmerBox(width: 100, height: 28),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryItemShimmer() {
    return const Row(
      children: [
        ShimmerBox(width: 12, height: 12, borderRadius: 2),
        Gap(8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ShimmerBox(width: 100, height: 14),
            Gap(4),
            ShimmerBox(width: 140, height: 12),
          ],
        ),
      ],
    );
  }
}
