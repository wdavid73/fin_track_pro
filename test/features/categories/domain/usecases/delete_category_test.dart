import 'package:fin_track_pro/features/categories/domain/usecases/delete_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late DeleteCategoryUseCase useCase;
  late MockCategoryRepository mockRepository;

  setUp(() {
    mockRepository = MockCategoryRepository();
    useCase = DeleteCategoryUseCase(mockRepository);
  });

  group('DeleteCategory', () {
    const tCategoryId = '1';

    test('should delete category from repository', () async {
      // arrange
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenAnswer((_) async => {});

      // act
      await useCase(tCategoryId);

      // assert
      verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository fails', () async {
      // arrange
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenThrow(Exception('Failed to delete category'));

      // act & assert
      expect(() => useCase(tCategoryId), throwsException);
      verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
    });

    test('should throw exception when category does not exist', () async {
      // arrange
      when(
        () => mockRepository.deleteCategory(any()),
      ).thenThrow(Exception('Category not found'));

      // act & assert
      expect(() => useCase(tCategoryId), throwsException);
      verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
    });

    test(
      'should throw exception when category is being used by transactions',
      () async {
        // arrange
        when(() => mockRepository.deleteCategory(any())).thenThrow(
          Exception('Cannot delete category with existing transactions'),
        );

        // act & assert
        expect(() => useCase(tCategoryId), throwsException);
        verify(() => mockRepository.deleteCategory(tCategoryId)).called(1);
      },
    );
  });
}
