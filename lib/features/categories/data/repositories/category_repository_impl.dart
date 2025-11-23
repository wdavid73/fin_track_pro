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
}
