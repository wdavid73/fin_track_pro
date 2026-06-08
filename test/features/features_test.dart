import 'analytics/analytics_test.dart' as analytics;
import 'auth/auth_test.dart' as auth;
import 'budgets/budgets_test.dart' as budgets;
import 'categories/categories_test.dart' as categories;
import 'home/home_test.dart' as home;
import 'onboarding/onboarding_test.dart' as onboarding;
import 'settings/settings_test.dart' as settings;
import 'transactions/transactions_test.dart' as transactions;

void main() {
  analytics.main();
  auth.main();
  budgets.main();
  categories.main();
  home.main();
  onboarding.main();
  settings.main();
  transactions.main();
}
