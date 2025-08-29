import 'package:school_mangmante/models/studint_Info.dart';
import 'package:school_mangmante/models/subject_infoStudent.dart';

class SectionData {
  final List<StudintInfo> students;
  final List<Subject> subjects;

  SectionData({required this.students, required this.subjects});

  factory SectionData.fromJson(Map<String, dynamic> json) {
    final studentsList = json['students'] as List? ?? [];
    final subjectsList = json['subjects'] as List? ?? [];

    return SectionData(
      students: studentsList.map((s) => StudintInfo.fromJson(s)).toList(),
      subjects: subjectsList.map((s) => Subject.fromJson(s)).toList(),
    );
  }
}
