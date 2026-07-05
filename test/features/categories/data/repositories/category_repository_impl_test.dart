import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/categories/data/repositories/category_repository_impl.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late CategoryRepositoryImpl repository;
  late MockCategoryLocalDataSource mockLocalDataSource;
  late MockCategoryRemoteDataSource mockRemoteDataSource;

  final tUpdatedAt = DateTime(2026, 1, 1);

  final tCategoryModel = CategoryModel(
    id: '1',
    name: 'Food',
    icon: 'food_icon',
    color: 123,
    type: 'expense',
    updatedAt: tUpdatedAt,
  );

  final tCategory = Category(
    id: '1',
    name: 'Food',
    icon: 'food_icon',
    color: 123,
    type: 'expense',
    updatedAt: tUpdatedAt,
  );

  setUpAll(() {
    registerFallbackValue(tCategoryModel);
  });

  setUp(() {
    mockLocalDataSource = MockCategoryLocalDataSource();
    mockRemoteDataSource = MockCategoryRemoteDataSource();
    repository = CategoryRepositoryImpl(
      mockLocalDataSource,
      mockRemoteDataSource,
    );
  });

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

    group('createCategory', () {
      test('should call datasource to create category', () async {
        // arrange
        when(
          () => mockLocalDataSource.createCategory(any()),
        ).thenAnswer((_) async => {});

        // act

        await repository.createCategory(tCategory);

        // assert
        verify(() => mockLocalDataSource.createCategory(any())).called(1);
      });
    });

    group('setUserId / remote sync', () {
      setUpAll(() {
        registerFallbackValue(tCategoryModel);
      });

      test(
        'does not call remote data source when no user is set',
        () async {
          when(
            () => mockLocalDataSource.createCategory(any()),
          ).thenAnswer((_) async => {});

          await repository.createCategory(tCategory);
          await Future<void>.delayed(Duration.zero);

          verifyNever(
            () => mockRemoteDataSource.createCategory(any(), any()),
          );
        },
      );

      test(
        'calls remote data source with the user id once it is set',
        () async {
          when(
            () => mockLocalDataSource.createCategory(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockRemoteDataSource.createCategory(any(), any()),
          ).thenAnswer((_) async => {});

          repository.setUserId('user_123');
          await repository.createCategory(tCategory);
          await Future<void>.delayed(Duration.zero);

          verify(
            () => mockRemoteDataSource.createCategory('user_123', any()),
          ).called(1);
        },
      );

      test(
        'does not throw when the remote write fails (fire-and-forget)',
        () async {
          when(
            () => mockLocalDataSource.createCategory(any()),
          ).thenAnswer((_) async => {});
          when(
            () => mockRemoteDataSource.createCategory(any(), any()),
          ).thenAnswer((_) async => throw Exception('network error'));

          repository.setUserId('user_123');

          await expectLater(
            repository.createCategory(tCategory),
            completes,
          );
        },
      );
    });
  });
}
