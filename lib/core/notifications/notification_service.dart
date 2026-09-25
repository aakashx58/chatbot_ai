import 'dart:async';
import 'dart:io';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../constants/app_constants.dart';

/// App-facing notification API. Features depend on this interface only.
abstract interface class NotificationService {
  Future<void> init();

  Future<bool> requestPermission();

  /// [payload] is routed back through [onNotificationTap] (e.g. a conversation id).
  Future<void> show({required String title, required String body, String payload = ''});

  Future<void> scheduleDailyReminder();

  Future<void> cancelDailyReminder();

  /// Emits the payload (a conversation id, or empty) when a notification is tapped.
  Stream<String> get onNotificationTap;

  /// Payload of the notification that cold-started the app, if any.
  Future<String?> consumeLaunchPayload();
}

final class LocalNotificationService implements NotificationService {
  LocalNotificationService(this._plugin);

  final FlutterLocalNotificationsPlugin _plugin;
  final _tapController = StreamController<String>.broadcast();

  @override
  Stream<String> get onNotificationTap => _tapController.stream;

  @override
  Future<void> init() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(NotificationConstants.androidIcon),
        // Permission is requested explicitly from settings, not on launch.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) =>
          _tapController.add(response.payload ?? ''),
    );
  }

  @override
  Future<bool> requestPermission() async {
    if (Platform.isAndroid) {
      final android = _plugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      return await android?.requestNotificationsPermission() ?? false;
    }
    if (Platform.isIOS) {
      final ios = _plugin
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    }
    return false;
  }

  @override
  Future<void> show({required String title, required String body, String payload = ''}) {
    return _plugin.show(
      // Stable per payload so repeated updates for one chat replace each other.
      id: (payload.isEmpty ? title : payload).hashCode & 0x7fffffff,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: _details(
        channelId: NotificationConstants.updatesChannelId,
        channelName: NotificationConstants.updatesChannelName,
        channelDescription: NotificationConstants.updatesChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
    );
  }

  @override
  Future<void> scheduleDailyReminder() async {
    await cancelDailyReminder();
    await _plugin.periodicallyShow(
      id: NotificationConstants.dailyReminderId,
      title: NotificationConstants.reminderTitle,
      body: NotificationConstants.reminderBody,
      payload: '',
      repeatInterval: RepeatInterval.daily,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      notificationDetails: _details(
        channelId: NotificationConstants.reminderChannelId,
        channelName: NotificationConstants.reminderChannelName,
        channelDescription: NotificationConstants.reminderChannelDescription,
      ),
    );
  }

  @override
  Future<void> cancelDailyReminder() =>
      _plugin.cancel(id: NotificationConstants.dailyReminderId);

  @override
  Future<String?> consumeLaunchPayload() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp != true) return null;
    return details?.notificationResponse?.payload;
  }

  /// Single builder for per-channel details (DRY across notification types).
  NotificationDetails _details({
    required String channelId,
    required String channelName,
    required String channelDescription,
    Importance importance = Importance.defaultImportance,
    Priority priority = Priority.defaultPriority,
  }) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        channelId,
        channelName,
        channelDescription: channelDescription,
        importance: importance,
        priority: priority,
      ),
      iOS: const DarwinNotificationDetails(),
    );
  }
}
