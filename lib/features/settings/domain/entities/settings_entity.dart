import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class SettingsEntity extends Equatable {
  final ThemeMode themeMode;
  final bool hasSeenOnboarding;

  const SettingsEntity({
    required this.themeMode,
    this.hasSeenOnboarding = false,
  });

  factory SettingsEntity.initial() => const SettingsEntity(
        themeMode: ThemeMode.system,
        hasSeenOnboarding: false,
      );

  @override
  List<Object?> get props => [themeMode, hasSeenOnboarding];

  SettingsEntity copyWith({
    ThemeMode? themeMode,
    bool? hasSeenOnboarding,
  }) {
    return SettingsEntity(
      themeMode: themeMode ?? this.themeMode,
      hasSeenOnboarding: hasSeenOnboarding ?? this.hasSeenOnboarding,
    );
  }
}
