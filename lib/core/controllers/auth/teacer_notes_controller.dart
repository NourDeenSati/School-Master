import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api/teacher_note_Api.dart';
import 'package:school_mangmante/models/saction_data.dart';

class TeacherNotesController extends GetxController {
  var classesData = <String, SectionData>{};
  var selectedClass = "".obs;
  var selectedSection = "".obs;
  var selectedStudentId = 0.obs;
  var noteType = "positive".obs;
  var reason = "".obs;

  var isLoading = false.obs;
  var isSending = false.obs;

  @override
  void onInit() {
    fetchClasses();
    super.onInit();
  }

  Future<void> fetchClasses() async {
    try {
      //   print(TeacherNotesApi.)
      isLoading.value = true;
      classesData = await TeacherNotesApi.fetchClasses();
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendNote() async {
    try {
      isSending.value = true;
      bool success = await TeacherNotesApi.sendNote(
        studentId: selectedStudentId.value,
        type: noteType.value,
        reason: reason.value,
      );

      if (success) {
        Get.snackbar("success".tr, "note_added_success".tr);
      } else {
        Get.snackbar("error".tr, "note_add_failed".tr);
      }
    } catch (e) {
      print(e);
      Get.snackbar("error".tr, "note_add_failed".tr);
    } finally {
      isSending.value = false;
    }
  }
}
