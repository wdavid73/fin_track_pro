import 'package:fin_track_pro/features/budgets/data/models/budget_model.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final tUpdatedAt = DateTime(2026, 1, 1);

  final tBudgetModel = BudgetModel(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
    updatedAt: tUpdatedAt,
  );

  final tBudget = Budget(
    id: '1',
    categoryId: 'cat1',
    amount: 500.0,
    period: 'monthly',
    updatedAt: tUpdatedAt,
  );

  group('BudgetModel', () {
    test('should be a subclass of Budget entity', () {
      expect(tBudgetModel, isA<Budget>());
    });

    group('fromEntity', () {
      test('should return a valid model from entity', () {
        final result = BudgetModel.fromEntity(tBudget);
        expect(result, tBudgetModel);
      });
    });

    group('toEntity', () {
      test('should return a valid entity from model', () {
        final result = tBudgetModel.toEntity();
        expect(result, tBudget);
      });
    });
  });
}
