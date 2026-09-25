import 'package:equatable/equatable.dart';

/// Framework-agnostic theme preference (mapped to Flutter's ThemeMode in UI).
enum AppThemeMode { system, light, dark }

final class AppSettings extends Equatable {
  const AppSettings({
    this.themeMode = AppThemeMode.system,
    this.streamingEnabled = true,
    this.notificationsEnabled = false,
    this.dailyReminderEnabled = false,
  });

  static const defaults = AppSettings();

  final AppThemeMode themeMode;

  /// Reveal replies word-by-word instead of all at once.
  final bool streamingEnabled;

  /// Notify when a reply finishes while the app is in the background.
  final bool notificationsEnabled;

  final bool dailyReminderEnabled;

  AppSettings copyWith({
    AppThemeMode? themeMode,
    bool? streamingEnabled,
    bool? notificationsEnabled,
    bool? dailyReminderEnabled,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      streamingEnabled: streamingEnabled ?? this.streamingEnabled,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
    );
  }

  @override
  List<Object?> get props => [
    themeMode,
    streamingEnabled,
    notificationsEnabled,
    dailyReminderEnabled,
  ];
}
