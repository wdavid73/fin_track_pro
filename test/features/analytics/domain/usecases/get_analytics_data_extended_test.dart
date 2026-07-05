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

  group('GetAnalyticsData - Period comparisons', () {
    final now = DateTime.now();

    final tCategory = Category(
      id: 'cat1',
      name: 'Food',
      icon: 'food_icon',
      color: 456,
      type: 'expense',
      updatedAt: DateTime.now(),
    );

    test('year period produces 12 comparisons', () async {
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => []);

      final result = await useCase(AnalyticsPeriod.year);

      expect(result.comparisons.length, 12);
    });

    test('week period produces 7 day comparisons', () async {
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => []);

      final result = await useCase(AnalyticsPeriod.week);

      expect(result.comparisons.length, 7);
    });

    test('month period produces 4 week comparisons', () async {
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => []);

      final result = await useCase(AnalyticsPeriod.month);

      expect(result.comparisons.length, 4);
    });

    test('income-only transactions: netSavings equals totalIncome', () async {
      final tDate = DateTime(now.year, now.month, 1);
      final tTransactions = [
        Transaction(
          id: '1',
          amount: 3000.0,
          categoryId: 'cat1',
          type: 'income',
          date: tDate,
          createdAt: tDate,
          updatedAt: tDate,
        ),
        Transaction(
          id: '2',
          amount: 1500.0,
          categoryId: 'cat1',
          type: 'income',
          date: tDate,
          createdAt: tDate,
          updatedAt: tDate,
        ),
      ];

      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => tTransactions);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [tCategory]);

      final result = await useCase(AnalyticsPeriod.month);

      expect(result.totalIncome, 4500.0);
      expect(result.totalExpenses, 0.0);
      expect(result.netSavings, 4500.0);
      expect(result.categorySpending, isEmpty); // no expenses
    });

    test('expense-only transactions: netSavings is negative', () async {
      final tDate = DateTime(now.year, now.month, 1);
      final tTransactions = [
        Transaction(
          id: '1',
          amount: 200.0,
          categoryId: 'cat1',
          type: 'expense',
          date: tDate,
          createdAt: tDate,
          updatedAt: tDate,
        ),
      ];

      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => tTransactions);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [tCategory]);

      final result = await useCase(AnalyticsPeriod.month);

      expect(result.totalIncome, 0.0);
      expect(result.totalExpenses, 200.0);
      expect(result.netSavings, -200.0);
      expect(result.categorySpending.length, 1);
    });

    test('multiple expenses in same category are accumulated', () async {
      final tDate = DateTime(now.year, now.month, 1);
      final tTransactions = [
        Transaction(
          id: '1',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          date: tDate,
          createdAt: tDate,
          updatedAt: tDate,
        ),
        Transaction(
          id: '2',
          amount: 50.0,
          categoryId: 'cat1',
          type: 'expense',
          date: tDate,
          createdAt: tDate,
          updatedAt: tDate,
        ),
        Transaction(
          id: '3',
          amount: 75.0,
          categoryId: 'cat1',
          type: 'expense',
          date: tDate,
          createdAt: tDate,
          updatedAt: tDate,
        ),
      ];

      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => tTransactions);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [tCategory]);

      final result = await useCase(AnalyticsPeriod.month);

      expect(result.categorySpending.length, 1);
      expect(result.categorySpending.first.amount, 225.0);
      expect(result.categorySpending.first.transactionCount, 3);
    });

    test('year comparisons include correct month labels', () async {
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => []);

      final result = await useCase(AnalyticsPeriod.year);

      final labels = result.comparisons.map((c) => c.label).toList();
      expect(labels, contains('Jan'));
      expect(labels, contains('Dec'));
      expect(labels.length, 12);
    });

    test('week comparisons include day labels', () async {
      when(
        () =>
            mockTransactionRepository.getTransactionsByDateRange(any(), any()),
      ).thenAnswer((_) async => []);
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => []);

      final result = await useCase(AnalyticsPeriod.week);

      final labels = result.comparisons.map((c) => c.label).toSet();
      // All day labels should be from the set of weekday abbreviations
      const validLabels = {'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'};
      expect(labels.every((l) => validLabels.contains(l)), isTrue);
    });
  });
}
