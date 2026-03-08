import 'package:fin_track_pro/core/core.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/wrapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/add_transaction_cubit/add_transaction_cubit.dart';
import '../bloc/add_transaction_cubit/add_transaction_state.dart';
import '../bloc/transaction_bloc/transaction_bloc.dart';
import '../widgets/amount_input_widget.dart';
import '../widgets/category_selector.dart';
import '../widgets/date_selector.dart';
import '../widgets/description_input.dart';
import '../widgets/transaction_type_toggle.dart';

/// A modal page for adding a new transaction.
///
/// This is a pure UI component that follows the MVVM pattern.
/// All business logic and state management is handled by [AddTransactionCubit].
class AddTransactionPage extends StatelessWidget {
  const AddTransactionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AddTransactionCubit, AddTransactionState>(
      listener: (context, state) {
        // Handle submission success
        if (state.submitSuccess) {
          // Reload transactions in the main TransactionBloc
          context.read<TransactionBloc>().add(const LoadTransactions());

          // Close the modal
          Navigator.of(context).pop();

          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Transaction created successfully'),
              backgroundColor: context.secondaryColor,
            ),
          );
        }

        // Handle errors
        if (state.errorMessage != null && !state.isLoadingCategories) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: context.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        return SafeArea(
          key: const Key('add_transaction_page'),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                    Expanded(
                      child: Text(
                        'Add Transaction',
                        textAlign: TextAlign.center,
                        style: context.textTheme.titleLarge?.copyWith(
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40), // Balance the close button
                  ],
                ),
              ),

              // Content
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),

                      // Transaction Type Toggle
                      TransactionTypeToggle(
                        selectedType: state.transactionType,
                        onTypeChanged: (type) {
                          context
                              .read<AddTransactionCubit>()
                              .updateTransactionType(type);
                        },
                      ),

                      const SizedBox(height: 24),

                      // Amount Input
                      AmountInputWidget(
                        initialAmount: state.amount,
                        onAmountChanged: (amount) {
                          context.read<AddTransactionCubit>().updateAmount(
                            amount,
                          );
                        },
                        transactionType: state.transactionType,
                      ),

                      const SizedBox(height: 32),

                      // Category Selector
                      if (state.isLoadingCategories)
                        const Center(
                          child: Padding(
                            padding: EdgeInsets.all(24.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      else
                        CategorySelector(
                          categories: state.categories,
                          selectedCategoryId: state.selectedCategoryId,
                          onCategorySelected: (categoryId) {
                            context.read<AddTransactionCubit>().updateCategory(
                              categoryId,
                            );
                          },
                          transactionType: state.transactionType,
                        ),

                      const SizedBox(height: 24),

                      // Description Input
                      DescriptionInput(
                        initialValue: state.description,
                        onChanged: (description) {
                          context.read<AddTransactionCubit>().updateDescription(
                            description,
                          );
                        },
                      ),

                      const SizedBox(height: 24),

                      // Date Selector
                      DateSelector(
                        selectedDate: state.selectedDate,
                        onDateSelected: (date) {
                          context.read<AddTransactionCubit>().updateDate(date);
                        },
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text(context.l10n.cancel),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: state.isFormValid && !state.isSubmitting
                            ? () => context
                                  .read<AddTransactionCubit>()
                                  .saveTransaction()
                            : null,
                        // Style is handled by the theme now
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : Text(context.l10n.saveTransaction),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Helper function to show the Add Transaction modal
void showAddTransactionModal(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (modalContext) =>
        const WrapperBlocProviderTransaction(child: AddTransactionPage()),
  );
}
