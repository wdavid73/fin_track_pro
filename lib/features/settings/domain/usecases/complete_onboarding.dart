import 'package:fin_track_pro/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CompleteOnboarding {
  final SettingsRepository repository;

  CompleteOnboarding(this.repository);

  Future<void> call() async {
    final settings = await repository.getSettings();
    final newSettings = settings.copyWith(hasSeenOnboarding: true);
    await repository.saveSettings(newSettings);
  }
}
