import 'package:injectable/injectable.dart';

import '../entities/category.dart';
import '../repositories/category_repository.dart';

@injectable
class CreateCategoryUseCase {
  final CategoryRepository repository;

  CreateCategoryUseCase(this.repository);

  Future<void> call(Category category) async {
    return await repository.createCategory(category);
  }
}
