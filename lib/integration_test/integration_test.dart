// Patrol Integration Test Bootstrap
//
// Punto de entrada para el runner nativo de Patrol.
// Patrol no requiere IntegrationTestWidgetsFlutterBinding porque
// usa su propio PatrolBinding. Solo se llama al main() de smoke_test.
//
// Ejecución:
//   patrol test --target integration_test/smoke_test.dart --flavor dev
import 'smoke_test.dart' as smoke;

void main() => smoke.main();
