import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';

/// Use case to update an existing budget
@injectable
class UpdateBudget {
  final BudgetRepository repository;

  UpdateBudget(this.repository);

  Future<void> call(Budget budget) async {
    return await repository.saveBudget(budget);
  }
}
