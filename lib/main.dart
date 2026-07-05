import 'dart:async';

import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/config/env_config.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/database_seeder.dart';
import 'package:fin_track_pro/features/auth/presentation/bloc/auth_bloc/auth_bloc.dart';
import 'package:fin_track_pro/core/services/crashlytics_service.dart';
import 'package:fin_track_pro/core/services/sync_service.dart';
import 'package:fin_track_pro/core/widgets/app_snack_bar.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'app/app.dart';
import 'firebase_options.dart';

Future<void> mainCommon(Flavor flavor, String envFile) async {
  // runZonedGuarded must wrap ALL initialization including ensureInitialized
  // so that runApp is called in the same zone as the binding.
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase first (required before any Firebase service call)
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      await GoogleSignIn.instance.initialize();

      // Load environment variables
      await EnvConfig.load(envFile);

      // Initialize flavor configuration
      FlavorConfig.initialize(
        flavor: flavor,
        appName: EnvConfig.appName,
        bundleId: EnvConfig.bundleId,
        enableLogging: EnvConfig.enableLogging,
        showDebugBanner: EnvConfig.enableDebugBanner,
      );

      // Initialize dependency injection
      await configureDependencies();

      // Wire Crashlytics for Flutter and platform errors
      getIt<CrashlyticsService>().initialize();

      // Start listening to Firebase auth state changes
      getIt<AuthBloc>().add(AuthStarted());

      // Initialize Hive database
      final hiveService = getIt<HiveService>();
      await hiveService.init(
        databaseSeeder: getIt.isRegistered<DatabaseSeeder>()
            ? getIt<DatabaseSeeder>()
            : null,
      );

      // Wire Firestore cloud sync to auth state. Must run after Hive is
      // initialized, since sync touches the transactions/categories/budgets
      // boxes.
      final syncService = getIt<SyncService>();
      getIt<AuthBloc>().stream.listen((state) {
        if (state.status == AuthStatus.authenticated && state.user != null) {
          syncService.onLogin(state.user!.id);
        } else if (state.status == AuthStatus.unauthenticated) {
          syncService.onLogout(clearLocalData: true);
        }
      });

      final messengerKey = GlobalKey<ScaffoldMessengerState>();
      AppSnackbar().init(messengerKey);

      runApp(MyApp(messengerKey: messengerKey));
    },
    (error, stack) =>
        getIt<CrashlyticsService>().recordError(error, stack, fatal: true),
  );
}
