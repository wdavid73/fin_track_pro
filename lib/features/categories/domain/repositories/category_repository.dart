import '../entities/category.dart';

abstract class CategoryRepository {
  /// Sets the active user id for Firestore write-through sync.
  /// Pass `null` on logout to disable remote writes.
  void setUserId(String? userId);

  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoriesByType(String type);
  Future<Category?> getCategoryById(String id);
  Future<void> createCategory(Category category);
  Future<void> updateCategory(Category category);
  Future<void> deleteCategory(String id);
  Future<List<Category>> searchCategories(String query);
}
