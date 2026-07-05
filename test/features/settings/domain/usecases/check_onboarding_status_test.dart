import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/check_onboarding_status.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/settings_mocks.dart';

void main() {
  late CheckOnboardingStatus sut;
  late MockSettingsRepository mockRepository;

  setUp(() {
    mockRepository = MockSettingsRepository();
    sut = CheckOnboardingStatus(mockRepository);
  });

  group('CheckOnboardingStatus', () {
    test('returns true when hasSeenOnboarding is true', () async {
      const tSettings = SettingsEntity(
        themeMode: ThemeMode.system,
        hasSeenOnboarding: true,
      );
      when(() => mockRepository.getSettings()).thenAnswer((_) async => tSettings);

      final result = await sut.call();

      expect(result, isTrue);
      verify(() => mockRepository.getSettings()).called(1);
    });

    test('returns false when hasSeenOnboarding is false', () async {
      const tSettings = SettingsEntity(
        themeMode: ThemeMode.system,
        hasSeenOnboarding: false,
      );
      when(() => mockRepository.getSettings()).thenAnswer((_) async => tSettings);

      final result = await sut.call();

      expect(result, isFalse);
      verify(() => mockRepository.getSettings()).called(1);
    });

    test('returns false for initial settings (default)', () async {
      when(
        () => mockRepository.getSettings(),
      ).thenAnswer((_) async => SettingsEntity.initial());

      final result = await sut.call();

      expect(result, isFalse);
    });

    test('propagates exception when repository fails', () async {
      when(
        () => mockRepository.getSettings(),
      ).thenThrow(Exception('Storage error'));

      expect(() => sut.call(), throwsA(isA<Exception>()));
    });
  });
}
