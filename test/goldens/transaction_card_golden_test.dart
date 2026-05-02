// 🖼️ Golden Tests — TransactionCard (Alchemist)
//
// Pruebas de regresión visual para el widget TransactionCard.
// Garantizan que el widget no cambie visualmente de forma accidental.
//
// Ejecución:
//   # Generar/actualizar capturas de referencia:
//   fvm flutter test test/goldens/transaction_card_golden_test.dart --update-goldens
//
//   # Validar contra capturas existentes:
//   fvm flutter test --tags golden
//
// Alchemist genera dos tipos de imágenes (relativas al archivo de test):
//   goldens/ci/      → texto oscurecido (estable en CI cross-platform) — versionado en git
//   goldens/macos/   → texto legible (revisión humana local)           — en .gitignore

import 'package:alchemist/alchemist.dart';
import 'package:fin_track_pro/features/home/presentation/widget/transaction_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('TransactionCard golden tests', () {
    goldenTest(
      'renders all transaction states correctly',
      fileName: 'transaction_card_states',
      pumpWidget: pumpWithFinTrackTheme,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 420),
        children: [
          GoldenTestScenario(
            name: 'income',
            child: const TransactionCard(
              icon: Icons.arrow_downward,
              iconBackgroundColor: Color(0xFFE8F5E9),
              iconColor: Color(0xFF43A047),
              title: 'Monthly Salary',
              date: 'Jan 22, 2026',
              amount: 3500.00,
              amountColor: Color(0xFF43A047),
              isIncome: true,
              heroTag: 'income-hero',
            ),
          ),
          GoldenTestScenario(
            name: 'expense',
            child: const TransactionCard(
              icon: Icons.arrow_upward,
              iconBackgroundColor: Color(0xFFFFEBEE),
              iconColor: Color(0xFFE53935),
              title: 'Grocery Shopping',
              date: 'Jan 22, 2026',
              amount: 87.50,
              amountColor: Color(0xFFE53935),
              isIncome: false,
              heroTag: 'expense-hero',
            ),
          ),
          GoldenTestScenario(
            name: 'long description',
            child: const TransactionCard(
              icon: Icons.arrow_downward,
              iconBackgroundColor: Color(0xFFE8F5E9),
              iconColor: Color(0xFF43A047),
              // ignore: lines_longer_than_80_chars
              title:
                  'A very long transaction title that should be truncated with ellipsis',
              date: 'Jan 22, 2026',
              amount: 120.00,
              amountColor: Color(0xFF43A047),
              isIncome: true,
            ),
          ),
          GoldenTestScenario(
            name: 'no heroTag — container icon',
            child: const TransactionCard(
              icon: Icons.arrow_upward,
              iconBackgroundColor: Color(0xFFFFEBEE),
              iconColor: Color(0xFFE53935),
              title: 'Transfer',
              date: 'Jan 22, 2026',
              amount: 200.00,
              amountColor: Color(0xFFE53935),
              isIncome: false,
            ),
          ),
        ],
      ),
    );
  });
}
