import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class VisibilityToggleButton extends StatelessWidget {
  const VisibilityToggleButton({
    super.key,
    required this.isVisible,
    required this.onToggle,
    required this.visibleLabel,
    required this.hiddenLabel,
    this.color = Colors.white70,
    this.backgroundColor,
  });

  final bool isVisible;
  final VoidCallback onToggle;
  final String visibleLabel;
  final String hiddenLabel;
  final Color color;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: backgroundColor ?? Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => ScaleTransition(
                scale: animation,
                child: child,
              ),
              child: Icon(
                isVisible
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                key: ValueKey(isVisible),
                color: color,
                size: 14,
              ),
            ),
            const Gap(4),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: child,
              ),
              child: Text(
                isVisible ? visibleLabel : hiddenLabel,
                key: ValueKey(isVisible),
                style: TextStyle(color: color, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
