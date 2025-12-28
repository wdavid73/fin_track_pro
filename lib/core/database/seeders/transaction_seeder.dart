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
            amount:
                3000000.0 +
                _random.nextDouble() * 3000000.0, // 3,000,000 - 6,000,000
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
            amount:
                500000.0 +
                _random.nextDouble() * 1500000.0, // 500,000 - 2,000,000
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
        return 20000.0 + _random.nextDouble() * 130000.0; // 20,000 - 150,000
      case 'Transporte':
        return 5000.0 + _random.nextDouble() * 45000.0; // 5,000 - 50,000
      case 'Vivienda':
        return 100000.0 + _random.nextDouble() * 400000.0; // 100,000 - 500,000
      case 'Entretenimiento':
        return 30000.0 + _random.nextDouble() * 270000.0; // 30,000 - 300,000
      case 'Salud':
        return 50000.0 + _random.nextDouble() * 450000.0; // 50,000 - 500,000
      case 'Educación':
        return 100000.0 +
            _random.nextDouble() * 900000.0; // 100,000 - 1,000,000
      case 'Compras':
        return 50000.0 + _random.nextDouble() * 450000.0; // 50,000 - 500,000
      case 'Servicios':
        return 50000.0 + _random.nextDouble() * 250000.0; // 50,000 - 300,000
      default:
        return 20000.0 + _random.nextDouble() * 80000.0; // 20,000 - 100,000
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
