import 'package:fin_track_pro/features/categories/data/datasources/category_local_datasource.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/usecases.dart';

import 'package:mocktail/mocktail.dart';

class MockCategoryLocalDataSource extends Mock
    implements CategoryLocalDataSource {}

class MockCategoryRepository extends Mock implements CategoryRepository {}

class MockGetCategoriesUseCase extends Mock implements GetCategoriesUseCase {}

class MockCreateCategoryUseCase extends Mock implements CreateCategoryUseCase {}

class MockUpdateCategoryUseCase extends Mock implements UpdateCategoryUseCase {}

class MockDeleteCategoryUseCase extends Mock implements DeleteCategoryUseCase {}

class MockSearchCategoriesUseCase extends Mock
    implements SearchCategoriesUseCase {}

class MockGetCategoryStatsUseCase extends Mock
    implements GetCategoryStatsUseCase {}
