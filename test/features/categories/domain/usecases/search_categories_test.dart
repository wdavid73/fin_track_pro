import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/search_categories_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late SearchCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = SearchCategoriesUseCase(mockRepository);
  });

  group('SearchCategories', () {
    const tCategories = [
      Category(
        id: '1',
        name: 'Groceries',
        icon: '🛒',
        color: 0xFF4CAF50,
        type: 'expense',
      ),
      Category(
        id: '2',
        name: 'Transport',
        icon: '🚗',
        color: 0xFF2196F3,
        type: 'expense',
      ),
      Category(
        id: '3',
        name: 'Entertainment',
        icon: '🎬',
        color: 0xFFE91E63,
        type: 'expense',
      ),
    ];

    test('should return categories that match the search query', () async {
      // arrange
      const tQuery = 'Groc';
      when(
        () => mockRepository.searchCategories(any()),
      ).thenAnswer((_) async => [tCategories[0]]);

      // act
      final result = await useCase(tQuery);

      // assert
      verify(() => mockRepository.searchCategories(tQuery)).called(1);
      expect(result, equals([tCategories[0]]));
    });

    test('should return all categories when query is empty', () async {
      // arrange
      const tQuery = '';
      when(
        () => mockRepository.searchCategories(any()),
      ).thenAnswer((_) async => tCategories);

      // act
      final result = await useCase(tQuery);

      // assert
      verify(() => mockRepository.searchCategories(tQuery)).called(1);
      expect(result, equals(tCategories));
    });

    test('should return empty list when no categories match', () async {
      // arrange
      const tQuery = 'NonExistent';
      when(
        () => mockRepository.searchCategories(any()),
      ).thenAnswer((_) async => []);

      // act
      final result = await useCase(tQuery);

      // assert
      verify(() => mockRepository.searchCategories(tQuery)).called(1);
      expect(result, isEmpty);
    });

    test('should be case insensitive when searching', () async {
      // arrange
      const tQuery = 'groc';
      when(
        () => mockRepository.searchCategories(any()),
      ).thenAnswer((_) async => [tCategories[0]]);

      // act
      final result = await useCase(tQuery);

      // assert
      verify(() => mockRepository.searchCategories(tQuery)).called(1);
      expect(result, equals([tCategories[0]]));
    });

    test('should throw exception when repository fails', () async {
      // arrange
      const tQuery = 'Groc';
      when(
        () => mockRepository.searchCategories(any()),
      ).thenThrow(Exception('Failed to search categories'));

      // act & assert
      expect(() => useCase(tQuery), throwsException);
      verify(() => mockRepository.searchCategories(tQuery)).called(1);
    });
  });
}
