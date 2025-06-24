import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class AppTranslations extends Translations {
  static Map<String, Map<String, String>> _translations = {};

  static Future<void> loadTranslations() async {
    final arJson = await rootBundle.loadString('assets/translations/ar.json');
    final enJson = await rootBundle.loadString('assets/translations/en.json');

    _translations = {
      'ar': Map<String, String>.from(json.decode(arJson)),
      'en': Map<String, String>.from(json.decode(enJson)),
    };
  }

  @override
  Map<String, Map<String, String>> get keys => _translations;
}
