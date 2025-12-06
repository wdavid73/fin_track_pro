import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/transaction.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tDateTime = DateTime(2024, 1, 1);
  final tCreatedAt = DateTime(2024, 1, 1, 10, 0, 0);

  final tTransactionModel = TransactionModel(
    id: '1',
    amount: 100.0,
    categoryId: 'cat1',
    type: 'expense',
    note: 'Test note',
    date: tDateTime,
    createdAt: tCreatedAt,
  );

  final tTransaction = Transaction(
    id: '1',
    amount: 100.0,
    categoryId: 'cat1',
    type: 'expense',
    note: 'Test note',
    date: tDateTime,
    createdAt: tCreatedAt,
  );

  group('TransactionModel', () {
    test('should be a subclass of Transaction entity', () {
      expect(tTransactionModel, isA<Transaction>());
    });

    group('fromEntity', () {
      test('should return a valid model from entity', () {
        final result = TransactionModel.fromEntity(tTransaction);
        expect(result, tTransactionModel);
      });

      test('should handle transaction without note', () {
        final tTransactionWithoutNote = Transaction(
          id: '2',
          amount: 200.0,
          categoryId: 'cat2',
          type: 'income',
          date: tDateTime,
          createdAt: tCreatedAt,
        );

        final result = TransactionModel.fromEntity(tTransactionWithoutNote);

        expect(result.id, '2');
        expect(result.amount, 200.0);
        expect(result.categoryId, 'cat2');
        expect(result.type, 'income');
        expect(result.note, null);
        expect(result.date, tDateTime);
        expect(result.createdAt, tCreatedAt);
      });
    });

    group('toEntity', () {
      test('should return a valid entity from model', () {
        final result = tTransactionModel.toEntity();
        expect(result, tTransaction);
      });

      test('should preserve all fields when converting to entity', () {
        final result = tTransactionModel.toEntity();

        expect(result.id, tTransactionModel.id);
        expect(result.amount, tTransactionModel.amount);
        expect(result.categoryId, tTransactionModel.categoryId);
        expect(result.type, tTransactionModel.type);
        expect(result.note, tTransactionModel.note);
        expect(result.date, tTransactionModel.date);
        expect(result.createdAt, tTransactionModel.createdAt);
      });
    });

    group('equality', () {
      test('should be equal when all properties are the same', () {
        final model1 = TransactionModel(
          id: '1',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          note: 'Test',
          date: tDateTime,
          createdAt: tCreatedAt,
        );

        final model2 = TransactionModel(
          id: '1',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          note: 'Test',
          date: tDateTime,
          createdAt: tCreatedAt,
        );

        expect(model1, equals(model2));
      });

      test('should not be equal when properties differ', () {
        final model1 = TransactionModel(
          id: '1',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          date: tDateTime,
          createdAt: tCreatedAt,
        );

        final model2 = TransactionModel(
          id: '2',
          amount: 100.0,
          categoryId: 'cat1',
          type: 'expense',
          date: tDateTime,
          createdAt: tCreatedAt,
        );

        expect(model1, isNot(equals(model2)));
      });
    });
  });
}
