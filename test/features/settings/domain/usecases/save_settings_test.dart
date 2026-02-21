import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/save_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/settings_mocks.dart';

void main() {
  late SaveSettings useCase;
  late MockSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const SettingsEntity(themeMode: ThemeMode.system));
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = SaveSettings(mockRepository);
  });

  group('SaveSettings', () {
    test(
      'should call repository.saveSettings() with the given entity',
      () async {
        // Arrange
        const tSettings = SettingsEntity(themeMode: ThemeMode.dark);
        when(
          () => mockRepository.saveSettings(any()),
        ).thenAnswer((_) async => {});

        // Act
        await useCase(tSettings);

        // Assert
        verify(() => mockRepository.saveSettings(tSettings)).called(1);
      },
    );

    test('should propagate exception when repository fails', () async {
      // Arrange
      const tSettings = SettingsEntity(themeMode: ThemeMode.light);
      when(
        () => mockRepository.saveSettings(any()),
      ).thenThrow(Exception('Failed to save settings'));

      // Act & Assert
      expect(() => useCase(tSettings), throwsA(isA<Exception>()));
    });

    test('should save light theme correctly', () async {
      // Arrange
      const tSettings = SettingsEntity(themeMode: ThemeMode.light);
      when(
        () => mockRepository.saveSettings(any()),
      ).thenAnswer((_) async => {});

      // Act
      await useCase(tSettings);

      // Assert
      final captured = verify(
        () => mockRepository.saveSettings(captureAny()),
      ).captured;
      expect((captured.first as SettingsEntity).themeMode, ThemeMode.light);
    });

    test('should save dark theme correctly', () async {
      // Arrange
      const tSettings = SettingsEntity(themeMode: ThemeMode.dark);
      when(
        () => mockRepository.saveSettings(any()),
      ).thenAnswer((_) async => {});

      // Act
      await useCase(tSettings);

      // Assert
      final captured = verify(
        () => mockRepository.saveSettings(captureAny()),
      ).captured;
      expect((captured.first as SettingsEntity).themeMode, ThemeMode.dark);
    });

    test('should save system theme correctly', () async {
      // Arrange
      const tSettings = SettingsEntity(themeMode: ThemeMode.system);
      when(
        () => mockRepository.saveSettings(any()),
      ).thenAnswer((_) async => {});

      // Act
      await useCase(tSettings);

      // Assert
      final captured = verify(
        () => mockRepository.saveSettings(captureAny()),
      ).captured;
      expect((captured.first as SettingsEntity).themeMode, ThemeMode.system);
    });
  });
}
