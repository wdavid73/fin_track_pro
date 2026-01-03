import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsEntity extends Equatable {
  final ThemeMode themeMode;

  const SettingsEntity({required this.themeMode});

  factory SettingsEntity.initial() =>
      const SettingsEntity(themeMode: ThemeMode.system);

  @override
  List<Object?> get props => [themeMode];

  SettingsEntity copyWith({ThemeMode? themeMode}) {
    return SettingsEntity(themeMode: themeMode ?? this.themeMode);
  }
}
