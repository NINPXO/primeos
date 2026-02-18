import 'package:sqflite/sqflite.dart';
import '../../../../core/constants/db_constants.dart';
import '../models/app_settings_model.dart';

class SettingsLocalDataSource {
  final Database database;

  SettingsLocalDataSource({required this.database});

  /// Get all settings from app_settings table
  Future<AppSettingsModel> getSettings() async {
    try {
      final result = await database.query(DbConstants.appSettingsTable);

      // Convert list of rows to map
      final settings = <String, String>{};
      for (final row in result) {
        final key = row[DbConstants.keyColumn] as String;
        final value = row['value'] as String;
        settings[key] = value;
      }

      return AppSettingsModel(
        themeMode: settings['theme_mode'] ?? 'system',
        dbVersion: settings['db_version'] ?? '1',
        updatedAt: DateTime.now(),
      );
    } catch (e) {
      throw Exception('Failed to get settings: $e');
    }
  }

  /// Get a specific setting by key
  Future<String?> getSetting(String key) async {
    try {
      final result = await database.query(
        DbConstants.appSettingsTable,
        columns: ['value'],
        where: '${DbConstants.keyColumn} = ?',
        whereArgs: [key],
        limit: 1,
      );

      if (result.isEmpty) return null;
      return result.first['value'] as String?;
    } catch (e) {
      throw Exception('Failed to get setting: $e');
    }
  }

  /// Update a setting
  Future<void> updateSetting(String key, String value) async {
    try {
      await database.insert(
        DbConstants.appSettingsTable,
        {
          DbConstants.keyColumn: key,
          'value': value,
          DbConstants.updatedAtColumn: DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw Exception('Failed to update setting: $e');
    }
  }

  /// Get theme mode
  Future<String> getThemeMode() async {
    final result = await getSetting('theme_mode');
    return result ?? 'system';
  }

  /// Set theme mode
  Future<void> setThemeMode(String mode) async {
    return updateSetting('theme_mode', mode);
  }
}
