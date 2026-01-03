import '../models/transaction_model.dart';

/// Abstract interface for Transaction data sources
/// This allows for multiple implementations (local, remote, etc.)
abstract class TransactionDataSource {
  Future<List<TransactionModel>> getTransactions();
  Future<TransactionModel?> getTransactionById(String id);
  Future<void> createTransaction(TransactionModel transaction);
  Future<void> updateTransaction(TransactionModel transaction);
  Future<void> deleteTransaction(String id);
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<TransactionModel>> getTransactionsByType(String type);
  Future<List<TransactionModel>> getPaginatedTransactions({
    required int limit,
    required int offset,
  });
  Future<List<TransactionModel>> getTransactionsByCategoryId(String categoryId);
}
