import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';

/// Use case to get all categories
@injectable
class GetCategoriesUseCase {
  final CategoryRepository repository;

  GetCategoriesUseCase(this.repository);

  Future<List<Category>> call() async {
    return await repository.getCategories();
  }
}
