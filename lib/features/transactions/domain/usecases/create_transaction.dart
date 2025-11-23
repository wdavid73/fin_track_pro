import 'package:injectable/injectable.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

@injectable
class CreateTransaction {
  final TransactionRepository _repository;

  CreateTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    await _repository.createTransaction(transaction);
  }
}
