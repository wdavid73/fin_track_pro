import 'package:fin_track_pro/features/settings/data/models/settings_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/database/seeders/database_seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';

@singleton
class HiveService {
  static const String categoriesBox = 'categories';
  static const String transactionsBox = 'transactions';
  static const String budgetsBox = 'budgets';
  static const String settingsBox = 'settings';

  HiveService();

  Future<void> init({
    bool runSeeders = true,
    DatabaseSeeder? databaseSeeder,
  }) async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(BudgetModelAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(SettingsModelAdapter());
    }

    // Open boxes and wait for them to be fully opened
    await _openBoxSafely<CategoryModel>(categoriesBox);
    await _openBoxSafely<TransactionModel>(transactionsBox);
    await _openBoxSafely<BudgetModel>(budgetsBox);
    await _openBoxSafely<SettingsModel>(settingsBox);

    // Run seeders only in development mode and if requested
    // IMPORTANT: This runs AFTER boxes are opened
    if (runSeeders &&
        FlavorConfig.isInitialized &&
        FlavorConfig.instance.isDev &&
        databaseSeeder != null) {
      await databaseSeeder.seedAll();
    }
  }

  /// Opens a box, recovering from schema-incompatible or corrupted local
  /// data by deleting and recreating the box instead of crashing app startup.
  ///
  /// Necessary because Hive fields added to existing models (e.g. `updatedAt`
  /// for Firestore sync) are missing on records written before the field
  /// existed, and the generated adapter has no way to default a `DateTime`
  /// (Dart's `DateTime` has no const constructor, so Hive's `defaultValue`
  /// mechanism can't be used for it).
  Future<void> _openBoxSafely<T>(String name) async {
    try {
      await Hive.openBox<T>(name);
    } catch (e, stackTrace) {
      LoggerService().warning(
        'Failed to open Hive box "$name", recreating it: $e',
        tag: 'HiveService',
        error: e,
        stackTrace: stackTrace,
      );
      await Hive.deleteBoxFromDisk(name);
      await Hive.openBox<T>(name);
    }
  }

  Box getBox(String boxName) {
    // Use typed box access to avoid errors when box is already open
    if (boxName == categoriesBox) {
      return Hive.box<CategoryModel>(boxName);
    } else if (boxName == transactionsBox) {
      return Hive.box<TransactionModel>(boxName);
    } else if (boxName == budgetsBox) {
      return Hive.box<BudgetModel>(boxName);
    } else if (boxName == settingsBox) {
      return Hive.box<SettingsModel>(boxName);
    }
    return Hive.box(boxName);
  }

  Future<void> clearAll() async {
    await Hive.box(categoriesBox).clear();
    await Hive.box(transactionsBox).clear();
    await Hive.box(budgetsBox).clear();
    await Hive.box(settingsBox).clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}
