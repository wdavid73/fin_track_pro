import 'package:fin_track_pro/features/settings/domain/entities/settings_entity.dart';
import 'package:fin_track_pro/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetSettings {
  final SettingsRepository _repository;

  GetSettings(this._repository);

  Future<SettingsEntity> call() async {
    return await _repository.getSettings();
  }
}
