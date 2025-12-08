import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class DeleteCategoryUseCase {
  final CategoryRepository repository;

  DeleteCategoryUseCase(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteCategory(id);
  }
}
