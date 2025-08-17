import 'package:school_mangmante/models/saction_data.dart';

class ClassesResponse {
  final Map<String, Map<String, SectionData>> classes;

  ClassesResponse({required this.classes});

  factory ClassesResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, Map<String, SectionData>> parsedClasses = {};

    (json['data'] as Map<String, dynamic>).forEach((className, sectionsMap) {
      final Map<String, SectionData> parsedSections = {};
      (sectionsMap as Map<String, dynamic>).forEach((sectionName, sectionData) {
        parsedSections[sectionName] =
            SectionData.fromJson(sectionData as Map<String, dynamic>);
      });
      parsedClasses[className] = parsedSections;
    });

    return ClassesResponse(classes: parsedClasses);
  }
}
