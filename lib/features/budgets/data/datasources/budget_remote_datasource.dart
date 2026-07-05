import '../models/budget_model.dart';

/// Abstract interface for the Firestore-backed budget datasource.
///
/// Reads only return the full per-user collection (used for sync merges);
/// filtered reads (by category) stay local-only.
abstract class BudgetRemoteDataSource {
  Future<List<BudgetModel>> getBudgets(String userId);
  Future<void> saveBudget(String userId, BudgetModel budget);
  Future<void> deleteBudget(String userId, String id);
  Future<void> uploadAll(String userId, List<BudgetModel> budgets);
  Future<void> deleteAll(String userId);
}
