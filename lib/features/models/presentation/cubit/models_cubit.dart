import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/error/result.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../settings/domain/usecases/notify_user.dart';
import '../../domain/entities/llm_model.dart';
import '../../domain/usecases/model_usecases.dart';

part 'models_state.dart';

/// App-wide so a download keeps running when the user leaves the screen.
final class ModelsCubit extends Cubit<ModelsState> {
  ModelsCubit({
    required this._getOverview,
    required this._downloadModel,
    required this._selectModel,
    required this._deleteModel,
    required this._notifyUser,
  }) : super(const ModelsState());

  final GetModelOverview _getOverview;
  final DownloadModel _downloadModel;
  final SelectModel _selectModel;
  final DeleteModel _deleteModel;
  final NotifyUser _notifyUser;

  StreamSubscription<int>? _download;

  Future<void> load() async {
    final result = await _getOverview(const NoParams());
    emit(
      result.fold(
        (failure) => state.copyWith(isLoading: false, message: failure.message),
        (overview) => state.copyWith(
          isLoading: false,
          catalog: overview.catalog,
          installedIds: overview.installedIds,
          activeModelId: () => overview.activeModelId,
        ),
      ),
    );
  }

  void download(LlmModel model) {
    if (state.isDownloading) return;
    emit(state.copyWith(downloadingId: () => model.id, progress: 0));

    _download = _downloadModel(model).listen(
      (progress) => emit(state.copyWith(progress: progress)),
      onError: (Object error) => _finishDownload(
        message: error is Failure ? error.message : 'Download failed.',
      ),
      onDone: () async {
        await _finishDownload(message: '${model.name} is ready. Chats now use it.');
        await _notifyUser(
          NotifyUserParams(
            title: 'Model ready',
            body: '${model.name} finished downloading and works offline.',
          ),
        );
      },
    );
  }

  void cancelDownload() => _downloadModel.cancel();

  Future<void> select(LlmModel? model) => _runAndReload(
    () => _selectModel(model),
    success: model == null ? 'Switched to basic mode.' : 'Now using ${model.name}.',
  );

  Future<void> delete(LlmModel model) => _runAndReload(
    () => _deleteModel(model),
    success: '${model.name} deleted.',
  );

  Future<void> _finishDownload({required String message}) async {
    _download = null;
    emit(state.copyWith(downloadingId: () => null, progress: 0, message: message));
    await load();
  }

  /// Shared "do it, report, refresh" flow for select/delete (DRY).
  Future<void> _runAndReload(
    Future<Result<void>> Function() action, {
    required String success,
  }) async {
    final result = await action();
    await load();
    emit(state.copyWith(message: result.fold((f) => f.message, (_) => success)));
  }

  @override
  Future<void> close() async {
    await _download?.cancel();
    return super.close();
  }
}
