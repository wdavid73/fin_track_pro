import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/budgets/data/datasources/firestore_budget_datasource.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreBudgetDataSource sut;

  final budget = BudgetModel(
    id: 'b1',
    categoryId: 'cat1',
    amount: 500,
    period: 'monthly',
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    sut = FirestoreBudgetDataSource(firestore);
  });

  test('writes under environments/{flavor}/users/{userId}/budgets', () async {
    FlavorConfig.initialize(
      flavor: Flavor.prod,
      appName: 'Test',
      bundleId: 'com.test',
      enableLogging: false,
      showDebugBanner: false,
    );

    await sut.saveBudget('user1', budget);

    final doc = await firestore
        .collection('environments')
        .doc('prod')
        .collection('users')
        .doc('user1')
        .collection('budgets')
        .doc('b1')
        .get();

    expect(doc.exists, isTrue);
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

    test('saveBudget then getBudgets roundtrips via toMap/fromMap', () async {
      await sut.saveBudget('user1', budget);

      final result = await sut.getBudgets('user1');

      expect(result, hasLength(1));
      expect(result.single.id, budget.id);
      expect(result.single.amount, budget.amount);
    });

    test('saveBudget upserts (merge) on the same id', () async {
      await sut.saveBudget('user1', budget);
      final updated = BudgetModel(
        id: budget.id,
        categoryId: budget.categoryId,
        amount: 750,
        period: budget.period,
        updatedAt: DateTime(2026, 1, 2),
      );

      await sut.saveBudget('user1', updated);
      final result = await sut.getBudgets('user1');

      expect(result, hasLength(1));
      expect(result.single.amount, 750);
    });

    test('deleteBudget removes the document', () async {
      await sut.saveBudget('user1', budget);

      await sut.deleteBudget('user1', budget.id);
      final result = await sut.getBudgets('user1');

      expect(result, isEmpty);
    });

    test('uploadAll batches multiple documents', () async {
      final second = BudgetModel(
        id: 'b2',
        categoryId: 'cat2',
        amount: 200,
        period: 'weekly',
        updatedAt: DateTime(2026, 1, 1),
      );

      await sut.uploadAll('user1', [budget, second]);
      final result = await sut.getBudgets('user1');

      expect(result, hasLength(2));
    });

    test('deleteAll removes every document for the user', () async {
      await sut.saveBudget('user1', budget);

      await sut.deleteAll('user1');
      final result = await sut.getBudgets('user1');

      expect(result, isEmpty);
    });
  });
}
