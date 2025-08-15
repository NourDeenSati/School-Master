import 'package:get/get.dart';
import 'package:http/http.dart';
import 'package:http/http.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/section.dart';
import 'package:school_mangmante/models/teacher_home_response.dart';
// import '../models/teacher_model.dart';
// import '../services/api_service.dart';
import 'package:school_mangmante/core/service/api/TeacherApi%20.dart';

class TeacherController extends GetxController {
  TeacherHomeResponse? teacherRes;
  // List<Section> sections = [];
  var isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    fetchTeacherData(); // ✅ استدعاء الدالة داخل onInit
  }

  Future<void> fetchTeacherData() async {
    try {
      isLoading.value = true;
      update(); // Add this to immediately show loading state

      final storage = Get.find<StorageService>();
      final token = storage.token;

      if (token == null) {
        throw Exception('No token found');
      }

      teacherRes = await TeacherApi.getTeacherHomeData(token);

      // print('✅ Teacher data loaded successfully');
      // print('✅ Teacher: ${teacherRes?.teacher.firstName}');
      // print('✅ Sections count: ${teacherRes?.sections.length}');
    } catch (e) {
      // print('✅ Teacher data loaded successfully');
      // print('✅ Teacher: ${teacherRes?.teacher.firstName}');
      // print('✅ Sections count: ${teacherRes?.sections.length}');
      print(e);
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      update();
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
