import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:hive/hive.dart';

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

  const BudgetModel({
    required super.id,
    required super.categoryId,
    required super.amount,
    super.period = 'monthly',
  });

  factory BudgetModel.fromEntity(Budget budget) {
    return BudgetModel(
      id: budget.id,
      categoryId: budget.categoryId,
      amount: budget.amount,
      period: budget.period,
    );
  }

  Budget toEntity() {
    return Budget(
      id: id,
      categoryId: categoryId,
      amount: amount,
      period: period,
    );
  }
}
