import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import '../models/transaction_model.dart';
import 'transaction_datasource.dart';

@injectable
class TransactionLocalDataSource implements TransactionDataSource {
  final HiveService _hiveService;

  TransactionLocalDataSource(this._hiveService);

  @override
  Future<List<TransactionModel>> getTransactions() async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    final transactions = box.values.cast<TransactionModel>().toList();

    // Sort by date descending (newest first)
    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    return box.get(id);
  }

  @override
  Future<void> createTransaction(TransactionModel transaction) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    await box.put(transaction.id, transaction);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    await box.put(transaction.id, transaction);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    await box.delete(id);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    final transactions = box.values
        .cast<TransactionModel>()
        .where((t) => t.date.isAfter(start) && t.date.isBefore(end))
        .toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Future<List<TransactionModel>> getTransactionsByType(String type) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    final transactions = box.values
        .cast<TransactionModel>()
        .where((t) => t.type == type)
        .toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }

  @override
  Future<List<TransactionModel>> getPaginatedTransactions({
    required int limit,
    required int offset,
  }) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    final allTransactions = box.values.cast<TransactionModel>().toList();

    // Sort by date descending (newest first)
    allTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Apply pagination
    final startIndex = offset;
    final endIndex = offset + limit;

    if (startIndex >= allTransactions.length) {
      return [];
    }

    final paginatedTransactions = allTransactions.sublist(
      startIndex,
      endIndex > allTransactions.length ? allTransactions.length : endIndex,
    );

    return paginatedTransactions;
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCategoryId(
    String categoryId,
  ) async {
    final box = _hiveService.getBox(HiveService.transactionsBox);
    final transactions = box.values
        .cast<TransactionModel>()
        .where((t) => t.categoryId == categoryId)
        .toList();

    transactions.sort((a, b) => b.date.compareTo(a.date));

    return transactions;
  }
}
