import 'dart:convert';
import 'dart:ffi';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:get/get_core/src/get_main.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/class_response.dart';
import 'package:school_mangmante/models/saction_data.dart';

class Administer {
  static const String baseUrl = "http://137.184.50.2";

  static Future<Map<String, Map<String, SectionData>>> fetchClasses() async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";

    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/mobile/supervisor/students"),
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
          throw Exception(
              "Expected Map but got".tr + "${responseData.runtimeType}");
        }
      } else {
        throw Exception(
            "Failed to load classes:".tr + "${response.statusCode}");
      }
    } catch (e) {
      print("Error in fetchClasses:".tr + "$e");
      throw Exception("Error fetching classes: $e");
    }
  }

  static Future<Map<String, dynamic>> sendStateAttendance({
    required int studentId,
    required int attendance_type_id,
    required String att_date,
    String? justification,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/supervisor/attendance/register"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Accept-Language': lang,
      },
      body: jsonEncode({
        "attendable_id": studentId,
        "attendance_type_id": attendance_type_id,
        "att_date": att_date,
        "justification": justification
      }),
    );

    final decodedBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return decodedBody;
    } else {
      throw Exception(decodedBody['message'] ?? 'Failed To load Absents'.tr);
    }
  }

  static Future<Map<String, dynamic>> sendNote({
    required int studentId,
    required String type,
    required String reason,
    required double value,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/supervisor/notes/create"),
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
        "value": value
      }),
    );
    final decodedBody = json.decode(response.body);

    if (response.statusCode == 201) {
      return decodedBody;
    } else {
      throw Exception(decodedBody['message'] ?? 'Failed To load Absents'.tr);
    }
  }

  static Future<Map<String, dynamic>> SendCreateExma({
    required int classId,
    required int subjectId,
    required int maxResult,
    required double nameExam,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final lang = storage.language ?? "ar";
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/supervisor/exams/create"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
        "Accept": "application/json",
        'Accept-Language': lang,
      },
      body: jsonEncode({
        "classroom_id": classId,
        "subject_id": subjectId,
        "max_result": maxResult,
        "name": nameExam
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
