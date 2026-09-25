import '../../../../core/constants/app_constants.dart';
import '../../../../core/storage/key_value_storage.dart';
import '../../domain/entities/app_settings.dart';
import '../models/app_settings_model.dart';

abstract interface class SettingsLocalDataSource {
  AppSettings read();

  Future<void> write(AppSettings settings);
}

final class SettingsLocalDataSourceImpl implements SettingsLocalDataSource {
  const SettingsLocalDataSourceImpl(this._storage);

  final KeyValueStorage _storage;

  static const _defaults = AppSettings.defaults;

  @override
  AppSettings read() {
    return AppSettings(
      themeMode: AppSettingsModel.themeModeFromName(
        _storage.read<String>(StorageKeys.themeMode),
      ),
      streamingEnabled:
          _storage.read<bool>(StorageKeys.streamingEnabled) ?? _defaults.streamingEnabled,
      notificationsEnabled:
          _storage.read<bool>(StorageKeys.notificationsEnabled) ??
          _defaults.notificationsEnabled,
      dailyReminderEnabled:
          _storage.read<bool>(StorageKeys.dailyReminderEnabled) ??
          _defaults.dailyReminderEnabled,
    );
  }

  @override
  Future<void> write(AppSettings settings) async {
    await Future.wait([
      _storage.write(StorageKeys.themeMode, settings.themeMode.name),
      _storage.write(StorageKeys.streamingEnabled, settings.streamingEnabled),
      _storage.write(StorageKeys.notificationsEnabled, settings.notificationsEnabled),
      _storage.write(StorageKeys.dailyReminderEnabled, settings.dailyReminderEnabled),
    ]);
  }
}
