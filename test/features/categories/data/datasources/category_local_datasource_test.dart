import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/features/categories/data/datasources/category_local_datasource.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveService extends Mock implements HiveService {}

class MockBox extends Mock implements Box<CategoryModel> {}

void main() {
  late CategoryLocalDataSource datasource;
  late MockHiveService mockHiveService;
  late MockBox mockBox;

  setUpAll(() {
    registerFallbackValue(
      const CategoryModel(
        id: 'fallback',
        name: 'Fallback',
        icon: 'icon',
        color: 0,
        type: 'expense',
      ),
    );
  });

  setUp(() {
    mockHiveService = MockHiveService();
    mockBox = MockBox();
    datasource = CategoryLocalDataSource(mockHiveService);

    when(
      () => mockHiveService.getBox(HiveService.categoriesBox),
    ).thenReturn(mockBox);
  });

  const tCategoryModel = CategoryModel(
    id: '1',
    name: 'Food',
    icon: '🍔',
    color: 123,
    type: 'expense',
  );

  const tCategoryModel2 = CategoryModel(
    id: '2',
    name: 'Salary',
    icon: '💼',
    color: 456,
    type: 'income',
  );

  group('CategoryLocalDataSource', () {
    group('getCategories', () {
      test(
        'should return list of categories from box when box is not empty',
        () async {
          // arrange
          when(() => mockBox.isEmpty).thenReturn(false);
          when(() => mockBox.values).thenReturn([tCategoryModel]);

          // act
          final result = await datasource.getCategories();

          // assert
          verify(
            () => mockHiveService.getBox(HiveService.categoriesBox),
          ).called(1);
          verify(() => mockBox.isEmpty).called(1);
          expect(result, equals([tCategoryModel]));
        },
      );

      test('should seed default categories when box is empty', () async {
        // arrange
        when(() => mockBox.isEmpty).thenReturn(true);
        when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});
        when(() => mockBox.values).thenReturn([]);

        // act
        final result = await datasource.getCategories();

        // assert
        verify(() => mockBox.isEmpty).called(1);
        // Verify that default categories were seeded (12 default categories)
        verify(() => mockBox.put(any(), any())).called(12);
        expect(result, isA<List<CategoryModel>>());
      });
    });

    group('getCategoriesByType', () {
      test('should return only expense categories', () async {
        // arrange
        when(
          () => mockBox.values,
        ).thenReturn([tCategoryModel, tCategoryModel2]);

        // act
        final result = await datasource.getCategoriesByType('expense');

        // assert
        verify(
          () => mockHiveService.getBox(HiveService.categoriesBox),
        ).called(1);
        expect(result, equals([tCategoryModel]));
        expect(result.length, 1);
        expect(result.first.type, 'expense');
      });

      test('should return only income categories', () async {
        // arrange
        when(
          () => mockBox.values,
        ).thenReturn([tCategoryModel, tCategoryModel2]);

        // act
        final result = await datasource.getCategoriesByType('income');

        // assert
        expect(result, equals([tCategoryModel2]));
        expect(result.length, 1);
        expect(result.first.type, 'income');
      });

      test('should return empty list when no categories match type', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tCategoryModel]);

        // act
        final result = await datasource.getCategoriesByType('income');

        // assert
        expect(result, isEmpty);
      });
    });

    group('getCategoryById', () {
      test('should return category when found', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tCategoryModel]);

        // act
        final result = await datasource.getCategoryById('1');

        // assert
        verify(
          () => mockHiveService.getBox(HiveService.categoriesBox),
        ).called(1);
        expect(result, equals(tCategoryModel));
      });

      test('should throw Exception when category not found', () async {
        // arrange
        when(() => mockBox.values).thenReturn([]);

        // act
        final call = datasource.getCategoryById;

        // assert
        expect(() => call('1'), throwsA(isA<Exception>()));
      });

      test(
        'should return correct category when multiple categories exist',
        () async {
          // arrange
          when(
            () => mockBox.values,
          ).thenReturn([tCategoryModel, tCategoryModel2]);

          // act
          final result = await datasource.getCategoryById('2');

          // assert
          expect(result, equals(tCategoryModel2));
          expect(result?.id, '2');
        },
      );
    });

    group('createCategory', () {
      const tCategory = CategoryModel(
        id: '1',
        name: 'Food',
        icon: '🍔',
        color: 123,
        type: 'expense',
      );
      test('should add category to Hive box', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

        // act
        await datasource.createCategory(tCategory);

        // assert
        verify(() => mockBox.put(tCategory.id, tCategory)).called(1);
      });
    });
  });
}
