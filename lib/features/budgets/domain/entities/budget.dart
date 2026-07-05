import 'package:equatable/equatable.dart';

/// Budget entity representing a budget assigned to a category
class Budget extends Equatable {
  final String id;
  final String categoryId;
  final double amount;
  final String period; // 'monthly', 'weekly', 'yearly'
  final DateTime updatedAt;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.amount,
    this.period = 'monthly',
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [id, categoryId, amount, period, updatedAt];

  Budget copyWith({
    String? id,
    String? categoryId,
    double? amount,
    String? period,
    DateTime? updatedAt,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      amount: amount ?? this.amount,
      period: period ?? this.period,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Budget(id: $id, categoryId: $categoryId, amount: $amount, period: $period)';
  }
}
