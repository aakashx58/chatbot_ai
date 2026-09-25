import '../../domain/entities/app_settings.dart';

/// Parsing helpers between raw stored values and [AppSettings].
abstract final class AppSettingsModel {
  static AppThemeMode themeModeFromName(String? name) => AppThemeMode.values.firstWhere(
    (mode) => mode.name == name,
    orElse: () => AppSettings.defaults.themeMode,
  );
}
