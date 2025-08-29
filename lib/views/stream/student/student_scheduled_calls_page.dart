import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:school_mangmante/core/controllers/call/student_call_controller.dart';

class StudentScheduledCallsPage extends StatelessWidget {
  StudentScheduledCallsPage({super.key});

  final StudentCallController controller = Get.find<StudentCallController>();

  String _fmt(String? d) => controller.formatDate(d);

  Future<void> _onRefresh() => controller.fetchScheduledCallsForStudent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('البثوث المتاحة للطالب')),
      body: Obx(() {
        if (controller.isLoading.value && controller.scheduledCalls.isEmpty) {
          // تحميل أولي
          return const Center(child: CircularProgressIndicator());
        }

        // لفّ الجسم كله بـ RefreshIndicator حتى يعمل السحب للتحديث دائمًا
        return RefreshIndicator(
          onRefresh: _onRefresh,
          child: controller.scheduledCalls.isEmpty
              // حالة فارغة: لازم نوفّر Scrollable حتى يعمل سحب للتحديث
              ? SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.7,
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('لا توجد بثوث متاحة حاليًا'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: _onRefresh,
                            child: const Text('تحديث'),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              // حالة فيها عناصر: ListView مع AlwaysScrollable
              : ListView.separated(
                  padding: const EdgeInsets.all(12),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: controller.scheduledCalls.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final s = controller.scheduledCalls[i];

                    final subjectName = s['subject']?['name']?.toString() ??
                        s['subject_name']?.toString() ??
                        '';
                    final sectionName = s['section']?['name']?.toString() ??
                        s['section_name']?.toString() ??
                        '';
                    final status = s['status']?.toString() ?? '';
                    final canJoin = controller.canJoinCall(s);
                    final hasCallId = s['call_id'] != null;

                    return Card(
                      child: ListTile(
                        title: Text([subjectName, sectionName]
                            .where((x) => x.isNotEmpty)
                            .join(' — ')),
                        subtitle: Text(
                            'الوقت: ${_fmt(s['scheduled_at'])}\nالحالة: ${status}'),
                        isThreeLine: true,
                        trailing: ElevatedButton(
                          onPressed: canJoin && !controller.isLoading.value
                              ? () => controller.joinCall(s)
                              : null,
                          child: Text(canJoin
                              ? 'انضمام'
                              : (hasCallId
                                  ? 'جاري التهيئة…'
                                  : 'بانتظار البدء')),
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
