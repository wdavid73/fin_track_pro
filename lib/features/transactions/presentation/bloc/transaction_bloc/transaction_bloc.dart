import 'package:fin_track_pro/features/transactions/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

import 'transaction_event.dart';
import 'transaction_state.dart';

@injectable
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final GetTransactions _getTransactions;
  final CreateTransaction _createTransaction;
  final UpdateTransaction _updateTransaction;
  final DeleteTransaction _deleteTransaction;

  TransactionBloc(
    this._getTransactions,
    this._createTransaction,
    this._updateTransaction,
    this._deleteTransaction,
  ) : super(const TransactionInitial()) {
    on<LoadTransactions>(_onLoadTransactions);
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
      final transactions = await _getTransactions();
      emit(TransactionLoaded(transactions));
      emit(
        const TransactionOperationSuccess('Transaction created successfully'),
      );
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
      final transactions = await _getTransactions();
      emit(TransactionLoaded(transactions));
      emit(
        const TransactionOperationSuccess('Transaction updated successfully'),
      );
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
      final transactions = await _getTransactions();
      emit(TransactionLoaded(transactions));
      emit(
        const TransactionOperationSuccess('Transaction deleted successfully'),
      );
    } catch (e) {
      emit(TransactionError('Failed to delete transaction: ${e.toString()}'));
    }
  }
}
