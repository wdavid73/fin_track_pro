part of 'transaction_bloc.dart';

abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;

  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

class TransactionError extends TransactionState {
  final String message;

  const TransactionError(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionOperationSuccess extends TransactionState {
  final String message;

  const TransactionOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class TransactionPaginatedLoaded extends TransactionState {
  final List<Transaction> transactions;
  final bool hasMore;
  final int currentOffset;

  const TransactionPaginatedLoaded({
    required this.transactions,
    required this.hasMore,
    required this.currentOffset,
  });

  @override
  List<Object?> get props => [transactions, hasMore, currentOffset];

  TransactionPaginatedLoaded copyWith({
    List<Transaction>? transactions,
    bool? hasMore,
    int? currentOffset,
  }) {
    return TransactionPaginatedLoaded(
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
    );
  }
}
