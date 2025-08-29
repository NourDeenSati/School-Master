class StudentInfo {
  final int? id;
  final String? name;
  final String? section;
  final String? classroom;

  StudentInfo({this.id, this.name, this.section, this.classroom});

  factory StudentInfo.fromJson(Map<String, dynamic> j) => StudentInfo(
    id: j['id'],
    name: j['name'],
    section: j['section'],
    classroom: j['classroom'],
  );
}

class ScheduleItem {
  final String period;
  final String time;
  final String subject;
  final String teacher;
  final String? section;
  final int? order; // جديد

  ScheduleItem({
    required this.period,
    required this.time,
    required this.subject,
    required this.teacher,
    this.section,
    this.order, // جديد
  });

  factory ScheduleItem.fromApi(Map<String, dynamic> j, {String? section}) {
    final p     = asMapSD(j['period']);
    final subj  = asMapSD(j['subject']);
    final teach = asMapSD(j['teacher']);

    final start = (p['start_time'] ?? '').toString();
    final end   = (p['end_time'] ?? '').toString();
    final time  = (start.isNotEmpty && end.isNotEmpty) ? '$start - $end' : '';

    return ScheduleItem(
      period : (p['name'] ?? '').toString(),
      time   : time,
      subject: (subj['name'] ?? '').toString(),
      teacher: (teach['name'] ?? '').toString(),
      section: section,
      order  : (p['order'] is int) ? p['order'] as int : int.tryParse('${p['order'] ?? ''}'),
    );
  }
}

class StudentScheduleModel {
  final StudentInfo student;
  final Map<String, List<ScheduleItem>> schedule; // مفهرس بـ saturday/sunday/...

  final int total;

  StudentScheduleModel({
    required this.student,
    required this.schedule,
    required this.total,
  });

  /// يتوقع الـ JSON الكامل للـ API (الجذر)
 factory StudentScheduleModel.fromApi(Map<String, dynamic> json) {
  final data    = asMapSD(json['data']);
  final student = StudentInfo.fromJson(asMapSD(data['student']));
  final week    = (data['week'] is List) ? data['week'] as List : const [];

  final total = (data['total'] is int)
      ? data['total'] as int
      : int.tryParse('${data['total'] ?? 0}') ?? 0;

  final map = <String, List<ScheduleItem>>{};

  for (final dayRaw in week) {
    final dayObj  = asMapSD(dayRaw);
    final dayKey  = (dayObj['day'] ?? '').toString();
    final items   = asListMapSD(dayObj['items']);

    final rows = items
        .map((it) => ScheduleItem.fromApi(it, section: student.section))
        .toList();

 
    map[dayKey] = rows;
  }

  return StudentScheduleModel(student: student, schedule: map, total: total);
}
}
Map<String, dynamic> asMapSD(dynamic v) =>
    v is Map ? Map<String, dynamic>.from(v as Map) : <String, dynamic>{};

List<Map<String, dynamic>> asListMapSD(dynamic v) {
  if (v is List) {
    return v
        .whereType<Map>() // يستبعد null/أنواع أخرى
        .map((m) => Map<String, dynamic>.from(m))
        .toList();
  }
  return <Map<String, dynamic>>[];
}
