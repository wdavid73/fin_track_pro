import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:flutter/material.dart';
import 'package:hive_ce/hive_ce.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 3)
class SettingsModel extends SettingsEntity {
  @HiveField(0)
  final String themeModeString;

  @override
  @HiveField(1, defaultValue: false)
  // ignore: overridden_fields
  final bool hasSeenOnboarding;

  SettingsModel({
    required this.themeModeString,
    required this.hasSeenOnboarding,
  }) : super(
          themeMode: _themeModeFromString(themeModeString),
          hasSeenOnboarding: hasSeenOnboarding,
        );

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      themeModeString: _themeModeToString(entity.themeMode),
      hasSeenOnboarding: entity.hasSeenOnboarding,
    );
  }

  static ThemeMode _themeModeFromString(String value) {
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
        return ThemeMode.system;
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}
