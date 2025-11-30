import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/extensions/context_extensions.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class TransactionDetailsModal extends StatelessWidget {
  final Transaction transaction;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;

  const TransactionDetailsModal({
    super.key,
    required this.transaction,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '\$');
    final isIncome = transaction.type == 'income';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.colorScheme.onSurfaceVariant.withValues(
                alpha: 0.2,
              ),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const Gap(24),

          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 40),
          ),
          const Gap(16),

          // Amount
          Text(
            '${isIncome ? '+' : '-'}${formatter.format(transaction.amount)}',
            style: context.textTheme.headlineMedium?.copyWith(
              color: isIncome ? context.secondaryColor : context.errorColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(8),

          // Title/Note
          Text(
            transaction.note ?? 'Transaction',
            style: context.textTheme.titleLarge,
            textAlign: TextAlign.center,
          ),
          const Gap(8),

          // Date
          Text(
            DateFormat('MMMM dd, yyyy • hh:mm a').format(transaction.date),
            style: context.textTheme.bodyMedium?.copyWith(
              color: context.colorScheme.onSurfaceVariant,
            ),
          ),
          const Gap(32),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.pop(),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Cancel'),
                ),
              ),
              const Gap(16),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Use singleton TransactionBloc to delete
                    getIt<TransactionBloc>().add(
                      DeleteTransactionEvent(transaction.id),
                    );
                    context.pop();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Transaction deleted'),
                        backgroundColor: context.errorColor,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.errorColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                ),
              ),
            ],
          ),
          const Gap(16),
        ],
      ),
    );
  }
}

void showTransactionDetailsModal({
  required BuildContext context,
  required Transaction transaction,
  required IconData icon,
  required Color iconColor,
  required Color iconBackgroundColor,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => TransactionDetailsModal(
      transaction: transaction,
      icon: icon,
      iconColor: iconColor,
      iconBackgroundColor: iconBackgroundColor,
    ),
  );
}
