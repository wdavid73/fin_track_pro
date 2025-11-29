import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:uuid/uuid.dart';
import '../../../../categories/domain/usecases/get_categories.dart';
import '../../../domain/entities/transaction.dart';
import '../../../domain/usecases/create_transaction.dart';
import 'add_transaction_state.dart';

/// Cubit that manages the state and business logic for adding a new transaction.
///
/// This serves as the ViewModel in the MVVM pattern, handling:
/// - Loading categories
/// - Form state management
/// - Form validation
/// - Transaction creation
@injectable
class AddTransactionCubit extends Cubit<AddTransactionState> {
  final GetCategories _getCategories;
  final CreateTransaction _createTransaction;

  AddTransactionCubit(this._getCategories, this._createTransaction)
    : super(AddTransactionState(selectedDate: DateTime.now())) {
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
    emit(
      state.copyWith(
        transactionType: type,
        clearCategoryId: true, // Reset category when type changes
      ),
    );
    _validateForm();
  }

  /// Updates the transaction amount
  void updateAmount(double? amount) {
    emit(state.copyWith(amount: amount, clearAmount: amount == null));
    _validateForm();
  }

  /// Updates the selected category
  void updateCategory(String? categoryId) {
    emit(
      state.copyWith(
        selectedCategoryId: categoryId,
        clearCategoryId: categoryId == null,
      ),
    );
    _validateForm();
  }

  /// Updates the transaction description
  void updateDescription(String description) {
    emit(state.copyWith(description: description));
  }

  /// Updates the selected date
  void updateDate(DateTime date) {
    emit(state.copyWith(selectedDate: date));
  }

  /// Validates the form and updates the isFormValid state
  void _validateForm() {
    final isValid =
        state.amount != null &&
        state.amount! > 0 &&
        state.selectedCategoryId != null;

    emit(state.copyWith(isFormValid: isValid));
  }

  /// Creates a new transaction
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
      final transaction = Transaction(
        id: const Uuid().v4(),
        amount: state.amount!,
        categoryId: state.selectedCategoryId!,
        type: state.transactionType,
        note: state.description.isEmpty ? null : state.description,
        date: state.selectedDate,
        createdAt: DateTime.now(),
      );

      await _createTransaction(transaction);

      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          errorMessage: 'Failed to create transaction: ${e.toString()}',
        ),
      );
    }
  }

  /// Resets the form to initial state
  void resetForm() {
    emit(
      AddTransactionState(
        selectedDate: DateTime.now(),
        categories: state.categories,
        isLoadingCategories: false,
      ),
    );
  }
}
