import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/teacher_controller.dart';

class TeacherHomeView extends StatefulWidget {
  const TeacherHomeView({super.key});

  @override
  State<TeacherHomeView> createState() => _TeacherHomeViewState();
}

class _TeacherHomeViewState extends State<TeacherHomeView> {
  final controller = Get.put(TeacherController());
  final PageController pageController = PageController();
  int currentPage = 0;
  Timer? sliderTimer;

  @override
  void initState() {
    super.initState();
    controller.fetchTeacherData();
    startAutoScroll();
  }

  void startAutoScroll() {
    sliderTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (controller.sections.isNotEmpty) {
        int nextPage = (currentPage + 1) % controller.sections.length;
        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
        setState(() {
          currentPage = nextPage;
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

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            // backgroundColor: const Color(0xFF4B70F5),
            title: Text(
              'teacherWelcome'.trParams({
                'name': '${controller.teacherRes?.teacher.firstName}'
                    '${controller.teacherRes?.teacher.lastName}'
              }),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.all(12.0),
                child: Icon(Icons.settings, color: Colors.white),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(30),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: Text(
                  '${'popularity'.tr} ⭐ ${controller.teacherRes?.teacher.popularity ?? 0}',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),

          // BODY
          body: Column(
            children: [
              // Slider
              SizedBox(
                height: 150,
                child: PageView.builder(
                  controller: pageController,
                  onPageChanged: (index) {
                    setState(() {
                      currentPage = index;
                    });
                  },
                  itemCount: controller.sections.length,
                  itemBuilder: (context, index) {
                    final section = controller.sections[index];
                    final topStudent = section.topByPoints;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '${'topByPoints'.tr}: ${topStudent.student.firstName} ${topStudent.student.lastName}',
                            ),
                            Text(
                              '${'points'.tr}: ${topStudent.points}',
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  controller.sections.length,
                  (index) => AnimatedContainer(
                    margin: const EdgeInsets.all(4),
                    duration: const Duration(milliseconds: 300),
                    width: currentPage == index ? 20 : 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: currentPage == index
                          ? const Color(0xFF4B70F5)
                          : Colors.grey,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // إدارة الطلاب
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

              // Icons Grid
              SizedBox(
                height: 100,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildActionItem(Icons.edit_note, 'notes'.tr, '/notes'),
                    _buildActionItem(Icons.flag, 'behavior'.tr, '/behavior'),
                    _buildActionItem(
                        Icons.menu_book, 'recitation'.tr, '/recite'),
                    _buildActionItem(
                        Icons.timer, 'attendance'.tr, '/attendance'),
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

              if (controller.sections.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          '${'section'.tr}: ${controller.sections[currentPage].name}'),
                      Text(
                          '${'classroom'.tr}: ${controller.sections[currentPage].classroom}'),
                      const SizedBox(height: 8),
                      Text(
                        '${'topByPoints'.tr}: '
                        '${controller.sections[currentPage].topByPoints.student.firstName} '
                        '${controller.sections[currentPage].topByPoints.student.lastName}',
                      ),
                      Text(
                        '${'topByNotes'.tr}: ${controller.sections[currentPage].topByNotes?.student?.firstName}'
                        '${controller.sections[currentPage].topByNotes?.student?.lastName} ',
                      ),
                      Text(
                        '${'topByExams'.tr}: ${controller.sections[currentPage].topByExams?.student?.firstName}'
                        '${controller.sections[currentPage].topByExams?.student?.lastName}',
                      ),
                      Text(
                          '${'avgExamResult'.tr}: ${controller.sections[currentPage].avgExamResult}'),
                    ],
                  ),
                ),
            ],
          ),

          bottomNavigationBar: BottomNavigationBar(
            currentIndex: 0,
            selectedItemColor: const Color(0xFF4B70F5),
            unselectedItemColor: Colors.grey,
            onTap: (index) {
              // هنا حسب التاب نروح لصفحة مختلفة
              switch (index) {
                case 0:
                  Get.toNamed('/teacherHome');
                  break;
                case 1:
                  Get.toNamed('/notifications');
                  break;
                case 2:
                  Get.toNamed('/settings');
                  break;
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: 'home'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.notifications),
                label: 'notifications'.tr,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.settings),
                label: 'settings'.tr,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionItem(IconData icon, String label, String route) {
    return GestureDetector(
      onTap: () => Get.toNamed(route),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFF4B70F5),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(height: 6),
            Text(label),
          ],
        ),
      ),
    );
  }
}
