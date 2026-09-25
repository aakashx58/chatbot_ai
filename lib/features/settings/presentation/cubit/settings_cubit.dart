import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/notifications/notification_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/usecases/get_settings.dart';
import '../../domain/usecases/save_settings.dart';

part 'settings_state.dart';

final class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({
    required this._getSettings,
    required this._saveSettings,
    required this._notificationService,
  }) : super(const SettingsState());

  final GetSettings _getSettings;
  final SaveSettings _saveSettings;
  final NotificationService _notificationService;

  Future<void> load() async {
    final result = await _getSettings(const NoParams());
    emit(
      result.fold(
        (failure) => state.copyWith(isLoaded: true, message: failure.message),
        (settings) => state.copyWith(settings: settings, isLoaded: true),
      ),
    );
  }

  Future<void> setThemeMode(AppThemeMode mode) =>
      _update((s) => s.copyWith(themeMode: mode));

  Future<void> setStreaming(bool enabled) =>
      _update((s) => s.copyWith(streamingEnabled: enabled));

  Future<void> setNotifications(bool enabled) async {
    if (enabled && !await _ensurePermission()) return;
    if (!enabled) await _notificationService.cancelDailyReminder();
    await _update(
      (s) => s.copyWith(
        notificationsEnabled: enabled,
        // The reminder can't outlive notifications being switched off.
        dailyReminderEnabled: enabled && s.dailyReminderEnabled,
      ),
    );
  }

  Future<void> setDailyReminder(bool enabled) async {
    if (enabled) {
      if (!await _ensurePermission()) return;
      await _notificationService.scheduleDailyReminder();
    } else {
      await _notificationService.cancelDailyReminder();
    }
    await _update((s) => s.copyWith(dailyReminderEnabled: enabled));
  }

  Future<bool> _ensurePermission() async {
    final granted = await _notificationService.requestPermission();
    if (!granted) {
      emit(state.copyWith(message: 'Notification permission was denied.'));
    }
    return granted;
  }

  /// Single write path: apply [transform], persist, emit (DRY for every toggle).
  Future<void> _update(AppSettings Function(AppSettings) transform) async {
    final previous = state.settings;
    final next = transform(previous);
    emit(state.copyWith(settings: next)); // optimistic
    final result = await _saveSettings(next);
    result.fold(
      (failure) => emit(state.copyWith(settings: previous, message: failure.message)),
      (_) {},
    );
  }
}
