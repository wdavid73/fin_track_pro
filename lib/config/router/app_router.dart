import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/config/router/fade_indexed_stack.dart';
import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/analytics/presentation/analytics_page.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/features/auth/presentation/pages/login_page.dart';
import 'package:fin_track_pro/features/auth/presentation/pages/register_page.dart';
import 'package:fin_track_pro/features/budgets/presentation/budget_detail_page.dart';
import 'package:fin_track_pro/features/budgets/presentation/budget_page.dart';
import 'package:fin_track_pro/features/categories/presentation/pages/categories_page.dart';
import 'package:fin_track_pro/features/home/presentation/home_page.dart';
import 'package:fin_track_pro/features/onboarding/presentation/pages/onboarding_page.dart';
import 'package:fin_track_pro/features/settings/presentation/settings_page.dart';
import 'package:fin_track_pro/features/splash/presentation/splash_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:fin_track_pro/features/home/presentation/shell_page.dart';
import 'package:fin_track_pro/features/transactions/domain/entities/budget_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Global navigator key to preserve state during hot reload
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Auth-aware routes: unauthenticated users are redirected to /login,
/// authenticated users trying to access /login or /register go to /home.
String? _authRedirect(BuildContext context, GoRouterState state) {
  final authState = getIt<AuthBloc>().state;
  final isAuthenticated = authState.isAuthenticated;
  final isAuthRoute = state.matchedLocation == RouteConstants.login ||
      state.matchedLocation == RouteConstants.register;
  final isSplash = state.matchedLocation == RouteConstants.splash;
  final isOnboarding = state.matchedLocation == RouteConstants.onboarding;

  // Never redirect away from splash or onboarding — they manage their own flow.
  if (isSplash || isOnboarding) return null;

  if (!isAuthenticated && !isAuthRoute) return RouteConstants.login;
  if (isAuthenticated && isAuthRoute) return RouteConstants.home;
  return null;
}

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: FlavorConfig.instance.isDev
        ? RouteConstants.home
        : RouteConstants.splash,
    debugLogDiagnostics: FlavorConfig.instance.isDev,
    redirect: _authRedirect,
    refreshListenable: _AuthStateListenable(),
    routes: AppRoutes.getAppRoutes(),
  );
}

/// Makes the router re-evaluate [redirect] whenever the AuthBloc emits.
class _AuthStateListenable extends ChangeNotifier {
  _AuthStateListenable() {
    getIt<AuthBloc>().stream.listen((_) => notifyListeners());
  }
}

class AppRoutes {
  static List<RouteBase> getAppRoutes() {
    return [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Stitch UI as the main app shell (4 tabs: Home, Transactions, Budget, Analytics)
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return FadeIndexedStack(
            index: navigationShell.currentIndex,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return ShellPage(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                builder: (context, state) => const HomePage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.transactions,
                builder: (context, state) => const AllTransactionsPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.budget,
                builder: (context, state) => const BudgetPage(),
                routes: [
                  GoRoute(
                    path: 'detail',
                    builder: (context, state) {
                      final budget = state.extra as CategoryBudget;
                      return BudgetDetailPage(budget: budget);
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.analytics,
                builder: (context, state) => const AnalyticsPage(),
              ),
            ],
          ),
        ],
      ),

      // Standalone routes accessible from settings icon / profile actions
      GoRoute(
        path: RouteConstants.categories,
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: RouteConstants.settings,
        builder: (context, state) => const SettingsPage(),
      ),
      GoRoute(
        path: RouteConstants.onboarding,
        builder: (context, state) => const OnboardingPage(),
      ),

      // Auth routes — provided with a shared AuthBloc instance
      GoRoute(
        path: RouteConstants.login,
        builder: (context, state) => BlocProvider.value(
          value: getIt<AuthBloc>(),
          child: const LoginPage(),
        ),
      ),
      GoRoute(
        path: RouteConstants.register,
        builder: (context, state) => BlocProvider.value(
          value: getIt<AuthBloc>(),
          child: const RegisterPage(),
        ),
      ),
    ];
  }
}
