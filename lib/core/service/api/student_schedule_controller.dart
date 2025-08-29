import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/student_schedule_model.dart';
import 'package:school_mangmante/models/teacher_schedule_model.dart';

class StudentScheduleController extends GetxController {
  var isLoading = false.obs;

  /// الصفحة تعتمد على هذا الحقل
  var schedule = Rxn<StudentScheduleModel>();

  /// ترتيب الأيام للعرض
  final List<String> daysOrder = const [
    "saturday",
    "sunday",
    "monday",
    "tuesday",
    "wednesday",
    "thursday",
  ];

  final String apiPath = 'api/v1/mobile/student/schedule/weekly';

  @override
  void onInit() {
    super.onInit();
    fetchSchedule();
  }

  Future<void> fetchSchedule() async {
    isLoading.value = true;

    try {
      final storage = Get.find<StorageService>();
      final token   = storage.token;
      final base    = ('http://137.184.50.2/' ?? '').replaceFirst(RegExp(r'/+$'), '');

      if (token == null || token.isEmpty || base.isEmpty) {
        Get.snackbar("خطأ", "التوكن أو العنوان غير متوفر.");
        isLoading.value = false;
        return;
      }

      final uri = Uri.parse('$base/$apiPath');

      final response = await http.get(
        uri,
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
          "Accept-Language": storage.language ?? 'ar',
        },
      );

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body) as Map<String, dynamic>;
        schedule.value = StudentScheduleModel.fromApi(jsonData);
      } else {
        Get.snackbar("خطأ", "تعذر جلب البيانات (${response.statusCode})");
        print(response.request);
      }
    } catch (e) {
      Get.snackbar("خطأ", e.toString());
      print(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
