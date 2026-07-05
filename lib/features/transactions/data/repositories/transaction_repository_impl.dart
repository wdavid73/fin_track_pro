import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_local_datasource.dart';
import '../datasources/transaction_remote_datasource.dart';
import '../models/transaction_model.dart';

@LazySingleton(as: TransactionRepository)
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource _localDataSource;
  final TransactionRemoteDataSource _remoteDataSource;

  String? _userId;

  TransactionRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  void setUserId(String? userId) => _userId = userId;

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
    final model = TransactionModel.fromEntity(
      transaction.copyWith(updatedAt: DateTime.now()),
    );
    await _localDataSource.createTransaction(model);
    _syncWrite(() => _remoteDataSource.createTransaction(_userId!, model));
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    final model = TransactionModel.fromEntity(
      transaction.copyWith(updatedAt: DateTime.now()),
    );
    await _localDataSource.updateTransaction(model);
    _syncWrite(() => _remoteDataSource.updateTransaction(_userId!, model));
  }

  @override
  Future<void> deleteTransaction(String id) async {
    await _localDataSource.deleteTransaction(id);
    _syncWrite(() => _remoteDataSource.deleteTransaction(_userId!, id));
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

  /// Fire-and-forget write to Firestore. Errors are logged, never thrown,
  /// so a Firestore outage never surfaces in the UI (Hive is already
  /// the source of truth by the time this runs).
  void _syncWrite(Future<void> Function() operation) {
    if (_userId == null) return;
    operation().catchError((Object e, StackTrace stackTrace) {
      LoggerService().warning(
        'Firestore write failed: $e',
        tag: 'TransactionRepository',
        error: e,
        stackTrace: stackTrace,
      );
    });
  }
}
