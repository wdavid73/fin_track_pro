import 'package:equatable/equatable.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/get_settings.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/save_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';

part 'settings_event.dart';
part 'settings_state.dart';

@injectable
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final GetSettings getSettings;
  final SaveSettings saveSettings;

  SettingsBloc({required this.getSettings, required this.saveSettings})
    : super(const SettingsState()) {
    on<LoadSettings>(_onLoadSettings);
    on<ChangeThemeMode>(_onChangeThemeMode);
    on<CompleteOnboardingEvent>(_onCompleteOnboarding);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final result = await getSettings.call();
      emit(state.copyWith(status: SettingsStatus.success, settings: result));
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.error));
    } finally {
      emit(state.copyWith(status: SettingsStatus.initial));
    }
  }

  Future<void> _onChangeThemeMode(
    ChangeThemeMode event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final currentSettings = state.settings ?? SettingsEntity.initial();
      final newSettings = currentSettings.copyWith(themeMode: event.themeMode);
      await saveSettings.call(newSettings);
      emit(
        state.copyWith(
          status: SettingsStatus.success,
          settings: newSettings,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.error));
    } finally {
      emit(state.copyWith(status: SettingsStatus.initial));
    }
  }

  Future<void> _onCompleteOnboarding(
    CompleteOnboardingEvent event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(status: SettingsStatus.loading));
    try {
      final currentSettings = state.settings ?? SettingsEntity.initial();
      final newSettings = currentSettings.copyWith(hasSeenOnboarding: true);
      await saveSettings.call(newSettings);
      emit(
        state.copyWith(
          status: SettingsStatus.success,
          settings: newSettings,
        ),
      );
    } catch (e) {
      emit(state.copyWith(status: SettingsStatus.error));
    } finally {
      emit(state.copyWith(status: SettingsStatus.initial));
    }
  }
}
