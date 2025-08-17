import 'package:school_mangmante/models/studint_Info.dart';

class SectionData {
  final List<StudintInfo> students;

  SectionData({required this.students});

  factory SectionData.fromJson(Map<String, dynamic> json) {
    final studentsList = json['students'] as List? ?? [];
    return SectionData(
      students: studentsList.map((s) => StudintInfo.fromJson(s)).toList(),
    );
  }
}
