import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category_stats.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CategoryStats', () {
    final tCategory = Category(
      id: '1',
      name: 'Groceries',
      icon: 'shopping_bag',
      color: 0xFF4CAF50,
      type: 'expense',
      updatedAt: DateTime(2026, 1, 1),
    );

    final tCategoryStats = CategoryStats(
      category: tCategory,
      transactionCount: 5,
      totalAmount: 250.50,
    );

    test('should be a subclass of Equatable', () {
      // assert
      expect(tCategoryStats, isA<Object>());
    });

    test('should have correct properties', () {
      // assert
      expect(tCategoryStats.category, tCategory);
      expect(tCategoryStats.transactionCount, 5);
      expect(tCategoryStats.totalAmount, 250.50);
    });

    test('props should contain category, transactionCount, and totalAmount', () {
      // assert
      expect(
        tCategoryStats.props,
        [tCategory, 5, 250.50],
      );
    });

    test('two instances with same values should be equal', () {
      // arrange
      final tCategoryStats1 = CategoryStats(
        category: tCategory,
        transactionCount: 5,
        totalAmount: 250.50,
      );
      final tCategoryStats2 = CategoryStats(
        category: tCategory,
        transactionCount: 5,
        totalAmount: 250.50,
      );

      // assert
      expect(tCategoryStats1, equals(tCategoryStats2));
    });

    test('two instances with different values should not be equal', () {
      // arrange
      final tCategoryStats1 = CategoryStats(
        category: tCategory,
        transactionCount: 5,
        totalAmount: 250.50,
      );
      final tCategoryStats2 = CategoryStats(
        category: tCategory,
        transactionCount: 10,
        totalAmount: 500.00,
      );

      // assert
      expect(tCategoryStats1, isNot(equals(tCategoryStats2)));
    });

    test('toString should return correct format', () {
      // assert
      expect(
        tCategoryStats.toString(),
        'CategoryStats(category: Groceries, count: 5, total: 250.5)',
      );
    });

    test('should handle zero transaction count', () {
      // arrange
      final tStatsWithZero = CategoryStats(
        category: tCategory,
        transactionCount: 0,
        totalAmount: 0.0,
      );

      // assert
      expect(tStatsWithZero.transactionCount, 0);
      expect(tStatsWithZero.totalAmount, 0.0);
    });

    test('should handle large transaction count', () {
      // arrange
      final tStatsWithLargeCount = CategoryStats(
        category: tCategory,
        transactionCount: 1000,
        totalAmount: 50000.99,
      );

      // assert
      expect(tStatsWithLargeCount.transactionCount, 1000);
      expect(tStatsWithLargeCount.totalAmount, 50000.99);
    });
  });
}
