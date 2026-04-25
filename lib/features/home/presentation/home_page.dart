import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/features/budgets/presentation/widgets/budget_bar_chart.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/home/presentation/widget/stat_card.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/add_transaction_modal.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const LoadHomeData()),
        ),
        BlocProvider.value(value: getIt<TransactionBloc>()),
      ],
      child: const _HomeBody(),
    );
  }
}

class _HomeBody extends StatefulWidget {
  const _HomeBody();

  @override
  State<_HomeBody> createState() => _HomeBodyState();
}

class _HomeBodyState extends State<_HomeBody> {
  bool _isVisible = true;

  void _showAddTransaction(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddTransactionModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          final balance = state is HomeLoaded ? state.totalBalance : 0.0;
          return CustomScrollView(
            slivers: [
              _buildCollapsibleHeader(context, balance),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: _buildContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _HomeFab(onTap: () => _showAddTransaction(context)),
    );
  }

  SliverAppBar _buildCollapsibleHeader(BuildContext context, double balance) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      expandedHeight: 280,
      pinned: true,
      automaticallyImplyLeading: false,
      elevation: 0,
      flexibleSpace: _CollapsibleAppBarContent(
        balance: balance,
        isVisible: _isVisible,
        onToggle: () => setState(() => _isVisible = !_isVisible),
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return _buildShimmer(context);
    }
    if (state is HomeError) {
      return _buildError(context, state.message);
    }
    if (state is HomeLoaded) {
      return _buildLoaded(context, state);
    }
    return const SizedBox.shrink();
  }

  Widget _buildLoaded(BuildContext context, HomeLoaded state) {
    final income = state.recentTransactions
        .where((t) => t.type == 'income')
        .fold(0.0, (s, t) => s + t.amount);
    final expenses = state.recentTransactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Gap(16.0),
        _QuickStatsRow(income: income, expenses: expenses),

        if (state.budgetData != null &&
            state.budgetData!.categories.isNotEmpty) ...[
          const Gap(16.0),
          _SectionHeader(
            title: context.l10n.budgetOverview,
            actionLabel: context.l10n.viewAll,
            onAction: () => context.go(RouteConstants.budget),
          ),
          const Gap(16.0),
          _BudgetBarsRow(budgetData: state.budgetData!),
        ],
        const Gap(16.00),
        _SectionHeader(
          title: context.l10n.recentTransactions,
          actionLabel: context.l10n.viewAll,
          onAction: () => context.go(RouteConstants.transactions),
        ),
        const Gap(20.0),
        ...state.recentTransactions.map((tx) {
          final category = state.categories[tx.categoryId];
          return _TransactionTile(
            emoji: CategoryHelper.categoryEmoji(category?.icon ?? ''),
            title: category?.name ?? (tx.note ?? 'Transacción'),
            category: category?.name ?? 'Sin categoría',
            amount: tx.type == 'income' ? tx.amount : -tx.amount,
            date: CategoryHelper.formatDate(tx.date),
          );
        }),
        const Gap(100),
      ],
    );
  }

  Widget _buildShimmer(BuildContext context) {
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

  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: context.colorScheme.secondary,
              size: 48,
            ),
            const Gap(16),
            Text(
              message,
              style: context.textTheme.bodyMedium!,
              textAlign: TextAlign.center,
            ),
            const Gap(16),
            TextButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(const LoadHomeData()),
              child: Text(
                'Reintentar',
                style: TextStyle(color: context.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Collapsible AppBar Content ---
class _CollapsibleAppBarContent extends StatelessWidget {
  const _CollapsibleAppBarContent({
    required this.balance,
    required this.isVisible,
    required this.onToggle,
  });

  final double balance;
  final bool isVisible;
  final VoidCallback onToggle;

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
            // Gradient background — always visible
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: ThemeConstants.heroCardGradient,
              ),
            ),

            // Expanded content — slides up + fades out as bar collapses
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
                            Container(
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
                            const Gap(10),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  context.l10n.welcome,
                                  style: context.textTheme.labelLarge!.copyWith(
                                    color: Colors.white70,
                                  ),
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
                                  isVisible ? balance.toCurrency() : '\$••••••',
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

            // Collapsed content — slides down into view + fades in
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

// --- Quick Stats Row ---
class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.income, required this.expenses});

  final double income;
  final double expenses;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            icon: Icons.arrow_upward_rounded,
            iconBg: context.colorScheme.surface,
            iconColor: context.colorScheme.secondary,
            label: context.l10n.income,
            value: income.toCurrency(),
          ),
        ),
        const Gap(14.0),
        Expanded(
          child: StatCard(
            icon: Icons.arrow_downward_rounded,
            iconBg: context.colorScheme.surface,
            iconColor: context.colorScheme.error,
            label: context.l10n.expense,
            value: expenses.toCurrency(),
          ),
        ),
      ],
    );
  }
}

// --- Section Header ---
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: context.textTheme.headlineSmall!),
        GestureDetector(
          onTap: onAction,
          child: Text(
            actionLabel,
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

// --- Transaction Tile ---
class _TransactionTile extends StatelessWidget {
  const _TransactionTile({
    required this.emoji,
    required this.title,
    required this.category,
    required this.amount,
    required this.date,
  });

  final String emoji;
  final String title;
  final String category;
  final double amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    final isPositive = amount > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const Gap(20.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: context.textTheme.titleMedium!),
                Text(category, style: context.textTheme.labelLarge!),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isPositive ? '+' : ''}${amount.abs().toCurrency()}',
                style: context.textTheme.titleMedium!.copyWith(
                  color: isPositive
                      ? context.colorScheme.secondary
                      : context.colorScheme.onSurface,
                ),
              ),
              Text(date, style: context.textTheme.labelLarge!),
            ],
          ),
        ],
      ),
    );
  }
}

// --- Budget Bars Row ---
class _BudgetBarsRow extends StatefulWidget {
  const _BudgetBarsRow({required this.budgetData});

  final BudgetData budgetData;

  @override
  State<_BudgetBarsRow> createState() => _BudgetBarsRowState();
}

class _BudgetBarsRowState extends State<_BudgetBarsRow> {
  static const double _barWidth = 72;
  static const double _barHeight = 140;
  static const double _barPadding = 12;
  static const double _itemWidth = _barWidth + _barPadding;
  static const double _stackHeight =
      _barHeight + _barHeight * 0.5; // barHeight + maxOverflow

  late List<CategoryBudget> _selectedBudgets;

  @override
  void initState() {
    super.initState();
    _selectedBudgets = _selectAndSort(widget.budgetData);
  }

  @override
  void didUpdateWidget(_BudgetBarsRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.budgetData != widget.budgetData) {
      setState(() {
        _selectedBudgets = _selectAndSort(widget.budgetData);
      });
    }
  }

  List<CategoryBudget> _selectAndSort(BudgetData data) {
    final overBudget = data.categories
        .where((c) => c.spent > c.budget)
        .toList();
    final normal = data.categories
        .where((c) => c.spent >= c.budget * 0.6 && c.spent <= c.budget)
        .toList();
    final underLow = data.categories
        .where((c) => c.spent < c.budget * 0.6)
        .toList();

    final selected = <CategoryBudget>[];
    // 1. Mostrar casos visuales: exceeded, normal, underlow
    if (overBudget.isNotEmpty) selected.add(overBudget.removeAt(0));
    if (normal.isNotEmpty) selected.add(normal.removeAt(0));
    if (underLow.isNotEmpty) selected.add(underLow.removeAt(0));

    // 2. Los otros dos por debajo del umbral del total (underLow o normal)
    final remainingPool = [...underLow, ...normal];
    for (final budget in remainingPool) {
      if (selected.length >= 5) break;
      if (!selected.contains(budget)) selected.add(budget);
    }

    // Fallback if there are less than 5
    for (final budget in data.categories) {
      if (selected.length >= 5) break;
      if (!selected.contains(budget)) selected.add(budget);
    }

    // Sort highest percentage first
    selected.sort((a, b) {
      final pA = a.budget > 0 ? a.spent / a.budget : 0.0;
      final pB = b.budget > 0 ? b.spent / b.budget : 0.0;
      return pB.compareTo(pA);
    });

    return selected;
  }

  @override
  Widget build(BuildContext context) {
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
                // TODO: wire onAddToBudget and onQuickTransaction when those flows exist
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// --- FAB ---
class _HomeFab extends StatelessWidget {
  const _HomeFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: context.colorScheme.secondary,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: context.colorScheme.onSurface.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Icons.add, color: Colors.white, size: 28),
      ),
    );
  }
}
