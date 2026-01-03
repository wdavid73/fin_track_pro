import 'package:fin_track_pro/core/database/hive_service.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:injectable/injectable.dart';

import '../models/settings_model.dart';
import 'settings_datasource.dart';

@LazySingleton(as: SettingsDatasource)
class SettingsLocalDatasource implements SettingsDatasource {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'app_settings';

  final HiveService _hiveService;

  SettingsLocalDatasource(this._hiveService);

  @override
  Future<SettingsModel> getSettings() async {
    final box = _hiveService.getBox(_boxName);
    final settings = box.get(_settingsKey);
    if (settings == null) {
      final defautlSettings = SettingsModel.fromEntity(
        SettingsEntity.initial(),
      );
      await box.put(_settingsKey, defautlSettings);
      return defautlSettings;
    }
    return settings;
  }

  @override
  Future<void> saveSettings(SettingsModel settings) async {
    final box = _hiveService.getBox(_boxName);
    await box.put(_settingsKey, settings);
  }
}
