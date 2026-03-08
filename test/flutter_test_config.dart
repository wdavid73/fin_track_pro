import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

/// Configuración global para los tests de Flutter.
/// Se ejecuta automáticamente una sola vez antes de todos los tests en la carpeta.
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  // Reemplazamos el comparador por defecto con uno que tolera una pequeña
  // diferencia porcentual. Esto soluciona los problemas de renderizado de texto
  // (anti-aliasing) que varían entre macOS (local) y Ubuntu (GitHub Actions CI).
  if (goldenFileComparator is LocalFileComparator) {
    final testUrl = (goldenFileComparator as LocalFileComparator).basedir;

    // Configura 1% de tolerancia (0.01). El log mostró 0.76% de fallo en CI.
    goldenFileComparator = LocalFileComparatorWithThreshold(
      Uri.parse('$testUrl/test.dart'),
      0.01,
    );
  }

  return testMain();
}

/// Comparador personalizado que ignora diferencias menores al [threshold].
class LocalFileComparatorWithThreshold extends LocalFileComparator {
  final double threshold;

  LocalFileComparatorWithThreshold(Uri testFile, this.threshold)
    : super(testFile);

  @override
  Future<bool> compare(Uint8List imageBytes, Uri golden) async {
    final ComparisonResult result = await GoldenFileComparator.compareLists(
      imageBytes,
      await getGoldenBytes(golden),
    );

    if (!result.passed && result.diffPercent > threshold) {
      final String error = await generateFailureOutput(result, golden, basedir);
      throw FlutterError(error);
    }

    if (!result.passed) {
      debugPrint(
        'A tolerance difference of ${result.diffPercent * 100}% was ignored for $golden',
      );
    }

    return true;
  }
}
