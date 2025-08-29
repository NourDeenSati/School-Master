import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/administe_controller.dart';
import 'package:school_mangmante/core/controllers/auth/teacer_represention_controller.dart';
import 'package:school_mangmante/models/studint_Info.dart';

class NoteTakingPage extends StatelessWidget {
  final AdministerHomeController controller =
      Get.put(AdministerHomeController());

  @override
  Widget build(BuildContext context) {
    final students = (controller.selectedClass.value.isEmpty ||
            controller.selectedSection.value.isEmpty)
        ? <StudintInfo>[]
        : controller
                .classesData[controller.selectedClass.value]
                    ?[controller.selectedSection.value]
                ?.students ??
            <StudintInfo>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "add_note".tr,
          style: TextStyle(color: Color(0xFF4B70F5)),
        ),
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              SizedBox(
                height: 5,
              ),
              // اختيار الصف
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "select_class".tr),
                value: controller.selectedClass.value.isEmpty
                    ? null
                    : controller.selectedClass.value,
                items: controller.classesData.keys.map((className) {
                  return DropdownMenuItem(
                    value: className,
                    child: Text(className),
                  );
                }).toList(),
                onChanged: (value) {
                  controller.selectedClass.value = value ?? "";
                  controller.selectedSection.value = "";
                  controller.selectedStudentId.value = 0;
                },
              ),
              SizedBox(height: 16),

              // اختيار الشعبة
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "select_section".tr),
                value: controller.selectedSection.value.isEmpty
                    ? null
                    : controller.selectedSection.value,
                items: controller.selectedClass.value.isEmpty
                    ? []
                    : controller
                        .classesData[controller.selectedClass
                            .value]! // هذه هي الخريطة التي تحتوي على أسماء الأقسام
                        .keys // ✅ استخدم .keys مباشرةً على الخريطة
                        .map((secName) => DropdownMenuItem(
                              value: secName,
                              child: Text(secName),
                            ))
                        .toList(),
                onChanged: (value) {
                  controller.selectedSection.value = value ?? "";
                  controller.selectedStudentId.value = 0;
                },
              ),

              SizedBox(height: 16),

              Obx(() {
                final students = controller.currentStudents;
                return DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "select_student".tr,
                    errorText: students.isEmpty &&
                            controller.selectedSection.value.isNotEmpty
                        ? "no_students_found".tr
                        : null,
                  ),
                  value: controller.selectedStudentId.value == 0
                      ? null
                      : controller.selectedStudentId.value,
                  items: students
                      .map((st) => DropdownMenuItem<int>(
                            value: st.id,
                            child: Text("${st.firstName} ${st.lastName}"),
                          ))
                      .toList(),
                  onChanged: students.isEmpty
                      ? null
                      : (val) => controller.selectedStudentId.value = val ?? 0,
                );
              }),

              SizedBox(height: 16),

              // نوع الملاحظة
              // نوع الملاحظة (Radio Buttons)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("note_type".tr,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Obx(() => Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text("positive_note".tr),
                              value: "positive",
                              groupValue: controller.noteType.value,
                              activeColor: Color(0xFF4B70F5),
                              onChanged: (value) {
                                controller.noteType.value = value ?? "positive";
                              },
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: RadioListTile<String>(
                              title: Text("negative_note".tr),
                              value: "negative",
                              groupValue: controller.noteType.value,
                              activeColor: Color(0xFF4B70F5),
                              onChanged: (value) {
                                controller.noteType.value = value ?? "positive";
                              },
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "value degree",
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    controller.value1.value = double.tryParse(val!) ?? 0,
              ),
              SizedBox(height: 16),
              // سبب الملاحظة
              TextField(
                decoration: InputDecoration(
                  labelText: "reason".tr,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (val) => controller.reason.value = val,
              ),
              SizedBox(height: 20),
              SizedBox(height: 16),
              // زر الإرسال
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isSending.value
                      ? null
                      : () => controller.sendNote(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4B70F5),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: controller.isSending.value
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
