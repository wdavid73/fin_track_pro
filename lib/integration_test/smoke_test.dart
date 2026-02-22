// Patrol Smoke Tests — FinTrack Pro
//
// Ejecución:
//   patrol test --target integration_test/smoke_test.dart --flavor dev
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

void main() {
  // ──────────────────────────────────────────
  // Group 1: Navegación entre tabs
  // ──────────────────────────────────────────
  patrolTest('puede navegar entre los 4 tabs del BottomNavigationBar', (
    $,
  ) async {
    await $.pumpAndSettle();

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

    // Regresa a Home
    await $.tap(find.byIcon(Icons.home_outlined));
    await $.pumpAndSettle();
    expect(find.byKey(const Key('home_page')), findsOneWidget);
  });

  // ──────────────────────────────────────────
  // Group 2: FAB de añadir transacción abre la pantalla
  // ──────────────────────────────────────────
  patrolTest('el FAB abre la pantalla de Add Transaction', ($) async {
    await $.pumpAndSettle();

    // Verifica que estamos en Home
    expect(find.byKey(const Key('home_page')), findsOneWidget);

    // Abre el FAB de "Add Transaction" (OpenContainer FAB)
    await $.tap(find.byType(FloatingActionButton));
    await $.pumpAndSettle();

    // Verifica que la pantalla de AddTransaction es visible
    expect(find.byKey(const Key('add_transaction_page')), findsOneWidget);
  });

  // ──────────────────────────────────────────
  // Group 3: Filtros de transacciones
  // ──────────────────────────────────────────
  patrolTest('puede abrir el panel de filtros desde All Transactions', (
    $,
  ) async {
    await $.pumpAndSettle();

    // Navega a All Transactions vía botón "See All"
    final seeAllButton = find.byKey(const Key('see_all_transactions'));
    if (seeAllButton.evaluate().isNotEmpty) {
      await $.tap(seeAllButton);
      await $.pumpAndSettle();

      // Abre el panel de filtros
      await $.tap(find.byKey(const Key('filter_button')));
      await $.pumpAndSettle();

      // Verifica que el BottomSheet de filtros es visible
      expect(find.byKey(const Key('transaction_filter_sheet')), findsOneWidget);

      // Cierra el sheet
      await $.tap(find.byIcon(Icons.close));
      await $.pumpAndSettle();
    }
  });
}
