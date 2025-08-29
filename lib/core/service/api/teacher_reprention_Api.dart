import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/class_response.dart';
import 'package:school_mangmante/models/saction_data.dart';

class TeacherNotesApi {
  static const String baseUrl = "http://137.184.50.2";

  /// جلب الصفوف والشعب
  static Future<Map<String, Map<String, SectionData>>> fetchClasses() async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/mobile/teacher/students"),
        headers: {
          "Authorization": "Bearer $token",
          'Accept-Language': lang,
        },
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        if (responseData is Map<String, dynamic>) {
          final parsed = ClassesResponse.fromJson(responseData);
          return parsed.classes;
        } else {
          throw Exception("Expected Map but got ${responseData.runtimeType}");
        }
      } else {
        throw Exception("Failed to load classes: ${response.statusCode}");
      }
    } catch (e) {
      print('Error in fetchClasses: $e');
      throw Exception("Error fetching classes: $e");
    }
  }

  static Future<Map<String, dynamic>> sendNote({
    required int studentId,
    required String type,
    required String reason,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/teacher/notes/create"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Accept-Language': lang,
      },
      body: jsonEncode({
        "student_id": studentId,
        "type": type,
        "reason": reason,
      }),
    );

    final decodedBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return decodedBody;
    } else {
      throw Exception(decodedBody['message'] ?? 'Failed To load Absents'.tr);
    }
  }

  static Future<Map<String, dynamic>> sendDictations({
    required int studentId,
    required int subjecttId,
    required int result,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/teacher/dictations/create"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Accept-Language': lang,
      },
      body: jsonEncode({
        "student_id": studentId,
        "subject_id": subjecttId,
        "result": result,
      }),
    );
    final decodedBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return decodedBody;
    } else {
      throw Exception(decodedBody['message'] ?? 'Failed To load Absents'.tr);
    }
  }

  static Future<Map<String, dynamic>> sendExam({
    required String name,
    required int subjectId,
    required int classId,
    required int sectionId,
    required String startTime,
    required String endTime,
    required List<Map<String, dynamic>> questions,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/teacher/quiz/create"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Accept-Language': lang,
      },
      body: jsonEncode({
        "name": name,
        "subject_id": subjectId,
        "classroom_id": classId,
        "section_id": sectionId,
        "start_time": startTime,
        "end_time": endTime,
        "questions": questions,
      }),
    );
    final decodedBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return decodedBody;
    } else {
      throw Exception(decodedBody['message'] ?? 'Failed To load Absents'.tr);
    }
  }
}
