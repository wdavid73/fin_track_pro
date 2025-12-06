import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';

/// Represents spending data for a specific category in analytics
class CategorySpending extends Equatable {
  final Category category;
  final double amount;
  final int transactionCount;

  const CategorySpending({
    required this.category,
    required this.amount,
    required this.transactionCount,
  });

  /// Calculate percentage of total spending
  double getPercentage(double totalSpending) {
    if (totalSpending == 0) return 0;
    return (amount / totalSpending) * 100;
  }

  @override
  List<Object?> get props => [category, amount, transactionCount];
}

/// Represents income vs expense data for a specific time unit (week/day)
class IncomeExpenseComparison extends Equatable {
  final String label; // e.g., "Week 1", "Mon", "Jan"
  final double income;
  final double expense;

  const IncomeExpenseComparison({
    required this.label,
    required this.income,
    required this.expense,
  });

  double get net => income - expense;

  @override
  List<Object?> get props => [label, income, expense];
}

/// Main analytics data entity
class AnalyticsData extends Equatable {
  final double totalIncome;
  final double totalExpenses;
  final List<CategorySpending> categorySpending;
  final List<IncomeExpenseComparison> comparisons;

  const AnalyticsData({
    required this.totalIncome,
    required this.totalExpenses,
    required this.categorySpending,
    required this.comparisons,
  });

  double get netSavings => totalIncome - totalExpenses;

  /// Get top spending categories sorted by amount
  List<CategorySpending> get topSpendingCategories {
    final sorted = List<CategorySpending>.from(categorySpending);
    sorted.sort((a, b) => b.amount.compareTo(a.amount));
    return sorted;
  }

  @override
  List<Object?> get props => [
    totalIncome,
    totalExpenses,
    categorySpending,
    comparisons,
  ];
}
