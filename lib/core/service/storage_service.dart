import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // ---------------------------
  // Language
  String? get language => _prefs.getString('language');
  Future<void> setLanguage(String value) async =>
      await _prefs.setString('language', value);

  // ---------------------------
  // Token
  String? get token => _prefs.getString('token');
  Future<void> setToken(String value) async =>
      await _prefs.setString('token', value);

  // ---------------------------
  // Role
  String? get role => _prefs.getString('role');
  Future<void> setRole(String value) async =>
      await _prefs.setString('role', value);

  // ---------------------------
  // Email
  String? get email => _prefs.getString('email');
  Future<void> setEmail(String value) async =>
      await _prefs.setString('email', value);

  // ---------------------------
  // First Name
  String? get firstName => _prefs.getString('first_name');
  Future<void> setFirstName(String value) async =>
      await _prefs.setString('first_name', value);

  // ---------------------------
  // Last Name
  String? get lastName => _prefs.getString('last_name');
  Future<void> setLastName(String value) async =>
      await _prefs.setString('last_name', value);

  // ---------------------------
  // Clear only auth-related keys
  Future<void> clearAuth() async {
    await _prefs.remove('token');
    await _prefs.remove('role');
    await _prefs.remove('email');
    await _prefs.remove('first_name');
    await _prefs.remove('last_name');
  }

  // Clear everything (لو حبيت تستعمله لمسح كامل التخزين)
  Future<void> clearAll() async => await _prefs.clear();
}
