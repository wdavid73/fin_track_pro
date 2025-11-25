import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';

/// Represents budget data for a specific category
class CategoryBudget extends Equatable {
  final Category category;
  final double spent;
  final double budget;

  const CategoryBudget({
    required this.category,
    required this.spent,
    required this.budget,
  });

  double get remaining => budget - spent;
  double get percentage => budget > 0 ? (spent / budget) * 100 : 0;

  @override
  List<Object?> get props => [category, spent, budget];
}

/// Represents overall budget data
class BudgetData extends Equatable {
  final double totalSpent;
  final double totalBudget;
  final List<CategoryBudget> categories;

  const BudgetData({
    required this.totalSpent,
    required this.totalBudget,
    required this.categories,
  });

  double get remaining => totalBudget - totalSpent;
  double get percentage =>
      totalBudget > 0 ? (totalSpent / totalBudget) * 100 : 0;

  @override
  List<Object?> get props => [totalSpent, totalBudget, categories];
}
