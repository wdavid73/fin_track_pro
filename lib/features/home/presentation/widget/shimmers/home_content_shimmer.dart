import 'package:fin_track_pro/core/widgets/shimmer_box.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeContentShimmer extends StatelessWidget {
  const HomeContentShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(height: 150, borderRadius: 24.0),
        const Gap(24.0),
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 72, borderRadius: 24.0)),
            Gap(16.0),
            Expanded(child: ShimmerBox(height: 72, borderRadius: 24.0)),
          ],
        ),
        const Gap(4.00),
        const ShimmerBox(height: 20, width: 100, borderRadius: 8),
        const Gap(24.0),
        ...List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                ShimmerCircle(size: 44),
                Gap(20.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ShimmerBox(height: 14, width: 120, borderRadius: 4),
                      Gap(4),
                      ShimmerBox(height: 12, width: 80, borderRadius: 4),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(100),
      ],
    );
  }
}
