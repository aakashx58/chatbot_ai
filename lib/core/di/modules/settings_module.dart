import 'package:get_it/get_it.dart';

import '../../../features/settings/data/datasources/settings_local_data_source.dart';
import '../../../features/settings/data/repositories/settings_repository_impl.dart';
import '../../../features/settings/domain/repositories/settings_repository.dart';
import '../../../features/settings/domain/usecases/get_settings.dart';
import '../../../features/settings/domain/usecases/notify_user.dart';
import '../../../features/settings/domain/usecases/save_settings.dart';
import '../../../features/settings/presentation/cubit/settings_cubit.dart';

void registerSettingsModule(GetIt sl) {
  sl
    // Data
    ..registerLazySingleton<SettingsLocalDataSource>(() => SettingsLocalDataSourceImpl(sl()))
    ..registerLazySingleton<SettingsRepository>(() => SettingsRepositoryImpl(sl()))
    // Domain
    ..registerLazySingleton(() => GetSettings(sl()))
    ..registerLazySingleton(() => SaveSettings(sl()))
    ..registerLazySingleton(
      () => NotifyUser(
        settingsRepository: sl(),
        notificationService: sl(),
        lifecycleTracker: sl(),
      ),
    )
    // Presentation
    ..registerFactory(
      () => SettingsCubit(getSettings: sl(), saveSettings: sl(), notificationService: sl()),
    );
}
