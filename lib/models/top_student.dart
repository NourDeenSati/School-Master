import 'package:school_mangmante/models/student.dart';

class TopStudent {
  final Student? student;
  final int? points;

  TopStudent({
    this.student,
    this.points,
  });

  factory TopStudent.fromJson(Map<String, dynamic>? json) {
    if (json == null) return TopStudent();

    return TopStudent(
      student:
          json['student'] != null ? Student.fromJson(json['student']) : null,
      points: json['points'],
    );
  }
}
