import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';

/// Repository interface for budget operations
abstract class BudgetRepository {
  /// Sets the active user id for Firestore write-through sync.
  /// Pass `null` on logout to disable remote writes.
  void setUserId(String? userId);

  /// Get all budgets
  Future<List<Budget>> getBudgets();

  /// Get budget by category ID
  Future<Budget?> getBudgetByCategoryId(String categoryId);

  /// Save or update a budget
  Future<void> saveBudget(Budget budget);

  /// Delete a budget
  Future<void> deleteBudget(String id);
}
