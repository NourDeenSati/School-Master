import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/administe_controller.dart';
import 'package:school_mangmante/core/controllers/auth/teacer_represention_controller.dart';
import 'package:school_mangmante/models/studint_Info.dart';

class ExamCraetionPage extends StatelessWidget {
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
          "Create Exam".tr,
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
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: "select_section".tr),
                value: controller.selectedSection.value.isEmpty
                    ? null
                    : controller.selectedSection.value,
                items: controller.selectedClass.value.isEmpty
                    ? []
                    : controller
                        .classesData[controller.selectedClass.value]!.keys
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
                final subject = controller.currentSubject;
                return DropdownButtonFormField<int>(
                  decoration: InputDecoration(
                    labelText: "select_subject".tr,
                    errorText: subject.isEmpty &&
                            controller.selectedSection.value.isNotEmpty
                        ? "no_subject_found".tr
                        : null,
                  ),
                  value: subject.any(
                          (sb) => sb.id == controller.selectedSubjectId.value)
                      ? controller.selectedSubjectId.value
                      : null,
                  items: subject
                      .map((sb) => DropdownMenuItem<int>(
                            value: sb.id,
                            child: Text(sb.name),
                          ))
                      .toList(),
                  onChanged: subject.isEmpty
                      ? null
                      : (val) => controller.selectedSubjectId.value = val ?? 0,
                );
              }),
              SizedBox(height: 16),
              TextFormField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: "Name Probe".tr,
                ),
                onChanged: (val) {
                  if (val.isEmpty) {
                    controller.maxResult.value = null; // ما يخزن شي
                  } else {
                    controller.maxResult.value =
                        int.tryParse(val); // يخزن رقم صحيح
                  }
                },
              ),
              SizedBox(height: 16),
              SizedBox(height: 20),
              Obx(() {
                final isValid = controller.maxResult.value != null &&
                    controller.selectedClass.value.isNotEmpty &&
                    controller.selectedSection.value.isNotEmpty &&
                    controller.selectedSubjectId.value != 0;

                return ElevatedButton(
                  onPressed: (!isValid || controller.isSending.value)
                      ? null
                      : () => controller.sendCreateExam(),
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
