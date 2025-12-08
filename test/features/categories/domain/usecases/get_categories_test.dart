import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_categories_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late GetCategoriesUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = GetCategoriesUseCase(mockRepository);
  });

  group('GetCategories', () {
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
        name: 'Salary',
        icon: '💼',
        color: 0xFF4CAF50,
        type: 'income',
      ),
    ];

    test('should return list of all categories from repository', () async {
      // arrange
      when(
        () => mockRepository.getCategories(),
      ).thenAnswer((_) async => tCategories);

      // act
      final result = await useCase();

      // assert
      verify(() => mockRepository.getCategories()).called(1);
      expect(result, equals(tCategories));
    });

    test('should return empty list when no categories exist', () async {
      // arrange
      when(() => mockRepository.getCategories()).thenAnswer((_) async => []);

      // act
      final result = await useCase();

      // assert
      verify(() => mockRepository.getCategories()).called(1);
      expect(result, isEmpty);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.getCategories(),
      ).thenThrow(Exception('Failed to get categories'));

      // act & assert
      expect(() => useCase(), throwsException);
      verify(() => mockRepository.getCategories()).called(1);
    });
  });
}
