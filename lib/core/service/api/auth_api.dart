import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../models/login_response.dart';

class AuthApi {
  static const baseUrl = 'https://6b3b4a337a0b.ngrok-free.app';

  static Future<LoginResponse> login(
      String email, String password, String lang) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/v1/mobile/login'),
      headers: {
        'Accept': 'application/json',
        'Accept-Language': lang,
      },
      body: {
        'email': email,
        'password': password,
      },
    );

    print('Request: ${response.request}');
    print('Status: ${response.statusCode}');
    print('Body: ${response.body}');

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final data = decoded['data']; // ← يحتوي على "user" و "token"
      return LoginResponse.fromJson(data); // ← تمرير مباشرة للـ fromJson
    } else {
      throw Exception(
          json.decode(response.body)['message'] ?? 'فشل تسجيل الدخول');
    }
  }
}
