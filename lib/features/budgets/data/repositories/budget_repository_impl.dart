import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';

/// Implementation of BudgetRepository
@LazySingleton(as: BudgetRepository)
class BudgetRepositoryImpl implements BudgetRepository {
  final BudgetDatasource datasource;

  BudgetRepositoryImpl(this.datasource);

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
    final model = BudgetModel.fromEntity(budget);
    await datasource.saveBudget(model);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await datasource.deleteBudget(id);
  }
}
