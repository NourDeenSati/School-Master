import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/auth/teacer_represention_controller.dart';

class TeacherExplorationView extends StatelessWidget {
  final TeacherNotesController controller3 = Get.put(TeacherNotesController());

  TeacherExplorationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Probe".tr),
        backgroundColor: const Color(0xFF4B70F5),
      ),
      body: Obx(() {
        if (controller3.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return controller3.isSending.value
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: ListView(
                  children: [
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(labelText: "select_class".tr),
                      value: controller3.selectedClass.value.isEmpty
                          ? null
                          : controller3.selectedClass.value,
                      items: controller3.classesData.keys.map((className) {
                        return DropdownMenuItem(
                          value: className,
                          child: Text(className),
                        );
                      }).toList(),
                      onChanged: (value) {
                        controller3.selectedClass.value = value ?? "";
                        controller3.selectedSection.value = "";
                        controller3.selectedStudentId.value = 0;
                        controller3.selectedSubjectId.value = 0;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration:
                          InputDecoration(labelText: "select_section".tr),
                      value: controller3.selectedSection.value.isEmpty
                          ? null
                          : controller3.selectedSection.value,
                      items: controller3.selectedClass.value.isEmpty
                          ? []
                          : controller3
                              .classesData[controller3.selectedClass.value]!
                              .keys
                              .map((secName) => DropdownMenuItem(
                                    value: secName,
                                    child: Text(secName),
                                  ))
                              .toList(),
                      onChanged: (value) {
                        controller3.selectedSection.value = value ?? "";
                        controller3.selectedStudentId.value = 0;
                        controller3.selectedSubjectId.value = 0;
                      },
                    ),
                    const SizedBox(height: 16),
                    Obx(() {
                      final subject = controller3.currentSubject;
                      return DropdownButtonFormField<int>(
                        decoration: InputDecoration(
                          labelText: "select_subject".tr,
                          errorText: subject.isEmpty &&
                                  controller3.selectedSection.value.isNotEmpty
                              ? "no_subject_found".tr
                              : null,
                        ),
                        value: subject.any((sb) =>
                                sb.id == controller3.selectedSubjectId.value)
                            ? controller3.selectedSubjectId.value
                            : null,
                        items: subject
                            .map((sb) => DropdownMenuItem<int>(
                                  value: sb.id,
                                  child: Text(sb.name),
                                ))
                            .toList(),
                        onChanged: subject.isEmpty
                            ? null
                            : (val) =>
                                controller3.selectedSubjectId.value = val ?? 0,
                      );
                    }),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(labelText: "Name Probe".tr),
                      onChanged: (val) => controller3.examName.value = val,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                          labelText: "Time Strat (yyyy-MM-dd HH:mm:ss)".tr),
                      onChanged: (val) => controller3.startTime.value = val,
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      decoration: InputDecoration(
                          labelText: "Time End (yyyy-MM-dd HH:mm:ss)".tr),
                      onChanged: (val) => controller3.endTime.value = val,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B70F5),
                      ),
                      onPressed: () {
                        _showAddQuestionDialog(context);
                      },
                      icon: const Icon(Icons.add),
                      label: Text("Add Quastion".tr),
                    ),
                    const SizedBox(height: 20),
                    ...controller3.questions.asMap().entries.map((entry) {
                      final index = entry.key;
                      final question = entry.value;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${index + 1}. ${question['question']} (Mark: ${question['mark']})"
                                    .tr,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: List.generate(
                                  question['answers'].length,
                                  (i) => Row(
                                    children: [
                                      Icon(
                                        question['answers'][i]['is_correct']
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        color: question['answers'][i]
                                                ['is_correct']
                                            ? Colors.green
                                            : Colors.red,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(question['answers'][i]['answer']),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.orange),
                                    onPressed: () {
                                      _showAddAnswerDialog(context, index);
                                    },
                                    child: Text("Add Answer".tr),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red),
                                    onPressed: () {
                                      controller3.removeQuestion(index);
                                    },
                                    child: Text("Remove Quastion".tr),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4B70F5),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: () {
                        if (controller3.examName.value.isEmpty ||
                            controller3.startTime.value.isEmpty ||
                            controller3.endTime.value.isEmpty ||
                            controller3.selectedClass.value.isEmpty ||
                            controller3.selectedSection.value.isEmpty ||
                            controller3.selectedSubjectId.value == 0 ||
                            controller3.questions.isEmpty) {
                          controller3.sendExam();
                        }
                      },
                      child: Text(
                        "Send Probe".tr,
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
              );
      }),
    );
  }

  void _showAddQuestionDialog(BuildContext context) {
    final questionController = TextEditingController();
    final markController = TextEditingController();

    Get.defaultDialog(
      title: "Add Quastion".tr,
      content: Column(
        children: [
          TextField(
            controller: questionController,
            decoration: InputDecoration(labelText: "Quastion Text".tr),
          ),
          TextField(
            controller: markController,
            decoration: InputDecoration(labelText: "Mark".tr),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      textCancel: "Cancel".tr,
      textConfirm: "Add".tr,
      onConfirm: () {
        if (questionController.text.isNotEmpty &&
            markController.text.isNotEmpty) {
          controller3.addQuestion(
              questionController.text, int.parse(markController.text));
          Get.back();
        }
      },
    );
  }

  void _showAddAnswerDialog(BuildContext context, int questionIndex) {
    final answerController = TextEditingController();
    var isCorrect = false.obs;

    Get.defaultDialog(
      title: "Add Answer".tr,
      content: Column(
        children: [
          TextField(
            controller: answerController,
            decoration: InputDecoration(labelText: "Answer Text".tr),
          ),
          const SizedBox(height: 10),
          Obx(() => CheckboxListTile(
                title: Text("The Correct Answer".tr),
                value: isCorrect.value,
                onChanged: (val) {
                  isCorrect.value = val ?? false;
                },
              )),
        ],
      ),
      textCancel: "Cancel".tr,
      textConfirm: "Add".tr,
      onConfirm: () {
        if (answerController.text.isNotEmpty) {
          controller3.addAnswer(
              questionIndex, answerController.text, isCorrect.value);
          Get.back();
        }
      },
    );
  }
}
