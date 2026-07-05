// 🖼️ Golden Tests — StatCard (Alchemist)
//
// Pruebas de regresión visual para el widget StatCard.
// StatCard muestra un ícono con fondo coloreado, un label y un valor.
// Aparece en la sección de quick stats de la Home page.

import 'package:alchemist/alchemist.dart';
import 'package:fin_track_pro/features/home/presentation/widget/stat_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/golden_test_helpers.dart';

void main() {
  group('StatCard golden tests', () {
    goldenTest(
      'renders all stat card variants correctly',
      fileName: 'stat_card_variants',
      pumpWidget: pumpWithFinTrackTheme,
      builder: () => GoldenTestGroup(
        scenarioConstraints: const BoxConstraints(maxWidth: 380),
        children: [
          GoldenTestScenario(
            name: 'income stat',
            child: const StatCard(
              icon: Icons.arrow_downward_rounded,
              iconBg: Color(0xFFE8F5E9),
              iconColor: Color(0xFF43A047),
              label: 'Total Income',
              value: r'$3,500.00',
            ),
          ),
          GoldenTestScenario(
            name: 'expense stat',
            child: const StatCard(
              icon: Icons.arrow_upward_rounded,
              iconBg: Color(0xFFFFEBEE),
              iconColor: Color(0xFFE53935),
              label: 'Total Expenses',
              value: r'$1,247.50',
            ),
          ),
          GoldenTestScenario(
            name: 'savings stat',
            child: const StatCard(
              icon: Icons.savings_rounded,
              iconBg: Color(0xFFE3F2FD),
              iconColor: Color(0xFF1E88E5),
              label: 'Net Savings',
              value: r'$2,252.50',
            ),
          ),
          GoldenTestScenario(
            name: 'long value text',
            child: const StatCard(
              icon: Icons.account_balance_wallet_rounded,
              iconBg: Color(0xFFF3E5F5),
              iconColor: Color(0xFF8E24AA),
              label: 'Total Balance',
              value: r'$123,456,789.99',
            ),
          ),
        ],
      ),
    );
  });
}
