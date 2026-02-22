import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/features/settings/data/datasources/settings_local_datasource.dart';
import 'package:fin_track_pro/features/settings/data/models/settings_model.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive_ce.dart';
import 'package:mocktail/mocktail.dart';

// ---------------------------------------------------------------------------
// Fakes & Mocks
// ---------------------------------------------------------------------------

class MockHiveService extends Mock implements HiveService {}

class _FakeSettingsBox extends Fake implements Box {
  final Map<dynamic, dynamic> _data = {};

  @override
  dynamic get(dynamic key, {dynamic defaultValue}) =>
      _data[key] ?? defaultValue;

  @override
  Future<void> put(dynamic key, dynamic value) async => _data[key] = value;

  @override
  bool get isEmpty => _data.isEmpty;

  @override
  bool get isNotEmpty => _data.isNotEmpty;

  @override
  Iterable get values => _data.values;
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  late MockHiveService hiveService;
  late _FakeSettingsBox settingsBox;
  late SettingsLocalDatasource datasource;

  setUp(() {
    hiveService = MockHiveService();
    settingsBox = _FakeSettingsBox();
    datasource = SettingsLocalDatasource(hiveService);

    when(() => hiveService.getBox('settings')).thenReturn(settingsBox);
  });

  group('SettingsLocalDatasource', () {
    group('getSettings()', () {
      test(
        'returns default settings and persists them when box is empty',
        () async {
          final result = await datasource.getSettings();

          // Default is persisted
          expect(settingsBox._data.containsKey('app_settings'), isTrue);

          // Default settings match SettingsEntity.initial() — stored as ThemeMode
          expect(result.themeMode, ThemeMode.system);
        },
      );

      test('returns stored settings when they exist', () async {
        final saved = SettingsModel.fromEntity(
          const SettingsEntity(themeMode: ThemeMode.dark),
        );
        settingsBox._data['app_settings'] = saved;

        final result = await datasource.getSettings();

        expect(result.themeMode, saved.themeMode);
      });
    });

    group('saveSettings()', () {
      test('persists settings to box with the correct key', () async {
        final model = SettingsModel.fromEntity(
          const SettingsEntity(themeMode: ThemeMode.dark),
        );

        await datasource.saveSettings(model);

        expect(settingsBox._data['app_settings'], model);
      });

      test('overwrites previously saved settings', () async {
        final first = SettingsModel.fromEntity(
          const SettingsEntity(themeMode: ThemeMode.light),
        );
        final second = SettingsModel.fromEntity(
          const SettingsEntity(themeMode: ThemeMode.dark),
        );

        await datasource.saveSettings(first);
        await datasource.saveSettings(second);

        expect(
          (settingsBox._data['app_settings'] as SettingsModel).themeMode,
          second.themeMode,
        );
      });
    });
  });
}
