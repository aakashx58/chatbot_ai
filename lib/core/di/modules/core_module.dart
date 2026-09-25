import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../database/app_database.dart';
import '../../lifecycle/app_lifecycle_tracker.dart';
import '../../notifications/notification_service.dart';
import '../../router/app_router.dart';
import '../../storage/key_value_storage.dart';

Future<void> registerCoreModule(GetIt sl) async {
  // External singletons that need async setup are resolved up front.
  final prefs = await SharedPreferences.getInstance();
  final database = await AppDatabase.open();
  final notifications = LocalNotificationService(FlutterLocalNotificationsPlugin());
  await notifications.init();

  sl
    ..registerSingleton<SharedPreferences>(prefs)
    ..registerSingleton<AppDatabase>(database, dispose: (db) => db.close())
    ..registerSingleton<NotificationService>(notifications)
    ..registerLazySingleton<KeyValueStorage>(() => SharedPreferencesStorage(sl()))
    ..registerLazySingleton<AppLifecycleTracker>(
      FlutterAppLifecycleTracker.new,
      dispose: (tracker) => tracker.dispose(),
    )
    ..registerLazySingleton(Uuid.new)
    ..registerLazySingleton(AppRouter.new);
}
