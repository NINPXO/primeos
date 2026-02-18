import '../../../../core/types/app_result.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetAppSettings {
  final SettingsRepository repository;

  GetAppSettings(this.repository);

  Future<AppResult<AppSettingsEntity>> call() {
    return repository.getSettings();
  }
}
