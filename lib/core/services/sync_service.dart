import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/services/last_write_wins_merger.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fin_track_pro/features/categories/data/datasources/category_local_datasource.dart';
import 'package:fin_track_pro/features/categories/data/datasources/category_remote_datasource.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/transaction_remote_datasource.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';

/// Coordinates Firestore cloud sync on login/logout.
///
/// Hive stays the source of truth for reads at all times; this only runs
/// a one-shot Last-Write-Wins merge on login and toggles the write-through
/// sync on the 3 repositories via `setUserId`.
@lazySingleton
class SyncService {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;
  final BudgetRepository _budgetRepository;

  final TransactionLocalDataSource _transactionLocal;
  final TransactionRemoteDataSource _transactionRemote;
  final CategoryLocalDataSource _categoryLocal;
  final CategoryRemoteDataSource _categoryRemote;
  final BudgetDatasource _budgetLocal;
  final BudgetRemoteDataSource _budgetRemote;

  final HiveService _hiveService;

  SyncService(
    this._transactionRepository,
    this._categoryRepository,
    this._budgetRepository,
    this._transactionLocal,
    this._transactionRemote,
    this._categoryLocal,
    this._categoryRemote,
    this._budgetLocal,
    this._budgetRemote,
    this._hiveService,
  );

  /// Enables remote write-through and merges cloud data with what's on this
  /// device. Never throws: a failed sync leaves the local data intact and
  /// is only logged, so login always succeeds even if offline.
  Future<void> onLogin(String userId) async {
    _transactionRepository.setUserId(userId);
    _categoryRepository.setUserId(userId);
    _budgetRepository.setUserId(userId);

    try {
      await Future.wait([
        _syncTransactions(userId),
        _syncCategories(userId),
        _syncBudgets(userId),
      ]);
    } catch (e, stackTrace) {
      LoggerService().warning(
        'Firestore sync on login failed: $e',
        tag: 'SyncService',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  /// Disables remote write-through. Optionally clears local `transactions`
  /// and `budgets` (kept: `categories`, `settings`) so the next user on this
  /// device doesn't see the previous user's data.
  Future<void> onLogout({bool clearLocalData = false}) async {
    _transactionRepository.setUserId(null);
    _categoryRepository.setUserId(null);
    _budgetRepository.setUserId(null);

    if (clearLocalData) {
      await _hiveService.getBox(HiveService.transactionsBox).clear();
      await _hiveService.getBox(HiveService.budgetsBox).clear();
    }
  }

  Future<void> _syncTransactions(String userId) async {
    final local = await _transactionLocal.getTransactions();
    final remote = await _transactionRemote.getTransactions(userId);
    final result = LastWriteWinsMerger.merge(
      local: local,
      remote: remote,
      idOf: (t) => t.id,
      updatedAtOf: (t) => t.updatedAt,
    );

    for (final model in result.toSaveLocally) {
      await _transactionLocal.updateTransaction(model);
    }
    if (result.toUploadRemote.isNotEmpty) {
      await _transactionRemote.uploadAll(userId, result.toUploadRemote);
    }
  }

  Future<void> _syncCategories(String userId) async {
    final local = await _categoryLocal.getCategories();
    final remote = await _categoryRemote.getCategories(userId);
    final result = LastWriteWinsMerger.merge(
      local: local,
      remote: remote,
      idOf: (c) => c.id,
      updatedAtOf: (c) => c.updatedAt,
    );

    for (final model in result.toSaveLocally) {
      await _categoryLocal.updateCategory(model);
    }
    if (result.toUploadRemote.isNotEmpty) {
      await _categoryRemote.uploadAll(userId, result.toUploadRemote);
    }
  }

  Future<void> _syncBudgets(String userId) async {
    final local = await _budgetLocal.getBudgets();
    final remote = await _budgetRemote.getBudgets(userId);
    final result = LastWriteWinsMerger.merge(
      local: local,
      remote: remote,
      idOf: (b) => b.id,
      updatedAtOf: (b) => b.updatedAt,
    );

    for (final model in result.toSaveLocally) {
      await _budgetLocal.saveBudget(model);
    }
    if (result.toUploadRemote.isNotEmpty) {
      await _budgetRemote.uploadAll(userId, result.toUploadRemote);
    }
  }
}
