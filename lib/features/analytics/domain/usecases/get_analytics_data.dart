import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:fin_track_pro/features/categories/domain/repositories/category_repository.dart';
import 'package:fin_track_pro/features/transactions/domain/repositories/transaction_repository.dart';
import 'package:injectable/injectable.dart';

/// Use case to get analytics data for a specific time period
@injectable
class GetAnalyticsData {
  final TransactionRepository _transactionRepository;
  final CategoryRepository _categoryRepository;

  GetAnalyticsData(this._transactionRepository, this._categoryRepository);

  Future<AnalyticsData> call(AnalyticsPeriod period) async {
    // Get date range for the period
    final dateRange = period.getDateRange();

    // Get all transactions in the date range
    final transactions = await _transactionRepository
        .getTransactionsByDateRange(dateRange.start, dateRange.end);

    // Get all categories
    final categories = await _categoryRepository.getCategories();

    // Calculate total income and expenses
    double totalIncome = 0;
    double totalExpenses = 0;

    for (final transaction in transactions) {
      if (transaction.type == 'income') {
        totalIncome += transaction.amount;
      } else if (transaction.type == 'expense') {
        totalExpenses += transaction.amount;
      }
    }

    // Group expenses by category
    final Map<String, CategorySpending> categoryMap = {};

    for (final transaction in transactions) {
      if (transaction.type == 'expense') {
        final categoryId = transaction.categoryId;

        if (categoryMap.containsKey(categoryId)) {
          final existing = categoryMap[categoryId]!;
          categoryMap[categoryId] = CategorySpending(
            category: existing.category,
            amount: existing.amount + transaction.amount,
            transactionCount: existing.transactionCount + 1,
          );
        } else {
          final category = categories.firstWhere(
            (c) => c.id == categoryId,
            orElse: () => categories.first,
          );

          categoryMap[categoryId] = CategorySpending(
            category: category,
            amount: transaction.amount,
            transactionCount: 1,
          );
        }
      }
    }

    // Create income vs expense comparisons based on period
    final comparisons = _createComparisons(
      transactions,
      period,
      dateRange.start,
      dateRange.end,
    );

    return AnalyticsData(
      totalIncome: totalIncome,
      totalExpenses: totalExpenses,
      categorySpending: categoryMap.values.toList(),
      comparisons: comparisons,
    );
  }

  List<IncomeExpenseComparison> _createComparisons(
    List<dynamic> transactions,
    AnalyticsPeriod period,
    DateTime start,
    DateTime end,
  ) {
    final List<IncomeExpenseComparison> comparisons = [];

    switch (period) {
      case AnalyticsPeriod.week:
        // Create 7 days comparison
        for (int i = 0; i < 7; i++) {
          final day = start.add(Duration(days: i));
          final dayTransactions = transactions.where((t) {
            final tDate = t.date;
            return tDate.year == day.year &&
                tDate.month == day.month &&
                tDate.day == day.day;
          }).toList();

          double income = 0;
          double expense = 0;

          for (final t in dayTransactions) {
            if (t.type == 'income') {
              income += t.amount;
            } else if (t.type == 'expense') {
              expense += t.amount;
            }
          }

          comparisons.add(
            IncomeExpenseComparison(
              label: _getDayLabel(day.weekday),
              income: income,
              expense: expense,
            ),
          );
        }
        break;

      case AnalyticsPeriod.month:
        // Create 4 weeks comparison
        for (int i = 0; i < 4; i++) {
          final weekStart = start.add(Duration(days: i * 7));
          final weekEnd = weekStart.add(const Duration(days: 7));

          final weekTransactions = transactions.where((t) {
            final tDate = t.date;
            return tDate.isAfter(
                  weekStart.subtract(const Duration(seconds: 1)),
                ) &&
                tDate.isBefore(weekEnd);
          }).toList();

          double income = 0;
          double expense = 0;

          for (final t in weekTransactions) {
            if (t.type == 'income') {
              income += t.amount;
            } else if (t.type == 'expense') {
              expense += t.amount;
            }
          }

          comparisons.add(
            IncomeExpenseComparison(
              label: 'Week ${i + 1}',
              income: income,
              expense: expense,
            ),
          );
        }
        break;

      case AnalyticsPeriod.quarter:
        // Create 3 months comparison (last 3 full months)
        for (int i = 2; i >= 0; i--) {
          final month = DateTime(start.year, start.month + i, 1);
          final monthTransactions = transactions.where((t) {
            final tDate = t.date;
            return tDate.year == month.year && tDate.month == month.month;
          }).toList();

          double income = 0;
          double expense = 0;

          for (final t in monthTransactions) {
            if (t.type == 'income') {
              income += t.amount;
            } else if (t.type == 'expense') {
              expense += t.amount;
            }
          }

          comparisons.add(
            IncomeExpenseComparison(
              label: _getMonthLabel(month.month),
              income: income,
              expense: expense,
            ),
          );
        }
        break;

      case AnalyticsPeriod.year:
        // Create 12 months comparison
        for (int i = 0; i < 12; i++) {
          final month = DateTime(start.year, start.month + i, 1);
          final monthTransactions = transactions.where((t) {
            final tDate = t.date;
            return tDate.year == month.year && tDate.month == month.month;
          }).toList();

          double income = 0;
          double expense = 0;

          for (final t in monthTransactions) {
            if (t.type == 'income') {
              income += t.amount;
            } else if (t.type == 'expense') {
              expense += t.amount;
            }
          }

          comparisons.add(
            IncomeExpenseComparison(
              label: _getMonthLabel(month.month),
              income: income,
              expense: expense,
            ),
          );
        }
        break;
    }

    return comparisons;
  }

  String _getDayLabel(int weekday) {
    switch (weekday) {
      case 1:
        return 'Mon';
      case 2:
        return 'Tue';
      case 3:
        return 'Wed';
      case 4:
        return 'Thu';
      case 5:
        return 'Fri';
      case 6:
        return 'Sat';
      case 7:
        return 'Sun';
      default:
        return '';
    }
  }

  String _getMonthLabel(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
