import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/get_budgets.dart';

/// Use case to calculate budget data from Hive database
@injectable
class GetBudgetData {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;
  final GetBudgets getBudgets;

  GetBudgetData(
    this.transactionRepository,
    this.categoryRepository,
    this.getBudgets,
  );

  Future<BudgetData> call() async {
    // Get all transactions, categories, and budgets
    final transactions = await transactionRepository.getTransactions();
    final categories = await categoryRepository.getCategories();
    final budgets = await getBudgets();

    // Filter only expense transactions
    final expenses = transactions.where((t) => t.type == 'expense').toList();

    // Group expenses by category
    final Map<String, double> spentByCategory = {};
    for (final expense in expenses) {
      spentByCategory[expense.categoryId] =
          (spentByCategory[expense.categoryId] ?? 0) + expense.amount;
    }

    // Create a map of budgets by category ID for quick lookup
    final Map<String, double> budgetByCategory = {};
    for (final budget in budgets) {
      budgetByCategory[budget.categoryId] = budget.amount;
    }

    // Create CategoryBudget list
    final List<CategoryBudget> categoryBudgets = [];
    double totalBudget = 0.0;
    double totalSpent = 0.0;

    for (final category in categories) {
      if (category.type == 'expense') {
        final spent = spentByCategory[category.id] ?? 0.0;
        final budget = budgetByCategory[category.id] ?? 500.0; // Default budget

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
