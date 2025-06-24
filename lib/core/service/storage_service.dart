import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  late SharedPreferences _prefs;

  Future<StorageService> init() async {
    _prefs = await SharedPreferences.getInstance();
    return this;
  }

  // اللغة
  String? get language => _prefs.getString('language');
  Future<void> setLanguage(String value) async =>
      await _prefs.setString('language', value);

  // التوكن
  String? get token => _prefs.getString('token');
  Future<void> setToken(String value) async =>
      await _prefs.setString('token', value);

  // الدور
  String? get role => _prefs.getString('role');
  Future<void> setRole(String value) async =>
      await _prefs.setString('role', value);

  // البريد
  String? get email => _prefs.getString('email');
  Future<void> setEmail(String value) async =>
      await _prefs.setString('email', value);

  // الاسم الأول
  String? get firstName => _prefs.getString('first_name');
  Future<void> setFirstName(String value) async =>
      await _prefs.setString('first_name', value);

  // الاسم الأخير
  String? get lastName => _prefs.getString('last_name');
  Future<void> setLastName(String value) async =>
      await _prefs.setString('last_name', value);

  // حذف كل شيء (للاستخدام عند تسجيل الخروج)
  Future<void> clear() async => await _prefs.clear();
}
