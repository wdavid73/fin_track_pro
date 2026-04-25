import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/presentation/bloc/budget_bloc/budget_bloc.dart';
import 'package:fin_track_pro/features/budgets/presentation/budget_form_page.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class BudgetDetailPage extends StatelessWidget {
  const BudgetDetailPage({required this.budget, super.key});

  final CategoryBudget budget;

  void _openEditForm(BuildContext context) {
    final budgetBloc = getIt<BudgetBloc>();
    final categories = getIt<CategoryBloc>().state.categories;
    final budgetState = budgetBloc.state;
    Budget? existing;

    List<Budget> budgets = const [];
    if (budgetState is BudgetLoaded) {
      budgets = budgetState.budgets;
    } else if (budgetState is BudgetActionSuccess) {
      budgets = budgetState.budgets;
    }
    try {
      existing = budgets.firstWhere((b) => b.categoryId == budget.category.id);
    } catch (_) {
      existing = null;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: budgetBloc,
        child: BudgetFormPage(
          budget: existing,
          categories: categories,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<TransactionBloc>()
        ..add(FilterTransactions(categoryId: budget.category.id)),
      child: _BudgetDetailBody(
        budget: budget,
        onEdit: () => _openEditForm(context),
      ),
    );
  }
}

class _BudgetDetailBody extends StatelessWidget {
  const _BudgetDetailBody({
    required this.budget,
    required this.onEdit,
  });

  final CategoryBudget budget;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final emoji = CategoryHelper.categoryEmoji(budget.category.icon);
    final now = DateTime.now();
    final daysElapsed = now.day;
    final daysInMonth = DateUtils.getDaysInMonth(now.year, now.month);
    final daysRemaining = daysInMonth - daysElapsed;
    final avgPerDay = daysElapsed > 0 ? budget.spent / daysElapsed : 0.0;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          budget.category.name,
          style: Theme.of(context).textTheme.headlineSmall!,
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            onPressed: onEdit,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(24.0),
            _RingProgressCard(
              emoji: emoji,
              categoryName: budget.category.name,
              spent: budget.spent,
              total: budget.budget,
            ),
            const Gap(4.00),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                final txCount = state.transactions.length;
                return _StatsRow(
                  spent: budget.spent,
                  avgPerDay: avgPerDay,
                  txCount: txCount,
                  daysRemaining: daysRemaining,
                );
              },
            ),
            const Gap(4.00),
            BlocBuilder<TransactionBloc, TransactionState>(
              builder: (context, state) {
                final txs = state.transactions;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          context.l10n.detailTransactions,
                          style: Theme.of(context).textTheme.headlineSmall!,
                        ),
                        Text(
                          context.l10n.detailMovements(txs.length),
                          style:
                              Theme.of(context).textTheme.bodyMedium!.copyWith(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                        ),
                      ],
                    ),
                    const Gap(24.0),
                    if (state.status == TransactionStatus.loading)
                      const Center(child: CircularProgressIndicator())
                    else if (txs.isEmpty)
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: Text(
                            context.l10n.detailNoTransactions,
                            style: Theme.of(context).textTheme.bodyMedium!,
                          ),
                        ),
                      )
                    else
                      ...txs.map(
                        (tx) => _DetailTxRow(
                          emoji: emoji,
                          title: tx.note ?? budget.category.name,
                          amount: tx.amount,
                          date: CategoryHelper.formatDate(tx.date),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RingProgressCard extends StatelessWidget {
  const _RingProgressCard({
    required this.emoji,
    required this.categoryName,
    required this.spent,
    required this.total,
  });

  final String emoji;
  final String categoryName;
  final double spent;
  final double total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final remaining = total - spent;
    final isOverBudget = spent > total;

    return Container(
      padding: const EdgeInsets.all(4.00),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: 1.0,
                    strokeWidth: 10,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                ),
                SizedBox(
                  width: 100,
                  height: 100,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    strokeCap: StrokeCap.round,
                    color: isOverBudget
                        ? Theme.of(context).colorScheme.secondary
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(progress * 100).toInt()}%',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      context.l10n.detailUsed,
                      style: Theme.of(context).textTheme.labelLarge!,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Gap(4.00),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(emoji, style: const TextStyle(fontSize: 28)),
                    const Gap(8),
                    Text(
                      categoryName,
                      style: Theme.of(context).textTheme.headlineSmall!,
                    ),
                  ],
                ),
                const Gap(16.0),
                Text(
                  '\$${spent.toStringAsFixed(0)}',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  context.l10n.detailBudgeted(total.toStringAsFixed(0)),
                  style: Theme.of(context).textTheme.bodyMedium!,
                ),
                const Gap(16.0),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isOverBudget
                        ? const Color(0xFFFFEBEE)
                        : const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isOverBudget
                        ? context.l10n.detailExceededBy(
                            '\$${(spent - total).toStringAsFixed(0)}')
                        : context.l10n.detailAvailable(
                            '\$${remaining.toStringAsFixed(0)}'),
                    style: TextStyle(
                      color: isOverBudget
                          ? Theme.of(context).colorScheme.secondary
                          : Theme.of(context).colorScheme.tertiary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
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

class _StatsRow extends StatelessWidget {
  const _StatsRow({
    required this.spent,
    required this.avgPerDay,
    required this.txCount,
    required this.daysRemaining,
  });

  final double spent;
  final double avgPerDay;
  final int txCount;
  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatBox(
            label: context.l10n.detailAvgPerDay,
            value: '\$${avgPerDay.toStringAsFixed(1)}',
            icon: Icons.today_outlined,
          ),
        ),
        const Gap(8),
        Expanded(
          child: _StatBox(
            label: context.l10n.transactions,
            value: '$txCount',
            icon: Icons.receipt_outlined,
          ),
        ),
        const Gap(8),
        Expanded(
          child: _StatBox(
            label: context.l10n.detailDaysRemaining,
            value: '$daysRemaining',
            icon: Icons.calendar_month_outlined,
          ),
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const Gap(4),
          Text(value, style: Theme.of(context).textTheme.titleMedium!),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium!,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _DetailTxRow extends StatelessWidget {
  const _DetailTxRow({
    required this.emoji,
    required this.title,
    required this.amount,
    required this.date,
  });

  final String emoji;
  final String title;
  final double amount;
  final String date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium!),
                Text(date, style: Theme.of(context).textTheme.labelLarge!),
              ],
            ),
          ),
          Text(
            '-\$${amount.toStringAsFixed(2)}',
            style: Theme.of(context).textTheme.titleMedium!,
          ),
        ],
      ),
    );
  }
}
