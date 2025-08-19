import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/controllers/call/teacher_call_controller.dart'; // <-- تأكد من إضافته
// استورد الكونترولر الصحيح (عدل المسار إذا لديك اسم/مسار آخر)

class ScheduledCallsPage extends StatelessWidget {
  ScheduledCallsPage({super.key});
  final LiveController controller = Get.find<LiveController>();

  String _formatDate(String? d) {
    if (d == null) return '';
    final dt = controller.parseServerDateTime(d); // <-- استخدم الدالة العامة الآن
    if (dt == null) return d;
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البثوث المجدولة')),
      body: Obx(() {
        if (controller.isLoading.value) return const Center(child: CircularProgressIndicator());
        if (controller.scheduledCalls.isEmpty) return const Center(child: Text('لا توجد بثوث مجدولة'));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.scheduledCalls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final s = controller.scheduledCalls[idx];
            final canStart = controller.canStartCall(s);
            return Card(
              child: ListTile(
                title: Text('${s['subject']?['name'] ?? ''} — ${s['section']?['name'] ?? ''}'),
                subtitle: Text('الوقت: ${_formatDate(s['scheduled_at'])}\nالحالة: ${s['status'] ?? ''}'),
                isThreeLine: true,
                trailing: ElevatedButton(
                  onPressed: canStart && !controller.isLoading.value
                      ? () => controller.startScheduledCall(s, context)
                      : null,
                  child: const Text('ابدأ البث'),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
