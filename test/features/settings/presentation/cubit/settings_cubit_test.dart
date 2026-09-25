import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:offline_ai/core/error/failures.dart';
import 'package:offline_ai/core/error/result.dart';
import 'package:offline_ai/core/notifications/notification_service.dart';
import 'package:offline_ai/core/usecase/usecase.dart';
import 'package:offline_ai/features/settings/domain/entities/app_settings.dart';
import 'package:offline_ai/features/settings/domain/usecases/get_settings.dart';
import 'package:offline_ai/features/settings/domain/usecases/save_settings.dart';
import 'package:offline_ai/features/settings/presentation/cubit/settings_cubit.dart';

class _MockGetSettings extends Mock implements GetSettings {}

class _MockSaveSettings extends Mock implements SaveSettings {}

class _MockNotificationService extends Mock implements NotificationService {}

void main() {
  late _MockGetSettings getSettings;
  late _MockSaveSettings saveSettings;
  late _MockNotificationService notifications;

  setUpAll(() {
    registerFallbackValue(const NoParams());
    registerFallbackValue(AppSettings.defaults);
  });

  setUp(() {
    getSettings = _MockGetSettings();
    saveSettings = _MockSaveSettings();
    notifications = _MockNotificationService();

    when(() => saveSettings(any())).thenAnswer(
      (invocation) async => Ok(invocation.positionalArguments.first as AppSettings),
    );
    when(() => notifications.scheduleDailyReminder()).thenAnswer((_) async {});
    when(() => notifications.cancelDailyReminder()).thenAnswer((_) async {});
  });

  SettingsCubit buildCubit() => SettingsCubit(
    getSettings: getSettings,
    saveSettings: saveSettings,
    notificationService: notifications,
  );

  blocTest<SettingsCubit, SettingsState>(
    'load emits stored settings',
    setUp: () => when(() => getSettings(any())).thenAnswer(
      (_) async => const Ok(AppSettings(themeMode: AppThemeMode.dark)),
    ),
    build: buildCubit,
    act: (cubit) => cubit.load(),
    expect: () => [
      const SettingsState(settings: AppSettings(themeMode: AppThemeMode.dark), isLoaded: true),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'rolls back an optimistic change when saving fails',
    setUp: () => when(() => saveSettings(any())).thenAnswer(
      (_) async => const Err(CacheFailure('disk full')),
    ),
    build: buildCubit,
    act: (cubit) => cubit.setStreaming(false),
    expect: () => [
      const SettingsState(settings: AppSettings(streamingEnabled: false)),
      const SettingsState(message: 'disk full'),
    ],
  );

  blocTest<SettingsCubit, SettingsState>(
    'does not enable notifications when permission is denied',
    setUp: () => when(() => notifications.requestPermission()).thenAnswer((_) async => false),
    build: buildCubit,
    act: (cubit) => cubit.setNotifications(true),
    expect: () => [const SettingsState(message: 'Notification permission was denied.')],
    verify: (_) => verifyNever(() => saveSettings(any())),
  );

  blocTest<SettingsCubit, SettingsState>(
    'enabling the daily reminder schedules it',
    setUp: () => when(() => notifications.requestPermission()).thenAnswer((_) async => true),
    build: buildCubit,
    seed: () => const SettingsState(settings: AppSettings(notificationsEnabled: true)),
    act: (cubit) => cubit.setDailyReminder(true),
    expect: () => [
      const SettingsState(
        settings: AppSettings(notificationsEnabled: true, dailyReminderEnabled: true),
      ),
    ],
    verify: (_) => verify(() => notifications.scheduleDailyReminder()).called(1),
  );

  blocTest<SettingsCubit, SettingsState>(
    'turning notifications off also cancels the reminder',
    build: buildCubit,
    seed: () => const SettingsState(
      settings: AppSettings(notificationsEnabled: true, dailyReminderEnabled: true),
    ),
    act: (cubit) => cubit.setNotifications(false),
    expect: () => [const SettingsState()],
    verify: (_) => verify(() => notifications.cancelDailyReminder()).called(1),
  );
}
