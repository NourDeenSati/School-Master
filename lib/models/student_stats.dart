class NoteItem {
  final int id;
  final String reason;
  final String type; // positive/negative
  final String status;
  final String value;
  final String createdAt;
  NoteItem({required this.id, required this.reason, required this.type, required this.status, required this.value, required this.createdAt});
  factory NoteItem.fromJson(Map<String, dynamic> j) => NoteItem(
    id: j['id'],
    reason: j['reason'] ?? '',
    type: j['type'] ?? '',
    status: j['status'] ?? '',
    value: '${j['value']}',
    createdAt: j['created_at'] ?? '',
  );
}

class NotesSummary {
  final int positiveCount;
  final double positivePoints;
  final int negativeCount;
  final double negativePoints;
  final double netPoints;
  NotesSummary({required this.positiveCount, required this.positivePoints, required this.negativeCount, required this.negativePoints, required this.netPoints});
  factory NotesSummary.fromJson(Map<String, dynamic> j) => NotesSummary(
    positiveCount: j['positive']?['count'] ?? 0,
    positivePoints: double.tryParse('${j['positive']?['points'] ?? 0}') ?? 0,
    negativeCount: j['negative']?['count'] ?? 0,
    negativePoints: double.tryParse('${j['negative']?['points'] ?? 0}') ?? 0,
    netPoints: double.tryParse('${j['net_points'] ?? 0}') ?? 0,
  );
}

class AttendanceTypeSummary {
  final int typeId;
  final String name; // present/absent/late
  final int value;   // +10 / -2 / -1
  final int count;
  final int points;
  AttendanceTypeSummary({required this.typeId, required this.name, required this.value, required this.count, required this.points});
  factory AttendanceTypeSummary.fromJson(Map<String, dynamic> j) => AttendanceTypeSummary(
    typeId: j['type_id'] ?? 0,
    name: j['name'] ?? '',
    value: j['value'] ?? 0,
    count: j['count'] ?? 0,
    points: j['points'] ?? 0,
  );
}

class AttendanceItem {
  final int id;
  final String date;
  final String? justification;
  final String typeName;
  final int typeValue;
  AttendanceItem({required this.id, required this.date, this.justification, required this.typeName, required this.typeValue});
  factory AttendanceItem.fromJson(Map<String, dynamic> j) => AttendanceItem(
    id: j['id'],
    date: j['date'] ?? '',
    justification: j['justification'],
    typeName: j['type']?['name'] ?? '',
    typeValue: j['type']?['value'] ?? 0,
  );
}

class DictationItem {
  final int id;
  final double result;
  final String createdAt;
  DictationItem({required this.id, required this.result, required this.createdAt});
  factory DictationItem.fromJson(Map<String, dynamic> j) => DictationItem(
    id: j['id'],
    result: (j['result'] as num).toDouble(),
    createdAt: j['created_at'] ?? '',
  );
}

class DictationSummary {
  final int count;
  final double avg;
  final double best;
  final double last;
  DictationSummary({required this.count, required this.avg, required this.best, required this.last});
  factory DictationSummary.fromJson(Map<String, dynamic> j) => DictationSummary(
    count: j['count'] ?? 0,
    avg: (j['avg_result'] as num).toDouble(),
    best: (j['best']?['result'] as num).toDouble(),
    last: (j['last']?['result'] as num).toDouble(),
  );
}

class ExamAttempt {
  final int attemptId;
  final String status; // wait/approved...
  final double result;
  final String submittedAt;
  final String examName;
  final String subjectName;
  ExamAttempt({required this.attemptId, required this.status, required this.result, required this.submittedAt, required this.examName, required this.subjectName});
  factory ExamAttempt.fromJson(Map<String, dynamic> j) => ExamAttempt(
    attemptId: j['attempt_id'],
    status: j['status'] ?? '',
    result: (j['result'] as num).toDouble(),
    submittedAt: j['submitted_at']?.toString() ?? '',
    examName: j['exam']?['name'] ?? '',
    subjectName: j['exam']?['subject']?['name'] ?? '',
  );
}

class ExamsSummary {
  final int total;
  final int approved;
  final int pending;
  final double avgResult;
  final double best;
  final double last;
  ExamsSummary({required this.total, required this.approved, required this.pending, required this.avgResult, required this.best, required this.last});
  factory ExamsSummary.fromJson(Map<String, dynamic> j) => ExamsSummary(
    total: j['total'] ?? 0,
    approved: j['approved'] ?? 0,
    pending: j['pending'] ?? 0,
    avgResult: (j['avg_result'] as num).toDouble(),
    best: (j['best']?['result'] as num).toDouble(),
    last: (j['last']?['result'] as num).toDouble(),
  );
}

class StudentStats {
  // Notes
  NotesSummary? notesSummary;
  List<NoteItem> notes = [];

  // Attendances
  List<AttendanceTypeSummary> attendanceByType = [];
  int attendanceTotalCount = 0;
  int attendanceTotalPoints = 0;
  List<AttendanceItem> attendances = [];

  // Dictations
  DictationSummary? dictationSummary;
  List<DictationItem> dictations = [];

  // Exams
  ExamsSummary? examsSummary;
  List<ExamAttempt> attempts = [];
}
