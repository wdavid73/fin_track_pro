import 'package:equatable/equatable.dart';
import '../../../../categories/domain/entities/category.dart';

/// State for the Add Transaction form
class AddTransactionState extends Equatable {
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

  const AddTransactionState({
    this.transactionType = 'expense',
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

  /// Creates a copy of this state with the given fields replaced
  AddTransactionState copyWith({
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
    return AddTransactionState(
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
