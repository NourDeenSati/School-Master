import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  String? get language => _prefs.getString('language');
  Future<void> setLanguage(String value) async =>
      await _prefs.setString('language', value);

  String? get token => _prefs.getString('token');
  Future<void> setToken(String value) async =>
      await _prefs.setString('token', value);

  String? get role => _prefs.getString('role');
  Future<void> setRole(String value) async =>
      await _prefs.setString('role', value);

  String? get email => _prefs.getString('email');
  Future<void> setEmail(String value) async =>
      await _prefs.setString('email', value);

  String? get firstName => _prefs.getString('first_name');
  Future<void> setFirstName(String value) async =>
      await _prefs.setString('first_name', value);

  String? get lastName => _prefs.getString('last_name');
  Future<void> setLastName(String value) async =>
      await _prefs.setString('last_name', value);

  Future<void> clear() async => await _prefs.clear();
}
