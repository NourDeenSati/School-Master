import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../core/controllers/call/teacher_call_controller.dart'; // <-- تأكد من إضافته

class ScheduledCallsPage extends StatelessWidget {
  ScheduledCallsPage({super.key});
  final LiveController controller = Get.find<LiveController>();

  String _formatDate(String? d) {
    if (d == null) return '';
    final dt =
        controller.parseServerDateTime(d); // <-- استخدم الدالة العامة الآن
    if (dt == null) return d;
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('البثوث المجدولة')),
      body: Obx(() {
        if (controller.isLoading.value)
          return const Center(child: CircularProgressIndicator());
        if (controller.scheduledCalls.isEmpty)
          return const Center(child: Text('لا توجد بثوث مجدولة'));

        return ListView.separated(
          padding: const EdgeInsets.all(12),
          itemCount: controller.scheduledCalls.length,
          separatorBuilder: (_, __) => const SizedBox(height: 8),
          itemBuilder: (context, idx) {
            final s = controller.scheduledCalls[idx];
            final canStart = controller.canStartCall(s);

            // استخرج المعرّف الصحيح للحذف
            final rawId = s['id'] ?? s['call_id'];
            final int? callId = (rawId is int) ? rawId : int.tryParse('$rawId');

            return Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                          '${s['subject']?['name'] ?? ''} — ${s['section']?['name'] ?? ''}'),
                      subtitle: Text(
                          'الوقت: ${_formatDate(s['scheduled_at'])}\nالحالة: ${s['status'] ?? ''}'),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton.icon(
                          icon: const Icon(Icons.play_arrow),
                          onPressed: (canStart && !controller.isLoading.value)
                              ? () => controller.startScheduledCall(s, context)
                              : null,
                          label: const Text('ابدأ البث'),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          icon: const Icon(Icons.delete_outline),
                          style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red),
                          onPressed:
                              (callId != null && !controller.isLoading.value)
                                  ? () async {
                                      final ok = await showDialog<bool>(
                                        context: context,
                                        builder: (_) => AlertDialog(
                                          title: const Text('تأكيد الحذف'),
                                          content: Text(
                                              'هل تريد حذف المكالمة رقم $callId؟ لا يمكن التراجع.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('إلغاء'),
                                            ),
                                            ElevatedButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('حذف'),
                                            ),
                                          ],
                                        ),
                                      );
                                      if (ok == true) {
                                        await controller
                                            .deleteScheduledCall(callId!);
                                      }
                                    }
                                  : null,
                          label: const Text('حذف'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
