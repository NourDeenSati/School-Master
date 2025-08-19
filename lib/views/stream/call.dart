import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/call/teacher_call_controller.dart';
import 'package:school_mangmante/views/stream/schedual_call_view.dart';

class CallView extends StatelessWidget {
  CallView({super.key});
  final LiveController controller = Get.put(LiveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('جدولة بث مباشر')),
      body: Obx(() {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Room dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'اختر الصف/المدرسة',
                    border: OutlineInputBorder()),
                value: controller.selectedRoom.value,
                items: controller.rooms.keys
                    .map((r) => DropdownMenuItem(value: r, child: Text(r)))
                    .toList(),
                onChanged: (v) => controller.onRoomChanged(v),
              ),
              const SizedBox(height: 12),

              // Section dropdown
              // Section dropdown
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                    labelText: 'اختر الشعبة', border: OutlineInputBorder()),
                value: controller.selectedSection.value,
                items: controller.selectedRoom.value == null
                    ? <DropdownMenuItem<String>>[]
                    : (controller.rooms[controller.selectedRoom.value]
                            as Map<dynamic, dynamic>)
                        .keys
                        .map((s) => s.toString())
                        .map<DropdownMenuItem<String>>((s) =>
                            DropdownMenuItem<String>(value: s, child: Text(s)))
                        .toList(),
                onChanged: (v) => controller.onSectionChanged(v),
              ),
              const SizedBox(height: 12),

              // Optional section id (some APIs require numeric id)
              // Obx(() {
              //   final sid = controller.selectedSectionId.value;
              //   return TextFormField(
              //     readOnly: true,
              //     decoration: InputDecoration(
              //       labelText: 'معرّف الشعبة',
              //       border: const OutlineInputBorder(),
              //       hintText: sid != null
              //           ? sid.toString()
              //           : 'غير متوفر (تأكد من بيانات الشعبة)',
              //     ),
              //   );
              // }),

              const SizedBox(height: 12),

              // Subjects dropdown
              // Subjects dropdown
              DropdownButtonFormField<int>(
                decoration: const InputDecoration(
                    labelText: 'اختر المادة', border: OutlineInputBorder()),
                value: controller.selectedSubjectId.value,
                items: controller.subjects
                    .map<DropdownMenuItem<int>>((s) => DropdownMenuItem<int>(
                          value: s['id'] is int
                              ? s['id'] as int
                              : int.tryParse(s['id']?.toString() ?? ''),
                          child: Text(s['name']?.toString() ?? ''),
                        ))
                    .toList(),
                onChanged: (v) => controller.selectedSubjectId.value = v,
              ),

              const SizedBox(height: 12),

              // Date & time
              TextField(
                controller: controller.timeController,
                readOnly: true,
                onTap: () async {
                  await controller.pickDate(context);
                  await controller.pickTime(context);
                },
                decoration: const InputDecoration(
                    labelText: 'تاريخ ووقت البدء',
                    border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),

              // Duration
              Row(
                children: [
                  const Text('المدة (دقائق):'),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Slider(
                      value: controller.durationMinutes.value.toDouble(),
                      min: 15,
                      max: 180,
                      divisions: 11,
                      label: '${controller.durationMinutes.value} دقيقة',
                      onChanged: (v) =>
                          controller.durationMinutes.value = v.toInt(),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Obx(() => ElevatedButton.icon(
                    icon: const Icon(Icons.schedule),
                    label: controller.isLoading.value
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('جدولة البث'),
                    onPressed: controller.isLoading.value
                        ? null
                        : () async {
                            await controller.startScheduledLiveStream(context);
                          },
                  )),

              const SizedBox(height: 8),

              ElevatedButton.icon(
                icon: const Icon(Icons.list),
                label: const Text('عرض البثوث المجدولة'),
                onPressed: () async {
                  await controller.fetchScheduledCalls();
                  Get.to(() => ScheduledCallsPage());
                },
              ),
            ],
          ),
        );
      }),
    );
  }
}
