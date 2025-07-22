import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../models/login_response.dart';
import '../../../views/home/admin_home_view.dart';
import '../../../views/home/student_home_view.dart';
import '../../../views/home/teacher_home_view.dart';
import '../../service/api/auth_api.dart';
import '../../service/storage_service.dart';

class LoginController extends GetxController {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final storage = Get.find<StorageService>();
  final isLoading = false.obs;
  bool obscureText = true;
  void togglePasswordVisibility() {
    if (obscureText == true) {
      obscureText = false;
      print(obscureText);
    } else if (obscureText == false) {
      obscureText = true;
      print(obscureText);
    }
    update();
  }

  Future<void> login() async {
    try {
      // التحقق من الحقول الفارغة
      // if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      //   throw 'empty_fields'.tr;
      // }

      // // التحقق من صحة البريد الإلكتروني
      // if (!GetUtils.isEmail(emailController.text.trim())) {
      //   throw 'invalid_email'.tr;
      // }

      isLoading.value = true;

      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      final lang = storage.language ?? 'ar';

      LoginResponse response = await AuthApi.login(email, password, lang);

      // حفظ المعلومات
      await storage.setToken(response.token);
      await storage.setRole(response.user.role);
      await storage.setEmail(response.user.email);
      await storage.setFirstName(response.user.firstName);
      await storage.setLastName(response.user.lastName);

      // التوجيه حسب الدور
      switch (response.user.role) {
        case 'student':
          Get.offAll(() => const StudentHomeView());
          break;
        case 'teacher':
          Get.offAll(() => const TeacherHomeView());
          break;
        case 'admin':
          Get.offAll(() => const AdminHomeView());
          break;
        default:
          throw 'unknown_role'.tr;
      }
    } catch (e) {
      String errorMessage;

      if (e.toString().contains('wrong_credentials')) {
        errorMessage = 'wrong_credentials'.tr;
      } else if (e.toString().contains('user_not_found')) {
        errorMessage = 'user_not_found'.tr;
      } else {
        errorMessage = e.toString();
      }

      Get.snackbar(
        'error'.tr,
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
      );
      print(errorMessage);
    } finally {
      isLoading.value = false;
    }
  }
  }

