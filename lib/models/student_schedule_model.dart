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
  final String period;   // مثال: P2
  final String time;     // مثال: 08:50:00 - 09:35:00
  final String subject;  // مثال: Science
  final String teacher;  // مثال: TeacherFirst4 TeacherLast4
  final String? section; // من student.section

  ScheduleItem({
    required this.period,
    required this.time,
    required this.subject,
    required this.teacher,
    this.section,
  });

  factory ScheduleItem.fromApi(Map<String, dynamic> j, {String? section}) {
    final p = (j['period'] ?? {}) as Map<String, dynamic>;
    final subj = (j['subject'] ?? {}) as Map<String, dynamic>;
    final teach = (j['teacher'] ?? {}) as Map<String, dynamic>;

    final start = (p['start_time'] ?? '').toString();
    final end   = (p['end_time'] ?? '').toString();
    final time  = (start.isNotEmpty && end.isNotEmpty) ? '$start - $end' : '';

    return ScheduleItem(
      period: (p['name'] ?? '').toString(),
      time: time,
      subject: (subj['name'] ?? '').toString(),
      teacher: (teach['name'] ?? '').toString(),
      section: section,
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
    final data = (json['data'] ?? {}) as Map<String, dynamic>;

    final student = StudentInfo.fromJson((data['student'] ?? {}) as Map<String, dynamic>);
    final week = (data['week'] as List? ?? []).cast<Map<String, dynamic>>();
    final total = (data['total'] ?? 0) as int;

    final map = <String, List<ScheduleItem>>{};

    for (final dayObj in week) {
      final dayKey = (dayObj['day'] ?? '').toString();      // مثال: saturday
      final items  = (dayObj['items'] as List? ?? []).cast<Map<String, dynamic>>();

      final rows = items.map((it) => ScheduleItem.fromApi(it, section: student.section)).toList();

      // ترتيب حسب period.order إن وُجد
      rows.sort((a, b) {
        final pa = (dayObj['items'] as List).firstWhere(
          (x) => ((x as Map)['period']?['name'] ?? '') == a.period,
          orElse: () => null,
        ) as Map<String, dynamic>?;

        final pb = (dayObj['items'] as List).firstWhere(
          (x) => ((x as Map)['period']?['name'] ?? '') == b.period,
          orElse: () => null,
        ) as Map<String, dynamic>?;

        final oa = (pa?['period']?['order'] ?? 0) as int;
        final ob = (pb?['period']?['order'] ?? 0) as int;
        return oa.compareTo(ob);
      });

      map[dayKey] = rows;
    }

    return StudentScheduleModel(student: student, schedule: map, total: total);
  }
}
