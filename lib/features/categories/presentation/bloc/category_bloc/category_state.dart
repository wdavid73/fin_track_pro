part of 'category_bloc.dart';

enum CategoryStatus {
  initial,
  loading,
  success,
  error,
}

class CategoryState extends Equatable {
  final CategoryStatus status;
  final List<Category> categories;
  final List<CategoryStats> categoryStats;
  final String? errorMessage;
  final String? successMessage;

  const CategoryState({
    this.status = CategoryStatus.initial,
    this.categories = const [],
    this.categoryStats = const [],
    this.errorMessage,
    this.successMessage,
  });

  CategoryState copyWith({
    CategoryStatus? status,
    List<Category>? categories,
    List<CategoryStats>? categoryStats,
    String? errorMessage,
    String? successMessage,
  }) {
    return CategoryState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      categoryStats: categoryStats ?? this.categoryStats,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        categories,
        categoryStats,
        errorMessage,
        successMessage,
      ];
}
