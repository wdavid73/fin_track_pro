import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category_stats.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/usecases.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'category_event.dart';
part 'category_state.dart';

@injectable
class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final GetCategoriesUseCase getCategories;
  final GetCategoryStatsUseCase getCategoryStats;
  final CreateCategoryUseCase createCategory;
  final UpdateCategoryUseCase updateCategory;
  final DeleteCategoryUseCase deleteCategory;
  final SearchCategoriesUseCase searchCategories;

  CategoryBloc({
    required this.getCategories,
    required this.getCategoryStats,
    required this.createCategory,
    required this.updateCategory,
    required this.deleteCategory,
    required this.searchCategories,
  }) : super(const CategoryState()) {
    on<LoadCategoriesEvent>(_onLoadCategories);
    on<LoadCategoryStatsEvent>(_onLoadCategoryStats);
    on<CreateCategoryEvent>(_onCreateCategory);
    on<UpdateCategoryEvent>(_onUpdateCategory);
    on<DeleteCategoryEvent>(_onDeleteCategory);
    on<SearchCategoriesEvent>(_onSearchCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await getCategories();
      emit(
        state.copyWith(status: CategoryStatus.success, categories: categories),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onLoadCategoryStats(
    LoadCategoryStatsEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categoryStats = await getCategoryStats();
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          categoryStats: categoryStats,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onCreateCategory(
    CreateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      await createCategory(event.category);
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          successMessage: 'Category created successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateCategory(
    UpdateCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      await updateCategory(event.category);
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          successMessage: 'Category updated successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteCategory(
    DeleteCategoryEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      await deleteCategory(event.categoryId);
      emit(
        state.copyWith(
          status: CategoryStatus.success,
          successMessage: 'Category deleted successfully',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onSearchCategories(
    SearchCategoriesEvent event,
    Emitter<CategoryState> emit,
  ) async {
    emit(state.copyWith(status: CategoryStatus.loading));
    try {
      final categories = await searchCategories(event.query);
      emit(
        state.copyWith(status: CategoryStatus.success, categories: categories),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: CategoryStatus.error,
          errorMessage: e.toString(),
        ),
      );
    }
  }
}
