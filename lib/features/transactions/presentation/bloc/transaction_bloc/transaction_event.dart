import 'package:equatable/equatable.dart';
import '../../../domain/entities/transaction.dart';

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
