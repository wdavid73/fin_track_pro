import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SettingsEntity', () {
    // ── Construction ──────────────────────────────────────────────────────

    test('creates with provided themeMode', () {
      const entity = SettingsEntity(themeMode: ThemeMode.dark);
      expect(entity.themeMode, ThemeMode.dark);
    });

    // ── initial() factory ─────────────────────────────────────────────────

    test('initial() returns ThemeMode.system', () {
      final entity = SettingsEntity.initial();
      expect(entity.themeMode, ThemeMode.system);
    });

    // ── Equatable ─────────────────────────────────────────────────────────

    test('two entities with same themeMode are equal', () {
      const a = SettingsEntity(themeMode: ThemeMode.dark);
      const b = SettingsEntity(themeMode: ThemeMode.dark);
      expect(a, equals(b));
    });

    test('two entities with different themeMode are not equal', () {
      const a = SettingsEntity(themeMode: ThemeMode.light);
      const b = SettingsEntity(themeMode: ThemeMode.dark);
      expect(a, isNot(equals(b)));
    });

    test('props contains themeMode', () {
      const entity = SettingsEntity(themeMode: ThemeMode.light);
      expect(entity.props, [ThemeMode.light]);
    });

    // ── copyWith() ────────────────────────────────────────────────────────

    test('copyWith changes themeMode', () {
      const original = SettingsEntity(themeMode: ThemeMode.light);
      final copy = original.copyWith(themeMode: ThemeMode.dark);
      expect(copy.themeMode, ThemeMode.dark);
    });

    test('copyWith without args preserves all fields', () {
      const original = SettingsEntity(themeMode: ThemeMode.dark);
      final copy = original.copyWith();
      expect(copy, equals(original));
    });
  });
}
