import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../datasources/category_local_datasource.dart';
import '../datasources/category_remote_datasource.dart';

@LazySingleton(as: CategoryRepository)
class CategoryRepositoryImpl implements CategoryRepository {
  final CategoryLocalDataSource _localDataSource;
  final CategoryRemoteDataSource _remoteDataSource;

  String? _userId;

  CategoryRepositoryImpl(this._localDataSource, this._remoteDataSource);

  @override
  void setUserId(String? userId) => _userId = userId;

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
  Future<void> createCategory(Category category) async {
    final model = CategoryModel.fromEntity(
      category.copyWith(updatedAt: DateTime.now()),
    );
    await _localDataSource.createCategory(model);
    _syncWrite(() => _remoteDataSource.createCategory(_userId!, model));
  }

  @override
  Future<List<Category>> searchCategories(String query) async {
    final models = await _localDataSource.searchCategories(query);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _localDataSource.deleteCategory(id);
    _syncWrite(() => _remoteDataSource.deleteCategory(_userId!, id));
  }

  @override
  Future<void> updateCategory(Category category) async {
    final model = CategoryModel.fromEntity(
      category.copyWith(updatedAt: DateTime.now()),
    );
    await _localDataSource.updateCategory(model);
    _syncWrite(() => _remoteDataSource.updateCategory(_userId!, model));
  }

  /// Fire-and-forget write to Firestore. Errors are logged, never thrown,
  /// so a Firestore outage never surfaces in the UI (Hive is already
  /// the source of truth by the time this runs).
  void _syncWrite(Future<void> Function() operation) {
    if (_userId == null) return;
    operation().catchError((Object e, StackTrace stackTrace) {
      LoggerService().warning(
        'Firestore write failed: $e',
        tag: 'CategoryRepository',
        error: e,
        stackTrace: stackTrace,
      );
    });
  }
}
