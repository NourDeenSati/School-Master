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
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        throw 'empty_fields'.tr;
      }

      // التحقق من صحة البريد الإلكتروني
      if (!GetUtils.isEmail(emailController.text.trim())) {
        throw 'invalid_email'.tr;
      }

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
        case 'supervisor':
          Get.offAll(() => const AdministerHomeView());
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
      print(emailController.text);
      print(passwordController.text);
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
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';

// class TeacherHomeController extends GetxController {
//   final PageController pageController = PageController();
//   final RxInt selectedIndex = 0.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     pageController.addListener(() {
//       selectedIndex.value = pageController.page?.round() ?? 0;
//     });
//   }

//   @override
//   void onClose() {
//     pageController.dispose();
//     super.onClose();
//   }

//   void onPageChanged(int index) {
//     selectedIndex.value = index;
//   }

//   void goToPage(int index) {
//     pageController.animateToPage(
//       index,
//       duration: const Duration(milliseconds: 300),
//       curve: Curves.easeOut,
//     );
//   }
// }\
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../controllers/teacher_home_controller.dart';
// import '../../service/storage_service.dart';

// // استيراد صفحات الميزات هنا
// import 'attendance_page.dart';
// import 'exam_creation_page.dart';
// import 'exam_grade_approval_page.dart';
// import 'note_approval_page.dart';
// import 'note_taking_page.dart';

// class TeacherHomeView extends StatelessWidget {
//   const TeacherHomeView({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     // جلب المتحكم
//     final controller = Get.put(TeacherHomeController());
//     final storage = Get.find<StorageService>();
//     final teacherName = '${storage.firstName ?? ''} ${storage.lastName ?? ''}';

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('أهلاً بك، $teacherName'),
//         centerTitle: true,
//       ),
//       body: PageView(
//         controller: controller.pageController,
//         onPageChanged: controller.onPageChanged,
//         children: const [
//           AttendancePage(),
//           NoteTakingPage(),
//           ExamCreationPage(),
//           ExamGradeApprovalPage(),
//           NoteApprovalPage(),
//         ],
//       ),
//       bottomNavigationBar: Obx(() {
//         return BottomNavigationBar(
//           currentIndex: controller.selectedIndex.value,
//           onTap: controller.goToPage,
//           selectedItemColor: Theme.of(context).colorScheme.primary,
//           unselectedItemColor: Colors.grey,
//           items: const [
//             BottomNavigationBarItem(
//               icon: Icon(Icons.check_circle_outline),
//               label: 'الحضور',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.edit_note),
//               label: 'ملاحظات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.assignment),
//               label: 'امتحانات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.grade),
//               label: 'الدرجات',
//             ),
//             BottomNavigationBarItem(
//               icon: Icon(Icons.approval),
//               label: 'قبول ملاحظات',
//             ),
//           ],
//         );
//       }),
//     );
//   }
// }
