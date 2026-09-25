import '../../../../core/error/result.dart';
import '../entities/llm_model.dart';

abstract interface class ModelRepository {
  /// All models the app knows how to download.
  List<LlmModel> get catalog;

  Future<Result<Set<String>>> getInstalledModelIds();

  /// The model the chat should use, or `null` for the built-in basic engine.
  Future<LlmModel?> getActiveModel();

  Future<Result<void>> setActiveModel(LlmModel? model);

  /// Downloads [model] and makes it active. Emits progress 0–100.
  /// Errors are emitted as [Failure]s.
  Stream<int> download(LlmModel model);

  void cancelDownload();

  Future<Result<void>> delete(LlmModel model);
}
