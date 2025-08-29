import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/administe_controller.dart';
import 'package:school_mangmante/core/controllers/auth/authManger.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/views/repreasantion/AttendancePage_Administor.dart';
import 'package:school_mangmante/views/repreasantion/ExamCreationPage_Administer.dart';
import 'package:school_mangmante/views/repreasantion/ExamGradeApprovalPage_Administer.dart';
import 'package:school_mangmante/views/repreasantion/NoteApprovalPage_Administer.dart';
import 'package:school_mangmante/views/repreasantion/NoteTakingPage_Administer.dart';

class AdministerHomeView extends StatelessWidget {
  const AdministerHomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdministerHomeController());
    final storage = Get.find<StorageService>();
    final teacherName = '${storage.firstName ?? ''} ${storage.lastName ?? ''}';

    return Scaffold(
      appBar: AppBar(
        title: Text('welcome'.trParams({"name": teacherName})),
        centerTitle: true,
        actions: [
          Obx(() {
            final loggingOut = AuthManager.isLoggingOut.value;
            return IconButton(
              onPressed: loggingOut ? null : () => AuthManager.logoutSafely(),
              icon: loggingOut
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.logout),
              tooltip: 'تسجيل الخروج',
            );
          })
        ],
      ),
      body: PageView(
        controller: controller.pageController,
        onPageChanged: controller.onPageChanged,
        children: [
          AttendancePage(),
          NoteTakingPage(),
          ExamCraetionPage(),
          ExamGradeApprovalPage(),
          NoteApprovalPage(),
        ],
      ),
      bottomNavigationBar: Obx(() {
        return BottomNavigationBar(
          currentIndex: controller.selectedIndex.value,
          onTap: controller.goToPage,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              label: 'Attendance',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note),
              label: 'Notes',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.assignment),
              label: 'Exams',
            ),
            BottomNavigationBarItem(
                icon: Icon(Icons.grade), label: 'the degrees'),
            BottomNavigationBarItem(
                icon: Icon(Icons.approval), label: 'Acceptance of comments'),
          ],
        );
      }),
    );
  }
}
