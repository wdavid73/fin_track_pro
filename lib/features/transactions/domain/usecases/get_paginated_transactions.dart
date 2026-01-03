import 'package:injectable/injectable.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

@injectable
class GetPaginatedTransactions {
  final TransactionRepository _repository;

  GetPaginatedTransactions(this._repository);

  Future<List<Transaction>> call({
    required int limit,
    required int offset,
  }) async {
    return await _repository.getPaginatedTransactions(
      limit: limit,
      offset: offset,
    );
  }
}
