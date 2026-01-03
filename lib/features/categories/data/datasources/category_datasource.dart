import '../models/category_model.dart';

/// Abstract interface for Category data sources
/// This allows for multiple implementations (local, remote, etc.)
abstract class CategoryDataSource {
  Future<List<CategoryModel>> getCategories();
  Future<List<CategoryModel>> getCategoriesByType(String type);
  Future<CategoryModel?> getCategoryById(String id);
  Future<void> createCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
  Future<List<CategoryModel>> searchCategories(String query);
}
