import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:hive_ce/hive_ce.dart';
part 'budget_model.g.dart';

@HiveType(typeId: 2)
class BudgetModel extends Budget {
  @HiveField(0)
  @override
  String get id => super.id;

  @HiveField(1)
  @override
  String get categoryId => super.categoryId;

  @HiveField(2)
  @override
  double get amount => super.amount;

  @HiveField(3)
  @override
  String get period => super.period;

  @HiveField(4)
  @override
  DateTime get updatedAt => super.updatedAt;

  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    super.period = 'monthly',
    required super.updatedAt,
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      amount: budget.amount,
      period: budget.period,
      updatedAt: budget.updatedAt,
    );
  }

  Budget toEntity() {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      period: period,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'categoryId': categoryId,
      'amount': amount,
      'period': period,
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory BudgetModel.fromMap(Map<String, dynamic> map) {
    return BudgetModel(
      id: map['id'] as String,
      categoryId: map['categoryId'] as String,
      amount: (map['amount'] as num).toDouble(),
      period: map['period'] as String,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
