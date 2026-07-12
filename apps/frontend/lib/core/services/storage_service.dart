import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  static StorageService get to => Get.find();

  static const String _accessTokenKey = 'auth_access_token';
  static const String _profileKey = 'auth_profile';

  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  SharedPreferences? _preferences;

  Future<SharedPreferences> get _prefs async =>
      _preferences ??= await SharedPreferences.getInstance();

  Future<String?> readAccessToken() => _secureStorage.read(key: _accessTokenKey);

  Future<void> writeAccessToken(String token) {
    return _secureStorage.write(key: _accessTokenKey, value: token);
  }

  Future<void> removeAccessToken() => _secureStorage.delete(key: _accessTokenKey);

  Future<Map<String, dynamic>?> readProfile() async {
    final SharedPreferences preferences = await _prefs;
    final String? serialized = preferences.getString(_profileKey);
    if (serialized == null) {
      return null;
    }

    try {
      return (jsonDecode(serialized) as Map<dynamic, dynamic>)
          .cast<String, dynamic>();
    } on FormatException {
      await preferences.remove(_profileKey);
      return null;
    }
  }

  Future<void> writeProfile(Map<String, dynamic> profile) async {
    await (await _prefs).setString(_profileKey, jsonEncode(profile));
  }

  Future<void> removeProfile() async {
    await (await _prefs).remove(_profileKey);
  }
}
