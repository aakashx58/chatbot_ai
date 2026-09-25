import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/app_settings.dart';
import '../repositories/settings_repository.dart';

class GetSettings implements UseCase<AppSettings, NoParams> {
  const GetSettings(this._repository);

  final SettingsRepository _repository;

  @override
  Future<Result<AppSettings>> call(NoParams params) => _repository.getSettings();
}
