import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api/schedule_controller.dart';
import 'package:school_mangmante/models/schedule_model.dart';

class ScheduleCleanPage extends StatelessWidget {
  ScheduleCleanPage({super.key});

  final ScheduleController controller = Get.put(ScheduleController());

  final Map<String, String> arabicDays = {
    "saturday": "السبت",
    "sunday": "الأحد",
    "monday": "الاثنين",
    "tuesday": "الثلاثاء",
    "wednesday": "الأربعاء",
    "thursday": "الخميس",
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("جدول الدوام"),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.schedule.value == null ||
            controller.schedule.value!.schedule.isEmpty) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final schedule = controller.schedule.value!.schedule;

        return RefreshIndicator(
          onRefresh: () => controller.fetchSchedule(),
          child: ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: controller.daysOrder.length,
            itemBuilder: (context, index) {
              final dayKey = controller.daysOrder[index];
              final dayItems = schedule[dayKey] ?? [];

              if (dayItems.isEmpty) return const SizedBox.shrink();

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // عنوان اليوم
                      Text(
                        arabicDays[dayKey] ?? dayKey,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // قائمة الحصص
                      Column(
                        children: dayItems.map((item) {
                          return Container(
                            margin: const EdgeInsets.symmetric(vertical: 4),
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // رقم الحصة
                                Text(
                                  item.period,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // المادة + القسم
                                Expanded(
                                  child: Padding(
                                    padding:
                                        const EdgeInsets.symmetric(horizontal: 8),
                                    child: Text(
                                      "${item.subject} (${item.section})",
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),

                                // الوقت
                                Text(
                                  item.time,
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}
