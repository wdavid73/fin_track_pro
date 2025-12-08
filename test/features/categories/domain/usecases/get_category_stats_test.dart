import 'package:fin_track_pro/features/categories/domain/entities/category.dart';
import 'package:fin_track_pro/features/categories/domain/entities/category_stats.dart';
import 'package:fin_track_pro/features/categories/domain/usecases/get_category_stats_use_case.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/category_mocks.dart';
import '../../../transactions/mocks/transactions_mocks.dart';

void main() {
  late GetCategoryStatsUseCase useCase;
  late MockCategoryRepository mockCategoryRepository;
  late MockTransactionRepository mockTransactionRepository;

  setUp(() {
    mockCategoryRepository = MockCategoryRepository();
    mockTransactionRepository = MockTransactionRepository();
    useCase = GetCategoryStatsUseCase(
      mockCategoryRepository,
      mockTransactionRepository,
    );
  });

  const tCategories = [
    Category(
      id: 'cat1',
      name: 'Groceries',
      icon: 'shopping_bag',
      color: 0xFF4CAF50,
      type: 'expense',
    ),
    Category(
      id: 'cat2',
      name: 'Transport',
      icon: 'directions_car',
      color: 0xFF2196F3,
      type: 'expense',
    ),
  ];

  final tTransactionsCat1 = [
    Transaction(
      id: '1',
      amount: 100.0,
      categoryId: 'cat1',
      type: 'expense',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    ),
    Transaction(
      id: '2',
      amount: 150.0,
      categoryId: 'cat1',
      type: 'expense',
      date: DateTime(2024, 1, 2),
      createdAt: DateTime(2024, 1, 2),
    ),
  ];

  final tTransactionsCat2 = [
    Transaction(
      id: '3',
      amount: 50.0,
      categoryId: 'cat2',
      type: 'expense',
      date: DateTime(2024, 1, 1),
      createdAt: DateTime(2024, 1, 1),
    ),
  ];

  group('GetCategoryStatsUseCase', () {
    test(
      'should return category stats with correct transaction count and totals',
      () async {
        // arrange
        when(
          () => mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => tCategories);
        when(
          () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
        ).thenAnswer((_) async => tTransactionsCat1);
        when(
          () => mockTransactionRepository.getTransactionsByCategoryId('cat2'),
        ).thenAnswer((_) async => tTransactionsCat2);

        // act
        final result = await useCase();

        // assert
        verify(() => mockCategoryRepository.getCategories()).called(1);
        verify(
          () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
        ).called(1);
        verify(
          () => mockTransactionRepository.getTransactionsByCategoryId('cat2'),
        ).called(1);

        expect(result, isA<List<CategoryStats>>());
        expect(result.length, 2);

        // Check first category stats (Groceries)
        expect(result[0].category.id, 'cat1');
        expect(result[0].transactionCount, 2);
        expect(result[0].totalAmount, 250.0); // 100 + 150

        // Check second category stats (Transport)
        expect(result[1].category.id, 'cat2');
        expect(result[1].transactionCount, 1);
        expect(result[1].totalAmount, 50.0);
      },
    );

    test('should return empty list when no categories exist', () async {
      // arrange
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => []);

      // act
      final result = await useCase();

      // assert
      verify(() => mockCategoryRepository.getCategories()).called(1);
      expect(result, isEmpty);
    });

    test(
      'should return zero stats for category with no transactions',
      () async {
        // arrange
        when(
          () => mockCategoryRepository.getCategories(),
        ).thenAnswer((_) async => [tCategories.first]);
        when(
          () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
        ).thenAnswer((_) async => []);

        // act
        final result = await useCase();

        // assert
        verify(() => mockCategoryRepository.getCategories()).called(1);
        verify(
          () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
        ).called(1);

        expect(result.length, 1);
        expect(result[0].category.id, 'cat1');
        expect(result[0].transactionCount, 0);
        expect(result[0].totalAmount, 0.0);
      },
    );

    test('should calculate correct totals with decimal amounts', () async {
      // arrange
      final tTransactionsWithDecimals = [
        Transaction(
          id: '1',
          amount: 99.99,
          categoryId: 'cat1',
          type: 'expense',
          date: DateTime(2024, 1, 1),
          createdAt: DateTime(2024, 1, 1),
        ),
        Transaction(
          id: '2',
          amount: 50.50,
          categoryId: 'cat1',
          type: 'expense',
          date: DateTime(2024, 1, 2),
          createdAt: DateTime(2024, 1, 2),
        ),
      ];

      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [tCategories.first]);
      when(
        () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
      ).thenAnswer((_) async => tTransactionsWithDecimals);

      // act
      final result = await useCase();

      // assert
      expect(result.length, 1);
      expect(result[0].transactionCount, 2);
      expect(result[0].totalAmount, closeTo(150.49, 0.01));
    });

    test('should throw exception when category repository fails', () async {
      // arrange
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenThrow(Exception('Database error'));

      // act & assert
      expect(() => useCase(), throwsException);
      verify(() => mockCategoryRepository.getCategories()).called(1);
    });

    test('should throw exception when transaction repository fails', () async {
      // arrange
      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [tCategories.first]);

      when(
        () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
      ).thenThrow(Exception('Database error'));

      // act & assert
      await expectLater(() => useCase(), throwsException);
      verify(() => mockCategoryRepository.getCategories()).called(1);
      verify(
        () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
      ).called(1);
    });

    test('should handle large number of transactions correctly', () async {
      // arrange
      final tManyTransactions = List.generate(
        100,
        (index) => Transaction(
          id: '$index',
          amount: 10.0,
          categoryId: 'cat1',
          type: 'expense',
          date: DateTime(2024, 1, 1).add(Duration(days: index)),
          createdAt: DateTime(2024, 1, 1),
        ),
      );

      when(
        () => mockCategoryRepository.getCategories(),
      ).thenAnswer((_) async => [tCategories.first]);
      when(
        () => mockTransactionRepository.getTransactionsByCategoryId('cat1'),
      ).thenAnswer((_) async => tManyTransactions);

      // act
      final result = await useCase();

      // assert
      expect(result.length, 1);
      expect(result[0].transactionCount, 100);
      expect(result[0].totalAmount, 1000.0); // 100 * 10.0
    });
  });
}
