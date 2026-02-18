import '../../domain/entities/app_settings.dart';

class AppSettingsModel extends AppSettingsEntity {
  const AppSettingsModel({
    required super.themeMode,
    required super.dbVersion,
    required super.updatedAt,
  });

  factory AppSettingsModel.fromEntity(AppSettingsEntity entity) {
    return AppSettingsModel(
      themeMode: entity.themeMode,
      dbVersion: entity.dbVersion,
      updatedAt: entity.updatedAt,
    );
  }

  AppSettingsEntity toEntity() {
    return AppSettingsEntity(
      themeMode: themeMode,
      dbVersion: dbVersion,
      updatedAt: updatedAt,
    );
  }
}
