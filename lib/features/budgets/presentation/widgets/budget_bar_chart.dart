import 'package:flutter/material.dart';
import 'package:fin_track_pro/core/core.dart';

// ---------------------------------------------------------------------------
// Data model
// ---------------------------------------------------------------------------

class BudgetBarData {
  const BudgetBarData({
    required this.label,
    required this.currentAmount,
    required this.totalBudget,
    required this.baseColor,
  });

  /// Emoji character displayed below the bar, e.g. '🍽️'.
  final String label;
  final double currentAmount;
  final double totalBudget;
  final Color baseColor;

  double get percentage =>
      totalBudget > 0 ? (currentAmount / totalBudget) * 100 : 0;

  double get clampedFraction => (percentage / 100).clamp(0.0, 1.0);

  /// Fraction that can exceed 1.0 for over-budget display (capped at 1.5).
  double get displayFraction =>
      totalBudget > 0 ? (currentAmount / totalBudget).clamp(0.0, 1.5) : 0;

  bool get isUnderLow => percentage < 60;
  bool get isNormal => percentage >= 60 && percentage <= 100;
  bool get isOverBudget => percentage > 100;

  /// Whether to show the dashed border (≥ 60%).
  bool get showDashedBorder => percentage >= 60;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

class _TooltipOption {
  const _TooltipOption({
    required this.label,
    required this.icon,
    required this.onSelected,
  });

  final String label;
  final IconData icon;
  final VoidCallback onSelected;
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class BudgetBarChart extends StatefulWidget {
  const BudgetBarChart({
    super.key,
    required this.data,
    this.barWidth = 72,
    this.barHeight = 140,
    this.isLoading = false,
    this.onAddToBudget,
    this.onViewTotalValue,
    this.onQuickTransaction,
  });

  final BudgetBarData data;
  final double barWidth;

  /// Height of the dashed container = 100% budget.
  final double barHeight;

  final bool isLoading;
  final VoidCallback? onAddToBudget;
  final VoidCallback? onViewTotalValue;
  final VoidCallback? onQuickTransaction;

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart>
    with TickerProviderStateMixin {
  late AnimationController _fillController;
  late AnimationController _tooltipController;
  late Animation<double> _fillAnimation;

  OverlayEntry? _overlayEntry;
  final GlobalKey _barKey = GlobalKey();
  final ValueNotifier<int> _hoverNotifier = ValueNotifier<int>(0);

  double _tooltipTopY = 0;
  double _tooltipItemHeight = 56;
  double _tooltipPaddingTop = 8;

  late final List<_TooltipOption> _tooltipOptions;

  BudgetBarData get data => widget.data;

  // Max overflow above the container: 50% of barHeight
  double get _maxOverflow => widget.barHeight * 0.5;

  @override
  void initState() {
    super.initState();

    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fillAnimation = Tween<double>(begin: 0, end: data.displayFraction).animate(
      CurvedAnimation(parent: _fillController, curve: Curves.easeOutCubic),
    );

    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _tooltipOptions = [
      _TooltipOption(
        label: 'Add to Budget',
        icon: Icons.add_circle_outline,
        onSelected: widget.onAddToBudget ?? () {},
      ),
      _TooltipOption(
        label: 'View Total Value',
        icon: Icons.bar_chart,
        onSelected: widget.onViewTotalValue ?? () {},
      ),
      _TooltipOption(
        label: 'Quick Transaction',
        icon: Icons.flash_on,
        onSelected: widget.onQuickTransaction ?? () {},
      ),
    ];

    _fillController.forward();
  }

  @override
  void didUpdateWidget(BudgetBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.data != widget.data) {
      _fillAnimation = Tween<double>(begin: 0, end: data.displayFraction)
          .animate(
            CurvedAnimation(
              parent: _fillController,
              curve: Curves.easeOutCubic,
            ),
          );
      _fillController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _tooltipController.dispose();
    _hoverNotifier.dispose();
    _removeOverlay();
    super.dispose();
  }

  // ---- Overlay management ----

  void _showOverlay(BuildContext context, Offset globalPosition) {
    final box = _barKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !mounted) return;

    final barOffset = box.localToGlobal(Offset.zero);
    final barSize = box.size;

    const tooltipWidth = 220.0;
    const tooltipItemHeight = 56.0;
    const tooltipPadding = 8.0;
    const tooltipHeight = tooltipItemHeight * 3 + tooltipPadding * 2;

    final screen = MediaQuery.of(context).size;
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    double left = barOffset.dx - tooltipWidth - 8;
    if (left < 8) left = barOffset.dx + barSize.width + 8;
    if (left + tooltipWidth > screen.width - 8) {
      left = (screen.width - tooltipWidth) / 2;
    }

    final double top = (globalPosition.dy - tooltipHeight / 2).clamp(
      safeTop + 8,
      screen.height - tooltipHeight - safeBottom - 8,
    );

    _tooltipTopY = top;
    _tooltipItemHeight = tooltipItemHeight;
    _tooltipPaddingTop = tooltipPadding;
    _hoverNotifier.value = 0;

    _overlayEntry = OverlayEntry(
      builder: (ctx) => Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: _removeOverlay,
              behavior: HitTestBehavior.translucent,
              child: const SizedBox.expand(),
            ),
          ),
          Positioned(
            left: left,
            top: top,
            width: tooltipWidth,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ValueListenableBuilder<int>(
                  valueListenable: _hoverNotifier,
                  builder: (ctx, hoveredIndex, _) => _TooltipCard(
                    options: _tooltipOptions,
                    hoveredIndex: hoveredIndex,
                    baseColor: data.baseColor,
                    itemHeight: tooltipItemHeight,
                    padding: tooltipPadding,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry?.dispose();
    _overlayEntry = null;
  }

  void _onLongPressStart(LongPressStartDetails details) {
    _showOverlay(context, details.globalPosition);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_overlayEntry == null) return;
    final relY = details.globalPosition.dy - _tooltipTopY - _tooltipPaddingTop;
    final index = (relY / _tooltipItemHeight).floor().clamp(
      0,
      _tooltipOptions.length - 1,
    );
    if (index != _hoverNotifier.value) {
      _hoverNotifier.value = index;
      _tooltipController.forward(from: 0);
    }
  }

  void _onLongPressEnd(LongPressEndDetails details) {
    final i = _hoverNotifier.value;
    _removeOverlay();
    if (mounted) _tooltipOptions[i].onSelected();
  }

  // ---- Colors ----

  Color _percentageTextColor(BuildContext context) {
    if (data.isOverBudget) return context.colorScheme.error;
    if (data.isNormal) return data.baseColor;
    return context.colorScheme.onSurfaceVariant;
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ShimmerBox(
        width: widget.barWidth,
        height: widget.barHeight + _maxOverflow,
        borderRadius: 16,
      );
    }

    if (data.totalBudget == 0) {
      return _buildZeroState(context);
    }

    return GestureDetector(
      key: _barKey,
      onLongPressStart: _onLongPressStart,
      onLongPressMoveUpdate: _onLongPressMoveUpdate,
      onLongPressEnd: _onLongPressEnd,
      child: SizedBox(
        width: widget.barWidth,
        height: widget.barHeight + _maxOverflow,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // [0] Background — subtle fill inside the container
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.barHeight,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ColoredBox(
                  color: context.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.12,
                  ),
                ),
              ),
            ),

            // [1] Fill — grows from bottom, overflows above
            //     container when over budget (fraction > 1.0).
            AnimatedBuilder(
              animation: _fillAnimation,
              builder: (context, _) {
                final fraction = _fillAnimation.value;
                final fillHeight = widget.barHeight * fraction;

                return Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: fillHeight,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: ColoredBox(
                      color: data.baseColor.withValues(alpha: 0.28),
                    ),
                  ),
                );
              },
            ),

            // [2] Dashed border (= 100% budget). On top of fill
            //     so it's visible even when fill overflows.
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: widget.barHeight,
              child: AnimatedOpacity(
                opacity: data.showDashedBorder ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: CustomPaint(
                  painter: _DashedBorderPainter(
                    color: data.baseColor.withValues(alpha: 0.40),
                    strokeWidth: 1.5,
                    borderRadius: 16,
                    dashLength: 5,
                    gapLength: 4,
                  ),
                ),
              ),
            ),

            // [3] Labels — pinned to bottom inside the container
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(data.label, style: const TextStyle(fontSize: 18)),
                  const SizedBox(height: 2),
                  Text(
                    data.currentAmount.toCompactCurrency(),
                    style: context.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${data.percentage.toStringAsFixed(0)}%',
                    style: context.textTheme.labelSmall?.copyWith(
                      color: _percentageTextColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZeroState(BuildContext context) {
    return SizedBox(
      width: widget.barWidth,
      height: widget.barHeight + _maxOverflow,
      child: Stack(
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            height: widget.barHeight,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: ColoredBox(
                color: context.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.12,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 8,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.label, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 2),
                Text(
                  '—',
                  style: context.textTheme.labelMedium?.copyWith(
                    color: context.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Dashed rounded-rect border painter
// ---------------------------------------------------------------------------

class _DashedBorderPainter extends CustomPainter {
  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.borderRadius,
    required this.dashLength,
    required this.gapLength,
  });

  final Color color;
  final double strokeWidth;
  final double borderRadius;
  final double dashLength;
  final double gapLength;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final inset = strokeWidth / 2;
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        inset,
        inset,
        size.width - strokeWidth,
        size.height - strokeWidth,
      ),
      Radius.circular(borderRadius),
    );

    final path = Path()..addRRect(rrect);
    for (final metric in path.computeMetrics()) {
      double distance = 0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      old.color != color ||
      old.strokeWidth != strokeWidth ||
      old.borderRadius != borderRadius;
}

// ---------------------------------------------------------------------------
// Tooltip overlay widgets
// ---------------------------------------------------------------------------

class _TooltipCard extends StatelessWidget {
  const _TooltipCard({
    required this.options,
    required this.hoveredIndex,
    required this.baseColor,
    required this.itemHeight,
    required this.padding,
  });

  final List<_TooltipOption> options;
  final int hoveredIndex;
  final Color baseColor;
  final double itemHeight;
  final double padding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(options.length, (i) {
          return _TooltipOptionRow(
            option: options[i],
            isHovered: i == hoveredIndex,
            baseColor: baseColor,
            height: itemHeight,
          );
        }),
      ),
    );
  }
}

class _TooltipOptionRow extends StatelessWidget {
  const _TooltipOptionRow({
    required this.option,
    required this.isHovered,
    required this.baseColor,
    required this.height,
  });

  final _TooltipOption option;
  final bool isHovered;
  final Color baseColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 120),
      height: height,
      decoration: BoxDecoration(
        color: isHovered
            ? baseColor.withValues(alpha: 0.12)
            : Colors.transparent,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: AnimatedScale(
        scale: isHovered ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: Row(
          children: [
            Icon(
              option.icon,
              size: 18,
              color: isHovered
                  ? baseColor
                  : context.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Text(
              option.label,
              style: context.textTheme.bodyMedium?.copyWith(
                fontWeight: isHovered ? FontWeight.w600 : FontWeight.normal,
                color: isHovered
                    ? context.colorScheme.onSurface
                    : context.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
