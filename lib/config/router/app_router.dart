import 'package:animations/animations.dart';
import 'package:fin_track_pro/config/router/fade_indexed_stack.dart';
import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/extensions/localization_extension.dart';
import 'package:fin_track_pro/features/analytics/presentation/analytics_page.dart';
import 'package:fin_track_pro/features/categories/presentation/pages/categories_page.dart';
import 'package:fin_track_pro/features/home/presentation/home_page.dart';
import 'package:fin_track_pro/features/settings/presentation/settings_page.dart';
import 'package:fin_track_pro/features/splash/presentation/splash_page.dart';
import 'package:fin_track_pro/features/transactions/presentation/pages/all_transactions_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Global navigator key to preserve state during hot reload
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

GoRouter createAppRouter() {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    // In development, start at home to avoid splash screen on hot reload
    // In production, start at splash
    initialLocation: FlavorConfig.instance.isDev
        ? RouteConstants.home
        : RouteConstants.splash,
    debugLogDiagnostics: FlavorConfig.instance.isDev,
    routes: AppRoutes.getAppRoutes(),
  );
}

class AppRoutes {
  static List<RouteBase> getAppRoutes() {
    return [
      GoRoute(
        path: RouteConstants.splash,
        builder: (context, state) => const SplashPage(),
      ),
      StatefulShellRoute(
        navigatorContainerBuilder: (context, navigationShell, children) {
          return FadeIndexedStack(
            index: navigationShell.currentIndex,
            children: children,
          );
        },
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.home,
                builder: (context, state) => const HomePage(),
                routes: [
                  GoRoute(
                    path: 'transactions',
                    pageBuilder: (context, state) {
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: const AllTransactionsPage(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                              return SharedAxisTransition(
                                animation: animation,
                                secondaryAnimation: secondaryAnimation,
                                transitionType:
                                    SharedAxisTransitionType.horizontal,
                                child: child,
                              );
                            },
                      );
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
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.categories,
                builder: (context, state) => const CategoriesPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: RouteConstants.settings,
                builder: (context, state) => const SettingsPage(),
              ),
            ],
          ),
        ],
      ),
    ];
  }
}

class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: navigationShell.currentIndex,
          onTap: (index) {
            navigationShell.goBranch(
              index,
              initialLocation: index == navigationShell.currentIndex,
            );
          },
          items: [
            BottomNavigationBarItem(
              icon: const Icon(Icons.home_outlined),
              activeIcon: const Icon(Icons.home),
              label: context.l10n.home,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart),
              label: context.l10n.analytics,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.category_outlined),
              activeIcon: const Icon(Icons.category),
              label: context.l10n.categories,
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.settings_outlined),
              activeIcon: const Icon(Icons.settings),
              label: context.l10n.settings,
            ),
          ],
        ),
      ),
    );
  }
}
