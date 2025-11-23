import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:fin_track_pro/theme/utils/resposive.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: SafeArea(child: _body()),
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
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          children: [
            _BalanceSummary(),
            Gap(16),
            _BudgetOverview(),
            Gap(16),
            _Transactions(),
          ],
        ),
      ),
    );
  }
}

class _BalanceSummary extends StatelessWidget {
  const _BalanceSummary();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: .start,
            mainAxisAlignment: .start,
            children: [
              Text(
                'Total Balance',
                style: TextStyle(color: ColorTheme.textPrimary),
              ),
              Text(
                '\$1000',
                style: TextStyle(
                  color: ColorTheme.textPrimary,
                  fontSize: 24,
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
  const _BudgetOverview();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: context.hp(30),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              _title(),
              const Gap(16),
              _chart(),
              const Divider(),
              _remaining(),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox _remaining() {
    return const SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Text(
            'Budget Remaining',
            style: TextStyle(color: ColorTheme.textPrimary, fontSize: 16),
          ),
          Text(
            '\$1000',
            style: TextStyle(
              color: ColorTheme.secondaryColor,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Expanded _chart() => const Expanded(child: Placeholder(child: Text('Chart')));

  Row _title() {
    return const Row(
      children: [
        Text(
          'Budget Overview',
          style: TextStyle(
            color: ColorTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Spacer(),
        Text('View Details', style: TextStyle(color: ColorTheme.primaryColor)),
      ],
    );
  }
}

class _Transactions extends StatelessWidget {
  const _Transactions();

  @override
  Widget build(BuildContext context) {
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
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TransactionCard(
                    amount: (100 * index).toDouble(),
                    icon: Icons.shopping_cart_outlined,
                    iconBackgroundColor: ColorTheme.primaryColor,
                    iconColor: ColorTheme.onPrimaryColor,
                    title: 'Transaction $index',
                    date: '2023-01-01',
                    amountColor: ColorTheme.primaryColor,
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

  const TransactionCard({
    super.key,
    required this.icon,
    required this.iconBackgroundColor,
    required this.iconColor,
    required this.title,
    required this.date,
    required this.amount,
    required this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
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
            '${amount.isNegative ? '-' : '+'}\$${amount.abs().toStringAsFixed(2)}',
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
