import 'dart:async';

import 'package:alchemist/alchemist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Alchemist configuration ensures consistent font rendering across environments (macOS/Ubuntu)
  final config = AlchemistConfig(
    theme: ThemeData(
      fontFamily:
          'Roboto', // Forzar una fuente predecible o dejar que Flutter use Ahem
    ),
    platformGoldensConfig: const PlatformGoldensConfig(
      enabled: false, // Desactivar goldens pormenorizados por SO
    ),
  );

  return AlchemistConfig.runWithConfig(
    config: config,
    run: () async {
      // Necesario para que golden_toolkit cargue las fuentes empaquetadas antes de correr los tests
      return testMain();
    },
  );
}
