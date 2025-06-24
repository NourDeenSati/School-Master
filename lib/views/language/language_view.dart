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
            ElevatedButton(
              onPressed: () => controller.selectLanguage('ar'),
              child: const Text('العربية'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.selectLanguage('en'),
              child: const Text('English'),
            ),
          ],
        ),
      ),
    );
  }
}
