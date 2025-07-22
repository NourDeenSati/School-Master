import 'package:school_mangmante/models/top_student.dart';

class Section {
  final int id;
  final String name;
  final String classroom;
  final TopStudent topByPoints;
  final TopStudent topByNotes;
  final TopStudent topByExams;
  final int avgExamResult;

  Section({
    required this.id,
    required this.name,
    required this.classroom,
    required this.topByPoints,
    required this.topByNotes,
    required this.topByExams,
    required this.avgExamResult,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      name: json['name'],
      classroom: json['classroom'],
      topByPoints: TopStudent.fromJson(json['top_by_points']),
      topByNotes: TopStudent.fromJson(json['top_by_notes']),
      topByExams: TopStudent.fromJson(json['top_by_exams']),
      avgExamResult: json['avg_exam_result'],
    );
  }
}