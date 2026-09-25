import 'package:shared_preferences/shared_preferences.dart';

import '../error/exceptions.dart';

/// Abstraction over simple key/value persistence so features don't depend on
/// SharedPreferences directly (and can be faked in tests).
abstract interface class KeyValueStorage {
  T? read<T>(String key);

  Future<void> write<T extends Object>(String key, T value);

  Future<void> remove(String key);
}

final class SharedPreferencesStorage implements KeyValueStorage {
  const SharedPreferencesStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  T? read<T>(String key) {
    final value = _prefs.get(key);
    return value is T ? value : null;
  }

  @override
  Future<void> write<T extends Object>(String key, T value) async {
    final saved = switch (value) {
      final bool v => await _prefs.setBool(key, v),
      final int v => await _prefs.setInt(key, v),
      final double v => await _prefs.setDouble(key, v),
      final String v => await _prefs.setString(key, v),
      final List<String> v => await _prefs.setStringList(key, v),
      _ => throw CacheException('Unsupported type ${value.runtimeType} for "$key".'),
    };
    if (!saved) throw CacheException('Failed to save "$key".');
  }

  @override
  Future<void> remove(String key) async {
    if (!await _prefs.remove(key)) {
      throw CacheException('Failed to remove "$key".');
    }
  }
}
