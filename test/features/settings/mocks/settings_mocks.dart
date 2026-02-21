import 'package:fin_track_pro/features/settings/data/datasources/settings_datasource.dart';
import 'package:fin_track_pro/features/settings/domain/repositories/settings_repository.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/get_settings.dart';
import 'package:fin_track_pro/features/settings/domain/usecases/save_settings.dart';
import 'package:mocktail/mocktail.dart';

class MockSettingsRepository extends Mock implements SettingsRepository {}

class MockGetSettings extends Mock implements GetSettings {}

class MockSaveSettings extends Mock implements SaveSettings {}

class MockSettingsDatasource extends Mock implements SettingsDatasource {}
