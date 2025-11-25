import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case to get recent transactions
///
/// Returns the most recent N transactions ordered by date (newest first)
@injectable
class GetRecentTransactions {
  final TransactionRepository repository;

  GetRecentTransactions(this.repository);

  Future<List<Transaction>> call({int limit = 5}) async {
    final transactions = await repository.getTransactions();

    // Sort by date descending (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    // Take only the requested number
    final recentTransactions = transactions.take(limit).toList();

    return recentTransactions;
  }
}
