import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:fin_track_pro/features/analytics/presentation/bloc/analytics_bloc.dart';
import 'package:fin_track_pro/core/utils/category_helper.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:fin_track_pro/theme/utils/resposive.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class AnalyticsPage extends StatelessWidget {
  const AnalyticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AnalyticsBloc>()..add(const LoadAnalyticsData()),
      child: const _AnalyticsBody(),
    );
  }
}

class _AnalyticsBody extends StatefulWidget {
  const _AnalyticsBody();

  @override
  State<_AnalyticsBody> createState() => _AnalyticsBodyState();
}

class _AnalyticsBodyState extends State<_AnalyticsBody> {
  int _rangeIndex = 1; // Default: Mes
  int _touchedPieIndex = -1;

  static const _periodMap = [
    AnalyticsPeriod.week,
    AnalyticsPeriod.month,
    AnalyticsPeriod.quarter,
    AnalyticsPeriod.year,
  ];

  List<String> _buildRanges(BuildContext context) => [
    context.l10n.week,
    context.l10n.month,
    context.l10n.threeMonths,
    context.l10n.year,
  ];

  void _onRangeChanged(int index) {
    setState(() {
      _rangeIndex = index;
      _touchedPieIndex = -1;
    });
    context.read<AnalyticsBloc>().add(ChangePeriod(_periodMap[index]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colorScheme.surface,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: BlocBuilder<AnalyticsBloc, AnalyticsState>(
                buildWhen: (p, c) => p.status != c.status || p.data != c.data,
                builder: (context, state) => _buildContent(context, state),
              ),
            ),
          ),
        ],
      ),
    );
  }

  SliverAppBar _buildAppBar() {
    return SliverAppBar(
      backgroundColor: context.colorScheme.surface,
      elevation: 0,
      floating: true,
      snap: true,
      titleSpacing: 20,
      title: Row(
        children: [
          Text(context.l10n.analytics, style: context.textTheme.headlineSmall!),
          const Spacer(),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: context.colorScheme.surface,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.ios_share_outlined,
              color: context.colorScheme.onSurface,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AnalyticsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RangeSelector(
          ranges: _buildRanges(context),
          selectedIndex: _rangeIndex,
          onChanged: _onRangeChanged,
        ),
        const Gap(32.0),
        if (state.status == AnalyticsStatus.loading)
          _buildShimmer()
        else if (state.status == AnalyticsStatus.error)
          _buildError(context, state.errorMessage ?? 'Error')
        else if (state.data != null)
          _buildLoaded(state.data!)
        else
          _buildShimmer(),
        const Gap(100),
      ],
    );
  }

  Widget _buildLoaded(AnalyticsData data) {
    final period = _periodMap[_rangeIndex];
    final dateRange = period.getDateRange();
    final daysInPeriod = dateRange.end
        .difference(dateRange.start)
        .inDays
        .clamp(1, 999);
    final avgPerDay = data.totalExpenses / daysInPeriod;

    final topCat = data.topSpendingCategories.isNotEmpty
        ? data.topSpendingCategories.first
        : null;
    final topCatLabel = topCat != null
        ? '${CategoryHelper.categoryEmoji(topCat.category.icon)} ${topCat.category.name}'
        : '—';

    final categoryShares = data.categorySpending
        .where((cs) => cs.amount > 0)
        .map(
          (cs) => _CategoryShare(
            emoji: CategoryHelper.categoryEmoji(cs.category.icon),
            name: cs.category.name,
            percent: cs.getPercentage(data.totalExpenses).round(),
            color: Color(cs.category.color),
          ),
        )
        .toList();

    final barValues = data.comparisons.map((c) => c.expense).toList();
    final barLabels = data.comparisons.map((c) => c.label).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SummaryCards(
          totalExpenses: data.totalExpenses,
          avgPerDay: avgPerDay,
          topCatLabel: topCatLabel,
        ),
        const Gap(4.00),
        Text(
          context.l10n.spendingTrend,
          style: context.textTheme.headlineSmall!,
        ),
        const Gap(26.0),
        _SpendingBarChart(barData: barValues, labels: barLabels),
        const Gap(16.00),
        Text(
          context.l10n.spendingByCategory,
          style: context.textTheme.headlineSmall!,
        ),
        const Gap(24.0),
        if (categoryShares.isNotEmpty) ...[
          _PieChartSection(
            items: categoryShares,
            touchedIndex: _touchedPieIndex,
            onTouch: (i) => setState(() => _touchedPieIndex = i),
          ),
          const Gap(38.0),
          ...categoryShares.map((c) => _CategoryBreakdownRow(item: c)),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                context.l10n.noSpendingDataAvailable,
                style: context.textTheme.bodyMedium!,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Expanded(child: ShimmerBox(height: 100, borderRadius: 12.0)),
            Gap(8),
            Expanded(
              child: Column(
                children: [
                  ShimmerBox(height: 44, borderRadius: 12.0),
                  Gap(8),
                  ShimmerBox(height: 44, borderRadius: 12.0),
                ],
              ),
            ),
          ],
        ),
        const Gap(4.00),
        const ShimmerBox(height: 20, width: 140, borderRadius: 8),
        const Gap(24.0),
        const ShimmerBox(height: 180, borderRadius: 24.0),
        const Gap(4.00),
        const ShimmerBox(height: 20, width: 100, borderRadius: 8),
        const Gap(24.0),
        const ShimmerBox(height: 200, borderRadius: 24.0),
        const Gap(32.0),
        ...List.generate(
          4,
          (_) => const Padding(
            padding: EdgeInsets.only(bottom: 12.0),
            child: ShimmerBox(height: 40, borderRadius: 12.0),
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
              onPressed: () => context.read<AnalyticsBloc>().add(
                const RefreshAnalyticsData(),
              ),
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

// --- Range Selector ---
class _RangeSelector extends StatelessWidget {
  const _RangeSelector({
    required this.ranges,
    required this.selectedIndex,
    required this.onChanged,
  });

  final List<String> ranges;
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: context.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Row(
        children: List.generate(ranges.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: isSelected
                      ? context.colorScheme.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Center(
                  child: Text(
                    ranges[i],
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : context.colorScheme.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                    ),
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

// --- Summary Cards ---
class _SummaryCards extends StatelessWidget {
  const _SummaryCards({
    required this.totalExpenses,
    required this.avgPerDay,
    required this.topCatLabel,
  });

  final double totalExpenses;
  final double avgPerDay;
  final String topCatLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: ThemeConstants.heroCardGradient,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.totalExpenses,
                  style: context.textTheme.bodyMedium!.copyWith(
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const Gap(6),
                Text(
                  totalExpenses.toCurrency(),
                  style: context.textTheme.headlineMedium!.copyWith(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
        const Gap(16),
        Expanded(
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    const Text('📊', style: TextStyle(fontSize: 18)),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.avgPerDay,
                            style: context.textTheme.labelLarge!,
                          ),
                          Text(
                            avgPerDay.toCurrency(),
                            style: context.textTheme.titleMedium!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: context.colorScheme.surface,
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Row(
                  children: [
                    const Text('🔥', style: TextStyle(fontSize: 18)),
                    const Gap(8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            context.l10n.topExpense,
                            style: context.textTheme.labelLarge!,
                          ),
                          Text(
                            topCatLabel,
                            style: context.textTheme.titleMedium!,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// --- Bar Chart ---
class _SpendingBarChart extends StatelessWidget {
  const _SpendingBarChart({required this.barData, required this.labels});

  final List<double> barData;
  final List<String> labels;

  @override
  Widget build(BuildContext context) {
    if (barData.isEmpty) {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: BorderRadius.circular(24.0),
        ),
        child: Center(
          child: Text(
            context.l10n.noDataAvailable,
            style: context.textTheme.bodyMedium!,
          ),
        ),
      );
    }

    final maxY = barData.reduce((a, b) => a > b ? a : b);
    final barWidth = (22.0 / (barData.length / 7.0).clamp(1.0, 4.0));

    return Container(
      height: 180,
      padding: const EdgeInsets.fromLTRB(8, 16, 8, 0),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: maxY > 0 ? maxY * 1.2 : 10,
          barTouchData: const BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= labels.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      labels[i],
                      style: context.textTheme.labelLarge!,
                    ),
                  );
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
          ),
          gridData: const FlGridData(show: false),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(barData.length, (i) {
            final isTallest = maxY > 0 && barData[i] == maxY;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barData[i],
                  width: barWidth,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  ),
                  gradient: isTallest
                      ? ThemeConstants.primaryGradient
                      : LinearGradient(
                          colors: [
                            context.colorScheme.primary.withValues(alpha: 0.3),
                            context.colorScheme.primaryContainer.withValues(
                              alpha: 0.3,
                            ),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// --- Category Share model ---
class _CategoryShare {
  const _CategoryShare({
    required this.emoji,
    required this.name,
    required this.percent,
    required this.color,
  });

  final String emoji;
  final String name;
  final int percent;
  final Color color;
}

// --- Pie Chart ---
class _PieChartSection extends StatelessWidget {
  const _PieChartSection({
    required this.items,
    required this.touchedIndex,
    required this.onTouch,
  });

  final List<_CategoryShare> items;
  final int touchedIndex;
  final ValueChanged<int> onTouch;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(18.0),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: BorderRadius.circular(24.0),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            width: context.wp(30),
            child: PieChart(
              PieChartData(
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (!event.isInterestedForInteractions ||
                        response == null ||
                        response.touchedSection == null) {
                      onTouch(-1);
                      return;
                    }
                    onTouch(response.touchedSection!.touchedSectionIndex);
                  },
                ),
                sections: List.generate(items.length, (i) {
                  final isTouched = i == touchedIndex;
                  final item = items[i];
                  return PieChartSectionData(
                    value: item.percent.toDouble(),
                    color: item.color,
                    radius: isTouched ? 60 : 50,
                    title: isTouched ? '${item.percent}%' : '',
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    borderSide: BorderSide.none,
                  );
                }),
                centerSpaceRadius: 40,
                sectionsSpace: 2,
              ),
            ),
          ),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: items.take(4).map((item) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: item.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Gap(6),
                    Text(
                      '${item.emoji} ${item.name}',
                      style: context.textTheme.labelLarge!,
                    ),
                    const Gap(4),
                    Text(
                      '${item.percent}%',
                      style: context.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

// --- Category Breakdown Row ---
class _CategoryBreakdownRow extends StatelessWidget {
  const _CategoryBreakdownRow({required this.item});

  final _CategoryShare item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: context.colorScheme.surfaceContainerHigh,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(item.emoji, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const Gap(10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.name, style: context.textTheme.titleMedium!),
                    Text(
                      '${item.percent}%',
                      style: context.textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const Gap(4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: item.percent / 100,
                    minHeight: 5,
                    backgroundColor:
                        context.colorScheme.surfaceContainerHighest,
                    valueColor: AlwaysStoppedAnimation<Color>(item.color),
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
