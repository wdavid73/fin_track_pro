import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/complete_onboarding.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/settings_mocks.dart';

void main() {
  late CompleteOnboarding sut;
  late MockSettingsRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const SettingsEntity(themeMode: ThemeMode.system));
  });

  setUp(() {
    mockRepository = MockSettingsRepository();
    sut = CompleteOnboarding(mockRepository);
  });

  group('CompleteOnboarding', () {
    test('reads settings, sets hasSeenOnboarding to true, and saves', () async {
      const tInitial = SettingsEntity(
        themeMode: ThemeMode.system,
        hasSeenOnboarding: false,
      );
      when(() => mockRepository.getSettings()).thenAnswer((_) async => tInitial);
      when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});

      await sut.call();

      verify(() => mockRepository.getSettings()).called(1);
      final captured = verify(
        () => mockRepository.saveSettings(captureAny()),
      ).captured.first as SettingsEntity;
      expect(captured.hasSeenOnboarding, isTrue);
      expect(captured.themeMode, ThemeMode.system);
    });

    test('preserves existing themeMode when completing onboarding', () async {
      const tDarkSettings = SettingsEntity(
        themeMode: ThemeMode.dark,
        hasSeenOnboarding: false,
      );
      when(() => mockRepository.getSettings()).thenAnswer((_) async => tDarkSettings);
      when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});

      await sut.call();

      final captured = verify(
        () => mockRepository.saveSettings(captureAny()),
      ).captured.first as SettingsEntity;
      expect(captured.hasSeenOnboarding, isTrue);
      expect(captured.themeMode, ThemeMode.dark);
    });

    test('is idempotent when onboarding already completed', () async {
      const tAlreadySeen = SettingsEntity(
        themeMode: ThemeMode.light,
        hasSeenOnboarding: true,
      );
      when(() => mockRepository.getSettings()).thenAnswer((_) async => tAlreadySeen);
      when(() => mockRepository.saveSettings(any())).thenAnswer((_) async {});

      await sut.call();

      final captured = verify(
        () => mockRepository.saveSettings(captureAny()),
      ).captured.first as SettingsEntity;
      expect(captured.hasSeenOnboarding, isTrue);
    });

    test('propagates exception when getSettings fails', () async {
      when(
        () => mockRepository.getSettings(),
      ).thenThrow(Exception('Storage error'));

      expect(() => sut.call(), throwsA(isA<Exception>()));
      verifyNever(() => mockRepository.saveSettings(any()));
    });

    test('propagates exception when saveSettings fails', () async {
      when(
        () => mockRepository.getSettings(),
      ).thenAnswer((_) async => SettingsEntity.initial());
      when(
        () => mockRepository.saveSettings(any()),
      ).thenThrow(Exception('Write error'));

      expect(() => sut.call(), throwsA(isA<Exception>()));
    });
  });
}
