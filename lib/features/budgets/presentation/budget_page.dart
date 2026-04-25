import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/presentation/bloc/budget_bloc/budget_bloc.dart';
import 'package:fin_track_pro/features/budgets/presentation/budget_form_page.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';

class BudgetPage extends StatelessWidget {
  const BudgetPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<BudgetBloc>()..add(const LoadBudgets()),
        ),
        BlocProvider.value(
          value: getIt<CategoryBloc>()..add(LoadCategoriesEvent()),
        ),
        BlocProvider(
          create: (_) => getIt<HomeBloc>()..add(const LoadHomeData()),
        ),
      ],
      child: const _BudgetBody(),
    );
  }
}

class _BudgetBody extends StatefulWidget {
  const _BudgetBody();

  @override
  State<_BudgetBody> createState() => _BudgetBodyState();
}

class _BudgetBodyState extends State<_BudgetBody> {
  int _periodIndex = 0;

  List<String> _buildPeriods(BuildContext context) => [
    context.l10n.thisMonth,
    context.l10n.lastMonth,
    context.l10n.thisYear,
  ];

  void _openBudgetForm(BuildContext context, {Budget? budget}) {
    final categories = context.read<CategoryBloc>().state.categories;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider.value(
        value: context.read<BudgetBloc>(),
        child: BudgetFormPage(budget: budget, categories: categories),
      ),
    ).then((_) {
      if (context.mounted) {
        // Reload home data so the budget chart on home also updates
        context.read<HomeBloc>().add(const LoadHomeData());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: BlocConsumer<BudgetBloc, BudgetState>(
        listener: (context, state) {
          if (state is BudgetActionSuccess) {
            context.read<HomeBloc>().add(const LoadHomeData());
          }
          if (state is BudgetError) {
            AppSnackbar().error(context, state.message);
          }
        },
        builder: (context, budgetState) {
          return BlocBuilder<HomeBloc, HomeState>(
            builder: (context, homeState) {
              return CustomScrollView(
                slivers: [
                  _buildAppBar(context),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: _buildContent(context, budgetState, homeState),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      key: const Key('budget_page_app_bar'),
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      floating: true,
      snap: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Text(context.l10n.budget, style: context.textTheme.headlineSmall!),
          const Spacer(),
          GestureDetector(
            onTap: () => _openBudgetForm(context),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: context.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.add,
                color: context.colorScheme.onPrimary,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    BudgetState budgetState,
    HomeState homeState,
  ) {
    // Show shimmer while either bloc is loading
    if (budgetState is BudgetLoading ||
        homeState is HomeLoading ||
        homeState is HomeInitial) {
      return _buildShimmer();
    }

    if (homeState is HomeError) {
      return _buildError(context, homeState.message);
    }

    if (homeState is HomeLoaded) {
      return _buildLoaded(context, homeState, budgetState);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoaded(
    BuildContext context,
    HomeLoaded homeState,
    BudgetState budgetState,
  ) {
    final budgetData = homeState.budgetData;
    final totalSpent = budgetData?.totalSpent ?? 0.0;
    final totalBudget = budgetData?.totalBudget ?? 0.0;
    final categories = budgetData?.categories ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _PeriodSelector(
          periods: _buildPeriods(context),
          selectedIndex: _periodIndex,
          onChanged: (i) => setState(() => _periodIndex = i),
        ),
        const Gap(32.0),
        _TotalBudgetCard(spent: totalSpent, total: totalBudget),
        const Gap(4.00),
        Text(context.l10n.categories, style: context.textTheme.headlineSmall!),
        const Gap(24.0),
        if (categories.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 32),
            child: Center(
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet_outlined,
                    size: 48,
                    color: context.colorScheme.outlineVariant,
                  ),
                  const Gap(12),
                  Text(
                    context.l10n.noBudgetsConfigured,
                    style: context.textTheme.bodyMedium!,
                  ),
                  const Gap(16),
                  FilledButton.tonal(
                    onPressed: () => _openBudgetForm(context),
                    child: Text(context.l10n.newBudget),
                  ),
                ],
              ),
            ),
          )
        else
          ...categories.map(
            (cb) => _BudgetCategoryCard(
              emoji: CategoryHelper.categoryEmoji(cb.category.icon),
              categoryName: cb.category.name,
              spent: cb.spent,
              total: cb.budget,
              color: Color(cb.category.color),
              onTap: () => context.go(RouteConstants.budgetDetail, extra: cb),
              onEdit: () => _openBudgetFormForCategory(context, cb.category.id),
              onDelete: () =>
                  _confirmDeleteByCategoryId(context, cb.category.id),
            ),
          ),
        const Gap(100),
      ],
    );
  }

  void _openBudgetFormForCategory(BuildContext context, String categoryId) {
    // Find budget by categoryId in BudgetBloc state
    final budgetState = context.read<BudgetBloc>().state;
    Budget? existing;
    List<Budget> budgets = const [];
    if (budgetState is BudgetLoaded) {
      budgets = budgetState.budgets;
    } else if (budgetState is BudgetActionSuccess) {
      budgets = budgetState.budgets;
    }
    try {
      existing = budgets.firstWhere((b) => b.categoryId == categoryId);
    } catch (_) {
      existing = null;
    }
    _openBudgetForm(context, budget: existing);
  }

  void _confirmDeleteByCategoryId(BuildContext context, String categoryId) {
    final budgetState = context.read<BudgetBloc>().state;
    String? budgetId;
    if (budgetState is BudgetLoaded) {
      try {
        budgetId = budgetState.budgets
            .firstWhere((b) => b.categoryId == categoryId)
            .id;
      } catch (_) {}
    } else if (budgetState is BudgetActionSuccess) {
      try {
        budgetId = budgetState.budgets
            .firstWhere((b) => b.categoryId == categoryId)
            .id;
      } catch (_) {}
    }
    if (budgetId == null) return;
    _confirmDelete(context, budgetId);
  }

  void _confirmDelete(BuildContext context, String budgetId) {
    showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(context.l10n.deleteBudget),
        content: Text(context.l10n.areYouSureDeleteBudget),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(context.l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(
              context.l10n.delete,
              style: TextStyle(color: context.colorScheme.error),
            ),
          ),
        ],
      ),
    ).then((confirmed) {
      if (confirmed == true && context.mounted) {
        context.read<BudgetBloc>().add(DeleteBudgetEvent(budgetId));
        AppSnackbar().success(context, context.l10n.budgetDeleted);
      }
    });
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const ShimmerBox(height: 40, borderRadius: 12.0),
        const Gap(32.0),
        const ShimmerBox(height: 140, borderRadius: 24.0),
        const Gap(4.00),
        const ShimmerBox(height: 20, width: 100, borderRadius: 8),
        const Gap(24.0),
        ...List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 16.0),
            child: ShimmerBox(height: 80, borderRadius: 24.0),
          ),
        ),
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
              onPressed: () {
                context.read<HomeBloc>().add(const LoadHomeData());
                context.read<BudgetBloc>().add(const LoadBudgets());
              },
              child: Text(
                context.l10n.retry,
                style: TextStyle(color: context.colorScheme.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Period Selector
// ---------------------------------------------------------------------------
class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periods,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(periods.length, (i) {
          final isSelected = i == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(right: i < periods.length - 1 ? 8 : 0),
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colorScheme.primary
                      : context.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Text(
                  periods[i],
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
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Total Budget Card
// ---------------------------------------------------------------------------
class _TotalBudgetCard extends StatelessWidget {
  const _TotalBudgetCard({required this.spent, required this.total});

  final double spent;
  final double total;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final remaining = total - spent;
    final isOverBudget = spent > total;

    return Container(
      padding: const EdgeInsets.all(32.0),
      decoration: BoxDecoration(
        gradient: ThemeConstants.heroCardGradient,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                context.l10n.totalBudget,
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              Text(
                isOverBudget ? context.l10n.overBudget : context.l10n.onTrack,
                style: TextStyle(
                  color: isOverBudget
                      ? const Color(0xFFFFB4A4)
                      : Colors.greenAccent,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const Gap(6),
          Text(
            '${spent.toCurrencyInt()} / ${total.toCurrencyInt()}',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          const Gap(24.0),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                isOverBudget ? const Color(0xFFFFB4A4) : Colors.greenAccent,
              ),
            ),
          ),
          const Gap(16.0),
          Text(
            isOverBudget
                ? context.l10n.overBudgetBy((spent - total).toCurrencyInt())
                : context.l10n.available(remaining.toCurrencyInt()),
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Budget Category Card (with edit/delete actions)
// ---------------------------------------------------------------------------
class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({
    required this.emoji,
    required this.categoryName,
    required this.spent,
    required this.total,
    required this.color,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final String emoji;
  final String categoryName;
  final double spent;
  final double total;
  final Color color;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
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
                      Text(categoryName, style: context.textTheme.titleMedium!),
                      Text(
                        context.l10n.spentOf(
                          spent.toCurrencyInt(),
                          total.toCurrencyInt(),
                        ),
                        style: context.textTheme.labelLarge!,
                      ),
                    ],
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: TextStyle(
                    color: isOverBudget ? context.colorScheme.secondary : color,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
                const Gap(4),
                // Edit / Delete popup menu
                PopupMenuButton<String>(
                  icon: Icon(
                    Icons.more_vert,
                    color: context.colorScheme.outline,
                    size: 18,
                  ),
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          const Icon(Icons.edit_outlined, size: 18),
                          const Gap(8),
                          Text(context.l10n.edit),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            size: 18,
                            color: context.colorScheme.error,
                          ),
                          const Gap(8),
                          Text(
                            context.l10n.delete,
                            style: TextStyle(color: context.colorScheme.error),
                          ),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (value) {
                    if (value == 'edit') onEdit();
                    if (value == 'delete') onDelete();
                  },
                ),
              ],
            ),
            const Gap(16.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 6,
                backgroundColor: context.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOverBudget ? context.colorScheme.secondary : color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
