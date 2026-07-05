import 'package:fin_track_pro/features/budgets/data/datasources/budget_remote_datasource.dart';
import 'package:fin_track_pro/features/budgets/domain/repositories/budget_repository.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/create_budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/delete_budget.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/get_budgets.dart';
import 'package:fin_track_pro/features/budgets/domain/usecases/update_budget.dart';
import 'package:mocktail/mocktail.dart';

class MockBudgetRepository extends Mock implements BudgetRepository {}

class MockBudgetRemoteDataSource extends Mock
    implements BudgetRemoteDataSource {}

class MockGetBudgets extends Mock implements GetBudgets {}

class MockCreateBudget extends Mock implements CreateBudget {}

class MockUpdateBudget extends Mock implements UpdateBudget {}

class MockDeleteBudget extends Mock implements DeleteBudget {}
