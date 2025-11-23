import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import '../models/category_model.dart';
import 'category_datasource.dart';

@injectable
class CategoryLocalDataSource implements CategoryDataSource {
  final HiveService _hiveService;

  CategoryLocalDataSource(this._hiveService);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final box = _hiveService.getBox(HiveService.categoriesBox);

    // Seed default categories if box is empty
    if (box.isEmpty) {
      await _seedDefaultCategories();
    }

    return box.values.cast<CategoryModel>().toList();
  }

  @override
  Future<List<CategoryModel>> getCategoriesByType(String type) async {
    final box = _hiveService.getBox(HiveService.categoriesBox);
    return box.values
        .cast<CategoryModel>()
        .where((cat) => cat.type == type)
        .toList();
  }

  @override
  Future<CategoryModel?> getCategoryById(String id) async {
    final box = _hiveService.getBox(HiveService.categoriesBox);
    return box.values.cast<CategoryModel>().firstWhere(
      (cat) => cat.id == id,
      orElse: () => throw Exception('Category not found'),
    );
  }

  Future<void> _seedDefaultCategories() async {
    final box = _hiveService.getBox(HiveService.categoriesBox);

    final defaultCategories = [
      // Income categories
      CategoryModel(
        id: 'income_salary',
        name: 'Salary',
        icon: '💼',
        color: Colors.green.value,
        type: 'income',
      ),
      CategoryModel(
        id: 'income_freelance',
        name: 'Freelance',
        icon: '💻',
        color: Colors.blue.value,
        type: 'income',
      ),
      CategoryModel(
        id: 'income_investment',
        name: 'Investment',
        icon: '📈',
        color: Colors.purple.value,
        type: 'income',
      ),
      CategoryModel(
        id: 'income_other',
        name: 'Other Income',
        icon: '💰',
        color: Colors.teal.value,
        type: 'income',
      ),

      // Expense categories
      CategoryModel(
        id: 'expense_food',
        name: 'Food & Dining',
        icon: '🍔',
        color: Colors.orange.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_transport',
        name: 'Transportation',
        icon: '🚗',
        color: Colors.red.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_shopping',
        name: 'Shopping',
        icon: '🛍️',
        color: Colors.pink.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_entertainment',
        name: 'Entertainment',
        icon: '🎬',
        color: Colors.indigo.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_bills',
        name: 'Bills & Utilities',
        icon: '📄',
        color: Colors.brown.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_health',
        name: 'Health',
        icon: '🏥',
        color: Colors.red.shade300.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_education',
        name: 'Education',
        icon: '📚',
        color: Colors.blue.shade700.value,
        type: 'expense',
      ),
      CategoryModel(
        id: 'expense_other',
        name: 'Other Expenses',
        icon: '💸',
        color: Colors.grey.value,
        type: 'expense',
      ),
    ];

    for (var i = 0; i < defaultCategories.length; i++) {
      await box.put(defaultCategories[i].id, defaultCategories[i]);
    }
  }
}
