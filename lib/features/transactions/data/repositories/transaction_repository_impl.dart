import 'package:injectable/injectable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../models/transaction_model.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;

  TransactionRepositoryImpl(this._localDataSource);

  @override
  Future<List<Transaction>> getTransactions() async {
    final models = await _localDataSource.getTransactions();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    final model = await _localDataSource.getTransactionById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _localDataSource.createTransaction(model);
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(transaction);
    await _localDataSource.updateTransaction(model);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _localDataSource.deleteTransaction(id);
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime start,
    DateTime end,
  ) async {
    final models = await _localDataSource.getTransactionsByDateRange(
      start,
      end,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByType(String type) async {
    final models = await _localDataSource.getTransactionsByType(type);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getPaginatedTransactions({
    required int limit,
    required int offset,
  }) async {
    final models = await _localDataSource.getPaginatedTransactions(
      limit: limit,
      offset: offset,
    );
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Transaction>> getTransactionsByCategoryId(
    String categoryId,
  ) async {
    final models = await _localDataSource.getTransactionsByCategoryId(
      categoryId,
    );
    return models.map((model) => model.toEntity()).toList();
  }
}
