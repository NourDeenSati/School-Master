import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/class_response.dart';
import 'package:school_mangmante/models/saction_data.dart';

class TeacherNotesApi {
  static const String baseUrl = "http://137.184.50.2";

  /// جلب الصفوف والشعب
  static Future<Map<String, SectionData>> fetchClasses() async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/api/v1/mobile/teacher/students"),
        headers: {"Authorization": "Bearer $token"},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        // تحقق من أن response.body هو JSON وليس boolean
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

  /// إرسال ملاحظة
  static Future<bool> sendNote({
    required int studentId,
    required String type,
    required String reason,
  }) async {
    final storage = Get.find<StorageService>();
    final token = storage.token;
    final response = await http.post(
      Uri.parse("$baseUrl/api/v1/mobile/teacher/dictations/create"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "student_id": studentId,
        "type": type,
        "reason": reason,
      }),
    );
    print(response.body);
    print(response.statusCode);
    return response.statusCode == 200;
  }
}
