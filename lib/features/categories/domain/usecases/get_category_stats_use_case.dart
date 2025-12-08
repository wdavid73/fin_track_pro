import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category_stats.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';

/// Use case to get category statistics with transaction count and total amount
@injectable
class GetCategoryStatsUseCase {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;

  GetCategoryStatsUseCase(
    this.categoryRepository,
    this.transactionRepository,
  );

  Future<List<CategoryStats>> call() async {
    final categories = await categoryRepository.getCategories();
    final List<CategoryStats> categoryStatsList = [];

    for (final category in categories) {
      final transactions = await transactionRepository.getTransactionsByCategoryId(
        category.id,
      );

      final transactionCount = transactions.length;
      final totalAmount = transactions.fold<double>(
        0.0,
        (sum, transaction) => sum + transaction.amount,
      );

      categoryStatsList.add(
        CategoryStats(
          category: category,
          transactionCount: transactionCount,
          totalAmount: totalAmount,
        ),
      );
    }

    return categoryStatsList;
  }
}
