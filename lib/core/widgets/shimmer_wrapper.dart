import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// A wrapper that applies shimmer effect to any widget
///
/// Usage:
/// ```dart
/// ShimmerWrapper(
///   isLoading: true,
///   child: MyWidget(),
/// )
/// ```
class ShimmerWrapper extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final Color? baseColor;
  final Color? highlightColor;

  const ShimmerWrapper({
    super.key,
    required this.isLoading,
    required this.child,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) {
      return child;
    }

    final isDark = context.brightness == Brightness.dark;
    final defaultBaseColor = context.colorScheme.surfaceContainerHighest;
    final defaultHighlightColor = isDark
        ? const Color(0xFF484848)
        : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor ?? defaultBaseColor,
      highlightColor: highlightColor ?? defaultHighlightColor,
      child: child,
    );
  }
}

/// Extension to easily add shimmer to any widget
extension ShimmerExtension on Widget {
  Widget shimmer({
    required bool isLoading,
    Color? baseColor,
    Color? highlightColor,
  }) {
    return ShimmerWrapper(
      isLoading: isLoading,
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: this,
    );
  }
}
