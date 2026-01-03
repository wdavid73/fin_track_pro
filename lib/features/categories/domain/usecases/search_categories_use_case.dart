import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class SearchCategoriesUseCase {
  final CategoryRepository repository;

  SearchCategoriesUseCase(this.repository);

  Future<List<Category>> call(String query) async {
    return await repository.searchCategories(query);
  }
}
