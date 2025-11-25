import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/utils/icon_helper.dart';
import 'package:fin_track_pro/core/widgets/budget_category_item.dart';
import 'package:fin_track_pro/core/widgets/donut_chart.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:fin_track_pro/theme/utils/resposive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => getIt<HomeBloc>()..add(const LoadHomeData()),
      child: Scaffold(
        appBar: _appBar(),
        body: SafeArea(child: _body()),
        bottomNavigationBar: _bottomNavigationBar(),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: ColorTheme.primaryColor,
          ),
          Gap(8),
          Text('FinTrack Pro', style: TextStyle(color: ColorTheme.textPrimary)),
          Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: ColorTheme.onPrimaryColor,
            child: Icon(Icons.person_outline_rounded),
          ),
        ],
      ),
    );
  }

  Widget _body() {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const Gap(16),
                Text(state.message),
                const Gap(16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const RefreshHomeData());
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (state is HomeLoaded) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  _BalanceSummary(balance: state.totalBalance),
                  const Gap(16),
                  _BudgetOverview(budgetData: state.budgetData),
                  const Gap(16),
                  _Transactions(
                    transactions: state.recentTransactions,
                    categories: state.categories,
                  ),
                ],
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _bottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        selectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart),
            label: 'Analytics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category_outlined),
            activeIcon: Icon(Icons.category),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  final double balance;

  const _BalanceSummary({required this.balance});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    final balanceColor = balance >= 0 ? Colors.green : Colors.red;

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Text(
                'Total Balance',
                style: TextStyle(color: ColorTheme.textPrimary, fontSize: 16),
              ),
              const Gap(8),
              Text(
                formatter.format(balance),
                style: TextStyle(
                  color: balanceColor,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BudgetOverview extends StatelessWidget {
  final BudgetData? budgetData;

  const _BudgetOverview({this.budgetData});

  @override
  Widget build(BuildContext context) {
    if (budgetData == null || budgetData!.categories.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(
              child: Text(
                'No budget data available',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'View Details',
                      style: TextStyle(fontSize: 15, color: Colors.blue),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Chart and Categories
              SizedBox(
                width: double.infinity,

                child: Wrap(
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  direction: Axis.horizontal,
                  children: [
                    // Donut Chart
                    DonutChart(
                      totalSpent: budgetData!.totalSpent,
                      totalBudget: budgetData!.totalBudget,
                      segments: budgetData!.categories.map((cat) {
                        return DonutSegment(
                          value: cat.spent,
                          color: IconHelper.getColor(cat.category.color),
                        );
                      }).toList(),
                    ),

                    // Categories List
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: budgetData!.categories.map((categoryBudget) {
                        return BudgetCategoryItem(
                          color: IconHelper.getColor(
                            categoryBudget.category.color,
                          ),
                          name: categoryBudget.category.name,
                          spent: categoryBudget.spent,
                          budget: categoryBudget.budget,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),

              // Budget Remaining
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Budget Remaining',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1C1C1E)),
                  ),
                  Text(
                    '\$${budgetData!.remaining.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: budgetData!.remaining >= 0
                          ? Colors.green
                          : Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Transactions extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, Category> categories;

  const _Transactions({required this.transactions, required this.categories});

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const SizedBox(
        width: double.infinity,
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
              Gap(16),
              Text(
                'No transactions yet',
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: context.hp(40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          const Text(
            'Recent Transactions',
            style: TextStyle(
              color: ColorTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          Expanded(
            child: ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];
                final isIncome = transaction.type == 'income';
                final category = categories[transaction.categoryId];

                // Get category icon and color, or use defaults
                final categoryIcon = category != null
                    ? IconHelper.getIcon(category.icon)
                    : (isIncome ? Icons.arrow_downward : Icons.arrow_upward);
                final categoryColor = category != null
                    ? IconHelper.getColor(category.color)
                    : (isIncome ? Colors.green : Colors.red);

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TransactionCard(
                    amount: transaction.amount,
                    icon: categoryIcon,
                    iconBackgroundColor: categoryColor.withValues(alpha: 0.1),
                    iconColor: categoryColor,
                    title: category?.name ?? transaction.note ?? 'Transaction',
                    date: DateFormat('MMM dd, yyyy').format(transaction.date),
                    amountColor: isIncome ? Colors.green : Colors.red,
                    isIncome: isIncome,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TransactionCard extends StatelessWidget {
  final IconData icon;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String title;
  final String date;
  final double amount;
  final Color amountColor;
  final bool isIncome;

  const TransactionCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
    required this.isIncome,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 28),
          ),
          const SizedBox(width: 16),

          // Título y fecha
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1C1C1E),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),

          // Monto
          Text(
            '${isIncome ? '+' : '-'}${formatter.format(amount)}',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: amountColor,
            ),
          ),
        ],
      ),
    );
  }
}
