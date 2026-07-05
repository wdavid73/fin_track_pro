import 'data/repositories/category_repository_impl_test.dart'
    as category_repository_impl_test;
import 'data/datasources/category_local_datasource_test.dart'
    as category_local_datasource_test;
import 'data/models/category_model_test.dart' as category_model_test;
import 'domain/entities/category_stats_test.dart' as category_stats_test;
import 'domain/usecases/get_categories_test.dart' as get_categories_test;
import 'domain/usecases/get_category_stats_test.dart'
    as get_category_stats_test;
import 'domain/usecases/create_category_test.dart' as create_category_test;
import 'domain/usecases/update_category_test.dart' as update_category_test;
import 'domain/usecases/delete_category_test.dart' as delete_category_test;
import 'domain/usecases/search_categories_test.dart' as search_categories_test;
import 'presentation/bloc/category_bloc_test.dart' as category_bloc_test;

void main() {
  category_repository_impl_test.main();
  category_local_datasource_test.main();
  category_model_test.main();
  category_stats_test.main();
  get_categories_test.main();
  get_category_stats_test.main();
  create_category_test.main();
  update_category_test.main();
  delete_category_test.main();
  category_bloc_test.main();
  search_categories_test.main();
}
