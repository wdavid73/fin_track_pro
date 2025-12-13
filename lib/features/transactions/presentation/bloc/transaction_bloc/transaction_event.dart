part of 'transaction_bloc.dart';

abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

class CreateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const CreateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends TransactionEvent {
  final Transaction transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends TransactionEvent {
  final String id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class LoadPaginatedTransactions extends TransactionEvent {
  final int limit;

  const LoadPaginatedTransactions({this.limit = 15});

  @override
  List<Object?> get props => [limit];
}

class LoadMoreTransactions extends TransactionEvent {
  const LoadMoreTransactions();
}

class FilterTransactions extends TransactionEvent {
  final String? type; // 'income', 'expense', or null for all
  final String? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? searchQuery;

  const FilterTransactions({
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [type, categoryId, startDate, endDate, searchQuery];
}

class ClearFilters extends TransactionEvent {
  const ClearFilters();
}
