import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'transaction_event.dart';
part 'transaction_state.dart';

/// BLoC for managing transaction-related operations
/// Singleton to ensure single instance across the app
@singleton
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;
  final GetPaginatedTransactions _getPaginatedTransactions;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionBloc(
    this._getTransactions,
    this._getPaginatedTransactions,
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
  ) : super(const TransactionState()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadPaginatedTransactions>(_onLoadPaginatedTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
    on<FilterTransactions>(_onFilterTransactions);
    on<ClearFilters>(_onClearFilters);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final transactions = await _getTransactions();
      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: transactions,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to load transactions: ${e.toString()}',
      ));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      await _createTransaction(event.transaction);
      emit(state.copyWith(
        status: TransactionStatus.success,
        successMessage: 'Transaction created successfully',
      ));
      add(const LoadPaginatedTransactions());
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to create transaction: ${e.toString()}',
      ));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      await _updateTransaction(event.transaction);
      emit(state.copyWith(
        status: TransactionStatus.success,
        successMessage: 'Transaction updated successfully',
      ));
      add(const LoadPaginatedTransactions());
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to update transaction: ${e.toString()}',
      ));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      await _deleteTransaction(event.id);
      emit(state.copyWith(
        status: TransactionStatus.success,
        successMessage: 'Transaction deleted successfully',
      ));
      add(const LoadPaginatedTransactions());
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to delete transaction: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadPaginatedTransactions(
    LoadPaginatedTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));
    try {
      final transactions = await _getPaginatedTransactions(
        limit: event.limit,
        offset: 0,
      );
      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: transactions,
        hasMore: transactions.length >= event.limit,
        currentOffset: transactions.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to load transactions: ${e.toString()}',
      ));
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    if (!state.hasMore) {
      return;
    }

    try {
      final newTransactions = await _getPaginatedTransactions(
        limit: 15,
        offset: state.currentOffset,
      );

      // Apply filters if active
      final filteredTransactions = _applyFilters(newTransactions);

      emit(state.copyWith(
        transactions: [...state.transactions, ...filteredTransactions],
        hasMore: newTransactions.length >= 15,
        currentOffset: state.currentOffset + newTransactions.length,
      ));
    } catch (e) {
      // Keep current state on error, just don't load more
    }
  }

  Future<void> _onFilterTransactions(
    FilterTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(status: TransactionStatus.loading));

    try {
      // Determine if there are active filters
      final hasFilters = event.type != null ||
          event.categoryId != null ||
          event.startDate != null ||
          event.endDate != null ||
          (event.searchQuery != null && event.searchQuery!.isNotEmpty);

      // Update filter state
      emit(state.copyWith(
        typeFilter: event.type,
        categoryFilter: event.categoryId,
        startDateFilter: event.startDate,
        endDateFilter: event.endDate,
        searchQuery: event.searchQuery,
        hasActiveFilters: hasFilters,
        clearTypeFilter: event.type == null,
        clearCategoryFilter: event.categoryId == null,
        clearStartDateFilter: event.startDate == null,
        clearEndDateFilter: event.endDate == null,
        clearSearchQuery: event.searchQuery == null || event.searchQuery!.isEmpty,
      ));

      // Reload transactions with filters
      final transactions = await _getTransactions();
      final filteredTransactions = _applyFilters(transactions);

      emit(state.copyWith(
        status: TransactionStatus.success,
        transactions: filteredTransactions,
        hasMore: false, // Disable pagination when filtering
        currentOffset: filteredTransactions.length,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TransactionStatus.error,
        errorMessage: 'Failed to filter transactions: ${e.toString()}',
      ));
    }
  }

  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<TransactionState> emit,
  ) async {
    emit(state.copyWith(
      clearTypeFilter: true,
      clearCategoryFilter: true,
      clearStartDateFilter: true,
      clearEndDateFilter: true,
      clearSearchQuery: true,
      hasActiveFilters: false,
    ));

    // Reload all transactions
    add(const LoadPaginatedTransactions());
  }

  /// Apply filters to a list of transactions
  List<Transaction> _applyFilters(List<Transaction> transactions) {
    var filtered = transactions;

    // Filter by type
    if (state.typeFilter != null) {
      filtered = filtered.where((t) => t.type == state.typeFilter).toList();
    }

    // Filter by category
    if (state.categoryFilter != null) {
      filtered = filtered.where((t) => t.categoryId == state.categoryFilter).toList();
    }

    // Filter by date range
    if (state.startDateFilter != null) {
      filtered = filtered.where((t) =>
        t.date.isAfter(state.startDateFilter!) ||
        t.date.isAtSameMomentAs(state.startDateFilter!)
      ).toList();
    }

    if (state.endDateFilter != null) {
      final endOfDay = DateTime(
        state.endDateFilter!.year,
        state.endDateFilter!.month,
        state.endDateFilter!.day,
        23,
        59,
        59,
      );
      filtered = filtered.where((t) =>
        t.date.isBefore(endOfDay) ||
        t.date.isAtSameMomentAs(endOfDay)
      ).toList();
    }

    // Filter by search query
    if (state.searchQuery != null && state.searchQuery!.isNotEmpty) {
      final query = state.searchQuery!.toLowerCase();
      filtered = filtered.where((t) {
        final note = t.note?.toLowerCase() ?? '';
        return note.contains(query);
      }).toList();
    }

    return filtered;
  }
}
