import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// A small, generic cache layer: stores any JSON-serializable payload with a
/// time-to-live. Used to keep the app usable (read-only) for a short window
/// without connectivity — e.g. the customer's last medication search results
/// or prescription list. This is intentionally simple (no Hive/Isar) to keep
/// the dependency footprint small; swap in Hive/Drift if you need querying.
class CacheService {
  CacheService(this._prefs);

  final SharedPreferences _prefs;

  Future<void> set(String key, Object value, {Duration ttl = const Duration(minutes: 15)}) async {
    final envelope = {
      'expiresAt': DateTime.now().add(ttl).toIso8601String(),
      'value': value,
    };
    await _prefs.setString(_prefixed(key), jsonEncode(envelope));
  }

  /// Returns the cached value if present and not expired, otherwise null.
  T? get<T>(String key, T Function(dynamic json) decode) {
    final raw = _prefs.getString(_prefixed(key));
    if (raw == null) return null;
    try {
      final envelope = jsonDecode(raw) as Map<String, dynamic>;
      final expiresAt = DateTime.parse(envelope['expiresAt'] as String);
      if (DateTime.now().isAfter(expiresAt)) {
        _prefs.remove(_prefixed(key));
        return null;
      }
      return decode(envelope['value']);
    } catch (_) {
      return null;
    }
  }

  Future<void> invalidate(String key) => _prefs.remove(_prefixed(key));

  String _prefixed(String key) => 'cache_$key';
}
