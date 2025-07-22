import 'package:school_mangmante/models/student.dart';

class TopStudent {
  final Student student;
  final int points;

  TopStudent({
    required this.student,
    required this.points,
  });

  factory TopStudent.fromJson(Map<String, dynamic> json) {
    return TopStudent(
      student: Student.fromJson(json['student']),
      points: json['points'],
    );
  }
}