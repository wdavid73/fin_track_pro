import '../entities/transaction.dart';

abstract class TransactionRepository {
  /// Sets the active user id for Firestore write-through sync.
  /// Pass `null` on logout to disable remote writes.
  void setUserId(String? userId);

  Future<List<Transaction>> getTransactions();
  Future<Transaction?> getTransactionById(String id);
  Future<void> createTransaction(Transaction transaction);
  Future<void> updateTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  );
  Future<List<Transaction>> getTransactionsByType(String type);
  Future<List<Transaction>> getPaginatedTransactions({
    required int limit,
    required int offset,
  });
  Future<List<Transaction>> getTransactionsByCategoryId(String categoryId);
}
