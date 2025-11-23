import '../entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<List<Category>> getCategoriesByType(String type);
  Future<Category?> getCategoryById(String id);
}
