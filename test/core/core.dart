import 'config/env_config_test.dart' as env_config_test;
import 'database/hive_service_test.dart' as hive_service_test;
// Seeders
import 'database/seeders/budget_seeder_test.dart' as budget_seeder_test;
import 'database/seeders/category_seeder_test.dart' as category_seeder_test;
import 'database/seeders/database_seeder_test.dart' as database_seeder_test;
import 'database/seeders/seeder_test.dart' as seeder_test;
import 'database/seeders/transaction_seeder_test.dart'
    as transaction_seeder_test;

// Utils
import 'utils/icon_helper_test.dart' as icon_helper_test;
import 'utils/logger_service_test.dart' as logger_service_test;

// Widgets
import 'widgets/formatters/money_input_formatter_test.dart'
    as money_input_formatter_test;

// extensions
import 'extensions/context_extensions_test.dart' as context_extensions_test;
import 'extensions/currency_extensions_test.dart' as currency_extensions_test;
import 'extensions/locale_extensions_test.dart' as locale_extensions_test;

// errors
import 'error/failures_test.dart' as failures_test;

void main() {
  env_config_test.main();
  hive_service_test.main();
  budget_seeder_test.main();
  category_seeder_test.main();
  database_seeder_test.main();
  seeder_test.main();
  transaction_seeder_test.main();
  icon_helper_test.main();
  logger_service_test.main();
  money_input_formatter_test.main();
  context_extensions_test.main();
  currency_extensions_test.main();
  locale_extensions_test.main();
  failures_test.main();
}
