import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api_student.dart';

import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/student_stats.dart';

class StudentController extends GetxController {
  final isLoading = false.obs;
  final stats = StudentStats().obs;

  late final ApiClient api;

  StudentController() {
    final storage = Get.find<StorageService>();
    api = ApiClient(storage);
  }

  @override
  void onInit() {
    super.onInit();
    fetchAll();
  }

  Future<void> fetchAll() async {
    try {
      isLoading.value = true;

      await Future.wait([
        _fetchNotes(),
        _fetchAttendances(),
        _fetchDictations(),
        _fetchExams(),
      ]);
    } catch (e) {
      Get.snackbar('خطأ', 'تعذّر تحميل بيانات الطالب: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  Future<void> _fetchNotes() async {
    final res = await api.getNotes();
    if (res.isOk && res.body is Map) {
      final data = res.body['data'] ?? {};
      final totals = data['totals'] ?? {};
      final items = (data['notes'] as List? ?? []);

      final s = stats.value;
      s.notesSummary = NotesSummary.fromJson(totals);
      s.notes = items.map((e) => NoteItem.fromJson(e)).toList();
      stats.refresh();
    } else {
      throw 'فشل جلب الملاحظات';
    }
  }

  Future<void> _fetchAttendances() async {
    final res = await api.getAttendances();
    if (res.isOk && res.body is Map) {
      final data = res.body['data'] ?? {};
      final summary = data['summary'] ?? {};
      final byType = (summary['by_type'] as List? ?? []);
      final totals = summary['totals'] ?? {};
      final list = (data['attendances'] as List? ?? []);

      final s = stats.value;
      s.attendanceByType = byType.map((e) => AttendanceTypeSummary.fromJson(e)).toList();
      s.attendanceTotalCount = totals['count'] ?? 0;
      s.attendanceTotalPoints = totals['points'] ?? 0;
      s.attendances = list.map((e) => AttendanceItem.fromJson(e)).toList();
      stats.refresh();
    } else {
      throw 'فشل جلب الحضور';
    }
  }

  Future<void> _fetchDictations() async {
    final res = await api.getDictations();
    if (res.isOk && res.body is Map) {
      final data = res.body['data'] ?? {};
      final summary = data['summary'] ?? {};
      final list = (data['dictations'] as List? ?? []);

      final s = stats.value;
      s.dictationSummary = DictationSummary.fromJson(summary);
      s.dictations = list.map((e) => DictationItem.fromJson(e)).toList();
      stats.refresh();
    } else {
      throw 'فشل جلب التسميعات';
    }
  }

  Future<void> _fetchExams() async {
    final res = await api.getExams();
    if (res.isOk && res.body is Map) {
      final data = res.body['data'] ?? {};
      final summary = data['summary'] ?? {};
      final attempts = (data['attempts'] as List? ?? []);

      final s = stats.value;
      s.examsSummary = ExamsSummary.fromJson(summary);
      s.attempts = attempts.map((e) => ExamAttempt.fromJson(e)).toList();
      stats.refresh();
    } else {
      throw 'فشل جلب الامتحانات';
    }
  }
}
