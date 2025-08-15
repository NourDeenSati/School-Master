// ضع الملف في: lib/core/service/api/schedule_controller.dart
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/models/schedule_model.dart';

class ScheduleController extends GetxController {
  var isLoading = false.obs;

  /// هذا الحقل يجب أن يكون موجود لأن الصفحة تستخدم controller.schedule
  var schedule = Rxn<ScheduleModel>();

  /// ترتيب الأيام الذي تستعمله الصفحة
  final List<String> daysOrder = [
    "saturday",
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday"
  ];

  /// تحويل P1 -> 1
  int periodToIndex(String period) {
    return int.tryParse(period.replaceAll("P", "")) ?? 0;
  }

  /// استبدل الرابط بالرابط الحقيقي لــ API عندك
  final String apiUrl = 'https://example.com/api/schedule';

  @override
  void onInit() {
    super.onInit();
    fetchSchedule(); // جلب البيانات مرة عند إنشاء الكونترولر
  }

  Future<void> fetchSchedule() async {
    isLoading.value = true;
    try {
      final uri = Uri.parse(apiUrl);
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        schedule.value = ScheduleModel.fromJson(jsonData);
      } else {
        Get.snackbar("خطأ", "تعذر جلب البيانات (${response.statusCode})");
      }
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
