import 'dart:async';
import 'package:alchemist/alchemist.dart';

/// Configuración global para todos los tests de Flutter.
///
/// Este archivo es cargado automáticamente por `flutter test` una sola
/// vez antes de ejecutar cualquier test en la carpeta `test/`.
///
/// Para golden tests, Alchemist diferencia entre:
///   - **Modo local** (plataforma): texto legible, para revisión humana.
///   - **Modo CI**: texto oscurecido con rectángulos de color — estable
///     entre macOS (local) y Ubuntu (GitHub Actions).
///
/// Alchemist detecta el modo CI automáticamente mediante la variable
/// de entorno `CI` (seteada por GitHub Actions). No se necesita
/// `--dart-define=CI=true`.
///
/// El tema de FinTrack Pro se provee en cada test via [GoldenTestScenario]
/// usando [buildWithFinTrackTheme] del helper `golden_test_helpers.dart`.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  await AlchemistConfig.runWithConfig(
    config: const AlchemistConfig(
      platformGoldensConfig: PlatformGoldensConfig(
        renderShadows: false,
      ),
      ciGoldensConfig: CiGoldensConfig(
        obscureText: true, // texto → rectángulos en CI (estable cross-platform)
        renderShadows: false,
      ),
    ),
    run: testMain,
  );
}
