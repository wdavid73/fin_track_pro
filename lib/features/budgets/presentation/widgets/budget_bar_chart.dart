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

  /// Emoji character displayed at the top of the bar, e.g. '🍽️'.
  final String label;
  final double currentAmount;
  final double totalBudget;
  final Color baseColor;

  double get percentage =>
      totalBudget > 0 ? (currentAmount / totalBudget) * 100 : 0;

  double get clampedFraction => (percentage / 100).clamp(0.0, 1.0);

  bool get isUnderLow => percentage < 60;
  bool get isNormal => percentage >= 60 && percentage <= 100;
  bool get isOverBudget => percentage > 100;
}

// ---------------------------------------------------------------------------
// Internal helpers
// ---------------------------------------------------------------------------

enum _BarBorderState { underLow, normal, overBudget }

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

_BarBorderState _stateFromData(BudgetBarData data) {
  if (data.isOverBudget) return _BarBorderState.overBudget;
  if (data.isNormal) return _BarBorderState.normal;
  return _BarBorderState.underLow;
}

// ---------------------------------------------------------------------------
// Public widget
// ---------------------------------------------------------------------------

class BudgetBarChart extends StatefulWidget {
  const BudgetBarChart({
    super.key,
    required this.data,
    this.width = 72,
    this.height = 180,
    this.isLoading = false,
    this.onAddToBudget,
    this.onViewTotalValue,
    this.onQuickTransaction,
  });

  final BudgetBarData data;
  final double width;
  final double height;
  final bool isLoading;
  final VoidCallback? onAddToBudget;
  final VoidCallback? onViewTotalValue;
  final VoidCallback? onQuickTransaction;

  @override
  State<BudgetBarChart> createState() => _BudgetBarChartState();
}

class _BudgetBarChartState extends State<BudgetBarChart>
    with TickerProviderStateMixin {
  // ---- Animation controllers ----
  late AnimationController _fillController;
  late AnimationController _borderController;
  late AnimationController _tooltipController;

  late Animation<double> _fillAnimation;

  // ---- Border crossfade state ----
  late _BarBorderState _currentBorderState;
  late _BarBorderState _previousBorderState;

  // ---- Overlay ----
  OverlayEntry? _overlayEntry;
  final GlobalKey _barKey = GlobalKey();
  final ValueNotifier<int> _hoverNotifier = ValueNotifier<int>(0);

  // Saved after _showOverlay; used in onLongPressMoveUpdate
  double _tooltipTopY = 0;
  double _tooltipItemHeight = 56;
  double _tooltipPaddingTop = 8;

  // ---- Tooltip options (built once in initState) ----
  late final List<_TooltipOption> _tooltipOptions;

  // ---- Convenience ----
  BudgetBarData get data => widget.data;

  @override
  void initState() {
    super.initState();

    _currentBorderState = _stateFromData(data);
    _previousBorderState = _currentBorderState;

    // Fill animation: 0 → clampedFraction
    _fillController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _fillAnimation = Tween<double>(
      begin: 0,
      end: data.clampedFraction,
    ).animate(CurvedAnimation(
      parent: _fillController,
      curve: Curves.easeOutCubic,
    ));

    // Border crossfade animation
    _borderController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
      value: 1.0, // starts fully at current state
    );

    // Tooltip item highlight animation
    _tooltipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    );

    _tooltipOptions = [
      // TODO(l10n): add keys 'addToBudget', 'viewTotalValue', 'quickTransaction'
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
      // Re-run fill animation with new target
      _fillAnimation = Tween<double>(
        begin: 0,
        end: data.clampedFraction,
      ).animate(CurvedAnimation(
        parent: _fillController,
        curve: Curves.easeOutCubic,
      ));
      _fillController.forward(from: 0);

      // Crossfade border if state changed
      final newState = _stateFromData(data);
      if (newState != _currentBorderState) {
        _previousBorderState = _currentBorderState;
        _currentBorderState = newState;
        _borderController.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _fillController.dispose();
    _borderController.dispose();
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

    // Horizontal: prefer left, then right, then centered
    double left = barOffset.dx - tooltipWidth - 8;
    if (left < 8) left = barOffset.dx + barSize.width + 8;
    if (left + tooltipWidth > screen.width - 8) {
      left = (screen.width - tooltipWidth) / 2;
    }

    // Vertical: center on touch, clamped to screen edges
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
          // Dismiss layer
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

  // ---- Gesture handlers ----

  void _onLongPressStart(LongPressStartDetails details) {
    _showOverlay(context, details.globalPosition);
  }

  void _onLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
    if (_overlayEntry == null) return;
    final relY =
        details.globalPosition.dy - _tooltipTopY - _tooltipPaddingTop;
    final index =
        (relY / _tooltipItemHeight).floor().clamp(0, _tooltipOptions.length - 1);
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

  // ---- Color helper ----

  Color _percentageColor(BuildContext context) {
    if (data.isOverBudget) return context.colorScheme.error;
    if (data.isNormal) return data.baseColor;
    return context.colorScheme.onSurfaceVariant;
  }

  // ---- Build ----

  @override
  Widget build(BuildContext context) {
    if (widget.isLoading) {
      return ShimmerBox(
        width: widget.width,
        height: widget.height,
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
        width: widget.width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // [0] Background
            Container(
              decoration: BoxDecoration(
                color: context.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(16),
              ),
            ),

            // [1] Animated fill from bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: AnimatedBuilder(
                animation: _fillAnimation,
                builder: (context, _) {
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      heightFactor: _fillAnimation.value,
                      child: Container(
                        width: double.infinity,
                        height: widget.height,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              data.baseColor.withValues(alpha: 0.35),
                              data.baseColor.withValues(alpha: 0.70),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // [2] Over-budget error tint
            if (data.isOverBudget)
              Container(
                decoration: BoxDecoration(
                  color: context.colorScheme.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
              ),

            // [3] Text content
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(data.label, style: const TextStyle(fontSize: 20)),
                  Text(
                    data.currentAmount.toCompactCurrency(),
                    style: context.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: context.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    '${data.percentage.toStringAsFixed(0)}%',
                    style: context.textTheme.labelLarge?.copyWith(
                      color: _percentageColor(context),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // [4] Border painter with crossfade
            AnimatedBuilder(
              animation: _borderController,
              builder: (context, _) => CustomPaint(
                painter: _BarBorderPainter(
                  currentState: _currentBorderState,
                  previousState: _previousBorderState,
                  crossfadeProgress: _borderController.value,
                  baseColor: data.baseColor,
                  errorColor: context.colorScheme.error,
                  neutralColor: context.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZeroState(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHighest
                  .withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          CustomPaint(
            painter: _BarBorderPainter(
              currentState: _BarBorderState.underLow,
              previousState: _BarBorderState.underLow,
              crossfadeProgress: 1.0,
              baseColor: data.baseColor,
              errorColor: context.colorScheme.error,
              neutralColor: context.colorScheme.onSurfaceVariant,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(data.label, style: const TextStyle(fontSize: 20)),
                const SizedBox.shrink(),
                Text(
                  '—',
                  style: context.textTheme.labelLarge?.copyWith(
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
// CustomPainter — dashed/solid border with crossfade
// ---------------------------------------------------------------------------

class _BarBorderPainter extends CustomPainter {
  const _BarBorderPainter({
    required this.currentState,
    required this.previousState,
    required this.crossfadeProgress,
    required this.baseColor,
    required this.errorColor,
    required this.neutralColor,
  });

  final _BarBorderState currentState;
  final _BarBorderState previousState;
  final double crossfadeProgress;
  final Color baseColor;
  final Color errorColor;
  final Color neutralColor;

  @override
  void paint(Canvas canvas, Size size) {
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(1, 1, size.width - 2, size.height - 2),
      const Radius.circular(16),
    );

    if (crossfadeProgress < 1.0 && currentState != previousState) {
      _drawState(canvas, rrect, previousState, 1.0 - crossfadeProgress);
    }
    _drawState(
      canvas,
      rrect,
      currentState,
      currentState == previousState ? 1.0 : crossfadeProgress,
    );
  }

  void _drawState(
    Canvas canvas,
    RRect rrect,
    _BarBorderState state,
    double opacity,
  ) {
    final paint = Paint()..style = PaintingStyle.stroke;

    switch (state) {
      case _BarBorderState.underLow:
        paint
          ..strokeWidth = 1.5
          ..color = neutralColor.withValues(alpha: opacity);
        _drawDashedRRect(canvas, paint, rrect, dashLength: 6, gapLength: 4);

      case _BarBorderState.normal:
        paint
          ..strokeWidth = 2.0
          ..color = baseColor.withValues(alpha: opacity);
        canvas.drawRRect(rrect, paint);

      case _BarBorderState.overBudget:
        paint
          ..strokeWidth = 3.0
          ..color = errorColor.withValues(alpha: opacity);
        _drawDashedRRect(canvas, paint, rrect, dashLength: 8, gapLength: 3);
    }
  }

  void _drawDashedRRect(
    Canvas canvas,
    Paint paint,
    RRect rrect, {
    required double dashLength,
    required double gapLength,
  }) {
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
  bool shouldRepaint(_BarBorderPainter old) =>
      old.crossfadeProgress != crossfadeProgress ||
      old.currentState != currentState ||
      old.previousState != previousState ||
      old.baseColor != baseColor;
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
                fontWeight:
                    isHovered ? FontWeight.w600 : FontWeight.normal,
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
