part of 'settings_bloc.dart';

enum SettingsStatus { initial, loading, success, error }

class SettingsState extends Equatable {
  final SettingsStatus status;
  final SettingsEntity? settings;

  const SettingsState({this.status = SettingsStatus.initial, this.settings});

  SettingsState copyWith({SettingsStatus? status, SettingsEntity? settings}) {
    return SettingsState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [status, settings];
}
