import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';

/// Use case to create a new budget
@injectable
class CreateBudget {
  final BudgetRepository repository;

  CreateBudget(this.repository);

  Future<void> call(Budget budget) async {
    return await repository.saveBudget(budget);
  }
}
