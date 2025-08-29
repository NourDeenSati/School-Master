import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/administe_controller.dart';
import 'package:school_mangmante/core/controllers/auth/teacer_represention_controller.dart';
import 'package:school_mangmante/models/studint_Info.dart';

class AttendancePage extends StatelessWidget {
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
          "state Attendeance".tr,
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
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("choose a stuaition".tr,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Obx(() => Row(
                        children: [
                          Flexible(
                            fit: FlexFit.tight,
                            child: RadioListTile<String>(
                              title: Text(
                                "Attendance".tr,
                              ),
                              value: "1",
                              groupValue: controller.attendance_type_id.value
                                  .toString(),
                              activeColor: Color(0xFF4B70F5),
                              onChanged: (value) {
                                controller.attendance_type_id.value =
                                    int.parse(value!) ?? 1;
                              },
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: RadioListTile<String>(
                              title: Text("Absent".tr),
                              value: "2",
                              groupValue: controller.attendance_type_id.value
                                  .toString(),
                              activeColor: Color(0xFF4B70F5),
                              onChanged: (value) {
                                controller.attendance_type_id.value =
                                    int.parse(value!) ?? 2;
                              },
                            ),
                          ),
                          Flexible(
                            fit: FlexFit.tight,
                            child: RadioListTile<String>(
                              title: Text(
                                "Layte".tr,
                              ),
                              value: "3",
                              groupValue: controller.attendance_type_id.value
                                  .toString(),
                              activeColor: Color(0xFF4B70F5),
                              onChanged: (value) {
                                controller.attendance_type_id.value =
                                    int.parse(value!) ?? 3;
                              },
                            ),
                          ),
                        ],
                      )),
                ],
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(labelText: "Time (yyyy-MM-dd)".tr),
                onChanged: (val) => controller.startTime.value = val,
              ),
              SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: "justification".tr,
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                onChanged: (val) => controller.justification.value = val,
              ),
              SizedBox(height: 20),
              Obx(() {
                return ElevatedButton(
                  onPressed: controller.isSending.value
                      ? null
                      : () => controller.sendStateAttendance(),
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
