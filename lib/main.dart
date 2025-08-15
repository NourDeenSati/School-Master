// main.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/theme/theme.dart';
import 'package:school_mangmante/views/repreasantion/teacher_note.dart';
import 'core/service/storage_service.dart';
import 'assets/translations/app_translations.dart';
import 'views/auth/login_view.dart';
import 'views/language/language_view.dart';
import 'views/home/admin_home_view.dart';
import 'views/home/student_home_view.dart';
import 'views/home/teacher_home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = Get.put(await StorageService().init());
  await AppTranslations.loadTranslations();

  final savedLang = storageService.language;
  final savedRole = storageService.role;
  final savedToken = storageService.token;

  String localeCode = savedLang ?? Get.deviceLocale?.languageCode ?? 'ar';
  Locale locale = Locale(localeCode);

  Widget initialPage;
  if (savedLang == null) {
    initialPage = const LanguageView();
  } else if (savedToken == null || savedRole == null) {
    initialPage = LoginView();
  } else {
    switch (savedRole) {
      case 'student':
        initialPage = const StudentHomeView();
        break;
      case 'teacher':
        initialPage = const TeacherHomeView();
        break;
      case 'admin':
        initialPage = const AdminHomeView();
        break;
      default:
        initialPage = LoginView();
    }
  }

  runApp(MyApp(locale: locale, home: initialPage));
}

class MyApp extends StatelessWidget {
  final Locale locale;
  final Widget home;

  const MyApp({super.key, required this.locale, required this.home});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Master',
      translations: AppTranslations(),
      theme: AppTheme.lightTheme,
      locale: locale,
      fallbackLocale: const Locale('ar'),
      home: home,
      routes: {
        // الصفحة الرئيسية
        '/teacher_note': (context) => TeacherNotesView(),
        // '/behavior': (context) => BehaviorPage(),
        // '/recite': (context) => RecitationPage(),
        // '/attendance': (context) => AttendancePage(),
      },
    );
  }
}
