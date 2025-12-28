import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/config/env_config.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/core/database/seeders/database_seeder.dart';
import 'package:fin_track_pro/core/widgets/app_snack_bar.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';

Future<void> mainCommon(Flavor flavor, String envFile) async {
  WidgetsFlutterBinding.ensureInitialized();

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

  // Initialize Hive database
  final hiveService = getIt<HiveService>();
  await hiveService.init(
    databaseSeeder: getIt.isRegistered<DatabaseSeeder>()
        ? getIt<DatabaseSeeder>()
        : null,
  );

  final messengerKey = GlobalKey<ScaffoldMessengerState>();
  AppSnackbar().init(messengerKey);

  runApp(MyApp(messengerKey: messengerKey));
}
