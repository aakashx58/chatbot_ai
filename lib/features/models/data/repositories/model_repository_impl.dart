import '../../../../core/constants/app_constants.dart';
import '../../../../core/error/guard.dart';
import '../../../../core/error/result.dart';
import '../../../../core/storage/key_value_storage.dart';
import '../../domain/entities/llm_model.dart';
import '../../domain/repositories/model_repository.dart';
import '../datasources/gemma_model_data_source.dart';
import '../datasources/model_catalog.dart';

final class ModelRepositoryImpl implements ModelRepository {
  const ModelRepositoryImpl({required this._gemma, required this._storage});

  final GemmaModelDataSource _gemma;
  final KeyValueStorage _storage;

  @override
  List<LlmModel> get catalog => ModelCatalog.models;

  @override
  Future<Result<Set<String>>> getInstalledModelIds() => guard(() async {
    final files = await _gemma.installedFileIds();
    return {
      for (final model in catalog)
        if (files.any((f) => GemmaModelDataSourceImpl.matchesFile(f, model))) model.id,
    };
  });

  @override
  Future<LlmModel?> getActiveModel() async {
    final id = _storage.read<String>(StorageKeys.activeModelId);
    if (id == null) return null;
    return catalog.where((m) => m.id == id).firstOrNull;
  }

  @override
  Future<Result<void>> setActiveModel(LlmModel? model) => guard(
    () => model == null
        ? _storage.remove(StorageKeys.activeModelId)
        : _storage.write(StorageKeys.activeModelId, model.id),
  );

  @override
  Stream<int> download(LlmModel model) async* {
    try {
      yield* _gemma.install(model);
    } catch (e) {
      throw mapExceptionToFailure(e);
    }
    final activated = await setActiveModel(model);
    if (activated case Err(:final failure)) throw failure;
  }

  @override
  void cancelDownload() => _gemma.cancelInstall();

  @override
  Future<Result<void>> delete(LlmModel model) => guard(() async {
    await _gemma.uninstall(model);
    if ((await getActiveModel())?.id == model.id) {
      await _storage.remove(StorageKeys.activeModelId);
    }
  });
}
