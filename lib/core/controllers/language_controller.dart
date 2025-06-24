import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../assets/translations/app_translations.dart';
import '../../views/auth/login_view.dart';
import '../service/storage_service.dart';

class LanguageController extends GetxController {
  final storage = Get.find<StorageService>();

  void selectLanguage(String langCode) async {
    await storage.setLanguage(langCode); // حفظ اللغة المختارة
    await AppTranslations.loadTranslations(); // تحميل ملفات الترجمة
    Get.updateLocale(Locale(langCode)); // تغيير لغة التطبيق
    Get.offAll(() => LoginView()); // الانتقال لصفحة تسجيل الدخول
  }
}
