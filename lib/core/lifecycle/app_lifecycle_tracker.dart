import 'package:flutter/widgets.dart';

/// Tracks whether the app is visible so we only notify when it's backgrounded.
abstract interface class AppLifecycleTracker {
  bool get isInForeground;

  void dispose();
}

final class FlutterAppLifecycleTracker implements AppLifecycleTracker {
  FlutterAppLifecycleTracker()
    : _state = WidgetsBinding.instance.lifecycleState ?? AppLifecycleState.resumed {
    _listener = AppLifecycleListener(onStateChange: (state) => _state = state);
  }

  late final AppLifecycleListener _listener;
  AppLifecycleState _state;

  @override
  bool get isInForeground => _state == AppLifecycleState.resumed;

  @override
  void dispose() => _listener.dispose();
}
