import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class Storage {
  static Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  static Future<String?> get(String key) async =>
      (await prefs).getString(jsonDecode(key));

  static Future set(String key, dynamic value) async =>
      (await prefs).setString(key, jsonEncode(value));

  static Future remove(String key) async => (await prefs).remove(key);

  static Future has(String key) async => (await prefs).containsKey(key);

  static Future clear() async => (await prefs).clear();
}
