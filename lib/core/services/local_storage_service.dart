import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent key-value local storage backed by SharedPreferences.
/// Also supports storing JSON objects/lists for complex data.
class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  SharedPreferences get _safePrefs {
    if (_prefs == null) {
      throw StateError('LocalStorageService not initialized. Call init() first.');
    }
    return _prefs!;
  }

  // ─── String ─────────────────────────────────────────────────────────────────
  Future<bool> setString(String key, String value) async {
    await init();
    return _safePrefs.setString(key, value);
  }

  String? getString(String key) => _prefs?.getString(key);

  // ─── Int ────────────────────────────────────────────────────────────────────
  Future<bool> setInt(String key, int value) async {
    await init();
    return _safePrefs.setInt(key, value);
  }

  int? getInt(String key) => _prefs?.getInt(key);

  // ─── Bool ───────────────────────────────────────────────────────────────────
  Future<bool> setBool(String key, bool value) async {
    await init();
    return _safePrefs.setBool(key, value);
  }

  bool? getBool(String key) => _prefs?.getBool(key);

  // ─── JSON Object ────────────────────────────────────────────────────────────
  Future<bool> setJson(String key, Map<String, dynamic> value) async {
    await init();
    return _safePrefs.setString(key, jsonEncode(value));
  }

  Map<String, dynamic>? getJson(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  // ─── JSON List ──────────────────────────────────────────────────────────────
  Future<bool> setJsonList(String key, List<Map<String, dynamic>> value) async {
    await init();
    return _safePrefs.setString(key, jsonEncode(value));
  }

  List<Map<String, dynamic>> getJsonList(String key) {
    final raw = _prefs?.getString(key);
    if (raw == null) return [];
    try {
      final decoded = jsonDecode(raw) as List<dynamic>;
      return decoded.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }

  // ─── String List ────────────────────────────────────────────────────────────
  Future<bool> setStringList(String key, List<String> value) async {
    await init();
    return _safePrefs.setStringList(key, value);
  }

  List<String> getStringList(String key) =>
      _prefs?.getStringList(key) ?? [];

  // ─── Remove / Clear ─────────────────────────────────────────────────────────
  Future<bool> remove(String key) async {
    await init();
    return _safePrefs.remove(key);
  }

  Future<void> clear() async {
    await init();
    await _safePrefs.clear();
  }

  bool containsKey(String key) => _prefs?.containsKey(key) ?? false;
}
