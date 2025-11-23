import 'package:fin_track_pro/config/router/app_router.dart';
import 'package:fin_track_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final flavorConfig = FlavorConfig.instance;

    return MaterialApp.router(
      title: flavorConfig.appName,
      debugShowCheckedModeBanner: flavorConfig.showDebugBanner,
      theme: AppTheme.getLightTheme(context),
      darkTheme: AppTheme.getDarkTheme(context),
      themeMode: ThemeMode.system,
      routerConfig: createAppRouter(),
    );
  }
}
