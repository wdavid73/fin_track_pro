import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/categories/data/repositories/category_repository_impl.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockCategoryLocalDataSource();
    repository = CategoryRepositoryImpl(mockLocalDataSource);
  });

  const tCategoryModel = CategoryModel(
    id: '1',
    name: 'Food',
    icon: 'food_icon',
    color: 123,
    type: 'expense',
  );

  const tCategory = Category(
    id: '1',
    name: 'Food',
    icon: 'food_icon',
    color: 123,
    type: 'expense',
  );

  group('CategoryRepositoryImpl', () {
    group('getCategories', () {
      test('should return list of categories from local datasource', () async {
        // arrange
        when(
          () => mockLocalDataSource.getCategories(),
        ).thenAnswer((_) async => [tCategoryModel]);

        // act
        final result = await repository.getCategories();

        // assert
        verify(() => mockLocalDataSource.getCategories()).called(1);
        expect(result, equals([tCategory]));
      });

      test('should return empty list when datasource is empty', () async {
        // arrange
        when(
          () => mockLocalDataSource.getCategories(),
        ).thenAnswer((_) async => []);

        // act
        final result = await repository.getCategories();

        // assert
        verify(() => mockLocalDataSource.getCategories()).called(1);
        expect(result, isEmpty);
      });
    });

    group('getCategoriesByType', () {
      const tType = 'expense';

      test(
        'should return list of categories by type from local datasource',
        () async {
          // arrange
          when(
            () => mockLocalDataSource.getCategoriesByType(tType),
          ).thenAnswer((_) async => [tCategoryModel]);

          // act
          final result = await repository.getCategoriesByType(tType);

          // assert
          verify(
            () => mockLocalDataSource.getCategoriesByType(tType),
          ).called(1);
          expect(result, equals([tCategory]));
        },
      );
    });

    group('getCategoryById', () {
      const tId = '1';

      test('should return category when found in local datasource', () async {
        // arrange
        when(
          () => mockLocalDataSource.getCategoryById(tId),
        ).thenAnswer((_) async => tCategoryModel);

        // act
        final result = await repository.getCategoryById(tId);

        // assert
        verify(() => mockLocalDataSource.getCategoryById(tId)).called(1);
        expect(result, equals(tCategory));
      });

      test('should return null when not found in local datasource', () async {
        // arrange
        when(
          () => mockLocalDataSource.getCategoryById(tId),
        ).thenAnswer((_) async => null);

        // act
        final result = await repository.getCategoryById(tId);

        // assert
        verify(() => mockLocalDataSource.getCategoryById(tId)).called(1);
        expect(result, isNull);
      });
    });
  });
}
