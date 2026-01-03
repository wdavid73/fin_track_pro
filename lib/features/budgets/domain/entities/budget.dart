import 'package:equatable/equatable.dart';

/// Budget entity representing a budget assigned to a category
class Budget extends Equatable {
  final String id;
  final String categoryId;
  final double amount;
  final String period; // 'monthly', 'weekly', 'yearly'

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.period = 'monthly',
  });

  @override
  List<Object?> get props => [id, categoryId, amount, period];

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, amount: $amount, period: $period)';
  }
}
