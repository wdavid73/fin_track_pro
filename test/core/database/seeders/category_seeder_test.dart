import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/category_seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class MockLoggerService extends Mock implements LoggerService {}

class MockHiveService extends Mock implements HiveService {}

/// A FakeBox that tracks put() calls for assertions.
class _FakeBox extends Fake implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Iterable get values => _data.values;

  @override
  int get length => _data.length;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }

  @override
  Future<int> add(dynamic value) async {
    final key = _data.length;
    _data[key] = value;
    return key;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockLoggerService logger;
  late MockHiveService hiveService;
  late _FakeBox categoriesBox;
  late CategorySeeder seeder;

  setUp(() {
    logger = MockLoggerService();
    hiveService = MockHiveService();
    categoriesBox = _FakeBox();
    seeder = CategorySeeder(hiveService, logger);

    // Stub calls
    when(
      () => hiveService.getBox(HiveService.categoriesBox),
    ).thenReturn(categoriesBox);
    when(() => logger.info(any(), tag: any(named: 'tag'))).thenReturn(null);
    when(() => logger.warning(any(), tag: any(named: 'tag'))).thenReturn(null);
  });

  group('CategorySeeder', () {
    test('name returns CategorySeeder', () {
      expect(seeder.name, 'CategorySeeder');
    });

    test('skips seeding when categories box already has data', () async {
      // Pre-populate the box so hasData returns true
      await categoriesBox.put('existing', 'value');

      await seeder.seed();

      // Only 1 item — the pre-existing one, no new categories added
      expect(categoriesBox.length, 1);
      verify(() => logger.info(any(), tag: 'CategorySeeder')).called(1);
    });

    test('seeds 13 categories when box is empty', () async {
      await seeder.seed();

      // 4 income + 9 expense = 13 total
      expect(categoriesBox.length, 13);
    });

    test('seeded categories include both income and expense types', () async {
      await seeder.seed();

      final items = categoriesBox.values.toList();
      final types = items.map((c) => (c as dynamic).type).toSet();
      expect(types, containsAll(['income', 'expense']));
    });

    test('seeded income categories include Salario and Freelance', () async {
      await seeder.seed();

      final incomeNames = categoriesBox.values
          .where((c) => (c as dynamic).type == 'income')
          .map((c) => (c as dynamic).name)
          .toList();

      expect(incomeNames, containsAll(['Salario', 'Freelance']));
    });

    test(
      'seeded expense categories include Alimentación and Transporte',
      () async {
        await seeder.seed();

        final expenseNames = categoriesBox.values
            .where((c) => (c as dynamic).type == 'expense')
            .map((c) => (c as dynamic).name)
            .toList();

        expect(expenseNames, containsAll(['Alimentación', 'Transporte']));
      },
    );

    test('logs success after seeding', () async {
      await seeder.seed();

      verify(
        () => logger.info(any(that: contains('13')), tag: 'CategorySeeder'),
      ).called(1);
    });
  });
}
