import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/controllers/language_controller.dart';

class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(LanguageController());

    return Scaffold(
      appBar: AppBar(title: const Text('Choose Language')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 90,
              width: 200,
              child: ElevatedButton(
                onPressed: () => controller.selectLanguage('ar'),
                child: const Text(
                  'العربية',
                  style: TextStyle(fontSize: 40, color: Color(0xFF4B70F5)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Container(
              height: 90,
              width: 200,
              child: ElevatedButton(
                onPressed: () => controller.selectLanguage('en'),
                child: const Text(
                  'English',
                  style: TextStyle(fontSize: 40, color: Color(0xFF4B70F5)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
