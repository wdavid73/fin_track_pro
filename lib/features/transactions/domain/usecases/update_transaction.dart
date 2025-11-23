import 'package:injectable/injectable.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

@injectable
class UpdateTransaction {
  final TransactionRepository _repository;

  UpdateTransaction(this._repository);

  Future<void> call(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
  }
}
