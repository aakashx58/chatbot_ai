import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/llm_model.dart';
import '../repositories/model_repository.dart';

final class ModelOverview {
  const ModelOverview({
    required this.catalog,
    required this.installedIds,
    required this.activeModelId,
  });

  final List<LlmModel> catalog;
  final Set<String> installedIds;
  final String? activeModelId;
}

/// Catalog + install state + active model in one call for the models screen.
class GetModelOverview implements UseCase<ModelOverview, NoParams> {
  const GetModelOverview(this._repository);

  final ModelRepository _repository;

  @override
  Future<Result<ModelOverview>> call(NoParams params) async {
    final installed = await _repository.getInstalledModelIds();
    final active = await _repository.getActiveModel();
    return installed.fold(
      Err.new,
      (ids) => Ok(
        ModelOverview(
          catalog: _repository.catalog,
          installedIds: ids,
          activeModelId: active?.id,
        ),
      ),
    );
  }
}

class DownloadModel implements StreamUseCase<int, LlmModel> {
  const DownloadModel(this._repository);

  final ModelRepository _repository;

  @override
  Stream<int> call(LlmModel model) => _repository.download(model);

  void cancel() => _repository.cancelDownload();
}

/// `null` switches back to the built-in basic engine.
class SelectModel implements UseCase<void, LlmModel?> {
  const SelectModel(this._repository);

  final ModelRepository _repository;

  @override
  Future<Result<void>> call(LlmModel? model) => _repository.setActiveModel(model);
}

class DeleteModel implements UseCase<void, LlmModel> {
  const DeleteModel(this._repository);

  final ModelRepository _repository;

  @override
  Future<Result<void>> call(LlmModel model) => _repository.delete(model);
}
