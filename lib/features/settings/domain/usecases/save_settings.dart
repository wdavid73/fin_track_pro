import 'package:injectable/injectable.dart';

import '../entities/settings_entity.dart';
import '../repositories/settings_repository.dart';

@injectable
class SaveSettings {
  final SettingsRepository _repository;

  SaveSettings(this._repository);

  Future<void> call(SettingsEntity settings) async {
    return await _repository.saveSettings(settings);
  }
}
