import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api/schedule_controller.dart';
import 'package:school_mangmante/models/schedule_model.dart';

class SchedulePage extends StatelessWidget {
  SchedulePage({super.key});
  final ScheduleController controller = Get.put(ScheduleController());

  // وضع العرض: true => جدول كامل، false => يوم واحد
  final RxBool showFullTable = true.obs;
  late final RxString selectedDay = controller.daysOrder.first.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("جدول دوام الأستاذ"),
        actions: [
          Obx(
            () => IconButton(
              icon: Icon(
                  showFullTable.value ? Icons.view_day : Icons.table_chart),
              tooltip: showFullTable.value ? "عرض يوم واحد" : "عرض الجدول كامل",
              onPressed: () {
                showFullTable.value = !showFullTable.value;
              },
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.schedule.value == null) {
          return const Center(child: Text("لا توجد بيانات"));
        }

        final scheduleModel = controller.schedule.value!;
        const int totalPeriods = 8;


        if (!showFullTable.value) {
          return Column(
            children: [
              // Dropdown لاختيار اليوم
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButton<String>(
                  value: selectedDay.value,
                  items: controller.daysOrder
                      .map((d) => DropdownMenuItem(
                            value: d,
                            child: Text(_translateDay(d)),
                          ))
                      .toList(),
                  onChanged: (val) {
                    if (val != null) selectedDay.value = val;
                  },
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Table(
                    border: TableBorder.all(color: Colors.blue),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FixedColumnWidth(60),
                      1: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(
                        children: [
                          _buildHeaderCell("الحصة"),
                          _buildHeaderCell(_translateDay(selectedDay.value)),
                        ],
                      ),
                      for (int period = 1; period <= totalPeriods; period++)
                        TableRow(
                          children: [
                            _buildHeaderCell(period.toString()),
                            _buildCell(_cellTextFor(
                                scheduleModel, selectedDay.value, period)),
                          ],
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Table(
            border: TableBorder.all(color: Colors.blue),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            columnWidths: const {
              0: FixedColumnWidth(60), // عمود الحصة
            },
            children: [
              TableRow(
                children: [
                  _buildHeaderCell("الحصة / اليوم"),
                  ...controller.daysOrder
                      .map((day) => _buildHeaderCell(_translateDay(day))),
                ],
              ),
              for (int period = 1; period <= totalPeriods; period++)
                TableRow(
                  children: [
                    _buildHeaderCell(period.toString()),
                    ...controller.daysOrder.map((day) =>
                        _buildCell(_cellTextFor(scheduleModel, day, period))),
                  ],
                ),
            ],
          ),
        );
      }),
    );
  }

  String _cellTextFor(ScheduleModel scheduleModel, String day, int period) {
    final items = scheduleModel.schedule[day] ?? [];
    final cellItems = items.where((e) {
      return int.tryParse(e.period.replaceAll("P", "")) == period;
    }).toList();
    if (cellItems.isEmpty) return "";
    return cellItems.map((e) => "${e.subject}\n${e.time}").join("\n---\n");
  }

  Widget _buildHeaderCell(String text) {
    return Container(
      color: const Color(0xFFEAF0FF),
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildCell(String text) {
    return Container(
      padding: const EdgeInsets.all(6),
      alignment: Alignment.center,
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 12),
      ),
    );
  }

  String _translateDay(String engDay) {
    switch (engDay) {
      case "saturday":
        return "السبت";
      case "sunday":
        return "الأحد";
      case "monday":
        return "الاثنين";
      case "tuesday":
        return "الثلاثاء";
      case "wednesday":
        return "الأربعاء";
      case "thursday":
        return "الخميس";
      default:
        return engDay;
    }
  }
}
