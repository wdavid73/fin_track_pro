import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:uuid/uuid.dart';

/// Seeder for default budgets
///
/// Creates predefined budgets for expense categories
@singleton
class BudgetSeeder extends Seeder {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  BudgetSeeder(this._hiveService, LoggerService logger) : super(logger);

  @override
  String get name => 'BudgetSeeder';

  @override
  Future<void> seed() async {
    final budgetBox = _hiveService.getBox(HiveService.budgetsBox);
    final categoryBox = _hiveService.getBox(HiveService.categoriesBox);

    // Skip if budgets already exist
    if (hasData(budgetBox)) {
      logger.info('Budgets already exist, skipping...', tag: name);
      return;
    }

    logger.info('Seeding budgets...', tag: name);

    // Get all expense categories
    final categories = categoryBox.values
        .cast<CategoryModel>()
        .where((cat) => cat.type == 'expense')
        .toList();

    // Budget amounts per category name (matching the hardcoded values)
    final Map<String, double> budgetAmounts = {
      'Alimentación': 500.0,
      'Compras': 800.0,
      'Entretenimiento': 400.0,
      'Transporte': 300.0,
      'Vivienda': 1500.0,
      'Salud': 500.0,
      'Educación': 600.0,
      'Servicios': 400.0,
      'Otros Gastos': 300.0,
    };

    final budgets = <BudgetModel>[];

    for (final category in categories) {
      final amount = budgetAmounts[category.name] ?? 500.0; // Default budget
      final budget = BudgetModel(
        id: _uuid.v4(),
        categoryId: category.id,
        amount: amount,
        period: 'monthly',
      );
      budgets.add(budget);
      await budgetBox.put(budget.id, budget);
    }

    logger.info('Seeded ${budgets.length} budgets successfully', tag: name);
  }
}
