import 'package:fin_track_pro/core/utils/icon_helper.dart';
import 'package:fin_track_pro/core/widgets/skeleton.dart';
import 'package:fin_track_pro/core/widgets/shimmer_wrapper.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:fin_track_pro/theme/utils/resposive.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class Transactions extends StatelessWidget {
  final List<Transaction> transactions;
  final Map<String, Category> categories;
  final bool _isLoading;

  const Transactions({
    required this.transactions,
    required this.categories,
    super.key,
  }) : _isLoading = false;

  /// Loading state constructor
  const Transactions.loading({super.key})
    : transactions = const [],
      categories = const {},
      _isLoading = true;

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
          if (_isLoading)
            const Skeleton(width: 180, height: 18).shimmer(isLoading: true)
          else
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
            child: _isLoading
                ? _buildLoadingSkeleton()
                : _buildTransactionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSkeleton() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildSkeletonTransactionCard(),
        );
      },
    );
  }

  Widget _buildSkeletonTransactionCard() {
    return const ShimmerWrapper(
      isLoading: true,
      child: Row(
        children: [
          SkeletonAvatar(size: 48),
          Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton(width: 120, height: 16),
                Gap(4),
                Skeleton(width: 80, height: 12),
              ],
            ),
          ),
          Gap(12),
          Skeleton(width: 70, height: 18),
        ],
      ),
    );
  }

  Widget _buildTransactionsList() {
    if (transactions.isEmpty) {
      return const Center(
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
      );
    }

    return ListView.builder(
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
    );
  }
}
