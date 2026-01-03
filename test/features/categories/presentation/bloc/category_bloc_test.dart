import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category_stats.dart';
import 'package:fin_track_pro/features/categories/presentation/bloc/category_bloc/category_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';

void main() {
  late CategoryBloc bloc;
  late MockGetCategoriesUseCase mockGetCategories;
  late MockGetCategoryStatsUseCase mockGetCategoryStats;
  late MockCreateCategoryUseCase mockCreateCategory;
  late MockUpdateCategoryUseCase mockUpdateCategory;
  late MockDeleteCategoryUseCase mockDeleteCategory;
  late MockSearchCategoriesUseCase mockSearchCategories;

  setUp(() {
    mockGetCategories = MockGetCategoriesUseCase();
    mockGetCategoryStats = MockGetCategoryStatsUseCase();
    mockCreateCategory = MockCreateCategoryUseCase();
    mockUpdateCategory = MockUpdateCategoryUseCase();
    mockDeleteCategory = MockDeleteCategoryUseCase();
    mockSearchCategories = MockSearchCategoriesUseCase();

    bloc = CategoryBloc(
      getCategories: mockGetCategories,
      getCategoryStats: mockGetCategoryStats,
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
    test('initial state should have initial status', () {
      expect(bloc.state.status, CategoryStatus.initial);
      expect(bloc.state.categories, const []);
      expect(bloc.state.categoryStats, const []);
    });

    group('LoadCategories', () {
      const tCategories = [
        Category(id: '', name: '', icon: '', color: 0, type: 'expense'),
      ];
      blocTest(
        'should emit [Loading, Success] when data is gotten successfully',
        build: () {
          when(() => mockGetCategories()).thenAnswer((_) async => tCategories);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoriesEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.success,
            categories: tCategories,
          ),
        ],
        verify: (_) {
          verify(() => mockGetCategories()).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when getting data fails',
        build: () {
          when(() => mockGetCategories()).thenThrow(Exception('Error'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoriesEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.error,
            errorMessage: 'Exception: Error',
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.success,
            successMessage: 'Category created successfully',
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.error,
            errorMessage: 'Exception: Failed to create',
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.success,
            successMessage: 'Category updated successfully',
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.error,
            errorMessage: 'Exception: Failed to update',
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.success,
            successMessage: 'Category deleted successfully',
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.error,
            errorMessage: 'Exception: Failed to delete',
          ),
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
        'should emit [Loading, Success] when search is successful',
        build: () {
          when(() => mockSearchCategories(any()))
              .thenAnswer((_) async => tCategories);
          return bloc;
        },
        act: (bloc) => bloc.add(const SearchCategoriesEvent(tQuery)),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.success,
            categories: tCategories,
          ),
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
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.error,
            errorMessage: 'Exception: Search failed',
          ),
        ],
        verify: (_) {
          verify(() => mockSearchCategories(tQuery)).called(1);
        },
      );
    });

    group('LoadCategoryStatsEvent', () {
      const tCategory = Category(
        id: 'cat1',
        name: 'Groceries',
        icon: 'shopping_bag',
        color: 0xFF4CAF50,
        type: 'expense',
      );

      final tCategoryStats = [
        const CategoryStats(
          category: tCategory,
          transactionCount: 5,
          totalAmount: 250.75,
        ),
      ];

      blocTest(
        'should emit [Loading, Success] when stats are loaded successfully',
        build: () {
          when(() => mockGetCategoryStats())
              .thenAnswer((_) async => tCategoryStats);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoryStatsEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          CategoryState(
            status: CategoryStatus.success,
            categoryStats: tCategoryStats,
          ),
        ],
        verify: (_) {
          verify(() => mockGetCategoryStats()).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Success] with empty list when no categories exist',
        build: () {
          when(() => mockGetCategoryStats()).thenAnswer((_) async => []);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoryStatsEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.success,
            categoryStats: [],
          ),
        ],
        verify: (_) {
          verify(() => mockGetCategoryStats()).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Error] when loading stats fails',
        build: () {
          when(() => mockGetCategoryStats())
              .thenThrow(Exception('Failed to load stats'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoryStatsEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          const CategoryState(
            status: CategoryStatus.error,
            errorMessage: 'Exception: Failed to load stats',
          ),
        ],
        verify: (_) {
          verify(() => mockGetCategoryStats()).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Success] with multiple category stats',
        build: () {
          final tMultipleStats = [
            const CategoryStats(
              category: Category(
                id: 'cat1',
                name: 'Groceries',
                icon: 'shopping_bag',
                color: 0xFF4CAF50,
                type: 'expense',
              ),
              transactionCount: 5,
              totalAmount: 250.75,
            ),
            const CategoryStats(
              category: Category(
                id: 'cat2',
                name: 'Transport',
                icon: 'directions_car',
                color: 0xFF2196F3,
                type: 'expense',
              ),
              transactionCount: 3,
              totalAmount: 150.00,
            ),
          ];
          when(() => mockGetCategoryStats())
              .thenAnswer((_) async => tMultipleStats);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoryStatsEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          isA<CategoryState>()
              .having((state) => state.status, 'status', CategoryStatus.success)
              .having((state) => state.categoryStats.length, 'length', 2)
              .having(
                (state) => state.categoryStats[0].transactionCount,
                'first count',
                5,
              )
              .having(
                (state) => state.categoryStats[1].transactionCount,
                'second count',
                3,
              ),
        ],
        verify: (_) {
          verify(() => mockGetCategoryStats()).called(1);
        },
      );

      blocTest(
        'should emit [Loading, Success] with zero stats for categories without transactions',
        build: () {
          final tStatsWithZero = [
            const CategoryStats(
              category: tCategory,
              transactionCount: 0,
              totalAmount: 0.0,
            ),
          ];
          when(() => mockGetCategoryStats())
              .thenAnswer((_) async => tStatsWithZero);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadCategoryStatsEvent()),
        expect: () => [
          const CategoryState(status: CategoryStatus.loading),
          isA<CategoryState>()
              .having((state) => state.status, 'status', CategoryStatus.success)
              .having(
                (state) => state.categoryStats[0].transactionCount,
                'count',
                0,
              )
              .having(
                (state) => state.categoryStats[0].totalAmount,
                'amount',
                0.0,
              ),
        ],
        verify: (_) {
          verify(() => mockGetCategoryStats()).called(1);
        },
      );
    });
  });
}
