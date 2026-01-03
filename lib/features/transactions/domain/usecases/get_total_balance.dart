import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case to calculate total balance
///
/// Calculates: sum(income transactions) - sum(expense transactions)
@injectable
class GetTotalBalance {
  final TransactionRepository repository;

  GetTotalBalance(this.repository);

  Future<double> call() async {
    final transactions = await repository.getTransactions();

    double totalIncome = 0.0;
    double totalExpense = 0.0;

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpense += transaction.amount;
      }
    }

    final balance = totalIncome - totalExpense;

    return balance;
  }
}
