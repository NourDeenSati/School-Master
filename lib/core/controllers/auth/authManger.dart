import 'package:get/get.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/views/auth/login_view.dart';

import '../../service/api/auth_api.dart';

class AuthManager {
  AuthManager._(); // private ctor
  static final _storage = Get.find<StorageService>();
  static final isLoggingOut = false.obs; // لمنع الضغط المزدوج

  static Future<void> logoutSafely() async {
    if (isLoggingOut.value) return;
    isLoggingOut.value = true;

    try {
      final token = _storage.token;
      final lang = _storage.language ?? 'ar';

      if (token != null && token.isNotEmpty) {
        try {
          await AuthApi.logout(token: token, lang: lang);
        } catch (_) {
          // نتجاهل أخطاء الشبكة/401 ونكمل خروج محلي
        }
      }

      // 1) تفريغ التخزين من بيانات الاعتماد
      await _clearAuthStorage();

      // 2) الذهاب لصفحة الدخول
      Get.offAll(() => LoginView());
    } finally {
      isLoggingOut.value = false;
    }
  }

  static Future<void> _clearAuthStorage() async {
    await _storage.clearAuth(); // ✅ الحل الثاني
    // أو لمسح كل شيء:
    // await _storage.clearAll();
  }
}
