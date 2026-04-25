// --- Hero Balance Card ---
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BalanceHeroCard extends StatelessWidget {
  const BalanceHeroCard({
    required this.balance,
    required this.isVisible,
    required this.onToggle,
    super.key,
  });

  final double balance;
  final bool isVisible;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: ThemeConstants.heroCardGradient,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.l10n.totalBalance,
            style: context.textTheme.bodyMedium!.copyWith(
              color: Colors.white70,
            ),
          ),
          const Gap(8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, animation) =>
                FadeTransition(opacity: animation, child: child),
            child: Align(
              key: ValueKey(isVisible),
              alignment: Alignment.centerLeft,
              child: Text(
                isVisible ? balance.toCurrency() : '\$••••••',
                style: context.textTheme.headlineLarge!.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1,
                ),
              ),
            ),
          ),
          const Gap(24.0),
          Row(
            children: [
              const Spacer(),
              VisibilityToggleButton(
                isVisible: isVisible,
                onToggle: onToggle,
                visibleLabel: context.l10n.hide,
                hiddenLabel: context.l10n.show,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
