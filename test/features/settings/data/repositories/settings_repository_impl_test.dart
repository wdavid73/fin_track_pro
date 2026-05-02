import 'package:fin_track_pro/features/settings/data/models/settings_model.dart';
import 'package:fin_track_pro/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/settings_mocks.dart';

void main() {
  late SettingsRepositoryImpl repository;
  late MockSettingsDatasource mockDatasource;

  setUpAll(() {
    registerFallbackValue(SettingsModel(themeModeString: 'system', hasSeenOnboarding: false));
  });

  setUp(() {
    mockDatasource = MockSettingsDatasource();
    repository = SettingsRepositoryImpl(mockDatasource);
  });

  group('SettingsRepositoryImpl', () {
    group('getSettings', () {
      test('should return SettingsEntity when datasource succeeds', () async {
        // Arrange
        final tModel = SettingsModel(themeModeString: 'dark', hasSeenOnboarding: false);
        when(
          () => mockDatasource.getSettings(),
        ).thenAnswer((_) async => tModel);

        // Act
        final result = await repository.getSettings();

        // Assert
        expect(result.themeMode, ThemeMode.dark);
        verify(() => mockDatasource.getSettings()).called(1);
      });

      test(
        'should return system theme when datasource returns default',
        () async {
          // Arrange
          final tModel = SettingsModel(themeModeString: 'system', hasSeenOnboarding: false);
          when(
            () => mockDatasource.getSettings(),
          ).thenAnswer((_) async => tModel);

          // Act
          final result = await repository.getSettings();

          // Assert
          expect(result.themeMode, ThemeMode.system);
        },
      );

      test('should throw Exception when datasource fails', () async {
        // Arrange
        when(
          () => mockDatasource.getSettings(),
        ).thenThrow(Exception('Hive read error'));

        // Act & Assert
        expect(
          () => repository.getSettings(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to get settings'),
            ),
          ),
        );
      });
    });

    group('saveSettings', () {
      const tSettings = SettingsEntity(themeMode: ThemeMode.light);

      test(
        'should convert entity to model and call datasource.saveSettings()',
        () async {
          // Arrange
          when(
            () => mockDatasource.saveSettings(any()),
          ).thenAnswer((_) async => {});

          // Act
          await repository.saveSettings(tSettings);

          // Assert
          final captured = verify(
            () => mockDatasource.saveSettings(captureAny()),
          ).captured;
          final savedModel = captured.first as SettingsModel;
          expect(savedModel.themeModeString, 'light');
        },
      );

      test('should throw Exception when datasource fails', () async {
        // Arrange
        when(
          () => mockDatasource.saveSettings(any()),
        ).thenThrow(Exception('Hive write error'));

        // Act & Assert
        expect(
          () => repository.saveSettings(tSettings),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Failed to save settings'),
            ),
          ),
        );
      });
    });
  });
}
