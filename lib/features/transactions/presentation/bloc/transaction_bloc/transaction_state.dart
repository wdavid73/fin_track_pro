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

  const TransactionState({
    this.status = TransactionStatus.initial,
    this.transactions = const [],
    this.hasMore = false,
    this.currentOffset = 0,
    this.errorMessage,
    this.successMessage,
  });

  TransactionState copyWith({
    TransactionStatus? status,
    List<Transaction>? transactions,
    bool? hasMore,
    int? currentOffset,
    String? errorMessage,
    String? successMessage,
  }) {
    return TransactionState(
      status: status ?? this.status,
      transactions: transactions ?? this.transactions,
      hasMore: hasMore ?? this.hasMore,
      currentOffset: currentOffset ?? this.currentOffset,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
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
      ];
}
