import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/config/router/routes.dart';
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
    return BlocProvider(
      create: (_) => getIt<HomeBloc>()..add(const LoadHomeData()),
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
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: _buildContent(context, state),
                ),
              ),
            ],
          );
        },
      ),
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
          Text(context.l10n.budget, style: context.textTheme.headlineSmall!),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.add, color: context.colorScheme.primary, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, HomeState state) {
    if (state is HomeLoading || state is HomeInitial) {
      return _buildShimmer();
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
    final budgetData = state.budgetData;
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
              child: Text(
                context.l10n.noBudgetsConfigured,
                style: context.textTheme.bodyMedium!,
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
            ),
          ),
        const Gap(100),
      ],
    );
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
          (_) => Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: const ShimmerBox(height: 80, borderRadius: 24.0),
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
            Text(message, style: context.textTheme.bodyMedium!, textAlign: TextAlign.center),
            const Gap(16),
            TextButton(
              onPressed: () =>
                  context.read<HomeBloc>().add(const LoadHomeData()),
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

// --- Period Selector ---
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
                    color: isSelected ? Colors.white : context.colorScheme.onSurface,
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

// --- Total Budget Card ---
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

// --- Budget Category Card ---
class _BudgetCategoryCard extends StatelessWidget {
  const _BudgetCategoryCard({
    required this.emoji,
    required this.categoryName,
    required this.spent,
    required this.total,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String categoryName;
  final double spent;
  final double total;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? (spent / total).clamp(0.0, 1.0) : 0.0;
    final isOverBudget = spent > total;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        padding: const EdgeInsets.all(24.0),
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
                        context.l10n.spentOf(spent.toCurrencyInt(), total.toCurrencyInt()),
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
                Icon(
                  Icons.chevron_right,
                  color: context.colorScheme.outline,
                  size: 18,
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
