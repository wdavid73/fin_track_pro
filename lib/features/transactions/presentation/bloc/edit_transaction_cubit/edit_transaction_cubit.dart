import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../categories/domain/usecases/get_categories_use_case.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/update_transaction.dart';
import 'edit_transaction_state.dart';

/// Cubit that manages the state and business logic for editing an existing transaction.
///
/// This serves as the ViewModel in the MVVM pattern, handling:
/// - Loading categories
/// - Form state management
/// - Form validation
/// - Transaction update
@injectable
class EditTransactionCubit extends Cubit<EditTransactionState> {
  final GetCategoriesUseCase _getCategories;
  final UpdateTransaction _updateTransaction;

  EditTransactionCubit(
    this._getCategories,
    this._updateTransaction,
    @factoryParam Transaction transaction,
  ) : super(EditTransactionState.fromTransaction(transaction)) {
    loadCategories();
  }

  /// Loads categories from the repository
  Future<void> loadCategories() async {
    try {
      final categories = await _getCategories();
      emit(
        state.copyWith(
          categories: categories,
          isLoadingCategories: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isLoadingCategories: false,
          errorMessage: 'Failed to load categories: ${e.toString()}',
        ),
      );
    }
  }

  /// Updates the transaction type (expense/income)
  void updateTransactionType(String type) {
    // When category is cleared, form becomes invalid (needs category selection)
    emit(
      state.copyWith(
        transactionType: type,
        clearCategoryId: true, // Reset category when type changes
        isFormValid: false, // Form is invalid without a category
      ),
    );
  }

  /// Updates the transaction amount
  void updateAmount(double? amount) {
    // Calculate validation inline to avoid double emit
    final isValid = amount != null &&
                    amount > 0 &&
                    state.selectedCategoryId != null;

    emit(state.copyWith(
      amount: amount,
      clearAmount: amount == null,
      isFormValid: isValid,
    ));
  }

  /// Updates the selected category
  void updateCategory(String? categoryId) {
    // Calculate validation inline to avoid double emit
    final isValid = state.amount != null &&
                    state.amount! > 0 &&
                    categoryId != null;

    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        clearCategoryId: categoryId == null,
        isFormValid: isValid,
      ),
    );
  }

  /// Updates the transaction description
  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  /// Updates the selected date
  void updateDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  /// Updates the existing transaction
  Future<void> saveTransaction() async {
    if (!state.isFormValid) {
      emit(
        state.copyWith(
          errorMessage: 'Please enter an amount and select a category',
        ),
      );
      return;
    }

    emit(state.copyWith(isSubmitting: true, clearError: true));

    try {
      final updatedTransaction = state.transaction.copyWith(
        amount: state.amount!,
        categoryId: state.selectedCategoryId!,
        type: state.transactionType,
        note: state.description.isEmpty ? null : state.description,
        date: state.selectedDate,
      );

      await _updateTransaction(updatedTransaction);

      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to update transaction: ${e.toString()}',
        ),
      );
    }
  }
}
