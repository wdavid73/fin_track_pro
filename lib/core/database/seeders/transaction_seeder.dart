import 'dart:math';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/seeder.dart';
import 'package:fin_track_pro/core/utils/logger_service.dart';
import 'package:fin_track_pro/features/categories/data/models/category_model.dart';
import 'package:fin_track_pro/features/transactions/data/models/transaction_model.dart';
import 'package:uuid/uuid.dart';

/// Seeder for sample transactions
///
/// Creates realistic transaction data for the last 30 days
/// Depends on CategorySeeder being run first
@singleton
class TransactionSeeder extends Seeder {
  final HiveService _hiveService;
  final Uuid _uuid = const Uuid();
  final Random _random = Random();

  TransactionSeeder(this._hiveService, LoggerService logger) : super(logger);

  @override
  String get name => 'TransactionSeeder';

  @override
  Future<void> seed() async {
    final transactionsBox = _hiveService.getBox(HiveService.transactionsBox);
    final categoriesBox = _hiveService.getBox(HiveService.categoriesBox);

    // Skip if transactions already exist
    if (hasData(transactionsBox)) {
      logger.info('Transactions already exist, skipping...', tag: name);
      return;
    }

    // Verify categories exist
    if (isBoxEmpty(categoriesBox)) {
      logger.warning(
        'Categories not found. Please run CategorySeeder first.',
        tag: name,
      );
      return;
    }

    logger.info('Seeding transactions...', tag: name);

    // Get all categories
    final categories = categoriesBox.values.cast<CategoryModel>().toList();
    final incomeCategories = categories
        .where((c) => c.type == 'income')
        .toList();
    final expenseCategories = categories
        .where((c) => c.type == 'expense')
        .toList();

    final transactions = <TransactionModel>[];
    final now = DateTime.now();

    // Create transactions for the last 30 days
    for (int i = 0; i < 30; i++) {
      final date = now.subtract(Duration(days: i));

      // Add 1-3 expenses per day
      final expenseCount = 1 + _random.nextInt(3);
      for (int j = 0; j < expenseCount; j++) {
        final category =
            expenseCategories[_random.nextInt(expenseCategories.length)];
        transactions.add(
          TransactionModel(
            id: _uuid.v4(),
            amount: _generateExpenseAmount(category.name),
            categoryId: category.id,
            type: 'expense',
            note: _generateNote(category.name, 'expense'),
            date: date,
            createdAt: date,
          ),
        );
      }

      // Add income every 15 days (simulating bi-weekly salary)
      if (i % 15 == 0 && incomeCategories.isNotEmpty) {
        final category = incomeCategories.firstWhere(
          (c) => c.name == 'Salario',
          orElse: () => incomeCategories.first,
        );
        transactions.add(
          TransactionModel(
            id: _uuid.v4(),
            amount: 3000.0 + _random.nextDouble() * 2000.0, // 3000-5000
            categoryId: category.id,
            type: 'income',
            note: 'Pago quincenal',
            date: date,
            createdAt: date,
          ),
        );
      }

      // Occasionally add freelance income
      if (_random.nextDouble() < 0.2 && incomeCategories.length > 1) {
        final freelanceCategory = incomeCategories.firstWhere(
          (c) => c.name == 'Freelance',
          orElse: () => incomeCategories[1],
        );
        transactions.add(
          TransactionModel(
            id: _uuid.v4(),
            amount: 500.0 + _random.nextDouble() * 1500.0, // 500-2000
            categoryId: freelanceCategory.id,
            type: 'income',
            note: 'Proyecto freelance',
            date: date,
            createdAt: date,
          ),
        );
      }
    }

    // Add all transactions to the box
    for (final transaction in transactions) {
      await transactionsBox.add(transaction);
    }

    logger.info(
      'Seeded ${transactions.length} transactions successfully',
      tag: name,
    );
  }

  /// Generate realistic expense amounts based on category
  double _generateExpenseAmount(String categoryName) {
    switch (categoryName) {
      case 'Alimentación':
        return 10.0 + _random.nextDouble() * 90.0; // 10-100
      case 'Transporte':
        return 5.0 + _random.nextDouble() * 45.0; // 5-50
      case 'Vivienda':
        return 500.0 + _random.nextDouble() * 1500.0; // 500-2000
      case 'Entretenimiento':
        return 20.0 + _random.nextDouble() * 180.0; // 20-200
      case 'Salud':
        return 30.0 + _random.nextDouble() * 470.0; // 30-500
      case 'Educación':
        return 50.0 + _random.nextDouble() * 450.0; // 50-500
      case 'Compras':
        return 15.0 + _random.nextDouble() * 285.0; // 15-300
      case 'Servicios':
        return 20.0 + _random.nextDouble() * 180.0; // 20-200
      default:
        return 10.0 + _random.nextDouble() * 90.0; // 10-100
    }
  }

  /// Generate realistic notes based on category
  String? _generateNote(String categoryName, String type) {
    if (_random.nextDouble() < 0.3) return null; // 30% chance of no note

    final expenseNotes = {
      'Alimentación': [
        'Supermercado',
        'Restaurante',
        'Cafetería',
        'Comida rápida',
      ],
      'Transporte': ['Gasolina', 'Uber', 'Taxi', 'Estacionamiento', 'Peaje'],
      'Vivienda': ['Renta', 'Servicios', 'Mantenimiento', 'Reparaciones'],
      'Entretenimiento': ['Cine', 'Concierto', 'Streaming', 'Videojuegos'],
      'Salud': ['Farmacia', 'Consulta médica', 'Medicamentos', 'Gimnasio'],
      'Educación': ['Curso online', 'Libros', 'Material escolar', 'Matrícula'],
      'Compras': ['Ropa', 'Electrónicos', 'Hogar', 'Accesorios'],
      'Servicios': ['Internet', 'Teléfono', 'Suscripciones', 'Seguros'],
    };

    final notes = expenseNotes[categoryName] ?? ['Gasto varios'];
    return notes[_random.nextInt(notes.length)];
  }
}
