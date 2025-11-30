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
  ) : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
    on<LoadPaginatedTransactions>(_onLoadPaginatedTransactions);
    on<LoadMoreTransactions>(_onLoadMoreTransactions);
    on<CreateTransactionEvent>(_onCreateTransaction);
    on<UpdateTransactionEvent>(_onUpdateTransaction);
    on<DeleteTransactionEvent>(_onDeleteTransaction);
  }

  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final transactions = await _getTransactions();
      emit(TransactionLoaded(transactions));
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onCreateTransaction(
    CreateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      await _createTransaction(event.transaction);
      emit(
        const TransactionOperationSuccess('Transaction created successfully'),
      );
      add(const LoadPaginatedTransactions());
    } catch (e) {
      emit(TransactionError('Failed to create transaction: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateTransaction(
    UpdateTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      await _updateTransaction(event.transaction);
      emit(
        const TransactionOperationSuccess('Transaction updated successfully'),
      );
      add(const LoadPaginatedTransactions());
    } catch (e) {
      emit(TransactionError('Failed to update transaction: ${e.toString()}'));
    }
  }

  Future<void> _onDeleteTransaction(
    DeleteTransactionEvent event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      await _deleteTransaction(event.id);
      emit(
        const TransactionOperationSuccess('Transaction deleted successfully'),
      );
      add(const LoadPaginatedTransactions());
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    }
  }

  Future<void> _onLoadPaginatedTransactions(
    LoadPaginatedTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());
    try {
      final transactions = await _getPaginatedTransactions(
        limit: event.limit,
        offset: 0,
      );
      emit(
        TransactionPaginatedLoaded(
          transactions: transactions,
          hasMore: transactions.length >= event.limit,
          currentOffset: transactions.length,
        ),
      );
    } catch (e) {
      emit(TransactionError('Failed to load transactions: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMoreTransactions(
    LoadMoreTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    final currentState = state;
    if (currentState is! TransactionPaginatedLoaded || !currentState.hasMore) {
      return;
    }

    try {
      final newTransactions = await _getPaginatedTransactions(
        limit: 15,
        offset: currentState.currentOffset,
      );

      emit(
        currentState.copyWith(
          transactions: [...currentState.transactions, ...newTransactions],
          hasMore: newTransactions.length >= 15,
          currentOffset: currentState.currentOffset + newTransactions.length,
        ),
      );
    } catch (e) {
      // Keep current state on error, just don't load more
    }
  }
}
