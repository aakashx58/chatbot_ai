import '../../../../core/error/guard.dart';
import '../../../../core/error/result.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../datasources/settings_local_data_source.dart';

final class SettingsRepositoryImpl implements SettingsRepository {
  const SettingsRepositoryImpl(this._local);

  final SettingsLocalDataSource _local;

  @override
  Future<Result<AppSettings>> getSettings() => guard(() async => _local.read());

  @override
  Future<Result<AppSettings>> saveSettings(AppSettings settings) => guard(() async {
    await _local.write(settings);
    return settings;
  });
}
