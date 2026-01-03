import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/config/router/app_router.dart';
import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/features/settings/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:fin_track_pro/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

GoRouter? _router;

class MyApp extends StatelessWidget {
  final GlobalKey<ScaffoldMessengerState> messengerKey;
  const MyApp({super.key, required this.messengerKey});

  @override
  Widget build(BuildContext context) {
    _router ??= createAppRouter();
    final flavorConfig = FlavorConfig.instance;

    return BlocProvider(
      create: (context) => getIt<SettingsBloc>()..add(LoadSettings()),
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          return MaterialApp.router(
            title: flavorConfig.appName,
            debugShowCheckedModeBanner: flavorConfig.showDebugBanner,
            theme: AppTheme.getLightTheme(context),
            darkTheme: AppTheme.getDarkTheme(context),
            themeMode: state.settings?.themeMode ?? ThemeMode.system,
            routerConfig: _router,
            scaffoldMessengerKey: messengerKey,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
          );
        },
      ),
    );
  }
}
