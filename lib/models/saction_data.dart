import 'package:school_mangmante/models/studint_Info.dart';

class SectionData {
  final Map<String, List<StudintInfo>> sections;

  SectionData({required this.sections});

  factory SectionData.fromJson(Map<String, dynamic> json) {
    final Map<String, List<StudintInfo>> parsedSections = {};

    json.forEach((sectionName, studentsList) {
      parsedSections[sectionName] = (studentsList as List? ?? [])
          .map((s) => StudintInfo.fromJson(s))
          .toList();
    });

    return SectionData(sections: parsedSections);
  }
}
