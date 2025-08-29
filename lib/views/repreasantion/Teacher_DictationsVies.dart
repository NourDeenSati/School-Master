import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/teacer_represention_controller.dart';
import 'package:school_mangmante/models/studint_Info.dart';
import 'package:school_mangmante/models/subject_infoStudent.dart';

class TeacherDictationsView extends StatelessWidget {
  final TeacherNotesController controller2 = Get.put(TeacherNotesController());
  final TextEditingController resultController =
      TextEditingController(text: "0");
  int selectedValue = 1;
  @override
  Widget build(BuildContext context) {
    final subject = (controller2.selectedClass.value.isEmpty ||
            controller2.selectedSection.value.isEmpty)
        ? <StudintInfo>[]
        : controller2
                .classesData[controller2.selectedClass.value]
                    ?[controller2.selectedSection.value]
                ?.students ??
            <Subject>[];
    final parsed = int.tryParse(resultController.text);
    if (parsed != null) {
      controller2.result.value = parsed;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text("add_note".tr),
        backgroundColor: Color(0xFF4B70F5),
      ),
      body: Obx(() {
        if (controller2.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              // اختيار الصف
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "select_class".tr),
                value: controller2.selectedClass.value.isEmpty
                    ? null
                    : controller2.selectedClass.value,
                items: controller2.classesData.keys.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (value) {
                  controller2.selectedClass.value = value ?? "";
                  controller2.selectedSection.value = "";
                  controller2.selectedStudentId.value = 0;
                  controller2.selectedSubjectId.value = 0;
                },
              ),
              SizedBox(height: 16),

              // اختيار الشعبة
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "select_section".tr),
                value: controller2.selectedSection.value.isEmpty
                    ? null
                    : controller2.selectedSection.value,
                items: controller2.selectedClass.value.isEmpty
                    ? []
                    : controller2
                        .classesData[controller2.selectedClass
                            .value]! // هذه هي الخريطة التي تحتوي على أسماء الأقسام
                        .keys // ✅ استخدم .keys مباشرةً على الخريطة
                        .map((secName) => DropdownMenuItem(
                              value: secName,
                              child: Text(secName),
                            ))
                        .toList(),
                onChanged: (value) {
                  controller2.selectedSection.value = value ?? "";
                  controller2.selectedStudentId.value = 0;
                  controller2.selectedSubjectId.value = 0;
                },
              ),

              SizedBox(height: 16),

              Obx(() {
                final students = controller2.currentStudents;
                return DropdownButtonFormField<int>(
                    decoration: InputDecoration(
                      labelText: "select_student".tr,
                      errorText: students.isEmpty &&
                              controller2.selectedSection.value.isNotEmpty
                          ? "no_students_found".tr
                          : null,
                    ),
                    value: students.any((st) =>
                            st.id == controller2.selectedStudentId.value)
                        ? controller2.selectedStudentId.value
                        : null,
                    items: students
                        .map((st) => DropdownMenuItem<int>(
                              value: st.id,
                              child: Text("${st.firstName} ${st.lastName}"),
                            ))
                        .toList(),
                    onChanged: (Value) {
                      controller2.selectedStudentId.value = Value ?? 0;
                      controller2.selectedSubjectId.value = 0;
                    });
              }),
              SizedBox(height: 16),

              Obx(() {
                final subject = controller2.currentSubject;
                return DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "select_subject".tr,
                    errorText: subject.isEmpty &&
                            controller2.selectedSection.value.isNotEmpty
                        ? "no_subject_found".tr
                        : null,
                  ),
                  value: subject.any(
                          (sb) => sb.id == controller2.selectedSubjectId.value)
                      ? controller2.selectedSubjectId.value
                      : null,
                  items: subject
                      .map((st) => DropdownMenuItem<int>(
                            value: st.id,
                            child: Text("${st.name} "),
                          ))
                      .toList(),
                  onChanged: subject.isEmpty
                      ? null
                      : (val) => controller2.selectedSubjectId.value = val ?? 0,
                );
              }),

              SizedBox(height: 16),

              // سبب الملاحظة
              // القيمة الافتراضية
              Text("result".tr),
              SizedBox(height: 10),
              Obx(
                () {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(11, (index) {
                        final value = index;
                        final isSelected = controller2.result.value == value;

                        return GestureDetector(
                          onTap: () {
                            controller2.result.value = value;
                          },
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            margin: EdgeInsets.symmetric(horizontal: 4),
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color:
                                  isSelected ? Color(0xFF4B70F5) : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? Color(0xFF4B70F5)
                                    : Colors.grey,
                                width: 2,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color:
                                            const Color.fromARGB(66, 5, 5, 5),
                                        blurRadius: 6,
                                        offset: Offset(0, 3),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Text(
                                value.toString(),
                                style: TextStyle(
                                  fontSize: isSelected ? 18 : 16,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isSelected ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
              ),

              SizedBox(height: 20),

              // زر الإرسال
              Obx(() {
                return ElevatedButton(
                  onPressed: controller2.isSending.value
                      ? null
                      : () => controller2.sendDictations(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B70F5),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: controller2.isSending.value
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text("send".tr, style: TextStyle(color: Colors.white)),
                );
              }),
            ],
          ),
        );
      }),
    );
  }
}
