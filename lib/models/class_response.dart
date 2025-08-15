import 'package:school_mangmante/models/saction_data.dart';

class ClassesResponse {
  final Map<String, SectionData> classes;

  ClassesResponse({required this.classes});

  factory ClassesResponse.fromJson(Map<String, dynamic> json) {
    final Map<String, SectionData> parsedClasses = {};

    json.forEach((className, sectionsMap) {
      parsedClasses[className] =
          SectionData.fromJson(sectionsMap as Map<String, dynamic>);
    });

    return ClassesResponse(classes: parsedClasses);
  }
}
