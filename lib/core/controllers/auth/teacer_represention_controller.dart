import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api/teacher_reprention_Api.dart';
import 'package:school_mangmante/models/saction_data.dart';
import 'package:school_mangmante/models/studint_Info.dart';
import 'package:school_mangmante/models/subject_infoStudent.dart';

class TeacherNotesController extends GetxController {
  var classesData = <String, Map<String, SectionData>>{};
  var selectedClass = "".obs;
  var selectedSection = "".obs;
  var selectedStudentId = 0.obs;
  var noteType = "positive".obs;
  var reason = "".obs;
  var selectedSubjectId = 0.obs;
  var sjId = 0.obs;
  var result = 0.obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var startTime = "".obs;
  var endTime = "".obs;
  var examName = "".obs;
  var questions = <Map<String, dynamic>>[].obs;
  @override
  void onInit() {
    fetchClasses();
    super.onInit();
  }

  List<StudintInfo> get currentStudents {
    if (selectedClass.value.isEmpty || selectedSection.value.isEmpty) {
      return [];
    }
    return classesData[selectedClass.value]?[selectedSection.value]?.students ??
        [];
  }

  List<Subject> get currentSubject {
    if (selectedClass.value.isEmpty || selectedSection.value.isEmpty) {
      return [];
    }
    return classesData[selectedClass.value]?[selectedSection.value]?.subjects ??
        [];
  }

  void addQuestion(String question, int mark) {
    questions.add({
      "question": question,
      "mark": mark,
      "answers": [],
    });
  }

  void addAnswer(int questionIndex, String answer, bool isCorrect) {
    if (questionIndex < questions.length) {
      questions[questionIndex]["answers"].add({
        "answer": answer,
        "is_correct": isCorrect,
      });
      questions.refresh();
    }
  }

  void removeQuestion(int index) {
    if (index < questions.length) {
      questions.removeAt(index);
    }
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
      final responseData = await TeacherNotesApi.sendNote(
        studentId: selectedStudentId.value,
        type: noteType.value,
        reason: reason.value,
      );

      if (responseData['success'] == true) {
        Get.snackbar(
            "success".tr, responseData['message'] ?? "note_added_success".tr);
      } else {
        Get.snackbar(
            "error".tr, responseData['message'] ?? "note_add_failed".tr);
      }
    } catch (e) {
      print(e);
      String errorMessage = "note_add_failed".tr;
      if (e is Exception && e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      Get.snackbar("error".tr, errorMessage);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendDictations() async {
    try {
      isSending.value = true;
      final responseData = await TeacherNotesApi.sendDictations(
        studentId: selectedStudentId.value,
        subjecttId: selectedSubjectId.value,
        result: result.value,
      );

      if (responseData['success'] == true) {
        Get.snackbar(
            "success".tr, responseData['message'] ?? "note_added_success".tr);
      } else {
        Get.snackbar(
            "error".tr, responseData['message'] ?? "note_add_failed".tr);
      }
    } catch (e) {
      print(e);
      String errorMessage = "note_add_failed".tr;
      if (e is Exception && e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      Get.snackbar("error".tr, errorMessage);
    } finally {
      isSending.value = false;
    }
  }

  Future<void> sendExam() async {
    try {
      isSending.value = true;

      final responseData = await TeacherNotesApi.sendExam(
        name: examName.value,
        subjectId: selectedSubjectId.value,
        classId: classesData.containsKey(selectedClass.value) ? 1 : 0,
        sectionId: selectedSection.value.isNotEmpty ? 1 : 0,
        startTime: startTime.value,
        endTime: endTime.value,
        questions: questions,
      );

      if (responseData['success'] == true) {
        Get.snackbar(
            "success".tr, responseData['message'] ?? "note_added_success".tr);
      } else {
        Get.snackbar(
            "error".tr, responseData['message'] ?? "note_add_failed".tr);
      }
    } catch (e) {
      print(e);
      String errorMessage = "note_add_failed".tr;
      if (e is Exception && e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      }
      Get.snackbar("error".tr, errorMessage);
    } finally {
      isSending.value = false;
    }
  }
}
