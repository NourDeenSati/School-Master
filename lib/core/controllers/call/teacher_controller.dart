import 'dart:async';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/models/teacher_call_model.dart';

class LiveController extends GetxController {
  final liveIdController = TextEditingController();
  final timeController = TextEditingController();
  DateTime? scheduledTime;

  var isLoading = false.obs;
  var callData = Rxn<CallData>();

  final userId = Random().nextInt(9999);

  Future<void> pickTime(BuildContext context) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
    );
    if (picked != null) {
      final nowDate = DateTime.now();
      scheduledTime = DateTime(
        nowDate.year,
        nowDate.month,
        nowDate.day,
        picked.hour,
        picked.minute,
      );
      timeController.text = picked.format(context);
    }
  }

  Future<void> requestPermission(Permission permission) async {
    final status = await permission.request();
    if (status.isDenied) {
      Get.snackbar("تنبيه", "يرجى منح صلاحية الكاميرا");
    }
  }

 Future<void> fetchCallData() async {
  isLoading.value = true;
  try {
    final url = Uri.parse(
      "http://137.184.50.2/api/v1/mobile/teacher/call",
    );

    // التوكن
    const String token = "1|yCuhyzI71ojYjyz0CINrSels97gqnOQYXtRLjJ3a2ef58de2";

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
        "Authorization": "Bearer $token",
      },
    );

    if (response.statusCode == 201) {
      final jsonData = json.decode(response.body);
      final model = CallModel.fromJson(jsonData);

      if (model.status && model.data != null) {
        callData.value = model.data;
        liveIdController.text = model.data!.channelName;
      } else {
        Get.snackbar("خطأ", "فشل في إنشاء البث");
      }
    } else {
      Get.snackbar("خطأ", "فشل الاتصال بالسيرفر\n${response.statusCode}");
    }
  } catch (e) {
    Get.snackbar("خطأ", e.toString());
  } finally {
    isLoading.value = false;
  }
}

  Future<void> startScheduledLiveStream(BuildContext context) async {
    if (scheduledTime == null) {
      Get.snackbar("تنبيه", "يرجى تحديد وقت صالح");
      return;
    }

    final now = DateTime.now();
    final delay = scheduledTime!.difference(now);

    if (delay.isNegative) {
      Get.snackbar("تنبيه", "لا يمكن اختيار وقت ماضٍ");
      return;
    }

    await requestPermission(Permission.camera);
    await fetchCallData();

    if (callData.value == null) return;

    Timer(delay, () {
      Get.toNamed(
        "/live",
        arguments: {
          "liveID": callData.value!.channelName,
          "isHost": true,
          "userId": userId
        },
      );
    });

    Get.dialog(
      AlertDialog(
        title: const Text("تمت جدولة البث"),
        content: Text("سيبدأ البث في: ${timeController.text}"),
      ),
    );
  }

  @override
  void onClose() {
    liveIdController.dispose();
    timeController.dispose();
    super.onClose();
  }
}
