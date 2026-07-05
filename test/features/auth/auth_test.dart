import 'data/datasources/firebase_auth_remote_datasource_test.dart'
    as firebase_auth_remote_datasource_test;
import 'data/repositories/auth_repository_impl_test.dart'
    as auth_repository_impl_test;
import 'presentation/bloc/auth_bloc/auth_bloc_test.dart' as auth_bloc_test;
import 'presentation/bloc/login_form_cubit/login_form_cubit_test.dart'
    as login_form_cubit_test;
import 'presentation/bloc/register_form_cubit/register_form_cubit_test.dart'
    as register_form_cubit_test;
import 'presentation/pages/login_page_test.dart' as login_page_test;
import 'presentation/pages/register_page_test.dart' as register_page_test;

void main() {
  firebase_auth_remote_datasource_test.main();
  auth_repository_impl_test.main();
  auth_bloc_test.main();
  login_form_cubit_test.main();
  register_form_cubit_test.main();
  login_page_test.main();
  register_page_test.main();
}
