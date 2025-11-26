import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/domain/entities/budget.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';

/// Use case to get all budgets
@injectable
class GetBudgets {
  final BudgetRepository repository;

  GetBudgets(this.repository);

  Future<List<Budget>> call() async {
    return await repository.getBudgets();
  }
}
