import 'package:bloc_test/bloc_test.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/presentation/blocs/settings_bloc/settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../mocks/settings_mocks.dart';

void main() {
  late SettingsBloc bloc;
  late MockGetSettings mockGetSettings;
  late MockSaveSettings mockSaveSettings;

  setUpAll(() {
    registerFallbackValue(const SettingsEntity(themeMode: ThemeMode.system));
  });

  setUp(() {
    mockGetSettings = MockGetSettings();
    mockSaveSettings = MockSaveSettings();
    bloc = SettingsBloc(
      getSettings: mockGetSettings,
      saveSettings: mockSaveSettings,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('SettingsBloc', () {
    test('initial state should be SettingsState with initial status', () {
      expect(bloc.state.status, SettingsStatus.initial);
      expect(bloc.state.settings, isNull);
    });

    group('LoadSettings', () {
      const tSettings = SettingsEntity(themeMode: ThemeMode.system);

      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success, initial] when getSettings succeeds',
        build: () {
          when(() => mockGetSettings()).thenAnswer((_) async => tSettings);
          return bloc;
        },
        act: (bloc) => bloc.add(LoadSettings()),
        expect: () => [
          const SettingsState(status: SettingsStatus.loading),
          const SettingsState(
            status: SettingsStatus.success,
            settings: tSettings,
          ),
          const SettingsState(
            status: SettingsStatus.initial,
            settings: tSettings,
          ),
        ],
        verify: (_) {
          verify(() => mockGetSettings()).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, error, initial] when getSettings fails',
        build: () {
          when(
            () => mockGetSettings(),
          ).thenThrow(Exception('Failed to load settings'));
          return bloc;
        },
        act: (bloc) => bloc.add(LoadSettings()),
        expect: () => [
          const SettingsState(status: SettingsStatus.loading),
          const SettingsState(status: SettingsStatus.error),
          const SettingsState(status: SettingsStatus.initial),
        ],
        verify: (_) {
          verify(() => mockGetSettings()).called(1);
        },
      );
    });

    group('ChangeThemeMode', () {
      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success, initial] with dark theme when save succeeds',
        build: () {
          when(() => mockSaveSettings(any())).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.dark)),
        expect: () => [
          const SettingsState(status: SettingsStatus.loading),
          const SettingsState(
            status: SettingsStatus.success,
            settings: SettingsEntity(themeMode: ThemeMode.dark),
          ),
          const SettingsState(
            status: SettingsStatus.initial,
            settings: SettingsEntity(themeMode: ThemeMode.dark),
          ),
        ],
        verify: (_) {
          verify(() => mockSaveSettings(any())).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success, initial] with light theme when save succeeds',
        build: () {
          when(() => mockSaveSettings(any())).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.light)),
        expect: () => [
          const SettingsState(status: SettingsStatus.loading),
          const SettingsState(
            status: SettingsStatus.success,
            settings: SettingsEntity(themeMode: ThemeMode.light),
          ),
          const SettingsState(
            status: SettingsStatus.initial,
            settings: SettingsEntity(themeMode: ThemeMode.light),
          ),
        ],
        verify: (_) {
          verify(() => mockSaveSettings(any())).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, success, initial] with system theme when save succeeds',
        build: () {
          when(() => mockSaveSettings(any())).thenAnswer((_) async => {});
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.system)),
        expect: () => [
          const SettingsState(status: SettingsStatus.loading),
          const SettingsState(
            status: SettingsStatus.success,
            settings: SettingsEntity(themeMode: ThemeMode.system),
          ),
          const SettingsState(
            status: SettingsStatus.initial,
            settings: SettingsEntity(themeMode: ThemeMode.system),
          ),
        ],
        verify: (_) {
          verify(() => mockSaveSettings(any())).called(1);
        },
      );

      blocTest<SettingsBloc, SettingsState>(
        'should emit [loading, error, initial] when saveSettings fails',
        build: () {
          when(
            () => mockSaveSettings(any()),
          ).thenThrow(Exception('Failed to save settings'));
          return bloc;
        },
        act: (bloc) => bloc.add(const ChangeThemeMode(ThemeMode.dark)),
        expect: () => [
          const SettingsState(status: SettingsStatus.loading),
          const SettingsState(status: SettingsStatus.error),
          const SettingsState(status: SettingsStatus.initial),
        ],
        verify: (_) {
          verify(() => mockSaveSettings(any())).called(1);
        },
      );
    });
  });
}
