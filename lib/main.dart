import 'package:fin_track_pro/app/injection_container.dart';
import 'package:fin_track_pro/core/config/env_config.dart';
import 'package:fin_track_pro/core/config/flavor_config.dart';
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

  runApp(const MyApp());
}
