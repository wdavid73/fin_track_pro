import 'package:injectable/injectable.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';

/// Use case to delete a budget by its ID
@injectable
class DeleteBudget {
  final BudgetRepository repository;

  DeleteBudget(this.repository);

  Future<void> call(String id) async {
    return await repository.deleteBudget(id);
  }
}
