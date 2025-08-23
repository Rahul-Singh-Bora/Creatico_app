// lib/core/services/storage_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _prefs;

  /// Call this once in main() before runApp()
  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<void> saveString(String key, String value) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs?.getString(key);
  }

  static Future<void> remove(String key) async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.remove(key);
  }

  static Future<void> clear() async {
    final prefs = _prefs ??= await SharedPreferences.getInstance();
    await prefs.clear();
  }
}
