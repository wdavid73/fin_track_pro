import 'package:fin_track_pro/config/router/app_router.dart';
import 'package:fin_track_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:go_router/go_router.dart';

GoRouter? _router;

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  const MyApp({super.key, required this.messengerKey});

  @override
  Widget build(BuildContext context) {
    _router ??= createAppRouter();
    final flavorConfig = FlavorConfig.instance;

    return MaterialApp.router(
      title: flavorConfig.appName,
      debugShowCheckedModeBanner: flavorConfig.showDebugBanner,
      theme: AppTheme.getLightTheme(context),
      darkTheme: AppTheme.getDarkTheme(context),
      themeMode: ThemeMode.system,
      routerConfig: _router,
      scaffoldMessengerKey: messengerKey,
    );
  }
}
