import 'package:fin_track_pro/features/analytics/domain/entities/analytics_period.dart';
import 'package:fin_track_pro/features/analytics/domain/usecases/get_analytics_data.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/analytics_mocks.dart';

void main() {
  late GetAnalyticsData useCase;
  late MockTransactionRepository mockTransactionRepository;
  late MockCategoryRepository mockCategoryRepository;

  setUp(() {
    mockTransactionRepository = MockTransactionRepository();
    mockCategoryRepository = MockCategoryRepository();
    useCase = GetAnalyticsData(
      mockTransactionRepository,
      mockCategoryRepository,
    );
  });

  group('GetAnalyticsData', () {
    final tDate = DateTime(2024, 1, 15); // A Monday
    final tTransactions = [
      Transaction(
        id: '1',
        amount: 100.0,
        categoryId: 'cat1',
        type: 'income',
        date: tDate,
        createdAt: tDate,
      ),
      Transaction(
        id: '2',
        amount: 50.0,
        categoryId: 'cat2',
        type: 'expense',
        date: tDate,
        createdAt: tDate,
      ),
      Transaction(
        id: '3',
        amount: 30.0,
        categoryId: 'cat2',
        type: 'expense',
        date: tDate.add(const Duration(days: 1)),
        createdAt: tDate.add(const Duration(days: 1)),
      ),
    ];

    final tCategories = [
      const Category(
        id: 'cat1',
        name: 'Salary',
        icon: 'salary_icon',
        color: 456,
        type: 'income',
      ),
      const Category(
        id: 'cat2',
        name: 'Food',
        icon: 'food_icon',
        color: 101,
        type: 'expense',
      ),
    ];

    test('should return correct analytics data for Week period', () async {
      // arrange
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => tTransactions);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => tCategories);

      // act
      final result = await useCase(AnalyticsPeriod.week);

      // assert
      expect(result.totalIncome, 100.0);
      expect(result.totalExpenses, 80.0); // 50 + 30
      expect(result.netSavings, 20.0); // 100 - 80

      // Check category spending
      expect(result.categorySpending.length, 1); // Only expense categories
      expect(result.categorySpending.first.category.id, 'cat2');
      expect(result.categorySpending.first.amount, 80.0);
      expect(result.categorySpending.first.transactionCount, 2);

      verify(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).called(1);
      verify(() => mockCategoryRepository.getCategories()).called(1);
    });

    test('should return empty data when no transactions found', () async {
      // arrange
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => tCategories);

      // act
      final result = await useCase(AnalyticsPeriod.month);

      // assert
      expect(result.totalIncome, 0.0);
      expect(result.totalExpenses, 0.0);
      expect(result.netSavings, 0.0);
      expect(result.categorySpending, isEmpty);
      // Comparisons should be generated even with no data (initialized to 0)
      expect(result.comparisons.length, 4); // 4 weeks for month
      expect(
        result.comparisons.every((c) => c.income == 0 && c.expense == 0),
        isTrue,
      );
    });

    test('should handle repository errors gracefully', () async {
      // arrange
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenThrow(Exception('Database error'));

      // act & assert
      expect(() => useCase(AnalyticsPeriod.year), throwsException);
    });
  });
}
