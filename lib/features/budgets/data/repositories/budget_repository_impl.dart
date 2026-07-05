import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';

/// Implementation of BudgetRepository
@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDatasource datasource;
  final BudgetRemoteDataSource _remoteDataSource;

  String? _userId;

  BudgetRepositoryImpl(this.datasource, this._remoteDataSource);

  @override
  void setUserId(String? userId) => _userId = userId;

  @override
  Future<List<Budget>> getBudgets() async {
    final models = await datasource.getBudgets();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Budget?> getBudgetByCategoryId(String categoryId) async {
    try {
      final model = await datasource.getBudgetByCategoryId(categoryId);
      return model?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> saveBudget(Budget budget) async {
    final model = BudgetModel.fromEntity(
      budget.copyWith(updatedAt: DateTime.now()),
    );
    await datasource.saveBudget(model);
    _syncWrite(() => _remoteDataSource.saveBudget(_userId!, model));
  }

  @override
  Future<void> deleteBudget(String id) async {
    await datasource.deleteBudget(id);
    _syncWrite(() => _remoteDataSource.deleteBudget(_userId!, id));
  }

  /// Fire-and-forget write to Firestore. Errors are logged, never thrown,
  /// so a Firestore outage never surfaces in the UI (Hive is already
  /// the source of truth by the time this runs).
  void _syncWrite(Future<void> Function() operation) {
    if (_userId == null) return;
    operation().catchError((Object e, StackTrace stackTrace) {
      LoggerService().warning(
        'Firestore write failed: $e',
        tag: 'BudgetRepository',
        error: e,
        stackTrace: stackTrace,
      );
    });
  }
}
