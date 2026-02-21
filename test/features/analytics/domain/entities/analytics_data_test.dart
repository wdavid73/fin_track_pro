import 'package:fin_track_pro/features/analytics/domain/entities/analytics_data.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tCategory = Category(
    id: 'cat1',
    name: 'Food',
    icon: 'food_icon',
    color: 0xFF4CAF50,
    type: 'expense',
  );

  group('CategorySpending', () {
    const tSpending = CategorySpending(
      category: tCategory,
      amount: 250.0,
      transactionCount: 5,
    );

    test('supports equality', () {
      const other = CategorySpending(
        category: tCategory,
        amount: 250.0,
        transactionCount: 5,
      );
      expect(tSpending, equals(other));
    });

    group('getPercentage', () {
      test('returns correct percentage when totalSpending > 0', () {
        expect(tSpending.getPercentage(500.0), 50.0);
      });

      test('returns 0 when totalSpending is 0 (no division by zero)', () {
        expect(tSpending.getPercentage(0), 0.0);
      });

      test('returns 100 when it is the only spending', () {
        expect(tSpending.getPercentage(250.0), 100.0);
      });

      test('returns less than 100 for partial spending', () {
        final result = tSpending.getPercentage(1000.0);
        expect(result, 25.0);
      });
    });
  });

  group('IncomeExpenseComparison', () {
    const tComparison = IncomeExpenseComparison(
      label: 'Week 1',
      income: 1000.0,
      expense: 600.0,
    );

    test('supports equality', () {
      const other = IncomeExpenseComparison(
        label: 'Week 1',
        income: 1000.0,
        expense: 600.0,
      );
      expect(tComparison, equals(other));
    });

    test('net returns income - expense', () {
      expect(tComparison.net, 400.0);
    });

    test('net is negative when expenses exceed income', () {
      const negative = IncomeExpenseComparison(
        label: 'Month',
        income: 200.0,
        expense: 500.0,
      );
      expect(negative.net, -300.0);
    });

    test('net is zero when income equals expense', () {
      const balanced = IncomeExpenseComparison(
        label: 'Mon',
        income: 100.0,
        expense: 100.0,
      );
      expect(balanced.net, 0.0);
    });
  });

  group('AnalyticsData', () {
    const tCategory2 = Category(
      id: 'cat2',
      name: 'Transport',
      icon: 'car_icon',
      color: 0xFF2196F3,
      type: 'expense',
    );

    final tCategorySpending = [
      const CategorySpending(
        category: tCategory,
        amount: 500.0,
        transactionCount: 10,
      ),
      const CategorySpending(
        category: tCategory2,
        amount: 200.0,
        transactionCount: 3,
      ),
    ];

    final tAnalyticsData = AnalyticsData(
      totalIncome: 2000.0,
      totalExpenses: 700.0,
      categorySpending: tCategorySpending,
      comparisons: const [],
    );

    test('supports equality', () {
      final other = AnalyticsData(
        totalIncome: 2000.0,
        totalExpenses: 700.0,
        categorySpending: tCategorySpending,
        comparisons: const [],
      );
      expect(tAnalyticsData, equals(other));
    });

    test('netSavings returns totalIncome - totalExpenses', () {
      expect(tAnalyticsData.netSavings, 1300.0);
    });

    test('netSavings is negative when expenses exceed income', () {
      final deficit = const AnalyticsData(
        totalIncome: 500.0,
        totalExpenses: 800.0,
        categorySpending: [],
        comparisons: [],
      );
      expect(deficit.netSavings, -300.0);
    });

    test(
      'topSpendingCategories returns categories sorted by amount descending',
      () {
        final top = tAnalyticsData.topSpendingCategories;
        expect(top.first.amount, 500.0); // Food first
        expect(top.last.amount, 200.0); // Transport last
      },
    );

    test('topSpendingCategories returns empty list when no spending', () {
      final empty = const AnalyticsData(
        totalIncome: 100.0,
        totalExpenses: 0.0,
        categorySpending: [],
        comparisons: [],
      );
      expect(empty.topSpendingCategories, isEmpty);
    });

    test('topSpendingCategories does not mutate original list', () {
      final originalOrder = tAnalyticsData.categorySpending
          .map((e) => e.amount)
          .toList();
      tAnalyticsData.topSpendingCategories; // trigger sort
      final afterSort = tAnalyticsData.categorySpending
          .map((e) => e.amount)
          .toList();
      expect(afterSort, originalOrder);
    });
  });
}
