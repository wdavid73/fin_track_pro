import 'data/models/budget_model_test.dart' as budget_model_test;
import 'data/repositories/budget_repository_impl_test.dart'
    as budget_repository_impl_test;
import 'data/datasources/budget_local_datasource_test.dart'
    as budget_local_datasource_test;
import 'domain/entities/budget_test.dart' as budget_test;
import 'domain/usecases/get_budgets_test.dart' as get_budgets_test;
import 'domain/usecases/save_budget_test.dart' as save_budget_test;
import 'domain/usecases/create_budget_test.dart' as create_budget_test;
import 'domain/usecases/update_budget_test.dart' as update_budget_test;
import 'domain/usecases/delete_budget_test.dart' as delete_budget_test;
import 'presentation/bloc/budget_bloc_test.dart' as budget_bloc_test;

void main() {
  budget_model_test.main();
  budget_repository_impl_test.main();
  budget_local_datasource_test.main();
  budget_test.main();
  get_budgets_test.main();
  save_budget_test.main();
  create_budget_test.main();
  update_budget_test.main();
  delete_budget_test.main();
  budget_bloc_test.main();
}
