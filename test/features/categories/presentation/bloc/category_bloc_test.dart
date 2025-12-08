import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late CategoryBloc bloc;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockUpdateCategoryUseCase mockUpdateCategory;
  late MockDeleteCategoryUseCase mockDeleteCategory;
  late MockSearchCategoriesUseCase mockSearchCategories;

  setUp(() {
    mockGetCategories = MockGetCategoriesUseCase();
    mockCreateCategory = MockCreateCategoryUseCase();
    mockUpdateCategory = MockUpdateCategoryUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();
    mockSearchCategories = MockSearchCategoriesUseCase();

    bloc = CategoryBloc(
      getCategories: mockGetCategories,
      createCategory: mockCreateCategory,
      updateCategory: mockUpdateCategory,
      deleteCategory: mockDeleteCategory,
      searchCategories: mockSearchCategories,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('CategoryBloc', () {
    test('initial state should be CategoryInitial', () {
      expect(bloc.state, const CategoryInitial());
    });

    group('LoadCategories', () {
      const tCategories = [
        Category(id: '', name: '', icon: '', color: 0, type: 'expense'),
      ];
      blocTest(
        'should emit [Loading, Loaded] when data is gotten successfully',
        build: () {
          when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoriesEvent()),
        expect: () => [CategoryLoading(), const CategoryLoaded(tCategories)],
        verify: (_) {
          verify(() => mockGetCategories()).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when data is gotten successfully',
        build: () {
          when(() => mockGetCategories()).thenThrow(Exception('Error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoriesEvent()),
        expect: () => [
          CategoryLoading(),
          const CategoryError('Exception: Error'),
        ],
        verify: (_) {
          verify(() => mockGetCategories()).called(1);
        },
      );
    });

    group('CreateCategoryEvent', () {
      final tCategory = const Category(
        id: '1',
        name: 'test',
        icon: 'test',
        color: 0,
        type: 'expense',
      );

      setUpAll(() {
        registerFallbackValue(tCategory);
      });

      blocTest(
        'should emit [Loading, Success] when data is created successfully',
        build: () {
          when(() => mockCreateCategory(any())).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(CreateCategoryEvent(tCategory)),
        expect: () => [
          CategoryLoading(),
          const CategoryOperationSuccess('Category created successfully'),
        ],
        verify: (_) {
          verify(() => mockCreateCategory(tCategory)).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when creation fails',
        build: () {
          when(() => mockCreateCategory(any()))
              .thenThrow(Exception('Failed to create'));
          return bloc;
        },
        act: (bloc) => bloc.add(CreateCategoryEvent(tCategory)),
        expect: () => [
          CategoryLoading(),
          const CategoryError('Exception: Failed to create'),
        ],
        verify: (_) {
          verify(() => mockCreateCategory(tCategory)).called(1);
        },
      );
    });

    group('UpdateCategoryEvent', () {
      final tCategory = const Category(
        id: '1',
        name: 'Updated Category',
        icon: 'icon',
        color: 0,
        type: 'expense',
      );

      setUpAll(() {
        registerFallbackValue(tCategory);
      });

      blocTest(
        'should emit [Loading, Success] when category is updated successfully',
        build: () {
          when(() => mockUpdateCategory(any())).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateCategoryEvent(tCategory)),
        expect: () => [
          CategoryLoading(),
          const CategoryOperationSuccess('Category updated successfully'),
        ],
        verify: (_) {
          verify(() => mockUpdateCategory(tCategory)).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when update fails',
        build: () {
          when(() => mockUpdateCategory(any()))
              .thenThrow(Exception('Failed to update'));
          return bloc;
        },
        act: (bloc) => bloc.add(UpdateCategoryEvent(tCategory)),
        expect: () => [
          CategoryLoading(),
          const CategoryError('Exception: Failed to update'),
        ],
        verify: (_) {
          verify(() => mockUpdateCategory(tCategory)).called(1);
        },
      );
    });

    group('DeleteCategoryEvent', () {
      const tCategoryId = '1';

      setUpAll(() {
        registerFallbackValue(tCategoryId);
      });

      blocTest(
        'should emit [Loading, Success] when category is deleted successfully',
        build: () {
          when(() => mockDeleteCategory(any())).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCategoryEvent(tCategoryId)),
        expect: () => [
          CategoryLoading(),
          const CategoryOperationSuccess('Category deleted successfully'),
        ],
        verify: (_) {
          verify(() => mockDeleteCategory(tCategoryId)).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when deletion fails',
        build: () {
          when(() => mockDeleteCategory(any()))
              .thenThrow(Exception('Failed to delete'));
          return bloc;
        },
        act: (bloc) => bloc.add(const DeleteCategoryEvent(tCategoryId)),
        expect: () => [
          CategoryLoading(),
          const CategoryError('Exception: Failed to delete'),
        ],
        verify: (_) {
          verify(() => mockDeleteCategory(tCategoryId)).called(1);
        },
      );
    });

    group('SearchCategoriesEvent', () {
      const tQuery = 'Food';
      const tCategories = [
        Category(
          id: '1',
          name: 'Food & Dining',
          icon: 'icon',
          color: 0,
          type: 'expense',
        ),
      ];

      setUpAll(() {
        registerFallbackValue(tQuery);
      });

      blocTest(
        'should emit [Loading, Loaded] when search is successful',
        build: () {
          when(() => mockSearchCategories(any()))
              .thenAnswer((_) async => tCategories);
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchCategoriesEvent(tQuery)),
        expect: () => [
          CategoryLoading(),
          const CategoryLoaded(tCategories),
        ],
        verify: (_) {
          verify(() => mockSearchCategories(tQuery)).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when search fails',
        build: () {
          when(() => mockSearchCategories(any()))
              .thenThrow(Exception('Search failed'));
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchCategoriesEvent(tQuery)),
        expect: () => [
          CategoryLoading(),
          const CategoryError('Exception: Search failed'),
        ],
        verify: (_) {
          verify(() => mockSearchCategories(tQuery)).called(1);
        },
      );
    });
  });
}
