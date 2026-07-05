import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/budget_seeder.dart';
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
  final Map<dynamic, dynamic> _data = {};
  final List<dynamic> _initial;

  _FakeBox({List<dynamic>? initial}) : _initial = initial ?? [];

  @override
  bool get isEmpty => _data.isEmpty && _initial.isEmpty;

  @override
  bool get isNotEmpty => !isEmpty;

  @override
  Iterable get values => _data.isEmpty ? _initial : _data.values;

  @override
  int get length => _data.isEmpty ? _initial.length : _data.length;

  @override
  Future<void> put(dynamic key, dynamic value) async {
    _data[key] = value;
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

CategoryModel _cat(String name, String type) => CategoryModel(
  id: 'cat-${name.toLowerCase().replaceAll(' ', '-')}',
  name: name,
  icon: 'icon',
  color: 0xFF000000,
  type: type,
  updatedAt: DateTime.now(),
);

// Default categories: 2 expense + 1 income (income should be ignored)
final _defaultCategories = [
  _cat('Alimentación', 'expense'),
  _cat('Transporte', 'expense'),
  _cat('Salario', 'income'),
];

BudgetSeeder _buildSeeder({
  required MockHiveService hiveService,
  required MockLoggerService logger,
  List<dynamic> initialBudgets = const [],
  List<dynamic>? categories,
}) {
  final budgetBox = _FakeBox(initial: initialBudgets);
  final categoryBox = _FakeBox(initial: categories ?? _defaultCategories);

  when(() => hiveService.getBox(HiveService.budgetsBox)).thenReturn(budgetBox);
  when(
    () => hiveService.getBox(HiveService.categoriesBox),
  ).thenReturn(categoryBox);

  return BudgetSeeder(hiveService, logger);
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockLoggerService logger;
  late MockHiveService hiveService;

  setUp(() {
    logger = MockLoggerService();
    hiveService = MockHiveService();
    when(() => logger.info(any(), tag: any(named: 'tag'))).thenReturn(null);
    when(() => logger.warning(any(), tag: any(named: 'tag'))).thenReturn(null);
  });

  group('BudgetSeeder', () {
    test('name returns BudgetSeeder', () {
      final seeder = _buildSeeder(hiveService: hiveService, logger: logger);
      expect(seeder.name, 'BudgetSeeder');
    });

    test('skips seeding when budget box already has data', () async {
      final seeder = _buildSeeder(
        hiveService: hiveService,
        logger: logger,
        initialBudgets: ['existing'],
      );

      await seeder.seed();

      verify(() => logger.info(any(), tag: 'BudgetSeeder')).called(1);
    });

    test('creates one budget per expense category only', () async {
      // Setup: capture the budgetBox that the seeder writes to
      final budgetBox = _FakeBox();
      final categoryBox = _FakeBox(initial: _defaultCategories);
      when(
        () => hiveService.getBox(HiveService.budgetsBox),
      ).thenReturn(budgetBox);
      when(
        () => hiveService.getBox(HiveService.categoriesBox),
      ).thenReturn(categoryBox);

      final seeder = BudgetSeeder(hiveService, logger);
      await seeder.seed();

      // 2 expense categories → 2 budgets (income ignored)
      expect(budgetBox.length, 2);
    });

    test('assigns known amounts for known category names', () async {
      final budgetBox = _FakeBox();
      final categoryBox = _FakeBox(initial: _defaultCategories);
      when(
        () => hiveService.getBox(HiveService.budgetsBox),
      ).thenReturn(budgetBox);
      when(
        () => hiveService.getBox(HiveService.categoriesBox),
      ).thenReturn(categoryBox);

      final seeder = BudgetSeeder(hiveService, logger);
      await seeder.seed();

      final amounts = budgetBox._data.values
          .map((b) => (b as dynamic).amount as double)
          .toList();
      expect(amounts, containsAll([1500000.0, 500000.0]));
    });

    test('assigns default 500.0 amount for unknown category names', () async {
      final budgetBox = _FakeBox();
      final categoryBox = _FakeBox(initial: [_cat('Misceláneos', 'expense')]);
      when(
        () => hiveService.getBox(HiveService.budgetsBox),
      ).thenReturn(budgetBox);
      when(
        () => hiveService.getBox(HiveService.categoriesBox),
      ).thenReturn(categoryBox);

      final seeder = BudgetSeeder(hiveService, logger);
      await seeder.seed();

      final amount = (budgetBox._data.values.first as dynamic).amount as double;
      expect(amount, 500.0);
    });

    test('all created budgets have period monthly', () async {
      final budgetBox = _FakeBox();
      final categoryBox = _FakeBox(initial: _defaultCategories);
      when(
        () => hiveService.getBox(HiveService.budgetsBox),
      ).thenReturn(budgetBox);
      when(
        () => hiveService.getBox(HiveService.categoriesBox),
      ).thenReturn(categoryBox);

      final seeder = BudgetSeeder(hiveService, logger);
      await seeder.seed();

      final periods = budgetBox._data.values
          .map((b) => (b as dynamic).period as String)
          .toSet();
      expect(periods, {'monthly'});
    });

    test('logs success with count after seeding', () async {
      final seeder = _buildSeeder(hiveService: hiveService, logger: logger);
      await seeder.seed();

      // seed() calls info twice: 'Seeding budgets...' + 'Seeded N budgets'
      verify(() => logger.info(any(), tag: 'BudgetSeeder')).called(2);
    });
  });
}
