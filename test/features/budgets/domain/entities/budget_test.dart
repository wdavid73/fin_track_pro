import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const budget = Budget(id: 'b-1', categoryId: 'cat-food', amount: 300.0);

  group('Budget', () {
    // ── Construction ──────────────────────────────────────────────────────

    test('creates with required fields', () {
      expect(budget.id, 'b-1');
      expect(budget.categoryId, 'cat-food');
      expect(budget.amount, 300.0);
    });

    test('period defaults to monthly', () {
      expect(budget.period, 'monthly');
    });

    test('accepts custom period', () {
      const weekly = Budget(
        id: 'b-2',
        categoryId: 'cat-food',
        amount: 75.0,
        period: 'weekly',
      );
      expect(weekly.period, 'weekly');
    });

    // ── Equatable ─────────────────────────────────────────────────────────

    test('two budgets with same fields are equal', () {
      const same = Budget(id: 'b-1', categoryId: 'cat-food', amount: 300.0);
      expect(budget, equals(same));
    });

    test('two budgets with different ids are not equal', () {
      const other = Budget(id: 'b-2', categoryId: 'cat-food', amount: 300.0);
      expect(budget, isNot(equals(other)));
    });

    test('two budgets with different amounts are not equal', () {
      const other = Budget(id: 'b-1', categoryId: 'cat-food', amount: 500.0);
      expect(budget, isNot(equals(other)));
    });

    test('two budgets with different periods are not equal', () {
      const other = Budget(
        id: 'b-1',
        categoryId: 'cat-food',
        amount: 300.0,
        period: 'yearly',
      );
      expect(budget, isNot(equals(other)));
    });

    test('props contains id, categoryId, amount, period', () {
      expect(budget.props, ['b-1', 'cat-food', 300.0, 'monthly']);
    });

    // ── toString ─────────────────────────────────────────────────────────

    test('toString includes all fields', () {
      final s = budget.toString();
      expect(s, contains('b-1'));
      expect(s, contains('cat-food'));
      expect(s, contains('300.0'));
      expect(s, contains('monthly'));
    });
  });
}
