import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/transactions/data/datasources/firestore_transaction_datasource.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreTransactionDataSource sut;

  final transaction = TransactionModel(
    id: 't1',
    amount: 42.5,
    categoryId: 'cat1',
    type: 'expense',
    note: 'note',
    date: DateTime(2026, 1, 1),
    createdAt: DateTime(2026, 1, 1),
    updatedAt: DateTime(2026, 1, 2),
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    sut = FirestoreTransactionDataSource(firestore);
  });

  group('flavor separation', () {
    test('writes under environments/{flavor}/users/{userId}/transactions', () async {
      FlavorConfig.initialize(
        flavor: Flavor.dev,
        appName: 'Test',
        bundleId: 'com.test',
        enableLogging: false,
        showDebugBanner: false,
      );

      await sut.createTransaction('user1', transaction);

      final doc = await firestore
          .collection('environments')
          .doc('dev')
          .collection('users')
          .doc('user1')
          .collection('transactions')
          .doc('t1')
          .get();

      expect(doc.exists, isTrue);
    });

    test('dev and prod flavors never see each other\'s data', () async {
      FlavorConfig.initialize(
        flavor: Flavor.dev,
        appName: 'Test',
        bundleId: 'com.test',
        enableLogging: false,
        showDebugBanner: false,
      );
      await sut.createTransaction('user1', transaction);

      FlavorConfig.initialize(
        flavor: Flavor.prod,
        appName: 'Test',
        bundleId: 'com.test',
        enableLogging: false,
        showDebugBanner: false,
      );
      final prodResult = await sut.getTransactions('user1');

      expect(prodResult, isEmpty);
    });
  });

  group('CRUD + roundtrip', () {
    setUp(() {
      FlavorConfig.initialize(
        flavor: Flavor.dev,
        appName: 'Test',
        bundleId: 'com.test',
        enableLogging: false,
        showDebugBanner: false,
      );
    });

    test('createTransaction then getTransactions roundtrips via toMap/fromMap', () async {
      await sut.createTransaction('user1', transaction);

      final result = await sut.getTransactions('user1');

      expect(result, hasLength(1));
      expect(result.single.id, transaction.id);
      expect(result.single.amount, transaction.amount);
      expect(result.single.updatedAt, transaction.updatedAt);
    });

    test('updateTransaction merges fields without overwriting the document', () async {
      await sut.createTransaction('user1', transaction);
      final updated = TransactionModel(
        id: transaction.id,
        amount: 99,
        categoryId: transaction.categoryId,
        type: transaction.type,
        note: transaction.note,
        date: transaction.date,
        createdAt: transaction.createdAt,
        updatedAt: DateTime(2026, 1, 3),
      );

      await sut.updateTransaction('user1', updated);
      final result = await sut.getTransactions('user1');

      expect(result.single.amount, 99);
    });

    test('deleteTransaction removes the document', () async {
      await sut.createTransaction('user1', transaction);

      await sut.deleteTransaction('user1', transaction.id);
      final result = await sut.getTransactions('user1');

      expect(result, isEmpty);
    });

    test('uploadAll batches multiple documents', () async {
      final second = TransactionModel(
        id: 't2',
        amount: 10,
        categoryId: 'cat2',
        type: 'income',
        note: null,
        date: DateTime(2026, 1, 5),
        createdAt: DateTime(2026, 1, 5),
        updatedAt: DateTime(2026, 1, 5),
      );

      await sut.uploadAll('user1', [transaction, second]);
      final result = await sut.getTransactions('user1');

      expect(result, hasLength(2));
    });

    test('deleteAll removes every document for the user', () async {
      await sut.createTransaction('user1', transaction);

      await sut.deleteAll('user1');
      final result = await sut.getTransactions('user1');

      expect(result, isEmpty);
    });
  });
}
