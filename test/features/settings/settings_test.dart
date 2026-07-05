import 'data/repositories/settings_repository_impl_test.dart'
    as settings_repository_impl_test;
import 'data/datasources/settings_local_datasource_test.dart'
    as settings_local_datasource_test;
import 'domain/entities/settings_entity_test.dart' as settings_entity_test;
import 'domain/usecases/get_settings_test.dart' as get_settings_test;
import 'domain/usecases/save_settings_test.dart' as save_settings_test;
import 'domain/usecases/complete_onboarding_test.dart'
    as complete_onboarding_test;
import 'domain/usecases/check_onboarding_status_test.dart'
    as check_onboarding_status_test;
import 'presentation/pages/settings_page_test.dart' as settings_page_test;
import 'presentation/bloc/settings_bloc_test.dart' as settings_bloc_test;

void main() {
  settings_repository_impl_test.main();
  settings_local_datasource_test.main();
  settings_bloc_test.main();
  get_settings_test.main();
  save_settings_test.main();
  complete_onboarding_test.main();
  check_onboarding_status_test.main();
  settings_page_test.main();
  settings_entity_test.main();
}
