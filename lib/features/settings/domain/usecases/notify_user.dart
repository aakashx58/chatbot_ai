import 'package:equatable/equatable.dart';

import '../../../../core/error/guard.dart';
import '../../../../core/error/result.dart';
import '../../../../core/lifecycle/app_lifecycle_tracker.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/utils/dart_extensions.dart';
import '../repositories/settings_repository.dart';

final class NotifyUserParams extends Equatable {
  const NotifyUserParams({required this.title, required this.body, this.payload = ''});

  final String title;
  final String body;

  /// Conversation id to open on tap, or empty for the home screen.
  final String payload;

  @override
  List<Object?> get props => [title, body, payload];
}

/// Single gate for every user-facing notification: only fires when the user
/// enabled notifications and the app is not on screen. Returns whether it
/// was shown.
class NotifyUser implements UseCase<bool, NotifyUserParams> {
  const NotifyUser({
    required this._settingsRepository,
    required this._notificationService,
    required this._lifecycleTracker,
  });

  final SettingsRepository _settingsRepository;
  final NotificationService _notificationService;
  final AppLifecycleTracker _lifecycleTracker;

  static const _bodyMaxLength = 120;

  @override
  Future<Result<bool>> call(NotifyUserParams params) => guard(() async {
    if (_lifecycleTracker.isInForeground) return false;
    final settings = (await _settingsRepository.getSettings()).dataOrNull;
    if (settings?.notificationsEnabled != true) return false;

    await _notificationService.show(
      title: params.title,
      body: params.body.truncate(_bodyMaxLength),
      payload: params.payload,
    );
    return true;
  });
}
