import 'package:fin_track_pro/core/l10n/app_localizations.dart';
import 'package:fin_track_pro/theme/theme_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';

/// Helpers para golden tests con Alchemist en FinTrack Pro.
///
/// ## Patrón correcto con Alchemist
///
/// El contexto de la app (MaterialApp + Scaffold) debe provverse via el
/// parámetro `pumpWidget` del `goldenTest`, NO dentro de cada
/// `GoldenTestScenario.child`.
///
/// Alchemist combina todos los scenarios en un GoldenTestGroup, y si cada
/// child lleva su propio Scaffold, el widget intenta expandirse infinitamente.
///
/// Uso:
/// ```dart
/// goldenTest(
///   'mi widget',
///   fileName: 'mi_widget',
///   pumpWidget: pumpWithFinTrackTheme,  // ← aquí
///   builder: () => GoldenTestGroup(
///     children: [
///       GoldenTestScenario(
///         name: 'estado 1',
///         child: MiWidget(),  // ← solo el widget, sin MaterialApp
///       ),
///     ],
///   ),
/// );
/// ```

/// Función [pumpWidget] para [goldenTest] que provee el tema de FinTrack Pro
/// y las localizations necesarias.
///
/// Compatible con widgets que usan [context.colorScheme], [context.textTheme]
/// y [context.l10n].
Future<void> pumpWithFinTrackTheme(WidgetTester tester, Widget widget) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      locale: const Locale('en'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: 'Roboto', // Fuente de test — Poppins no está bundleada en test
        colorScheme: ThemeConstants.colorScheme,
      ),
      home: Scaffold(
        backgroundColor: ThemeConstants.colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: widget,
        ),
      ),
    ),
  );
  await tester.pump();
}
