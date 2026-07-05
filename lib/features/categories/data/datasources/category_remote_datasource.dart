import '../models/category_model.dart';

/// Abstract interface for the Firestore-backed category datasource.
///
/// Reads only return the full per-user collection (used for sync merges);
/// filtered reads (by type, id, search) stay local-only.
abstract class CategoryRemoteDataSource {
  Future<List<CategoryModel>> getCategories(String userId);
  Future<void> createCategory(String userId, CategoryModel category);
  Future<void> updateCategory(String userid, CategoryModel category);
  Future<void> deleteCategory(String userId, String id);
  Future<void> uploadAll(String userId, List<CategoryModel> categories);
  Future<void> deleteAll(String userId);
}
