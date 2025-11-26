import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/seeders/seeder.dart';
import 'package:fin_track_pro/core/database/seeders/category_seeder.dart';
import 'package:fin_track_pro/core/database/seeders/budget_seeder.dart';
import 'package:fin_track_pro/core/database/seeders/transaction_seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';

/// Main database seeder orchestrator
///
/// Executes all seeders in the correct order
/// Handles dependencies between seeders
@singleton
class DatabaseSeeder {
  final CategorySeeder _categorySeeder;
  final BudgetSeeder _budgetSeeder;
  final TransactionSeeder _transactionSeeder;
  final LoggerService _logger;

  DatabaseSeeder(
    this._categorySeeder,
    this._budgetSeeder,
    this._transactionSeeder,
    this._logger,
  );

  /// Run all seeders in order
  ///
  /// This method executes all registered seeders in the correct order
  /// to ensure dependencies are met (e.g., categories before transactions)
  Future<void> seedAll() async {
    _logger.info('🌱 Starting database seeding...', tag: 'DatabaseSeeder');

    final seeders = <Seeder>[
      _categorySeeder,
      _budgetSeeder, // Must run after categories
      _transactionSeeder,
    ];

    for (final seeder in seeders) {
      try {
        await seeder.seed();
      } catch (e, stackTrace) {
        _logger.error(
          'Error seeding ${seeder.name}',
          tag: 'DatabaseSeeder',
          error: e,
          stackTrace: stackTrace,
        );
      }
    }

    _logger.info('✅ Database seeding completed!', tag: 'DatabaseSeeder');
  }

  /// Run a specific seeder by name
  Future<void> seedOne(String seederName) async {
    final seederMap = {
      'CategorySeeder': _categorySeeder,
      'BudgetSeeder': _budgetSeeder,
      'TransactionSeeder': _transactionSeeder,
    };

    final seeder = seederMap[seederName];
    if (seeder == null) {
      _logger.warning('Seeder not found: $seederName', tag: 'DatabaseSeeder');
      return;
    }

    _logger.info('🌱 Running $seederName...', tag: 'DatabaseSeeder');
    try {
      await seeder.seed();
      _logger.info('✅ $seederName completed!', tag: 'DatabaseSeeder');
    } catch (e, stackTrace) {
      _logger.error(
        'Error seeding ${seeder.name}',
        tag: 'DatabaseSeeder',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }
}
