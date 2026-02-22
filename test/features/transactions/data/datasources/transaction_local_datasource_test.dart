import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/transaction_local_datasource.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

class MockHiveService extends Mock implements HiveService {}

class MockBox extends Mock implements Box<TransactionModel> {}

void main() {
  late TransactionLocalDataSource datasource;
  late MockHiveService mockHiveService;
  late MockBox mockBox;

  setUpAll(() {
    registerFallbackValue(
      TransactionModel(
        id: 'fallback',
        amount: 0,
        categoryId: 'fallback',
        type: 'expense',
        date: DateTime.now(),
        createdAt: DateTime.now(),
        note: 'fallback',
      ),
    );
  });

  setUp(() {
    mockHiveService = MockHiveService();
    mockBox = MockBox();
    datasource = TransactionLocalDataSource(mockHiveService);

    when(
      () => mockHiveService.getBox(HiveService.transactionsBox),
    ).thenReturn(mockBox);
  });

  final tTransactionModel = TransactionModel(
    id: '1',
    amount: 100.0,
    categoryId: 'cat1',
    type: 'expense',
    date: DateTime(2024, 1, 1),
    createdAt: DateTime(2024, 1, 1),
    note: 'Test',
  );

  group('TransactionLocalDataSource', () {
    group('getTransactions', () {
      test('should return sorted list of transactions from box', () async {
        // arrange
        when(() => mockBox.values).thenReturn([tTransactionModel]);

        // act
        final result = await datasource.getTransactions();

        // assert
        verify(
          () => mockHiveService.getBox(HiveService.transactionsBox),
        ).called(1);
        expect(result, equals([tTransactionModel]));
      });
    });

    group('getTransactionById', () {
      test('should return transaction when found', () async {
        // arrange
        when(() => mockBox.get('1')).thenReturn(tTransactionModel);

        // act
        final result = await datasource.getTransactionById('1');

        // assert
        verify(() => mockBox.get('1')).called(1);
        expect(result, equals(tTransactionModel));
      });
    });

    group('createTransaction', () {
      test('should save transaction to box', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

        // act
        await datasource.createTransaction(tTransactionModel);

        // assert
        verify(
          () => mockBox.put(tTransactionModel.id, tTransactionModel),
        ).called(1);
      });
    });

    group('updateTransaction', () {
      test('should update transaction in box', () async {
        // arrange
        when(() => mockBox.put(any(), any())).thenAnswer((_) async => {});

        // act
        await datasource.updateTransaction(tTransactionModel);

        // assert
        verify(
          () => mockBox.put(tTransactionModel.id, tTransactionModel),
        ).called(1);
      });
    });

    group('deleteTransaction', () {
      test('should delete transaction from box', () async {
        // arrange
        when(() => mockBox.delete(any())).thenAnswer((_) async => {});

        // act
        await datasource.deleteTransaction('1');

        // assert
        verify(() => mockBox.delete('1')).called(1);
      });
    });

    group('getPaginatedTransactions', () {
      test('should return paginated transactions', () async {
        // arrange
        final tTransactions = List.generate(
          10,
          (index) => TransactionModel(
            id: '$index',
            amount: 100.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 1).add(Duration(days: index)),
            createdAt: DateTime(2024, 1, 1),
            note: 'Test $index',
          ),
        );
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getPaginatedTransactions(
          limit: 5,
          offset: 0,
        );

        // assert
        // Should return 5 newest transactions (indices 9, 8, 7, 6, 5)
        expect(result.length, 5);
        expect(result.first.id, '9');
      });

      test(
        'should return empty list when offset is greater than list length',
        () async {
          // arrange
          final tTransactions = List.generate(
            5,
            (index) => TransactionModel(
              id: '$index',
              amount: 100.0,
              categoryId: 'cat1',
              type: 'expense',
              date: DateTime(2024, 1, 1).add(Duration(days: index)),
              createdAt: DateTime(2024, 1, 1),
              note: 'Test $index',
            ),
          );
          when(() => mockBox.values).thenReturn(tTransactions);

          // act
          final result = await datasource.getPaginatedTransactions(
            limit: 5,
            offset: 10,
          );

          // assert
          expect(result, isEmpty);
        },
      );

      test(
        'should return remaining items when limit exceeds remaining items',
        () async {
          // arrange
          final tTransactions = List.generate(
            10,
            (index) => TransactionModel(
              id: '$index',
              amount: 100.0,
              categoryId: 'cat1',
              type: 'expense',
              date: DateTime(2024, 1, 1).add(Duration(days: index)),
              createdAt: DateTime(2024, 1, 1),
              note: 'Test $index',
            ),
          );
          when(() => mockBox.values).thenReturn(tTransactions);

          // act
          final result = await datasource.getPaginatedTransactions(
            limit: 10,
            offset: 5,
          );

          // assert
          expect(result.length, 5);
        },
      );
    });

    group('getTransactionsByDateRange', () {
      test('should return transactions within date range', () async {
        // arrange
        final startDate = DateTime(2024, 1, 5);
        final endDate = DateTime(2024, 1, 10);
        final tTransactions = [
          TransactionModel(
            id: '1',
            amount: 100.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 6),
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '2',
            amount: 200.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 4),
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '3',
            amount: 300.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 8),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByDateRange(
          startDate,
          endDate,
        );

        // assert
        expect(result.length, 2);
        expect(result.any((t) => t.id == '1'), true);
        expect(result.any((t) => t.id == '3'), true);
      });

      test('should return sorted transactions by date descending', () async {
        // arrange
        final startDate = DateTime(2024, 1, 1);
        final endDate = DateTime(2024, 1, 30);
        final tTransactions = [
          TransactionModel(
            id: '1',
            amount: 100.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 5),
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '2',
            amount: 200.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 15),
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '3',
            amount: 300.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 10),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByDateRange(
          startDate,
          endDate,
        );

        // assert
        expect(result.first.id, '2'); // Most recent
        expect(result.last.id, '1'); // Oldest
      });
    });

    group('getTransactionsByType', () {
      test('should return only expense transactions', () async {
        // arrange
        final tTransactions = [
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
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '3',
            amount: 300.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 3),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByType('expense');

        // assert
        expect(result.length, 2);
        expect(result.every((t) => t.type == 'expense'), true);
      });

      test('should return only income transactions', () async {
        // arrange
        final tTransactions = [
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
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByType('income');

        // assert
        expect(result.length, 1);
        expect(result.first.type, 'income');
        expect(result.first.id, '2');
      });

      test('should return sorted transactions by date descending', () async {
        // arrange
        final tTransactions = [
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
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 5),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByType('expense');

        // assert
        expect(result.first.id, '2'); // Most recent
        expect(result.last.id, '1'); // Oldest
      });
    });

    group('getTransactionsByCategoryId', () {
      test('should return only transactions for specified category', () async {
        // arrange
        final tTransactions = [
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
            type: 'expense',
            date: DateTime(2024, 1, 2),
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '3',
            amount: 300.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 3),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByCategoryId('cat1');

        // assert
        expect(result.length, 2);
        expect(result.every((t) => t.categoryId == 'cat1'), true);
        expect(result.any((t) => t.id == '1'), true);
        expect(result.any((t) => t.id == '3'), true);
      });

      test(
        'should return empty list when no transactions for category',
        () async {
          // arrange
          final tTransactions = [
            TransactionModel(
              id: '1',
              amount: 100.0,
              categoryId: 'cat1',
              type: 'expense',
              date: DateTime(2024, 1, 1),
              createdAt: DateTime(2024, 1, 1),
            ),
          ];
          when(() => mockBox.values).thenReturn(tTransactions);

          // act
          final result = await datasource.getTransactionsByCategoryId('cat2');

          // assert
          expect(result, isEmpty);
        },
      );

      test('should return sorted transactions by date descending', () async {
        // arrange
        final tTransactions = [
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
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 10),
            createdAt: DateTime(2024, 1, 1),
          ),
          TransactionModel(
            id: '3',
            amount: 300.0,
            categoryId: 'cat1',
            type: 'expense',
            date: DateTime(2024, 1, 5),
            createdAt: DateTime(2024, 1, 1),
          ),
        ];
        when(() => mockBox.values).thenReturn(tTransactions);

        // act
        final result = await datasource.getTransactionsByCategoryId('cat1');

        // assert
        expect(result.length, 3);
        expect(result.first.id, '2'); // Most recent (Jan 10)
        expect(result[1].id, '3'); // Middle (Jan 5)
        expect(result.last.id, '1'); // Oldest (Jan 1)
      });
    });
  });
}
