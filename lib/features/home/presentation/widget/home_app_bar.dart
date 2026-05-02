import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({
    super.key,
    required this.balance,
    required this.isVisible,
    required this.onToggle,
    required this.onOpenDrawer,
  });

  final double balance;
  final bool isVisible;
  final VoidCallback onToggle;
  final VoidCallback onOpenDrawer;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, _) {
        final settings = context
            .dependOnInheritedWidgetOfExactType<FlexibleSpaceBarSettings>();

        double t = 0.0;
        if (settings != null) {
          final delta = settings.maxExtent - settings.minExtent;
          if (delta > 0) {
            t = (1.0 - (settings.currentExtent - settings.minExtent) / delta)
                .clamp(0.0, 1.0);
          }
        }

        final safeTop = MediaQuery.of(context).padding.top;
        final expandedOpacity = (1.0 - t / 0.45).clamp(0.0, 1.0);
        final collapsedOpacity = ((t - 0.65) / 0.35).clamp(0.0, 1.0);

        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.hardEdge,
          children: [
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: ThemeConstants.heroCardGradient,
              ),
            ),

            if (expandedOpacity > 0.0)
              Transform.translate(
                offset: Offset(0, -28 * t),
                child: Opacity(
                  opacity: expandedOpacity,
                  child: Padding(
                    padding: EdgeInsets.only(top: safeTop),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: onOpenDrawer,
                                child: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      'F',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Gap(10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    context.l10n.welcome,
                                    style: context.textTheme.labelLarge!
                                        .copyWith(color: Colors.white70),
                                  ),
                                  Text(
                                    'Wilson',
                                    style: context.textTheme.titleMedium!
                                        .copyWith(color: Colors.white),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Colors.white12,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.notifications_outlined,
                                  color: Colors.white70,
                                  size: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Gap(16),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                                    FadeTransition(
                                      opacity: animation,
                                      child: child,
                                    ),
                                child: Align(
                                  key: ValueKey(isVisible),
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    isVisible
                                        ? balance.toCurrency()
                                        : '\$••••••',
                                    style: context.textTheme.headlineLarge!
                                        .copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: -1,
                                        ),
                                  ),
                                ),
                              ),
                              const Gap(16),
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
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            if (collapsedOpacity > 0.0)
              Transform.translate(
                offset: Offset(0, 10 * (1 - collapsedOpacity)),
                child: Opacity(
                  opacity: collapsedOpacity,
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      height: kToolbarHeight,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          children: [
                            const Gap(12),
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              transitionBuilder: (child, animation) =>
                                  FadeTransition(
                                    opacity: animation,
                                    child: child,
                                  ),
                              child: Text(
                                key: ValueKey(isVisible),
                                isVisible ? balance.toCurrency() : '\$••••••',
                                style: context.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              icon: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  isVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  key: ValueKey(isVisible),
                                  size: 20,
                                  color: Colors.white70,
                                ),
                              ),
                              onPressed: onToggle,
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white12,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.notifications_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                            ),
                            const Gap(4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
