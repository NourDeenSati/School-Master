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
  List<Section> sections = [];
  var isLoading = true.obs;

  Future<void> fetchTeacherData() async {
    try {
      final storage = Get.find<StorageService>();
      final token = storage.token;
      isLoading.value = true;

      teacherRes = await TeacherApi.getTeacherHomeData(token!);
      sections = teacherRes?.sections ?? [];

      update();
    } catch (e) {
      Get.snackbar('error'.tr, e.toString(),
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
      update();
    }
  }
}
