import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/update_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late UpdateCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(
      Category(
        id: '',
        name: '',
        icon: '',
        color: 0,
        type: '',
        updatedAt: DateTime(2026, 1, 1),
      ),
    );
  });

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = UpdateCategoryUseCase(mockRepository);
  });

  group('UpdateCategory', () {
    final tCategory = Category(
      id: '1',
      name: 'Updated Groceries',
      icon: '🛒',
      color: 0xFF4CAF50,
      type: 'expense',
      updatedAt: DateTime(2026, 1, 1),
    );

    test('should update category in repository', () async {
      // arrange
      when(
        () => mockRepository.updateCategory(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(tCategory);

      // assert
      verify(() => mockRepository.updateCategory(tCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.updateCategory(any()),
      ).thenThrow(Exception('Failed to update category'));

      // act & assert
      expect(() => useCase(tCategory), throwsException);
      verify(() => mockRepository.updateCategory(tCategory)).called(1);
    });

    test('should throw exception when category does not exist', () async {
      // arrange
      when(
        () => mockRepository.updateCategory(any()),
      ).thenThrow(Exception('Category not found'));

      // act & assert
      expect(() => useCase(tCategory), throwsException);
      verify(() => mockRepository.updateCategory(tCategory)).called(1);
    });
  });
}
