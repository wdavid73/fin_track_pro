import '../models/transaction_model.dart';

/// Abstract interface for the Firestore-backed transaction datasource.
///
/// Reads only return the full per-user collection (used for sync merges);
/// filtered reads (by date range, type, pagination, category) stay local-only.
abstract class TransactionRemoteDataSource {
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<void> createTransaction(String userId, TransactionModel transaction);
  Future<void> updateTransaction(String userId, TransactionModel transaction);
  Future<void> deleteTransaction(String userId, String id);
  Future<void> uploadAll(String userId, List<TransactionModel> transactions);
  Future<void> deleteAll(String userId);
}
