import 'package:bachelor/core/services/database_service.dart';

/// Bietet typisierte Zugriffe auf die Einstellungstabelle von [DatabaseService].
/// Weitere primitive Datentypen erhalten hier ein eigenes Lese-/Schreibpaar,
/// damit Umwandlung und Ersatzwerte an einer Stelle bleiben.
class LocalStorageService {
  LocalStorageService({DatabaseService? databaseService})
    : _db = databaseService ?? DatabaseService.instance;

  final DatabaseService _db;

  Future<int> getInt(String key, {int fallback = 0}) async {
    final value = await _db.getSetting(key);
    return int.tryParse(value ?? '') ?? fallback;
  }

  Future<void> setInt(String key, int value) {
    return _db.setSetting(key, value.toString());
  }

  /// Liest `1` als wahr; fehlt der Eintrag, wird [fallback] verwendet.
  Future<bool> getBool(String key, {bool fallback = false}) async {
    final value = await _db.getSetting(key);
    if (value == null) return fallback;
    return value == '1';
  }

  Future<void> setBool(String key, bool value) {
    return _db.setSetting(key, value ? '1' : '0');
  }

  Future<String?> getString(String key) {
    return _db.getSetting(key);
  }

  Future<void> setString(String key, String value) {
    return _db.setSetting(key, value);
  }
}
