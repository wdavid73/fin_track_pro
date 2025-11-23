import 'package:fin_track_pro/config/router/routes.dart';
import 'package:fin_track_pro/features/home/presentation/home_page.dart';
import 'package:go_router/go_router.dart';

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: RouteConstants.home,
    routes: AppRoutes.getAppRoutes(),
  );
}

class AppRoutes {
  static List<RouteBase> getAppRoutes() {
    return [
      GoRoute(
        path: RouteConstants.home,
        builder: (context, state) => const HomePage(),
      ),
    ];
  }
}
