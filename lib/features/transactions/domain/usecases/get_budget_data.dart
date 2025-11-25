import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case to calculate budget data with hardcoded budgets
@injectable
class GetBudgetData {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  GetBudgetData(this.transactionRepository, this.categoryRepository);

  /// Hardcoded budgets per category name
  static const Map<String, double> _categoryBudgets = {
    'Alimentación': 500.0,
    'Shopping': 800.0,
    'Compras': 800.0,
    'Entretenimiento': 400.0,
    'Transporte': 300.0,
    'Vivienda': 1500.0,
    'Salud': 500.0,
    'Educación': 600.0,
    'Servicios': 400.0,
    'Otros Gastos': 300.0,
  };

  Future<BudgetData> call() async {
    // Get all transactions and categories
    final transactions = await transactionRepository.getTransactions();
    final categories = await categoryRepository.getCategories();

    // Filter only expense transactions
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // Group expenses by category
    final Map<String, double> spentByCategory = {};
    for (final expense in expenses) {
      spentByCategory[expense.categoryId] =
          (spentByCategory[expense.categoryId] ?? 0) + expense.amount;
    }

    // Create CategoryBudget list
    final List<CategoryBudget> categoryBudgets = [];
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (final category in categories) {
      if (category.type == 'expense') {
        final spent = spentByCategory[category.id] ?? 0.0;
        final budget =
            _categoryBudgets[category.name] ?? 500.0; // Default budget

        if (spent > 0 || budget > 0) {
          categoryBudgets.add(
            CategoryBudget(category: category, spent: spent, budget: budget),
          );

          totalBudget += budget;
          totalSpent += spent;
        }
      }
    }

    // Sort by spent amount (descending) and take top 3
    categoryBudgets.sort((a, b) => b.spent.compareTo(a.spent));
    final topCategories = categoryBudgets.take(3).toList();

    return BudgetData(
      totalSpent: totalSpent,
      totalBudget: totalBudget,
      categories: topCategories,
    );
  }
}
