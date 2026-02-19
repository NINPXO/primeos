import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/providers/database_provider.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_app_settings.dart';
import '../../domain/usecases/update_theme_mode.dart';

/// Provider for settings repository (async)
final settingsRepositoryProvider = FutureProvider((ref) async {
  final database = await ref.watch(databaseProvider.future);
  final datasource = SettingsLocalDataSource(database: database);
  return SettingsRepositoryImpl(localDataSource: datasource);
});

/// Provider for GetAppSettings use case
final getAppSettingsUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(settingsRepositoryProvider.future);
  return GetAppSettings(repository);
});

/// Provider for UpdateThemeMode use case
final updateThemeModeUseCaseProvider = FutureProvider((ref) async {
  final repository = await ref.watch(settingsRepositoryProvider.future);
  return UpdateThemeMode(repository);
});

/// Provider for application settings
final appSettingsProvider = FutureProvider<AppSettingsEntity>((ref) async {
  final useCase = await ref.watch(getAppSettingsUseCaseProvider.future);
  final result = await useCase();

  return result.fold(
    (failure) => const AppSettingsEntity(
      themeMode: 'system',
      dbVersion: '1',
      updatedAt: null,
    ),
    (data) => data,
  );
});

/// State notifier for theme mode with persistence
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final UpdateThemeMode updateThemeModeUseCase;
  final String initialMode;

  ThemeModeNotifier({
    required this.updateThemeModeUseCase,
    required this.initialMode,
  }) : super(_stringToThemeMode(initialMode));

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    final modeString = _themeModeToString(mode);
    await updateThemeModeUseCase(modeString);
  }

  static ThemeMode _stringToThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  static String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }
}

/// Provider for theme mode state
final themeModeProvider =
    StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final settings = ref.watch(appSettingsProvider).maybeWhen(
    data: (data) => data,
    orElse: () => const AppSettingsEntity(
      themeMode: 'system',
      dbVersion: '1',
      updatedAt: null,
    ),
  );

  return ThemeModeNotifier(
    updateThemeModeUseCase: UpdateThemeMode(
      ref.watch(settingsRepositoryProvider).maybeWhen(
        data: (repo) => repo,
        orElse: () => throw UnimplementedError(),
      ),
    ),
    initialMode: settings.themeMode,
  );
});
