import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/presentation/bloc/bloc.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/edit_transaction_page.dart';
import 'package:fin_track_pro/theme/utils/color_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Helper function to show the Edit Transaction modal
void showEditTransactionModal(BuildContext context, Transaction transaction) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (modalContext) {
      // Get singleton TransactionBloc and create EditTransactionCubit
      final transactionBloc = getIt<TransactionBloc>();
      final editTransactionCubit = getIt.get<EditTransactionCubit>(
        param1: transaction,
      );

      return Container(
        decoration: BoxDecoration(
          color: Theme.of(modalContext).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: MultiBlocProvider(
          providers: [
            BlocProvider.value(value: transactionBloc),
            BlocProvider(create: (_) => editTransactionCubit),
          ],
          child: const EditTransactionPage(),
        ),
      );
    },
  );
}

class TransactionDetailsModal extends StatelessWidget {
  final Transaction transaction;
  final IconData icon;
  final Color iconColor;
  final Color iconBackgroundColor;
  final String? heroTag;

  const TransactionDetailsModal({
    super.key,
    required this.transaction,
    required this.icon,
    required this.iconColor,
    required this.iconBackgroundColor,
    this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
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
          if (heroTag != null)
            Hero(
              tag: heroTag!,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: iconBackgroundColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: iconColor, size: 40),
                ),
              ),
            )
          else
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
            '${isIncome ? '+' : '-'}${transaction.amount.toCurrencyInt()}',
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
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.pop();
                    // Show edit modal
                    showEditTransactionModal(context, transaction);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.edit),
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
                      side: const BorderSide(color: ColorTheme.errorColor),
                    ),
                  ),
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.l10n.delete),
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
  required String heroTag,
}) {
  Navigator.of(context, rootNavigator: true).push(
    PageRouteBuilder(
      opaque: false,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      fullscreenDialog: true,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Tap listener for background dismissal
              Positioned.fill(
                child: GestureDetector(
                  onTap: () => context.pop(),
                  child: Container(color: Colors.transparent),
                ),
              ),
              // Content aligned to bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOutCubic,
                          reverseCurve: Curves.easeInCubic,
                        ),
                      ),
                  child: GestureDetector(
                    onTap: () {}, // Prevent tap from passing through
                    child: TransactionDetailsModal(
                      transaction: transaction,
                      icon: icon,
                      iconColor: iconColor,
                      iconBackgroundColor: iconBackgroundColor,
                      heroTag: heroTag,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ),
  );
}
