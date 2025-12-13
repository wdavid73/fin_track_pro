import 'package:equatable/equatable.dart';
import '../../../../categories/domain/entities/category.dart';
import '../../../domain/entities/transaction.dart';

/// State for the Edit Transaction form
class EditTransactionState extends Equatable {
  final Transaction transaction;
  final String transactionType;
  final double? amount;
  final String? selectedCategoryId;
  final String description;
  final DateTime selectedDate;
  final List<Category> categories;
  final bool isLoadingCategories;
  final bool isFormValid;
  final String? errorMessage;
  final bool isSubmitting;
  final bool submitSuccess;

  const EditTransactionState({
    required this.transaction,
    required this.transactionType,
    this.amount,
    this.selectedCategoryId,
    this.description = '',
    required this.selectedDate,
    this.categories = const [],
    this.isLoadingCategories = true,
    this.isFormValid = false,
    this.errorMessage,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  /// Factory constructor to create initial state from a transaction
  factory EditTransactionState.fromTransaction(Transaction transaction) {
    return EditTransactionState(
      transaction: transaction,
      transactionType: transaction.type,
      amount: transaction.amount,
      selectedCategoryId: transaction.categoryId,
      description: transaction.note ?? '',
      selectedDate: transaction.date,
      isFormValid: true, // Already has valid data
    );
  }

  /// Creates a copy of this state with the given fields replaced
  EditTransactionState copyWith({
    Transaction? transaction,
    String? transactionType,
    double? amount,
    String? selectedCategoryId,
    String? description,
    DateTime? selectedDate,
    List<Category>? categories,
    bool? isLoadingCategories,
    bool? isFormValid,
    String? errorMessage,
    bool? isSubmitting,
    bool? submitSuccess,
    bool clearAmount = false,
    bool clearCategoryId = false,
    bool clearError = false,
  }) {
    return EditTransactionState(
      transaction: transaction ?? this.transaction,
      transactionType: transactionType ?? this.transactionType,
      amount: clearAmount ? null : (amount ?? this.amount),
      selectedCategoryId: clearCategoryId
          ? null
          : (selectedCategoryId ?? this.selectedCategoryId),
      description: description ?? this.description,
      selectedDate: selectedDate ?? this.selectedDate,
      categories: categories ?? this.categories,
      isLoadingCategories: isLoadingCategories ?? this.isLoadingCategories,
      isFormValid: isFormValid ?? this.isFormValid,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }

  @override
  List<Object?> get props => [
    transaction,
    transactionType,
    amount,
    selectedCategoryId,
    description,
    selectedDate,
    categories,
    isLoadingCategories,
    isFormValid,
    errorMessage,
    isSubmitting,
    submitSuccess,
  ];
}
