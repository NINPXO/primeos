import 'package:freezed_annotation/freezed_annotation.dart';

part 'app_settings.freezed.dart';

/// Application settings entity
@freezed
class AppSettingsEntity with _$AppSettingsEntity {
  const factory AppSettingsEntity({
    required String themeMode, // 'light' | 'dark' | 'system'
    required String dbVersion,
    required DateTime updatedAt,
  }) = _AppSettingsEntity;
}
