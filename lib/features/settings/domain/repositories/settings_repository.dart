import '../../../../core/error/result.dart';
import '../entities/app_settings.dart';

abstract interface class SettingsRepository {
  Future<Result<AppSettings>> getSettings();

  Future<Result<AppSettings>> saveSettings(AppSettings settings);
}
