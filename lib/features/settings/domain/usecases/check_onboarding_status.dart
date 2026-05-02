import 'package:fin_track_pro/features/settings/domain/repositories/settings_repository.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class CheckOnboardingStatus {
  final SettingsRepository repository;

  CheckOnboardingStatus(this.repository);

  Future<bool> call() async {
    final settings = await repository.getSettings();
    return settings.hasSeenOnboarding;
  }
}
