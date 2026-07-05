import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/categories/data/datasources/firestore_category_datasource.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late FirestoreCategoryDataSource sut;

  final category = CategoryModel(
    id: 'c1',
    name: 'Food',
    icon: '🍔',
    color: 0xFF00FF00,
    type: 'expense',
    updatedAt: DateTime(2026, 1, 1),
  );

  setUp(() {
    firestore = FakeFirebaseFirestore();
    sut = FirestoreCategoryDataSource(firestore);
  });

  test('writes under environments/{flavor}/users/{userId}/categories', () async {
    FlavorConfig.initialize(
      flavor: Flavor.staging,
      appName: 'Test',
      bundleId: 'com.test',
      enableLogging: false,
      showDebugBanner: false,
    );

    await sut.createCategory('user1', category);

    final doc = await firestore
        .collection('environments')
        .doc('staging')
        .collection('users')
        .doc('user1')
        .collection('categories')
        .doc('c1')
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

    test('createCategory then getCategories roundtrips via toMap/fromMap', () async {
      await sut.createCategory('user1', category);

      final result = await sut.getCategories('user1');

      expect(result, hasLength(1));
      expect(result.single.id, category.id);
      expect(result.single.name, category.name);
    });

    test('updateCategory merges fields', () async {
      await sut.createCategory('user1', category);
      final updated = CategoryModel(
        id: category.id,
        name: 'Groceries',
        icon: category.icon,
        color: category.color,
        type: category.type,
        updatedAt: DateTime(2026, 1, 2),
      );

      await sut.updateCategory('user1', updated);
      final result = await sut.getCategories('user1');

      expect(result.single.name, 'Groceries');
    });

    test('deleteCategory removes the document', () async {
      await sut.createCategory('user1', category);

      await sut.deleteCategory('user1', category.id);
      final result = await sut.getCategories('user1');

      expect(result, isEmpty);
    });

    test('uploadAll batches multiple documents', () async {
      final second = CategoryModel(
        id: 'c2',
        name: 'Transport',
        icon: '🚗',
        color: 0xFFFF0000,
        type: 'expense',
        updatedAt: DateTime(2026, 1, 1),
      );

      await sut.uploadAll('user1', [category, second]);
      final result = await sut.getCategories('user1');

      expect(result, hasLength(2));
    });

    test('deleteAll removes every document for the user', () async {
      await sut.createCategory('user1', category);

      await sut.deleteAll('user1');
      final result = await sut.getCategories('user1');

      expect(result, isEmpty);
    });
  });
}
