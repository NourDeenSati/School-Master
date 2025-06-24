import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../models/login_response.dart';

/*class AuthApi {
  static const baseUrl = 'https://yourapi.com/api';

  static Future<LoginResponse> login(
      String email, String password, String lang) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': lang, // نرسل اللغة المختارة مع الطلب
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode == 200) {
      return LoginResponse.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          json.decode(response.body)['message'] ?? 'فشل تسجيل الدخول');
    }
  }
}*/
