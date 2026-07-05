import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/transaction_seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class MockLoggerService extends Mock implements LoggerService {}

class MockHiveService extends Mock implements HiveService {}

class _FakeBox extends Fake implements Box {
  final List<dynamic> _data;

  _FakeBox([List<dynamic>? initial]) : _data = List.from(initial ?? []);

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Iterable get values => List.unmodifiable(_data);

  @override
  int get length => _data.length;

  @override
  Future<void> put(dynamic key, dynamic value) async => _data.add(value);

  @override
  Future<int> add(dynamic value) async {
    _data.add(value);
    return _data.length - 1;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CategoryModel _cat(String id, String name, String type) => CategoryModel(
  id: id,
  name: name,
  icon: 'icon',
  color: 0xFF000000,
  type: type,
  updatedAt: DateTime.now(),
);

final _expenseCategories = [
  _cat('cat-food', 'Alimentación', 'expense'),
  _cat('cat-transport', 'Transporte', 'expense'),
];

final _incomeCategories = [
  _cat('cat-salary', 'Salario', 'income'),
  _cat('cat-freelance', 'Freelance', 'income'),
];

final _allCategories = [..._expenseCategories, ..._incomeCategories];

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockLoggerService logger;
  late MockHiveService hiveService;
  late _FakeBox transactionsBox;
  late _FakeBox categoriesBox;
  late TransactionSeeder seeder;

  setUp(() {
    logger = MockLoggerService();
    hiveService = MockHiveService();
    transactionsBox = _FakeBox();
    categoriesBox = _FakeBox(_allCategories);
    seeder = TransactionSeeder(hiveService, logger);

    when(
      () => hiveService.getBox(HiveService.transactionsBox),
    ).thenReturn(transactionsBox);
    when(
      () => hiveService.getBox(HiveService.categoriesBox),
    ).thenReturn(categoriesBox);
    when(() => logger.info(any(), tag: any(named: 'tag'))).thenReturn(null);
    when(() => logger.warning(any(), tag: any(named: 'tag'))).thenReturn(null);
  });

  group('TransactionSeeder', () {
    test('name returns TransactionSeeder', () {
      expect(seeder.name, 'TransactionSeeder');
    });

    test('skips seeding when transactions box already has data', () async {
      final nonEmptyBox = _FakeBox(['existing']);
      when(
        () => hiveService.getBox(HiveService.transactionsBox),
      ).thenReturn(nonEmptyBox);

      await seeder.seed();

      // Only original item remains — no new ones added
      expect(nonEmptyBox.length, 1);
      verify(() => logger.info(any(), tag: 'TransactionSeeder')).called(1);
    });

    test('skips seeding and logs warning when categories are empty', () async {
      when(
        () => hiveService.getBox(HiveService.categoriesBox),
      ).thenReturn(_FakeBox()); // empty categories

      await seeder.seed();

      expect(transactionsBox.length, 0);
      verify(() => logger.warning(any(), tag: 'TransactionSeeder')).called(1);
    });

    test('seeds more than 30 transactions for 30 days', () async {
      await seeder.seed();

      // At minimum 1 expense per day × 30 days = 30 transactions
      // Plus at least 2 salary payments (days 0 and 15)
      expect(transactionsBox.length, greaterThanOrEqualTo(32));
    });

    test('seeded transactions contain both income and expense types', () async {
      await seeder.seed();

      final types = transactionsBox.values
          .map((t) => (t as dynamic).type as String)
          .toSet();
      expect(types, containsAll(['income', 'expense']));
    });

    test('all seeded transactions have a valid categoryId', () async {
      await seeder.seed();

      final validIds = _allCategories.map((c) => c.id).toSet();
      final txCategoryIds = transactionsBox.values
          .map((t) => (t as dynamic).categoryId as String)
          .toSet();

      expect(txCategoryIds.every((id) => validIds.contains(id)), isTrue);
    });

    test('all seeded transactions have a positive amount', () async {
      await seeder.seed();

      final amounts = transactionsBox.values
          .map((t) => (t as dynamic).amount as double)
          .toList();
      expect(amounts.every((a) => a > 0), isTrue);
    });

    test('logs success after seeding', () async {
      await seeder.seed();

      // logger.info is called twice: 'Seeding...' and 'Seeded N transactions'
      verify(
        () => logger.info(
          any(that: contains('transactions')),
          tag: 'TransactionSeeder',
        ),
      ).called(2);
    });
  });
}
