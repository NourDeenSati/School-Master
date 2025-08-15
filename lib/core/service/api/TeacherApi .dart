import 'dart:convert';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../../models/teacher_home_response.dart';
import '../../service/storage_service.dart';

class TeacherApi {
  static const String baseUrl = 'http://137.184.50.2'; // عدل لاحقًا

  static Future<TeacherHomeResponse> getTeacherHomeData(String token) async {
    final storage = Get.find<StorageService>();
    final lang = storage.language ?? 'ar';

    final response = await http.get(
      Uri.parse('$baseUrl/api/v1/mobile/teacher/home'),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
        'Accept-Language': lang,
      },
    );

    if (response.statusCode == 200) {
      print(response.body);

      return TeacherHomeResponse.fromJson(json.decode(response.body));
    } else {
      // نحاول استخراج رسالة الخطأ من الـ response
      final error =
          json.decode(response.body)['message'] ?? 'فشل في جلب بيانات المعلم';
      print(response.body);
      Text('error');
      throw Exception(error);
    }
  }
}
