import 'package:get_it/get_it.dart';

import '../../../features/models/data/datasources/gemma_model_data_source.dart';
import '../../../features/models/data/engine/on_device_llm_engine.dart';
import '../../../features/models/data/repositories/model_repository_impl.dart';
import '../../../features/models/domain/repositories/model_repository.dart';
import '../../../features/models/domain/usecases/model_usecases.dart';
import '../../../features/models/presentation/cubit/models_cubit.dart';

Future<void> registerModelsModule(GetIt sl) async {
  final gemma = GemmaModelDataSourceImpl();
  await gemma.initialize();

  sl
    // Data
    ..registerSingleton<GemmaModelDataSource>(gemma)
    ..registerLazySingleton<ModelRepository>(
      () => ModelRepositoryImpl(gemma: sl(), storage: sl()),
    )
    ..registerLazySingleton(() => OnDeviceLlmEngine(models: sl(), gemma: sl()))
    // Domain
    ..registerLazySingleton(() => GetModelOverview(sl()))
    ..registerLazySingleton(() => DownloadModel(sl()))
    ..registerLazySingleton(() => SelectModel(sl()))
    ..registerLazySingleton(() => DeleteModel(sl()))
    // Presentation
    ..registerFactory(
      () => ModelsCubit(
        getOverview: sl(),
        downloadModel: sl(),
        selectModel: sl(),
        deleteModel: sl(),
        notifyUser: sl(),
      ),
    );
}
