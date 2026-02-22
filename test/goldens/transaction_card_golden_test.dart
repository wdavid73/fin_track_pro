// 🖼️ Golden Tests — FinTrack Pro
//
// Pruebas de regresión visual para los widgets clave.
// Garantizan que los componentes no cambien visualmente de forma accidental.
//
// Ejecución:
//   # Generar/actualizar capturas base:
//   fvm flutter test test/goldens/ --update-goldens
//
//   # Validar contra capturas existentes:
//   fvm flutter test test/goldens/
//
// Los archivos .png generados se guardan en test/goldens/goldens/
// y deben ser comiteados al repositorio.
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';

// ─── Helpers ─────────────────────────────────────────────────────────────────

Widget _buildCard({
  required String title,
  required double amount,
  required bool isIncome,
  String? heroTag,
}) {
  return MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      useMaterial3: true,
    ),
    home: Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TransactionCard(
          icon: isIncome ? Icons.arrow_downward : Icons.arrow_upward,
          iconBackgroundColor: isIncome
              ? const Color(0xFFE8F5E9)
              : const Color(0xFFFFEBEE),
          iconColor: isIncome
              ? const Color(0xFF43A047)
              : const Color(0xFFE53935),
          title: title,
          date: 'Jan 22, 2026',
          amount: amount,
          amountColor: isIncome
              ? const Color(0xFF43A047)
              : const Color(0xFFE53935),
          isIncome: isIncome,
          heroTag: heroTag,
        ),
      ),
    ),
  );
}

// ─── Tests ────────────────────────────────────────────────────────────────────

void main() {
  setUpAll(() async {
    await loadAppFonts();
  });

  group('TransactionCard — Golden Tests', () {
    testGoldens('income transaction card renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [Device.phone, Device.iphone11],
        )
        ..addScenario(
          widget: _buildCard(
            title: 'Monthly Salary',
            amount: 3500.00,
            isIncome: true,
          ),
          name: 'income — light theme',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'transaction_card_income');
    });

    testGoldens('expense transaction card renders correctly', (tester) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(
          devices: [Device.phone, Device.iphone11],
        )
        ..addScenario(
          widget: _buildCard(
            title: 'Grocery Shopping',
            amount: 87.50,
            isIncome: false,
          ),
          name: 'expense — light theme',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'transaction_card_expense');
    });

    testGoldens('transaction card with long title truncates correctly', (
      tester,
    ) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: _buildCard(
            title:
                'A very long transaction title that should be truncated with ellipsis',
            amount: 120.00,
            isIncome: true,
          ),
          name: 'long title — truncated',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'transaction_card_long_title');
    });

    testGoldens('transaction card without heroTag renders container icon', (
      tester,
    ) async {
      final builder = DeviceBuilder()
        ..overrideDevicesForAllScenarios(devices: [Device.phone])
        ..addScenario(
          widget: _buildCard(
            title: 'Transfer',
            amount: 200.00,
            isIncome: false,
          ),
          name: 'no heroTag',
        );

      await tester.pumpDeviceBuilder(builder);
      await screenMatchesGolden(tester, 'transaction_card_no_hero');
    });
  });
}
