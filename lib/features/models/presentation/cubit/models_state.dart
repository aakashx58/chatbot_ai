part of 'models_cubit.dart';

final class ModelsState extends Equatable {
  const ModelsState({
    this.isLoading = true,
    this.catalog = const [],
    this.installedIds = const {},
    this.activeModelId,
    this.downloadingId,
    this.progress = 0,
    this.message,
  });

  final bool isLoading;
  final List<LlmModel> catalog;
  final Set<String> installedIds;
  final String? activeModelId;
  final String? downloadingId;

  /// Download progress 0–100 for [downloadingId].
  final int progress;

  /// One-off feedback for a SnackBar. Cleared on the next emit.
  final String? message;

  LlmModel? get activeModel => catalog.where((m) => m.id == activeModelId).firstOrNull;

  bool get isDownloading => downloadingId != null;

  ModelInstallStatus statusOf(LlmModel model) => switch (model.id) {
    final id when id == downloadingId => ModelInstallStatus.downloading,
    final id when installedIds.contains(id) => ModelInstallStatus.installed,
    _ => ModelInstallStatus.notInstalled,
  };

  ModelsState copyWith({
    bool? isLoading,
    List<LlmModel>? catalog,
    Set<String>? installedIds,
    ValueGetter<String?>? activeModelId,
    ValueGetter<String?>? downloadingId,
    int? progress,
    String? message,
  }) {
    return ModelsState(
      isLoading: isLoading ?? this.isLoading,
      catalog: catalog ?? this.catalog,
      installedIds: installedIds ?? this.installedIds,
      activeModelId: activeModelId != null ? activeModelId() : this.activeModelId,
      downloadingId: downloadingId != null ? downloadingId() : this.downloadingId,
      progress: progress ?? this.progress,
      message: message,
    );
  }

  @override
  List<Object?> get props => [
    isLoading,
    catalog,
    installedIds,
    activeModelId,
    downloadingId,
    progress,
    message,
  ];
}
