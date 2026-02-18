import '../../../../core/types/app_result.dart';
import '../repositories/settings_repository.dart';

class UpdateThemeMode {
  final SettingsRepository repository;

  UpdateThemeMode(this.repository);

  Future<AppResult<void>> call(String mode) {
    return repository.setThemeMode(mode);
  }
}
