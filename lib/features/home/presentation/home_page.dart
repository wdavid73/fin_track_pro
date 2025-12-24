import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/home/presentation/bloc/home_bloc.dart';
import 'package:fin_track_pro/features/home/presentation/widget/balance_summary.dart';
import 'package:fin_track_pro/features/home/presentation/widget/budget_overview.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transactions.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/add_transaction_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Use singleton TransactionBloc from get_it
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => getIt<HomeBloc>()..add(const LoadHomeData()),
        ),
        BlocProvider.value(value: getIt<TransactionBloc>()),
      ],
      child: Scaffold(
        appBar: _appBar(context),
        body: SafeArea(child: _body()),
        floatingActionButton: Builder(
          builder: (ctx) => FloatingActionButton(
            tooltip: context.l10n.addTransaction,
            onPressed: () {
              showAddTransactionModal(context);
            },
            backgroundColor: context.colorScheme.primary,
            child: const Icon(Icons.add, color: Colors.white),
          ),
        ),
      ),
    );
  }

  AppBar _appBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          Icon(
            Icons.account_balance_wallet_outlined,
            color: context.primaryColor,
          ),
          const Gap(8),
          Text(context.l10n.appTitle, style: context.textTheme.titleLarge),
          const Spacer(),
          CircleAvatar(
            radius: 20,
            backgroundColor: context.colorScheme.primaryContainer,
            child: Icon(
              Icons.person_outline_rounded,
              color: context.colorScheme.onPrimaryContainer,
            ),
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
                Icon(Icons.error_outline, size: 48, color: context.errorColor),
                const Gap(16),
                Text(state.message),
                const Gap(16),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeBloc>().add(const RefreshHomeData());
                  },
                  child: Text(context.l10n.retry),
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
}
