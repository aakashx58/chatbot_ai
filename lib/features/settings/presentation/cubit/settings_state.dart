part of 'settings_cubit.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    this.settings = AppSettings.defaults,
    this.isLoaded = false,
    this.message,
  });

  final AppSettings settings;
  final bool isLoaded;

  /// One-off feedback for the UI (e.g. permission denied). Cleared on next emit.
  final String? message;

  SettingsState copyWith({AppSettings? settings, bool? isLoaded, String? message}) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoaded: isLoaded ?? this.isLoaded,
      message: message,
    );
  }

  @override
  List<Object?> get props => [settings, isLoaded, message];
}
