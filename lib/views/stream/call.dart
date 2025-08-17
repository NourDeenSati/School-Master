import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/call/teacher_controller.dart';

class callView extends StatelessWidget {
  callView({super.key});
  final LiveController controller = Get.put(LiveController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text("جدولة بث مباشر")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Spacer(),
            TextField(
              controller: controller.liveIdController,
              decoration: const InputDecoration(
                labelText: "معرف البث",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller.timeController,
              readOnly: true,
              onTap: () => controller.pickTime(context),
              decoration: const InputDecoration(
                labelText: "وقت بدء البث",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            Obx(() => ElevatedButton.icon(
                  icon: const Icon(Icons.schedule),
                  label: controller.isLoading.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text("جدولة البث"),
                  onPressed: () =>
                      controller.startScheduledLiveStream(context),
                )),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
