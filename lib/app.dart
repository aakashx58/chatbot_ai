import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/constants/app_constants.dart';
import 'core/di/injection.dart';
import 'core/notifications/notification_service.dart';
import 'core/router/app_router.dart';
import 'core/router/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'features/chat/presentation/bloc/conversations/conversations_bloc.dart';
import 'features/models/presentation/cubit/models_cubit.dart';
import 'features/settings/domain/entities/app_settings.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';

/// Root widget: app-wide blocs, theming, routing and notification deep links.
class OfflineAiApp extends StatefulWidget {
  const OfflineAiApp({super.key});

  @override
  State<OfflineAiApp> createState() => _OfflineAiAppState();
}

class _OfflineAiAppState extends State<OfflineAiApp> {
  final GoRouter _router = sl<AppRouter>().router;
  final NotificationService _notifications = sl<NotificationService>();
  StreamSubscription<String>? _tapSubscription;

  @override
  void initState() {
    super.initState();
    _tapSubscription = _notifications.onNotificationTap.listen(_openFromNotification);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _openFromNotification(await _notifications.consumeLaunchPayload());
    });
  }

  @override
  void dispose() {
    _tapSubscription?.cancel();
    super.dispose();
  }

  /// Payload is a conversation id (reply notifications) or empty (reminders).
  void _openFromNotification(String? payload) {
    if (payload == null) return;
    payload.isEmpty ? _router.go(AppRoutes.home) : _router.push(AppRoutes.chatPath(payload));
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<SettingsCubit>()..load()),
        BlocProvider(create: (_) => sl<ModelsCubit>()..load()),
        BlocProvider(
          create: (_) => sl<ConversationsBloc>()..add(const ConversationsSubscribed()),
        ),
      ],
      child: BlocSelector<SettingsCubit, SettingsState, AppThemeMode>(
        selector: (state) => state.settings.themeMode,
        builder: (context, themeMode) => MaterialApp.router(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: themeMode.toThemeMode(),
          routerConfig: _router,
        ),
      ),
    );
  }
}

extension on AppThemeMode {
  ThemeMode toThemeMode() => switch (this) {
    AppThemeMode.system => ThemeMode.system,
    AppThemeMode.light => ThemeMode.light,
    AppThemeMode.dark => ThemeMode.dark,
  };
}
