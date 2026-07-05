// 🖼️ Golden Tests — BalanceHeroCard (Alchemist)
//
// Pruebas de regresión visual para el widget BalanceHeroCard.
// BalanceHeroCard es el hero widget principal de la Home: muestra
// el saldo total con gradiente, soporte de visibilidad y toggle.
//
// Nota: BalanceHeroCard usa context.l10n y context.textTheme,
// por lo que requiere pumpWithFinTrackTheme.

import 'package:alchemist/alchemist.dart';
import 'package:fin_track_pro/features/home/presentation/widget/balance_summary.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('BalanceHeroCard golden tests', () {
    goldenTest(
      'renders all balance hero card states correctly',
      fileName: 'balance_hero_card_states',
      pumpWidget: pumpWithFinTrackTheme,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 400),
        children: [
          GoldenTestScenario(
            name: 'positive balance — visible',
            child: BalanceHeroCard(
              balance: 12345.67,
              isVisible: true,
              onToggle: () {},
            ),
          ),
          GoldenTestScenario(
            name: 'balance hidden',
            child: BalanceHeroCard(
              balance: 12345.67,
              isVisible: false,
              onToggle: () {},
            ),
          ),
          GoldenTestScenario(
            name: 'zero balance — visible',
            child: BalanceHeroCard(
              balance: 0.00,
              isVisible: true,
              onToggle: () {},
            ),
          ),
          GoldenTestScenario(
            name: 'negative balance — visible',
            child: BalanceHeroCard(
              balance: -500.25,
              isVisible: true,
              onToggle: () {},
            ),
          ),
        ],
      ),
    );
  });
}
