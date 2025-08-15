import 'package:school_mangmante/models/top_student.dart';

class Section {
  final int id;
  final String name;
  final String classroom;
  final TopStudent? topByPoints;
  final TopStudent? topByNotes;
  final TopStudent? topByExams;
  final int avgExamResult;

  Section({
    required this.id,
    required this.name,
    required this.classroom,
    this.topByPoints,
    this.topByNotes,
    this.topByExams,
    required this.avgExamResult,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      classroom: json['classroom'] ?? '',
      topByPoints: json['top_by_points'] != null
          ? TopStudent.fromJson(json['top_by_points'])
          : null,
      topByNotes: json['top_by_notes'] != null
          ? TopStudent.fromJson(json['top_by_notes'])
          : null,
      topByExams: json['top_by_exams'] != null
          ? TopStudent.fromJson(json['top_by_exams'])
          : null,
      avgExamResult: json['avg_exam_result'] ?? 0,
    );
  }
}
