import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/database/seeders/database_seeder.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';

@singleton
class HiveService {
  static const String categoriesBox = 'categories';
  static const String transactionsBox = 'transactions';
  static const String budgetsBox = 'budgets';

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

    // Open boxes and wait for them to be fully opened
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox<TransactionModel>(transactionsBox);
    await Hive.openBox<BudgetModel>(budgetsBox);

    // Run seeders only in development mode and if requested
    // IMPORTANT: This runs AFTER boxes are opened
    if (runSeeders &&
        FlavorConfig.isInitialized &&
        FlavorConfig.instance.isDev &&
        databaseSeeder != null) {
      await databaseSeeder.seedAll();
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
    }
    return Hive.box(boxName);
  }

  Future<void> clearAll() async {
    await Hive.box(categoriesBox).clear();
    await Hive.box(transactionsBox).clear();
    await Hive.box(budgetsBox).clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}
