import 'package:school_mangmante/models/section.dart';
import 'package:school_mangmante/models/teacher.dart';

class TeacherHomeResponse {
  final bool success;
  final Teacher teacher;
  final List<Section> sections;

  TeacherHomeResponse({
    required this.success,
    required this.teacher,
    required this.sections,
  });

  factory TeacherHomeResponse.fromJson(Map<String, dynamic> json) {
    return TeacherHomeResponse(
      success: json['success'] ?? false,
      teacher: Teacher.fromJson(json['teacher'] ?? {}),
      sections: (json['sections'] as List? ?? [])
          .map((section) => Section.fromJson(section ?? {}))
          .toList(),
    );
  }
}
