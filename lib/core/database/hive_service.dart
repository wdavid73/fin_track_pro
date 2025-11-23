import 'package:hive_flutter/hive_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';

@singleton
class HiveService {
  static const String categoriesBox = 'categories';
  static const String transactionsBox = 'transactions';

  Future<void> init() async {
    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CategoryModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(TransactionModelAdapter());
    }

    // Open boxes
    await Hive.openBox<CategoryModel>(categoriesBox);
    await Hive.openBox<TransactionModel>(transactionsBox);
  }

  Box getBox(String boxName) {
    return Hive.box(boxName);
  }

  Future<void> clearAll() async {
    await Hive.box(categoriesBox).clear();
    await Hive.box(transactionsBox).clear();
  }

  Future<void> close() async {
    await Hive.close();
  }
}
