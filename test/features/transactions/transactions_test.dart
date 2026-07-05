import 'data/repositories/transaction_repository_test.dart'
    as transaction_repository_test;
import 'data/datasources/transaction_local_datasource_test.dart'
    as transaction_local_datasource_test;
import 'data/models/transaction_model_test.dart' as transaction_model_test;
import 'domain/usecases/get_transactions_test.dart' as get_transactions_test;
import 'domain/usecases/create_transaction_test.dart'
    as create_transaction_test;
import 'domain/usecases/update_transaction_test.dart'
    as update_transaction_test;
import 'domain/usecases/delete_transaction_test.dart'
    as delete_transaction_test;
import 'domain/usecases/get_paginated_transactions_test.dart'
    as get_paginated_transactions_test;
import 'domain/usecases/get_recent_transactions_test.dart'
    as get_recent_transactions_test;
import 'domain/usecases/get_total_balance_test.dart' as get_total_balance_test;
import 'domain/usecases/get_budget_data_test.dart' as get_budget_data_test;
import 'presentation/bloc/transaction_bloc_test.dart' as transaction_bloc_test;
import 'presentation/bloc/edit_transaction_cubit/edit_transaction_cubit_test.dart'
    as edit_transaction_cubit_test;
import 'presentation/bloc/add_transaction_cubit/add_transaction_cubit_test.dart'
    as add_transaction_cubit_test;
import 'presentation/pages/all_transactions_page_test.dart'
    as all_transactions_page_test;
import 'presentation/pages/add_transaction_page_test.dart'
    as add_transaction_page_test;
import 'presentation/pages/edit_transaction_page_test.dart'
    as edit_transaction_page_test;
import 'presentation/widgets/amount_input_widget_test.dart'
    as amount_input_widget_test;
import 'presentation/widgets/category_selector_test.dart'
    as category_selector_test;
import 'presentation/widgets/date_selector_test.dart' as date_selector_test;
import 'presentation/widgets/description_input_test.dart'
    as description_input_test;
import 'presentation/widgets/transaction_type_toggle_test.dart'
    as transaction_type_toggle_test;
import 'presentation/widgets/transaction_details_modal_test.dart'
    as transaction_details_modal_test;
import 'presentation/widgets/transaction_filter_bottom_sheet_test.dart'
    as transaction_filter_bottom_sheet_test;

void main() {
  transaction_repository_test.main();
  transaction_local_datasource_test.main();
  transaction_model_test.main();
  get_transactions_test.main();
  create_transaction_test.main();
  update_transaction_test.main();
  delete_transaction_test.main();
  get_paginated_transactions_test.main();
  get_recent_transactions_test.main();
  get_total_balance_test.main();
  get_budget_data_test.main();
  transaction_bloc_test.main();
  edit_transaction_cubit_test.main();
  add_transaction_cubit_test.main();
  all_transactions_page_test.main();
  add_transaction_page_test.main();
  edit_transaction_page_test.main();
  amount_input_widget_test.main();
  category_selector_test.main();
  date_selector_test.main();
  description_input_test.main();
  transaction_type_toggle_test.main();
  transaction_details_modal_test.main();
  transaction_filter_bottom_sheet_test.main();
}
