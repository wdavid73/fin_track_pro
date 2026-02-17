import 'package:hive_ce/hive_ce.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';

/// Local datasource implementation using Hive
@LazySingleton(as: BudgetDatasource)
class BudgetLocalDatasource implements BudgetDatasource {
  final Box<BudgetModel> budgetBox;

  BudgetLocalDatasource(@Named('budgetBox') this.budgetBox);

  @override
  Future<List<BudgetModel>> getBudgets() async {
    return budgetBox.values.toList();
  }

  @override
  Future<BudgetModel?> getBudgetByCategoryId(String categoryId) async {
    return budgetBox.values.firstWhere(
      (budget) => budget.categoryId == categoryId,
      orElse: () => throw StateError('Budget not found'),
    );
  }

  @override
  Future<void> saveBudget(BudgetModel budget) async {
    await budgetBox.put(budget.id, budget);
  }

  @override
  Future<void> deleteBudget(String id) async {
    await budgetBox.delete(id);
  }
}
