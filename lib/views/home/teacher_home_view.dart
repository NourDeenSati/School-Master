import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/authManger.dart';
import 'package:school_mangmante/core/controllers/auth/teacher_controller.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/views/auth/login_view.dart';
import 'package:school_mangmante/views/schedule/teacher_schedule_page.dart';
import 'package:school_mangmante/views/stream/call.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final controller = Get.put(TeacherController());

  int bottomNavIndex = 0;
  final PageController pageController = PageController();
  int sliderPage = 0;
  Timer? sliderTimer;

  @override
  void initState() {
    super.initState();
    controller.fetchTeacherData();
    startAutoScroll();
  }

  void startAutoScroll() {
    sliderTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (controller.teacherRes != null &&
          controller.teacherRes!.sections.isNotEmpty) {
        setState(() {
          sliderPage =
              (sliderPage + 1) % controller.teacherRes!.sections.length;
          // Animate slider فقط
        });
      }
    });
  }

  @override
  void dispose() {
    sliderTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TeacherController>(
      builder: (_) {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.isLoading.value) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

// ✅ إذا ما في بيانات أو فشل التحميل
        if (controller.teacherRes == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("واجهة المعلم"),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "فشل تحميل البيانات",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {
                      controller.fetchTeacherData();
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text("إعادة المحاولة"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4B70F5),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            actions: [
              Obx(
                () {
                  final loggingOut = AuthManager.isLoggingOut.value;
                  return IconButton(
                    onPressed:
                        loggingOut ? null : () => AuthManager.logoutSafely(),
                    icon: loggingOut
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.logout),
                    tooltip: 'تسجيل الخروج',
                  );
                },
              ),
            ],
            title: Text(
              'teacherWelcome'.trParams({
                'name':
                    '${controller.teacherRes?.teacher.firstName ?? 'لايوجد'} ${controller.teacherRes?.teacher.lastName ?? 'لايوجد'}'
              }),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          body: PageView(
            controller: pageController,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                bottomNavIndex = index;
              });
            },
            children: [
              // ===== صفحة جدول الدوام =====
              SingleChildScrollView(
                child: Column(
                  children: [
                    // Slider
                    SizedBox(
                      height: 150,
                      child: PageView.builder(
                        itemCount: controller.teacherRes?.sections.length ?? 0,
                        onPageChanged: (index) {
                          setState(() {
                            sliderPage = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final section =
                              controller.teacherRes!.sections[index];
                          final topStudent = section.topByPoints;
                          return Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${'section'.tr}: ${section.name}\n${'classroom'.tr}: ${section.classroom}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '${'topByPoints'.tr}: ${topStudent != null ? '${topStudent.student?.firstName} ${topStudent.student?.lastName ?? ''}' : 'لايوجد'}',
                                  ),
                                  Text(
                                    '${'points'.tr}: ${topStudent?.points ?? 'لايوجد'}',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),

                    // Slider indicators
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.teacherRes!.sections.length,
                        (index) => AnimatedContainer(
                          margin: const EdgeInsets.all(4),
                          duration: const Duration(milliseconds: 300),
                          width: sliderPage == index ? 20 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: sliderPage == index
                                ? const Color(0xFF4B70F5)
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // إدارة الطلاب (Icons Grid)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'studentManagement'.tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: [
                          _buildActionItem(
                              Icons.edit_note, 'notes'.tr, '/teacher_note'),
                          _buildActionItem(Icons.flag, 'Custom Questaion'.tr,
                              '/Teacher_DictationsVies'),
                          _buildActionItem(Icons.menu_book, 'exploration'.tr,
                              '/TeacherExplorationView'),
                          _buildActionItem(
                              Icons.timer, 'exam'.tr, '/attendance'),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // تقييم الطلاب
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          'studentEvaluation'.tr,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    if (controller.teacherRes!.sections.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                '${'section'.tr}: ${controller.teacherRes?.sections[sliderPage].name}'),
                            Text(
                                '${'classroom'.tr}: ${controller.teacherRes?.sections[sliderPage].classroom}'),
                            const SizedBox(height: 8),
                            Text(
                                '${'topByPoints'.tr}: ${controller.teacherRes!.sections[sliderPage].topByPoints?.student?.firstName ?? 'لايوجد'}'),
                            Text(
                                '${'topByNotes'.tr}: ${controller.teacherRes!.sections[sliderPage].topByNotes?.student?.firstName ?? 'لايوجد'}'),
                            Text(
                                '${'topByExams'.tr}: ${controller.teacherRes!.sections[sliderPage].topByExams?.student?.firstName ?? 'لايوجد'}'),
                            Text(
                                '${'avgExamResult'.tr}: ${controller.teacherRes!.sections[sliderPage].avgExamResult ?? 'لايوجد'}'),
                          ],
                        ),
                      ),
                  ],
                ),
              ),

              // ===== صفحة البث المباشر =====
              ScheduleCleanPage(),
              CallView(),
              // ===== صفحة الإشعارات =====
              Center(child: Text('الإشعارات', style: TextStyle(fontSize: 24))),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: bottomNavIndex,
            selectedItemColor: const Color(0xFF4B70F5),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              setState(() {
                bottomNavIndex = index;
              });
              pageController.jumpToPage(index);
            },
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home),
                label: 'الرئيسية',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule),
                label: 'جدول الدوام',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.live_tv),
                label: 'البث المباشر',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.notifications),
                label: 'الإشعارات',
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem(IconData icon, String label, String route) {
    final screenWidth = MediaQuery.of(context).size.width;

    // الدائرة: قطرها = 1/6 من عرض الشاشة → نصف القطر = 1/12
    final circleRadius = screenWidth / 12;

    // حجم الخط (نسبة صغيرة من العرض)
    final fontSize = screenWidth * 0.035; // تقريباً 3.5% من العرض

    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.03), // padding نسبي
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: circleRadius,
              backgroundColor: const Color(0xFF4B70F5),
              child: Icon(
                icon,
                color: Colors.white,
                size: circleRadius * 0.8, // الأيقونة أصغر شوي من الدائرة
              ),
            ),
            SizedBox(height: screenWidth * 0.015), // مسافة ديناميكية
            Text(
              label,
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
