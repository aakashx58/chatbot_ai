import 'dart:async';

import 'package:flutter_gemma/flutter_gemma.dart' as gemma;
import 'package:flutter_gemma_litertlm/flutter_gemma_litertlm.dart';
import 'package:flutter_gemma_mediapipe/flutter_gemma_mediapipe.dart';

import '../../../../core/error/exceptions.dart';
import '../../domain/entities/llm_model.dart';

/// The only class that talks to flutter_gemma's model management API.
abstract interface class GemmaModelDataSource {
  Future<void> initialize();

  Future<List<String>> installedFileIds();

  /// Downloads (if needed) and marks [model] active. Emits progress 0–100.
  Stream<int> install(LlmModel model);

  void cancelInstall();

  Future<void> uninstall(LlmModel model);

  /// Loads [model] into memory for inference.
  Future<gemma.InferenceModel> load(LlmModel model);
}

final class GemmaModelDataSourceImpl implements GemmaModelDataSource {
  gemma.CancelToken? _cancelToken;

  @override
  Future<void> initialize() => gemma.FlutterGemma.initialize(
    inferenceEngines: const [LiteRtLmEngine(), MediaPipeEngine()],
  );

  @override
  Future<List<String>> installedFileIds() => gemma.FlutterGemma.listInstalledModels();

  @override
  Stream<int> install(LlmModel model) {
    final controller = StreamController<int>();
    final token = _cancelToken = gemma.CancelToken();

    _builder(model)
        .withCancelToken(token)
        .withProgress(controller.add)
        .install()
        .then((_) => controller.close())
        .catchError((Object error) {
          controller
            ..addError(_mapInstallError(error))
            ..close();
        });

    return controller.stream;
  }

  @override
  void cancelInstall() => _cancelToken?.cancel('Cancelled by user');

  @override
  Future<void> uninstall(LlmModel model) async {
    final ids = await installedFileIds();
    for (final id in ids.where((id) => matchesFile(id, model))) {
      await gemma.FlutterGemma.uninstallModel(id);
    }
  }

  @override
  Future<gemma.InferenceModel> load(LlmModel model) async {
    // Re-running install() on an installed file skips the download and only
    // switches flutter_gemma's active model.
    await _builder(model).install();
    return gemma.FlutterGemma.getActiveModel(
      maxTokens: model.maxTokens,
      preferredBackend: gemma.PreferredBackend.cpu,
    );
  }

  /// Installed ids may be namespaced, so match by file-name suffix.
  static bool matchesFile(String installedId, LlmModel model) =>
      installedId == model.fileName || installedId.endsWith(model.fileName);

  gemma.InferenceInstallationBuilder _builder(LlmModel model) => gemma.FlutterGemma.installModel(
    modelType: model.family.toGemma(),
    fileType: model.format.toGemma(),
  ).fromNetwork(model.url);

  static AppException _mapInstallError(Object error) => switch (error) {
    gemma.DownloadException(:final error) => StorageException(error.toUserMessage()),
    _ when gemma.CancelToken.isCancel(error) => const StorageException('Download cancelled.'),
    _ => StorageException('Model download failed: $error'),
  };
}

extension LlmFamilyGemmaX on LlmFamily {
  gemma.ModelType toGemma() => switch (this) {
    LlmFamily.qwen3 => gemma.ModelType.qwen3,
    LlmFamily.qwen => gemma.ModelType.qwen,
    LlmFamily.general => gemma.ModelType.general,
  };
}

extension LlmFormatGemmaX on LlmFormat {
  gemma.ModelFileType toGemma() => switch (this) {
    LlmFormat.litertlm => gemma.ModelFileType.litertlm,
    LlmFormat.task => gemma.ModelFileType.task,
  };
}
