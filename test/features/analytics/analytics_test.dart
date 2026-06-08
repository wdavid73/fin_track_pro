import 'domain/usecases/get_analytics_data_test.dart'
    as get_analytics_data_test;
import 'domain/usecases/get_analytics_data_extended_test.dart'
    as get_analytics_data_extended_test;
import 'domain/entities/analytics_data_test.dart' as analytics_data_test;
import 'presentation/bloc/analytics_bloc_test.dart' as analytics_bloc_test;
import 'presentation/bloc/analytics_bloc_extended_test.dart'
    as analytics_bloc_extended_test;

void main() {
  get_analytics_data_test.main();
  get_analytics_data_extended_test.main();
  analytics_data_test.main();
  analytics_bloc_test.main();
  analytics_bloc_extended_test.main();
}
