import 'package:injectable/injectable.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

@injectable
class GetTransactions {
  final TransactionRepository _repository;

  GetTransactions(this._repository);

  Future<List<Transaction>> call() async {
    return await _repository.getTransactions();
  }
}
