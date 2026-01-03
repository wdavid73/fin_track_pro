import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class UpdateCategoryUseCase {
  final CategoryRepository repository;

  UpdateCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.updateCategory(category);
  }
}
