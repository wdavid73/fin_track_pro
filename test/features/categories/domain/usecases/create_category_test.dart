import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/create_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late CreateCategoryUseCase useCase;
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
    useCase = CreateCategoryUseCase(mockRepository);
  });

  group('CreateCategory', () {
    final tCategory = Category(
      id: '1',
      name: 'Groceries',
      icon: '🛒',
      color: 0xFF4CAF50,
      type: 'expense',
      updatedAt: DateTime(2026, 1, 1),
    );

    test('should create category in repository', () async {
      // arrange
      when(
        () => mockRepository.createCategory(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(tCategory);

      // assert
      verify(() => mockRepository.createCategory(tCategory)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.createCategory(any()),
      ).thenThrow(Exception('Failed to create category'));

      // act & assert
      expect(() => useCase(tCategory), throwsException);
      verify(() => mockRepository.createCategory(tCategory)).called(1);
    });
  });
}
