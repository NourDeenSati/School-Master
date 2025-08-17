class ScheduleModel {
  final Map<String, List<ScheduleItem>> schedule;

  ScheduleModel({required this.schedule});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ScheduleItem>> scheduleMap = {};
    final scheduleJson = json['schedule'] as Map<String, dynamic>?;

    if (scheduleJson != null) {
      scheduleJson.forEach((day, items) {
        scheduleMap[day] = (items as List)
            .map((item) => ScheduleItem.fromJson(item))
            .toList();
      });
    }

    return ScheduleModel(schedule: scheduleMap);
  }
}

class ScheduleItem {
  final String section;
  final String period;
  final String time;
  final String subject;

  ScheduleItem({
    required this.section,
    required this.period,
    required this.time,
    required this.subject,
  });

  factory ScheduleItem.fromJson(Map<String, dynamic> json) {
    return ScheduleItem(
      section: json['section'] ?? '',
      period: json['period'] ?? '',
      time: json['time'] ?? '',
      subject: json['subject'] ?? '',
    );
  }
}
