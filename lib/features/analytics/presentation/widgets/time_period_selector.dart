import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:flutter/material.dart';

/// Widget for selecting the analytics time period (Week/Month/Year)
class TimePeriodSelector extends StatelessWidget {
  final AnalyticsPeriod selectedPeriod;
  final ValueChanged<AnalyticsPeriod> onPeriodChanged;

  const TimePeriodSelector({
    super.key,
    required this.selectedPeriod,
    required this.onPeriodChanged,
  });

  Alignment _alignmentForPeriod(AnalyticsPeriod period) {
    switch (period) {
      case AnalyticsPeriod.week:
        return Alignment.centerLeft;
      case AnalyticsPeriod.month:
        return Alignment.center;
      case AnalyticsPeriod.year:
        return Alignment.centerRight;
    }
  }

  @override
  Widget build(BuildContext context) {
    final periods = AnalyticsPeriod.values;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.3,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final itemWidth = constraints.maxWidth / periods.length;

          return Stack(
            children: [
              /// Indicador animado (slide)
              AnimatedAlign(
                alignment: _alignmentForPeriod(selectedPeriod),
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: Container(
                  width: itemWidth,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: context.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),

              /// Botones
              Row(
                children: periods.map((period) {
                  final isSelected = period == selectedPeriod;

                  return Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTap: () => onPeriodChanged(period),
                      child: Center(
                        child: AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          style: context.textTheme.labelLarge!.copyWith(
                            color: isSelected
                                ? context.colorScheme.onPrimaryContainer
                                : context.colorScheme.onSurfaceVariant,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                          child: Text(period.label),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        },
      ),
    );
  }
}
