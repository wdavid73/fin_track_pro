import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:injectable/injectable.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;

  CategoryRepositoryImpl(this._localDataSource);

  @override
  Future<List<Category>> getCategories() async {
    final models = await _localDataSource.getCategories();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Category>> getCategoriesByType(String type) async {
    final models = await _localDataSource.getCategoriesByType(type);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Category?> getCategoryById(String id) async {
    final model = await _localDataSource.getCategoryById(id);
    return model?.toEntity();
  }

  @override
  Future<void> createCategory(Category category) {
    final model = CategoryModel.fromEntity(category);
    return _localDataSource.createCategory(model);
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    final models = await _localDataSource.searchCategories(query);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteCategory(String id) {
    return _localDataSource.deleteCategory(id);
  }

  @override
  Future<void> updateCategory(Category category) {
    final model = CategoryModel.fromEntity(category);
    return _localDataSource.updateCategory(model);
  }
}
