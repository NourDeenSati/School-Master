class ScheduleModel {
  final bool success;
  final Map<String, List<ScheduleItem>> schedule;

  ScheduleModel({required this.success, required this.schedule});

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    final Map<String, List<ScheduleItem>> map = {};
    if (json['schedule'] != null && json['schedule'] is Map) {
      (json['schedule'] as Map<String, dynamic>).forEach((day, items) {
        map[day] = List<ScheduleItem>.from(
          (items as List).map((e) => ScheduleItem.fromJson(e)),
        );
      });
    }
    return ScheduleModel(
      success: json['success'] ?? false,
      schedule: map,
    );
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
      section: json['section']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      time: json['time']?.toString() ?? '',
      subject: json['subject']?.toString() ?? '',
    );
  }
}
