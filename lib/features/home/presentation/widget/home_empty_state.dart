import 'package:fin_track_pro/core/core.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeEmptyState extends StatelessWidget {
  const HomeEmptyState({super.key, required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 40, color: context.colorScheme.outlineVariant),
            const Gap(8),
            Text(label, style: context.textTheme.bodyMedium!),
          ],
        ),
      ),
    );
  }
}
