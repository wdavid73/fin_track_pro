import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/get_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/settings_mocks.dart';

void main() {
  late GetSettings useCase;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    useCase = GetSettings(mockRepository);
  });

  group('GetSettings', () {
    const tSettings = SettingsEntity(themeMode: ThemeMode.system);

    test(
      'should call repository.getSettings() and return SettingsEntity',
      () async {
        // Arrange
        when(
          () => mockRepository.getSettings(),
        ).thenAnswer((_) async => tSettings);

        // Act
        final result = await useCase();

        // Assert
        expect(result, tSettings);
        verify(() => mockRepository.getSettings()).called(1);
      },
    );

    test('should propagate exception when repository fails', () async {
      // Arrange
      when(
        () => mockRepository.getSettings(),
      ).thenThrow(Exception('Failed to get settings'));

      // Act & Assert
      expect(() => useCase(), throwsA(isA<Exception>()));
    });

    test('should return light theme settings', () async {
      // Arrange
      const tLightSettings = SettingsEntity(themeMode: ThemeMode.light);
      when(
        () => mockRepository.getSettings(),
      ).thenAnswer((_) async => tLightSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.themeMode, ThemeMode.light);
    });

    test('should return dark theme settings', () async {
      // Arrange
      const tDarkSettings = SettingsEntity(themeMode: ThemeMode.dark);
      when(
        () => mockRepository.getSettings(),
      ).thenAnswer((_) async => tDarkSettings);

      // Act
      final result = await useCase();

      // Assert
      expect(result.themeMode, ThemeMode.dark);
    });
  });
}
