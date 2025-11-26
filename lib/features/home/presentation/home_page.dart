import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/home/presentation/widget/balance_summary.dart';
import 'package:fin_track_pro/features/home/presentation/widget/budget_overview.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transactions.dart';
import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

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

        if (state is HomeLoading) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  BalanceSummary.loading(),
                  Gap(16),
                  BudgetOverview.loading(),
                  Gap(16),
                  Transactions.loading(),
                ],
              ),
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
                  BalanceSummary(balance: state.totalBalance),
                  const Gap(16),
                  BudgetOverview(budgetData: state.budgetData),
                  const Gap(16),
                  Transactions(
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
