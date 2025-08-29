import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api/Administer_Api.dart';
import 'package:school_mangmante/models/saction_data.dart';
import 'package:school_mangmante/models/studint_Info.dart';
import 'package:school_mangmante/models/subject_infoStudent.dart';

class AdministerHomeController extends GetxController {
  final PageController pageController = PageController();
  final RxInt selectedIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pageController.addListener(() {
      selectedIndex.value = pageController.page?.round() ?? 0;
      fetchClasses();
    });
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    selectedIndex.value = index;
  }

  void goToPage(int index) {
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  var classesData = <String, Map<String, SectionData>>{};
  var selectedClass = "".obs;
  var selectedSection = "".obs;
  var selectedStudentId = 0.obs;
  var noteType = "".obs;
  var reason = "".obs;
  var selectedSubjectId = 0.obs;
  var sjId = 0.obs;
  var result = 0.obs;
  var isLoading = false.obs;
  var isSending = false.obs;
  var startTime = "".obs;
  var endTime = "".obs;
  var examName = "".obs;
  var attendance_type_id = 0.obs;
  var justification = "".obs;
  var value1 = 0.0.obs;
  var questions = <Map<String, dynamic>>[].obs;
  var classId = 0.obs;
  var maxResult = RxnInt(); // int? داخل Rx
  @override
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
      questions.refresh(); // لتحديث الواجهة
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
      classesData = await Administer.fetchClasses();
    } catch (e) {
      print("Error fetching classes: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendStateAttendance() async {
    try {
      isSending.value = true;
      // استدعاء التابع الجديد الذي يعود بالـ JSON
      final responseData = await Administer.sendStateAttendance(
        studentId: selectedStudentId.value,
        attendance_type_id: attendance_type_id.value,
        att_date: startTime.value,
        justification: justification.value,
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

  Future<void> sendNote() async {
    try {
      isSending.value = true;
      final responseData = await Administer.sendNote(
          studentId: selectedStudentId.value,
          type: noteType.value,
          reason: reason.value,
          value: value1.value);

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

  Future<void> sendCreateExam() async {
    try {
      isSending.value = true;
      final responseData = await Administer.SendCreateExma(
          classId: classId.value,
          subjectId: selectedSubjectId.value,
          maxResult: maxResult.value!,
          nameExam: value1.value);

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

  // Future<void> sendDictations() async {
  //   try {
  //     isSending.value = true;
  //     bool success = await Administer.sendDictations(
  //       studentId: selectedStudentId.value,
  //       subjecttId: selectedSubjectId.value,
  //       result: result.value,
  //     );

  //     if (success) {
  //       Get.snackbar("success".tr, "dictations_added_success".tr);
  //     } else {
  //       Get.snackbar("error".tr, "dictations_add_failed".tr);
  //     }
  //   } catch (e) {
  //     print(e);
  //     Get.snackbar("error".tr, "dictations_add_failed".tr);
  //   } finally {
  //     isSending.value = false;
  //   }
  // }

  // Future<void> sendExam() async {
  //   try {
  //     isSending.value = true;

  //     final success = await Administer.sendExam(
  //       name: examName.value,
  //       subjectId: selectedSubjectId.value,
  //       classId: classesData.containsKey(selectedClass.value)
  //           ? 1
  //           : 0, // أو جيب ID الصف الحقيقي
  //       sectionId: selectedSection.value.isNotEmpty ? 1 : 0, // أو ID الشعبة
  //       startTime: startTime.value,
  //       endTime: endTime.value,
  //       questions: questions,
  //     );

  //     if (success) {
  //       Get.snackbar("نجاح", "تم إرسال الامتحان بنجاح ✅".tr);
  //       questions.clear();
  //       examName.value = "";
  //       startTime.value = "";
  //       endTime.value = "";
  //       selectedSubjectId.value = 0;
  //       selectedClass.value = "";
  //       selectedSection.value = "";
  //     } else {
  //       Get.snackbar("خطأ", "فشل إرسال الامتحان ⚠️".tr);
  //     }
  //   } catch (e) {
  //     print("Error sending exam: $e");
  //     Get.snackbar("خطأ", "حدث خطأ أثناء الإرسال".tr);
  //   } finally {
  //     isSending.value = false;
  //   }
  // }

