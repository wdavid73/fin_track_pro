import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/features/budgets/presentation/widgets/budget_bar_chart.dart';
import 'package:fin_track_pro/features/home/presentation/widget/home_empty_state.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

enum _BudgetBarsMode { data, empty }

class BudgetBarsRow extends StatefulWidget {
  const BudgetBarsRow({super.key, required this.budgetData})
    : _mode = _BudgetBarsMode.data;

  const BudgetBarsRow.empty({super.key})
    : budgetData = null,
      _mode = _BudgetBarsMode.empty;

  final BudgetData? budgetData;
  final _BudgetBarsMode _mode;

  @override
  State<BudgetBarsRow> createState() => _BudgetBarsRowState();
}

class _BudgetBarsRowState extends State<BudgetBarsRow> {
  static const double _barWidth = 72;
  static const double _barHeight = 140;
  static const double _barPadding = 12;
  static const double _itemWidth = _barWidth + _barPadding;
  static const double _stackHeight = _barHeight + _barHeight * 0.5;

  late List<CategoryBudget> _selectedBudgets;

  @override
  void initState() {
    super.initState();
    _selectedBudgets =
        widget._mode == _BudgetBarsMode.data && widget.budgetData != null
        ? _selectAndSort(widget.budgetData!)
        : [];
  }

  @override
  void didUpdateWidget(BudgetBarsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.budgetData != widget.budgetData) {
      setState(() {
        _selectedBudgets =
            widget._mode == _BudgetBarsMode.data && widget.budgetData != null
            ? _selectAndSort(widget.budgetData!)
            : [];
      });
    }
  }

  List<CategoryBudget> _selectAndSort(BudgetData data) {
    final validCategories = data.categories.where((c) => c.budget > 0).toList();

    final overBudget = validCategories
        .where((c) => c.spent > c.budget)
        .toList();
    final normal = validCategories
        .where((c) => c.spent >= c.budget * 0.6 && c.spent <= c.budget)
        .toList();
    final underLow = validCategories
        .where((c) => c.spent < c.budget * 0.6)
        .toList();

    final selected = <CategoryBudget>[];
    if (overBudget.isNotEmpty) selected.add(overBudget.removeAt(0));
    if (normal.isNotEmpty) selected.add(normal.removeAt(0));
    if (underLow.isNotEmpty) selected.add(underLow.removeAt(0));

    final remainingPool = [...underLow, ...normal];
    for (final budget in remainingPool) {
      if (selected.length >= 5) break;
      if (!selected.contains(budget)) selected.add(budget);
    }

    for (final budget in validCategories) {
      if (selected.length >= 5) break;
      if (!selected.contains(budget)) selected.add(budget);
    }

    selected.sort((a, b) {
      final pA = a.budget > 0 ? a.spent / a.budget : 0.0;
      final pB = b.budget > 0 ? b.spent / b.budget : 0.0;
      return pB.compareTo(pA);
    });

    return selected;
  }

  @override
  Widget build(BuildContext context) {
    if (widget._mode == _BudgetBarsMode.empty || _selectedBudgets.isEmpty) {
      return HomeEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        label: context.l10n.noBudgetsConfigured,
      );
    }

    final totalWidth = _selectedBudgets.length * _itemWidth;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: totalWidth,
        height: _stackHeight,
        child: Stack(
          clipBehavior: Clip.none,
          children: _selectedBudgets.asMap().entries.map((entry) {
            final index = entry.key;
            final cb = entry.value;

            return AnimatedPositioned(
              key: ValueKey(cb.category.name),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOutCubic,
              left: index * _itemWidth,
              bottom: 0,
              width: _barWidth,
              height: _stackHeight,
              child: BudgetBarChart(
                data: BudgetBarData(
                  label: CategoryHelper.categoryEmoji(cb.category.icon),
                  currentAmount: cb.spent,
                  totalBudget: cb.budget,
                  baseColor: Color(cb.category.color),
                ),
                barWidth: _barWidth,
                barHeight: _barHeight,
                onViewTotalValue: () =>
                    context.go(RouteConstants.budgetDetail, extra: cb),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
