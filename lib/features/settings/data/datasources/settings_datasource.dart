import 'package:fin_track_pro/features/settings/data/models/settings_model.dart';

abstract class SettingsDatasource {
  Future<SettingsModel> getSettings();
  Future<void> saveSettings(SettingsModel settings);
}
