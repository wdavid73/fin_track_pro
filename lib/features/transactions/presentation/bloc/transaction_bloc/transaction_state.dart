part of 'transaction_bloc.dart';

enum TransactionStatus {
  initial,
  loading,
  success,
  error,
}

class TransactionState extends Equatable {
  final TransactionStatus status;
  final List<Transaction> transactions;
  final bool hasMore;
  final int currentOffset;
  final String? errorMessage;
  final String? successMessage;
  final String? typeFilter;
  final String? categoryFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;
  final String? searchQuery;
  final bool hasActiveFilters;

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.hasMore = false,
    this.currentOffset = 0,
    this.errorMessage,
    this.successMessage,
    this.typeFilter,
    this.categoryFilter,
    this.startDateFilter,
    this.endDateFilter,
    this.searchQuery,
    this.hasActiveFilters = false,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    bool? hasMore,
    int? currentOffset,
    String? errorMessage,
    String? successMessage,
    String? typeFilter,
    String? categoryFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
    String? searchQuery,
    bool? hasActiveFilters,
    bool clearTypeFilter = false,
    bool clearCategoryFilter = false,
    bool clearStartDateFilter = false,
    bool clearEndDateFilter = false,
    bool clearSearchQuery = false,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      typeFilter: clearTypeFilter ? null : (typeFilter ?? this.typeFilter),
      categoryFilter: clearCategoryFilter ? null : (categoryFilter ?? this.categoryFilter),
      startDateFilter: clearStartDateFilter ? null : (startDateFilter ?? this.startDateFilter),
      endDateFilter: clearEndDateFilter ? null : (endDateFilter ?? this.endDateFilter),
      searchQuery: clearSearchQuery ? null : (searchQuery ?? this.searchQuery),
      hasActiveFilters: hasActiveFilters ?? this.hasActiveFilters,
    );
  }

  @override
  List<Object?> get props => [
        status,
        transactions,
        hasMore,
        currentOffset,
        errorMessage,
        successMessage,
        typeFilter,
        categoryFilter,
        startDateFilter,
        endDateFilter,
        searchQuery,
        hasActiveFilters,
      ];
}
