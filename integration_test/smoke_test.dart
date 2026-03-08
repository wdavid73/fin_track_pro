// integration_test/smoke_test.dart
//
// Patrol Smoke Tests — FinTrack Pro
//
// Ejecución:
//   patrol test --target integration_test/smoke_test.dart --flavor dev --device emulator-5554
//
// Requisito: simulador/emulador activo con la app instalada en flavor dev.

import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  // ────────────────────────────────────────────────────────────────
  // Bootstrap compartido: inicializa Hive + DI + FlavorConfig
  // antes de que la app arranque dentro de cada patrolTest.
  // ────────────────────────────────────────────────────────────────
  Future<void> bootstrap() async {
    await app.mainCommon(Flavor.dev, '.env.dev');
  }

  // ──────────────────────────────────────────
  // Test 1: Navegación entre tabs
  // ──────────────────────────────────────────
  patrolTest('puede navegar entre los 4 tabs del BottomNavigationBar', (
    $,
  ) async {
    await bootstrap();
    await $.pumpAndSettle();

    // Arrancamos en Home (flavor dev va directo a /home)
    expect(find.byKey(const Key('home_page')), findsOneWidget);

    // Tab 2: Analytics
    await $.tap(find.byIcon(Icons.bar_chart_outlined));
    await $.pumpAndSettle();
    expect(find.byKey(const Key('analytics_page')), findsOneWidget);

    // Tab 3: Categories
    await $.tap(find.byIcon(Icons.category_outlined));
    await $.pumpAndSettle();
    expect(find.byKey(const Key('categories_page')), findsOneWidget);

    // Tab 4: Settings
    await $.tap(find.byIcon(Icons.settings_outlined));
    await $.pumpAndSettle();
    expect(find.byKey(const Key('settings_page')), findsOneWidget);

    // Regresamos a Home
    await $.tap(find.byIcon(Icons.home_outlined));
    await $.pumpAndSettle();
    expect(find.byKey(const Key('home_page')), findsOneWidget);
  });

  // ──────────────────────────────────────────
  // Test 2: FAB abre AddTransactionPage
  // ──────────────────────────────────────────
  patrolTest('el FAB abre la pantalla de Add Transaction', ($) async {
    await bootstrap();
    await $.pumpAndSettle();

    // Verificamos que estamos en Home
    expect(find.byKey(const Key('home_page')), findsOneWidget);

    // El FAB usa OpenContainer — el icon '+' está dentro del closedBuilder
    // Hacemos tap en él para abrir la animación de OpenContainer
    await $.tap(find.byIcon(Icons.add));

    // Esperamos que la animación OpenContainer termine (400ms + buffer)
    await $.tester.pump(const Duration(milliseconds: 500));
    await $.pumpAndSettle();

    // AddTransactionPage debe estar visible
    expect(find.byKey(const Key('add_transaction_page')), findsOneWidget);
  });

  // ──────────────────────────────────────────
  // Test 3: Filtros en AllTransactionsPage
  // ──────────────────────────────────────────
  patrolTest('puede abrir el panel de filtros desde All Transactions', (
    $,
  ) async {
    await bootstrap();
    await $.pumpAndSettle();

    // Navega a All Transactions vía botón "View all"
    final seeAllFinder = find.byKey(const Key('see_all_transactions'));

    // El botón puede estar fuera de la viewport en el SingleChildScrollView
    if (seeAllFinder.evaluate().isNotEmpty) {
      // Scroll hasta que el botón sea hit-testable
      await $.scrollUntilVisible(
        finder: seeAllFinder,
        view: find.byType(SingleChildScrollView).first,
        delta: 100,
      );
      await $.pumpAndSettle();

      await $.tap(seeAllFinder);
      await $.pumpAndSettle();

      // Abre el panel de filtros
      await $.tap(find.byKey(const Key('filter_button')));
      await $.pumpAndSettle();

      // Verifica que el BottomSheet de filtros es visible
      expect(find.byKey(const Key('transaction_filter_sheet')), findsOneWidget);

      // Cierra el sheet
      await $.tap(find.byIcon(Icons.close));
      await $.pumpAndSettle();

      // Sigue en AllTransactionsPage
      expect(find.text('All Transactions'), findsOneWidget);
    }
  });
}
