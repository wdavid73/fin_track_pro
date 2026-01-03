import 'package:fin_track_pro/features/settings/data/datasources/settings_datasource.dart';
import 'package:fin_track_pro/features/settings/data/models/settings_model.dart';
import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: SettingsRepository)
class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsDatasource datasource;

  SettingsRepositoryImpl(this.datasource);

  @override
  Future<SettingsEntity> getSettings() {
    try {
      final settings = datasource.getSettings();
      return settings;
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) {
    try {
      final model = SettingsModel.fromEntity(settings);
      return datasource.saveSettings(model);
    } catch (e) {
      throw Exception('Failed to save settings: $e');
    }
  }
}
