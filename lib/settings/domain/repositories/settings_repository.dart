import '../../../../core/types/app_result.dart';
import '../entities/app_settings.dart';

/// Repository interface for application settings
abstract class SettingsRepository {
  /// Get all application settings
  Future<AppResult<AppSettingsEntity>> getSettings();

  /// Update a specific setting
  Future<AppResult<void>> updateSetting(String key, String value);

  /// Get a specific setting value
  Future<AppResult<String?>> getSetting(String key);

  /// Get theme mode (convenience method)
  Future<AppResult<String>> getThemeMode();

  /// Update theme mode
  Future<AppResult<void>> setThemeMode(String mode);
}
