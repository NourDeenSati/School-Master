// ضع الملف في: lib/core/service/api/schedule_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/teacher_schedule_model.dart';

class ScheduleController extends GetxController {
  var isLoading = false.obs;

  var schedule = Rxn<ScheduleModel>();

  final List<String> daysOrder = [
    "saturday",
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday"
  ];

  int periodToIndex(String period) {
    return int.tryParse(period.replaceAll("P", "")) ?? 0;
  }

  final String apiUrl =
      'http://137.184.50.2/api/v1/mobile/teacher/weekly-schedule';

  @override
  void onInit() {
    super.onInit();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    isLoading.value = true;
    final storage = Get.find<StorageService>();
    final token = storage.token;

    if (token == null || token.isEmpty) {
      Get.snackbar("خطأ", "التوكن غير موجود، يرجى تسجيل الدخول.");
      isLoading.value = false;
      return;
    }

    try {
      final uri = Uri.parse(apiUrl);
      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        schedule.value = ScheduleModel.fromJson(jsonData);
      } else {
        Get.snackbar("خطأ", "تعذر جلب البيانات (${response.statusCode})");
        print("Request URL: ${response.request?.url}");
        print(response.headers);
        print("Status: ${response.statusCode}");
        print("Body: ${response.body}");
      }
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
      print("Exception: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
