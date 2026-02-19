import '../../../../core/types/app_result.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  final SettingsLocalDataSource localDataSource;

  SettingsRepositoryImpl({required this.localDataSource});

  @override
  Future<AppResult<AppSettingsEntity>> getSettings() async {
    try {
      final settings = await localDataSource.getSettings();
      return AppResult.success(settings.toEntity());
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to get settings: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AppResult<void>> updateSetting(String key, String value) async {
    try {
      await localDataSource.updateSetting(key, value);
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to update setting: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AppResult<String?>> getSetting(String key) async {
    try {
      final value = await localDataSource.getSetting(key);
      return AppResult.success(value);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure(
          message: 'Failed to get setting "$key": ${e.toString()}',
        ),
      );
    }
  }

  @override
  Future<AppResult<String>> getThemeMode() async {
    try {
      final mode = await localDataSource.getThemeMode();
      return AppResult.success(mode);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to get theme mode: ${e.toString()}'),
      );
    }
  }

  @override
  Future<AppResult<void>> setThemeMode(String mode) async {
    try {
      await localDataSource.setThemeMode(mode);
      return AppResult.success(null);
    } catch (e) {
      return AppResult.failure(
        DatabaseFailure( 'Failed to set theme mode: ${e.toString()}'),
      );
    }
  }
}
