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

class _HomeBody extends StatelessWidget {
  const _HomeBody();

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
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
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

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      floating: true,
      snap: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              gradient: ThemeConstants.heroCardGradient,
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
              Text(context.l10n.welcome, style: context.textTheme.labelLarge),
              Text('Wilson', style: context.textTheme.titleMedium!),
            ],
          ),
          const Spacer(),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.notifications_outlined,
              color: context.colorScheme.onSurfaceVariant,
              size: 20,
            ),
          ),
        ],
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
        _BalanceHeroCard(balance: state.totalBalance),
        const Gap(24.0),
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

// --- Hero Balance Card ---
class _BalanceHeroCard extends StatelessWidget {
  const _BalanceHeroCard({required this.balance});

  final double balance;

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
          Text(
            balance.toCurrency(),
            style: const TextStyle(
              fontSize: 42,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -1,
            ),
          ),
          const Gap(24.0),
          Row(
            children: [
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.visibility_outlined,
                      color: Colors.white70,
                      size: 14,
                    ),
                    const Gap(4),
                    Text(
                      context.l10n.hide,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
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
class _BudgetBarsRow extends StatelessWidget {
  const _BudgetBarsRow({required this.budgetData});

  final BudgetData budgetData;

  @override
  Widget build(BuildContext context) {
    final overBudget = budgetData.categories.where((c) => c.spent > c.budget).toList();
    final normal = budgetData.categories.where((c) => c.spent >= c.budget * 0.6 && c.spent <= c.budget).toList();
    final underLow = budgetData.categories.where((c) => c.spent < c.budget * 0.6).toList();

    final selectedBudgets = <CategoryBudget>[];
    // 1. Mostrar casos visuales: exceeded, normal, underlow
    if (overBudget.isNotEmpty) selectedBudgets.add(overBudget.removeAt(0));
    if (normal.isNotEmpty) selectedBudgets.add(normal.removeAt(0));
    if (underLow.isNotEmpty) selectedBudgets.add(underLow.removeAt(0));

    // 2. Los otros dos por debajo del umbral del total (underLow o normal)
    final remainingPool = [...underLow, ...normal];
    for (final budget in remainingPool) {
      if (selectedBudgets.length >= 5) break;
      if (!selectedBudgets.contains(budget)) {
        selectedBudgets.add(budget);
      }
    }

    // Fallback if there are less than 5
    for (final budget in budgetData.categories) {
      if (selectedBudgets.length >= 5) break;
      if (!selectedBudgets.contains(budget)) {
        selectedBudgets.add(budget);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: selectedBudgets.map((cb) {
          return Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: BudgetBarChart(
              data: BudgetBarData(
                label: CategoryHelper.categoryEmoji(cb.category.icon),
                currentAmount: cb.spent,
                totalBudget: cb.budget,
                baseColor: Color(cb.category.color),
              ),
              width: 72,
              height: 160,
              onViewTotalValue: () => context.go(
                RouteConstants.budgetDetail,
                extra: cb,
              ),
              // TODO: wire onAddToBudget and onQuickTransaction when those flows exist
            ),
          );
        }).toList(),
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
