import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';

/// Abstract datasource for budget operations
abstract class BudgetDatasource {
  /// Get all budgets
  Future<List<BudgetModel>> getBudgets();

  /// Get budget by category ID
  Future<BudgetModel?> getBudgetByCategoryId(String categoryId);

  /// Save or update a budget
  Future<void> saveBudget(BudgetModel budget);

  /// Delete a budget
  Future<void> deleteBudget(String id);
}
