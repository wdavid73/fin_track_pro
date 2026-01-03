import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:fin_track_pro/features/transactions/data/repositories/transaction_repository_impl.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/transactions_mocks.dart';

void main() {
  late TransactionRepositoryImpl repository;
  late MockTransactionLocalDataSource mockLocalDataSource;

  setUp(() {
    mockLocalDataSource = MockTransactionLocalDataSource();
    repository = TransactionRepositoryImpl(mockLocalDataSource);
  });

  group('TransactionRepository', () {
    final tTransactionModels = [
      TransactionModel(
        id: '1',
        amount: 100.0,
        categoryId: 'cat1',
        type: 'expense',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      ),
      TransactionModel(
        id: '2',
        amount: 200.0,
        categoryId: 'cat2',
        type: 'income',
        date: DateTime(2024, 1, 2),
        createdAt: DateTime(2024, 1, 2),
      ),
    ];

    final tTransactions = tTransactionModels
        .map((model) => model.toEntity())
        .toList();

    group('getTransactions', () {
      test('should return list of transactions from data source', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactions(),
        ).thenAnswer((_) async => tTransactionModels);

        // act
        final result = await repository.getTransactions();

        // assert
        expect(result, tTransactions);
        verify(() => mockLocalDataSource.getTransactions()).called(1);
      });

      test('should throw exception when data source fails', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactions(),
        ).thenThrow(Exception('Database error'));

        // act & assert
        expect(() => repository.getTransactions(), throwsException);
      });
    });

    group('getTransactionById', () {
      const tId = '1';
      final tModel = tTransactionModels.first;

      test('should return transaction when found', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionById(any()),
        ).thenAnswer((_) async => tModel);

        // act
        final result = await repository.getTransactionById(tId);

        // assert
        expect(result, tModel.toEntity());
        verify(() => mockLocalDataSource.getTransactionById(tId)).called(1);
      });

      test('should return null when transaction not found', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionById(any()),
        ).thenAnswer((_) async => null);

        // act
        final result = await repository.getTransactionById(tId);

        // assert
        expect(result, null);
      });
    });

    group('createTransaction', () {
      final tTransaction = Transaction(
        id: '1',
        amount: 150.0,
        categoryId: 'cat1',
        type: 'expense',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      setUpAll(() {
        registerFallbackValue(TransactionModel.fromEntity(tTransaction));
      });

      test('should create transaction in data source', () async {
        // arrange
        when(
          () => mockLocalDataSource.createTransaction(any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.createTransaction(tTransaction);

        // assert
        verify(() => mockLocalDataSource.createTransaction(any())).called(1);
      });
    });

    group('updateTransaction', () {
      final tTransaction = Transaction(
        id: '1',
        amount: 200.0,
        categoryId: 'cat1',
        type: 'expense',
        date: DateTime(2024, 1, 1),
        createdAt: DateTime(2024, 1, 1),
      );

      setUpAll(() {
        registerFallbackValue(TransactionModel.fromEntity(tTransaction));
      });

      test('should update transaction in data source', () async {
        // arrange
        when(
          () => mockLocalDataSource.updateTransaction(any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.updateTransaction(tTransaction);

        // assert
        verify(() => mockLocalDataSource.updateTransaction(any())).called(1);
      });
    });

    group('deleteTransaction', () {
      const tId = '1';

      test('should delete transaction from data source', () async {
        // arrange
        when(
          () => mockLocalDataSource.deleteTransaction(any()),
        ).thenAnswer((_) async => {});

        // act
        await repository.deleteTransaction(tId);

        // assert
        verify(() => mockLocalDataSource.deleteTransaction(tId)).called(1);
      });
    });

    group('getTransactionsByType', () {
      const tType = 'expense';
      final tExpenseModels = [tTransactionModels.first];

      test('should return filtered transactions by type', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionsByType(any()),
        ).thenAnswer((_) async => tExpenseModels);

        // act
        final result = await repository.getTransactionsByType(tType);

        // assert
        expect(result.length, 1);
        expect(result.first.type, tType);
        verify(
          () => mockLocalDataSource.getTransactionsByType(tType),
        ).called(1);
      });
    });

    group('getTransactionsByDateRange', () {
      final tStart = DateTime(2024, 1, 1);
      final tEnd = DateTime(2024, 1, 31);

      test('should return transactions within date range', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionsByDateRange(any(), any()),
        ).thenAnswer((_) async => tTransactionModels);

        // act
        final result = await repository.getTransactionsByDateRange(
          tStart,
          tEnd,
        );

        // assert
        expect(result, tTransactions);
        verify(
          () => mockLocalDataSource.getTransactionsByDateRange(tStart, tEnd),
        ).called(1);
      });
    });

    group('getTransactionsByCategoryId', () {
      const tCategoryId = 'cat1';
      final tCategoryTransactions = [tTransactionModels.first];

      test('should return transactions for specified category', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionsByCategoryId(any()),
        ).thenAnswer((_) async => tCategoryTransactions);

        // act
        final result = await repository.getTransactionsByCategoryId(tCategoryId);

        // assert
        expect(result.length, 1);
        expect(result.first.categoryId, tCategoryId);
        verify(
          () => mockLocalDataSource.getTransactionsByCategoryId(tCategoryId),
        ).called(1);
      });

      test('should return empty list when no transactions for category',
          () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionsByCategoryId(any()),
        ).thenAnswer((_) async => []);

        // act
        final result = await repository.getTransactionsByCategoryId(tCategoryId);

        // assert
        expect(result, isEmpty);
        verify(
          () => mockLocalDataSource.getTransactionsByCategoryId(tCategoryId),
        ).called(1);
      });

      test('should throw exception when data source fails', () async {
        // arrange
        when(
          () => mockLocalDataSource.getTransactionsByCategoryId(any()),
        ).thenThrow(Exception('Database error'));

        // act & assert
        expect(
          () => repository.getTransactionsByCategoryId(tCategoryId),
          throwsException,
        );
      });
    });
  });
}
