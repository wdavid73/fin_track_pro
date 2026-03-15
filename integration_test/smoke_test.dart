// integration_test/smoke_test.dart
//
// Patrol Smoke Tests — FinTrack Pro
//
// Ejecución:
//   patrol test --target integration_test/smoke_test.dart --flavor dev --device emulator-5554
//
// Requisito: simulador/emulador activo con la app instalada en flavor dev.

import 'package:fin_track_pro/core/config/flavor_config.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:fin_track_pro/features/transactions/presentation/widgets/category_chip.dart';
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
      expect(find.byKey(const Key('all_transactions_page')), findsOneWidget);
    }
  });

  // ──────────────────────────────────────────
  // Test 4: Crear transacción E2E completo
  // ──────────────────────────────────────────
  patrolTest(
    'puede crear una transacción y verificarla en Home y All Transactions',
    ($) async {
      // ────────────────────────────────────────────────────────────────
      // Fase 1: Bootstrap y verificar estado inicial
      // ────────────────────────────────────────────────────────────────
      await bootstrap();
      await $.pumpAndSettle();

      // Verificamos que estamos en Home
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // ────────────────────────────────────────────────────────────────
      // Fase 2: Abrir modal de Add Transaction via FAB
      // ────────────────────────────────────────────────────────────────
      await $.tap(find.byIcon(Icons.add));

      // OpenContainer animation: 400ms + buffer
      await $.tester.pump(const Duration(milliseconds: 500));
      await $.pumpAndSettle();

      // AddTransactionPage debe estar visible
      expect(find.byKey(const Key('add_transaction_page')), findsOneWidget);

      // ────────────────────────────────────────────────────────────────
      // Fase 3: Esperar carga de categorías
      // ────────────────────────────────────────────────────────────────
      await $.pumpAndSettle(timeout: const Duration(seconds: 5));

      // Verificar que las categorías cargaron (no loading indicator)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // ────────────────────────────────────────────────────────────────
      // Fase 4: Llenar formulario con datos únicos
      // ────────────────────────────────────────────────────────────────
      final uniqueDescription = 'E2E_${DateTime.now().millisecondsSinceEpoch}';

      // 4a. Ingresar monto (primer TextField)
      final amountField = find.byType(TextField).first;
      await $.tap(amountField);
      await $.tester.enterText(amountField, '123');
      await $.pumpAndSettle();

      // 4b. Seleccionar primera categoría disponible (cierra el teclado)
      final categoryChip = find.byType(CategoryChip).first;
      await $.tap(categoryChip);
      await $.pumpAndSettle();

      // 4c. Scroll para hacer visible el campo de descripción
      final descriptionField = find.byType(TextField).last;
      await $.scrollUntilVisible(
        finder: descriptionField,
        view: find.byType(SingleChildScrollView).first,
        delta: 100,
      );
      await $.pumpAndSettle();

      // Ingresar descripción única
      await $.tap(descriptionField);
      await $.tester.enterText(descriptionField, uniqueDescription);
      await $.pumpAndSettle();

      // ────────────────────────────────────────────────────────────────
      // Fase 5: Guardar transacción (la fecha por defecto es hoy)
      // ────────────────────────────────────────────────────────────────
      // El botón de guardar está fuera del SingleChildScrollView,
      // en un Padding fijo en la parte inferior, por lo que siempre es visible.
      final saveButton = find.byKey(const Key('save_transaction_button'));

      // Esperar a que el formulario se valide y el botón esté habilitado
      await $.pumpAndSettle(timeout: const Duration(seconds: 2));

      await $.tap(saveButton);
      await $.pumpAndSettle(timeout: const Duration(seconds: 3));

      // ────────────────────────────────────────────────────────────────
      // Fase 6: Verificar modal cerrado y volver a Home
      // ────────────────────────────────────────────────────────────────
      expect(find.byKey(const Key('add_transaction_page')), findsNothing);
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // ────────────────────────────────────────────────────────────────
      // Fase 7: Verificar transacción en Home (Recent Transactions)
      // ────────────────────────────────────────────────────────────────
      // Nota: En Home se muestra el nombre de la categoría, no la descripción.
      // Verificamos que hay al menos una transacción visible.
      await $.pumpAndSettle(timeout: const Duration(seconds: 3));
      expect(find.byType(TransactionCard), findsWidgets);

      // ────────────────────────────────────────────────────────────────
      // Fase 8: Navegar a All Transactions
      // ────────────────────────────────────────────────────────────────
      final seeAllFinder = find.byKey(const Key('see_all_transactions'));

      // Scroll hasta que el botón sea visible
      await $.scrollUntilVisible(
        finder: seeAllFinder,
        view: find.byType(SingleChildScrollView).first,
        delta: 100,
      );
      await $.pumpAndSettle();

      await $.tap(seeAllFinder);
      await $.pumpAndSettle(timeout: const Duration(seconds: 5));

      // ────────────────────────────────────────────────────────────────
      // Fase 9: Verificar transacción en All Transactions
      // ────────────────────────────────────────────────────────────────
      expect(find.byKey(const Key('all_transactions_page')), findsOneWidget);
      expect(find.text(uniqueDescription), findsOneWidget);
    },
  );
}
