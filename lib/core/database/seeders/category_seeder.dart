import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:uuid/uuid.dart';

/// Seeder for default categories
///
/// Creates predefined income and expense categories
@singleton
class CategorySeeder extends Seeder {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();

  CategorySeeder(this._hiveService, LoggerService logger) : super(logger);

  @override
  String get name => 'CategorySeeder';

  @override
  Future<void> seed() async {
    final box = _hiveService.getBox(HiveService.categoriesBox);

    // Skip if categories already exist
    if (hasData(box)) {
      logger.info('Categories already exist, skipping...', tag: name);
      return;
    }

    logger.info('Seeding categories...', tag: name);

    final categories = [
      // Income Categories
      CategoryModel(
        id: _uuid.v4(),
        name: 'Salario',
        icon: 'work',
        color: Colors.green.toARGB32(),
        type: 'income',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Freelance',
        icon: 'laptop',
        color: Colors.teal.toARGB32(),
        type: 'income',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Inversiones',
        icon: 'trending_up',
        color: Colors.blue.toARGB32(),
        type: 'income',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Otros Ingresos',
        icon: 'attach_money',
        color: Colors.lightGreen.toARGB32(),
        type: 'income',
      ),

      // Expense Categories
      CategoryModel(
        id: _uuid.v4(),
        name: 'Alimentación',
        icon: 'restaurant',
        color: Colors.orange.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Transporte',
        icon: 'directions_car',
        color: Colors.purple.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Vivienda',
        icon: 'home',
        color: Colors.brown.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Entretenimiento',
        icon: 'movie',
        color: Colors.pink.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Salud',
        icon: 'local_hospital',
        color: Colors.red.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Educación',
        icon: 'school',
        color: Colors.indigo.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Compras',
        icon: 'shopping_bag',
        color: Colors.deepOrange.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Servicios',
        icon: 'settings',
        color: Colors.blueGrey.toARGB32(),
        type: 'expense',
      ),
      CategoryModel(
        id: _uuid.v4(),
        name: 'Otros Gastos',
        icon: 'more_horiz',
        color: Colors.grey.toARGB32(),
        type: 'expense',
      ),
    ];

    // Add all categories to the box using category ID as key
    for (final category in categories) {
      await box.put(category.id, category);
    }

    logger.info(
      'Seeded ${categories.length} categories successfully',
      tag: name,
    );
  }
}
