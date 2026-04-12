import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/add_transaction_modal.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/transaction_bloc/transaction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AllTransactionsPage extends StatelessWidget {
  const AllTransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: getIt<TransactionBloc>()
            ..add(const LoadPaginatedTransactions()),
        ),
        BlocProvider(
          create: (_) => getIt<CategoryBloc>()..add(LoadCategoriesEvent()),
        ),
      ],
      child: const _TransactionsBody(),
    );
  }
}

class _TransactionsBody extends StatefulWidget {
  const _TransactionsBody();

  @override
  State<_TransactionsBody> createState() => _TransactionsBodyState();
}

class _TransactionsBodyState extends State<_TransactionsBody> {
  int _filterIndex = 0;
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      context.read<TransactionBloc>().add(const LoadMoreTransactions());
    }
  }

  List<String> _buildFilters(BuildContext context) => [
    context.l10n.all,
    context.l10n.expense,
    context.l10n.income,
  ];

  void _applyTypeFilter(int index) {
    setState(() => _filterIndex = index);
    final typeMap = {1: 'expense', 2: 'income'};
    context.read<TransactionBloc>().add(
      FilterTransactions(type: typeMap[index]),
    );
  }

  void _showCategoryFilter(BuildContext context, List<Category> categories) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<TransactionBloc>(),
        child: _CategoryFilterModal(categories: categories),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      appBar: AppBar(
        backgroundColor: context.colorScheme.surface,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          context.l10n.allTransactions,
          style: context.textTheme.headlineSmall!,
        ),
        actions: [
          BlocBuilder<CategoryBloc, CategoryState>(
            builder: (context, catState) {
              return IconButton(
                icon: Icon(
                  Icons.filter_list_rounded,
                  color: context.colorScheme.onSurface,
                ),
                onPressed: () =>
                    _showCategoryFilter(context, catState.categories),
              );
            },
          ),
          const Gap(8),
        ],
      ),
      body: BlocBuilder<TransactionBloc, TransactionState>(
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: _FilterChips(
                  filters: _buildFilters(context),
                  selectedIndex: _filterIndex,
                  onChanged: _applyTypeFilter,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                child: _SummaryRow(transactions: state.transactions),
              ),
              Expanded(child: _buildList(context, state)),
            ],
          );
        },
      ),
      floatingActionButton: _AddFab(
        onTap: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => const AddTransactionModal(),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, TransactionState state) {
    if (state.status == TransactionStatus.loading &&
        state.transactions.isEmpty) {
      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
        itemCount: 8,
        itemBuilder: (context, _) => const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Row(
            children: [
              ShimmerCircle(size: 44),
              Gap(12),
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
      );
    }

    if (state.transactions.isEmpty &&
        state.status == TransactionStatus.success) {
      return Center(
        child: Text(
          context.l10n.noTransactions,
          style: context.textTheme.bodyMedium!,
        ),
      );
    }

    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, catState) {
        final catMap = {for (final c in catState.categories) c.id: c};
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          itemCount: state.transactions.length,
          itemBuilder: (context, index) {
            final tx = state.transactions[index];
            final cat = catMap[tx.categoryId];
            return _TransactionRow(
              emoji: CategoryHelper.categoryEmoji(cat?.icon ?? ''),
              title: cat?.name ?? (tx.note ?? context.l10n.transactionFallback),
              date: CategoryHelper.formatDate(tx.date),
              amount: tx.amount,
              isIncome: tx.type == 'income',
              category: cat?.name ?? context.l10n.noCategory,
            );
          },
        );
      },
    );
  }
}

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.filters,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> filters;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(filters.length, (i) {
        final isSelected = i == selectedIndex;
        return Padding(
          padding: EdgeInsets.only(right: i < filters.length - 1 ? 8 : 0),
          child: GestureDetector(
            onTap: () => onChanged(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isSelected
                    ? context.colorScheme.primary
                    : context.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Text(
                filters[i],
                style: TextStyle(
                  color: isSelected
                      ? Colors.white
                      : context.colorScheme.onSurface,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.transactions});

  final List<Transaction> transactions;

  @override
  Widget build(BuildContext context) {
    final income = transactions
        .where((t) => t.type == 'income')
        .fold(0.0, (s, t) => s + t.amount);
    final expense = transactions
        .where((t) => t.type == 'expense')
        .fold(0.0, (s, t) => s + t.amount);
    return Row(
      children: [
        _SummaryChip(
          label: context.l10n.totalIncome,
          value: income.toCurrency(),
          color: context.colorScheme.secondary,
        ),
        const Gap(8),
        _SummaryChip(
          label: context.l10n.totalExpenses,
          value: expense.toCurrency(),
          color: context.colorScheme.error,
        ),
      ],
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: context.textTheme.labelLarge!),
            Text(
              value,
              style: context.textTheme.titleMedium!.copyWith(color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionRow extends StatelessWidget {
  const _TransactionRow({
    required this.emoji,
    required this.title,
    required this.date,
    required this.amount,
    required this.isIncome,
    required this.category,
  });

  final String emoji;
  final String title;
  final String date;
  final double amount;
  final bool isIncome;
  final String category;

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
              color: context.colorScheme.surfaceContainerHigh,
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
                Text(title, style: context.textTheme.titleMedium!),
                Text(date, style: context.textTheme.labelLarge!),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}${amount.toCurrency()}',
                style: context.textTheme.titleMedium!.copyWith(
                  color: isIncome
                      ? context.colorScheme.tertiary
                      : context.colorScheme.onSurface,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(category, style: context.textTheme.labelMedium!),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AddFab extends StatelessWidget {
  const _AddFab({required this.onTap});

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

// --- Category Filter Modal ---
class _CategoryFilterModal extends StatefulWidget {
  const _CategoryFilterModal({required this.categories});

  final List<Category> categories;

  @override
  State<_CategoryFilterModal> createState() => _CategoryFilterModalState();
}

class _CategoryFilterModalState extends State<_CategoryFilterModal> {
  final _selected = <String>{};

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24.0)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: context.colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
            child: Text(
              context.l10n.filterByCategory,
              style: context.textTheme.headlineSmall!,
            ),
          ),
          if (widget.categories.isEmpty)
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                context.l10n.noCategories,
                style: context.textTheme.bodyMedium!,
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.categories.map((cat) {
                  final isSelected = _selected.contains(cat.id);
                  final label =
                      '${CategoryHelper.categoryEmoji(cat.icon)} ${cat.name}';
                  return GestureDetector(
                    onTap: () => setState(() {
                      isSelected
                          ? _selected.remove(cat.id)
                          : _selected.add(cat.id);
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? context.colorScheme.primary
                            : context.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : context.colorScheme.onSurface,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          const Gap(32.0),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() => _selected.clear());
                      context.read<TransactionBloc>().add(const ClearFilters());
                      Navigator.of(context).pop();
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: context.colorScheme.outlineVariant,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      context.l10n.clearAll,
                      style: TextStyle(color: context.colorScheme.onSurface),
                    ),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: ThemeConstants.primaryGradient,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: TextButton(
                      onPressed: () {
                        if (_selected.isNotEmpty) {
                          context.read<TransactionBloc>().add(
                            FilterTransactions(categoryId: _selected.first),
                          );
                        }
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        context.l10n.applyFilters,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Gap(32.0),
        ],
      ),
    );
  }
}
