import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api_student.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/quiz_models.dart';

// حالة زمن الاختبار
enum QuizPhase { before, running, ended }

class QuizTakeController extends GetxController {
  final isLoading = false.obs;
  final isSubmitting = false.obs;

  final quiz = Rxn<QuizDetail>();
  final selected = <int, int?>{}.obs; // questionId -> answerId (قد تكون null)

  late final ApiClient api;
  final int quizId;

  // العدّاد
  final phase = QuizPhase.before.obs;
  final remaining = Duration.zero.obs;
  DateTime? _startAt, _endAt;
  Timer? _ticker;

  QuizTakeController(this.quizId) {
    api = ApiClient(Get.find<StorageService>());
  }

  @override
  void onInit() {
    super.onInit();
    fetchQuiz();
  }

  @override
  void onClose() {
    _ticker?.cancel();
    super.onClose();
  }

  Future<void> fetchQuiz() async {
    try {
      isLoading.value = true;
      final res = await api.getQuizQuestions(quizId);
      if (res.isOk && res.body is Map) {
        final q = QuizDetail.fromJson(res.body);
        quiz.value = q;

        // تهيئة الاختيارات (كلها null)
        for (final que in q.questions) {
          selected[que.id] = null;
        }

        // ضبط أوقات البدء/الانتهاء
        _startAt = _toLocal(q.startTime);
        _endAt   = _toLocal(q.endTime);

        _startTicker();
      } else {
        Get.snackbar('خطأ', 'تعذر تحميل الاختبار');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // تحويل نص الوقت إلى DateTime محلي (يدعم "YYYY-MM-DD HH:MM:SS" و ISO مع Z)
  DateTime _toLocal(String s) {
    var t = s.trim();
    if (!t.contains('T') && t.contains(' ')) {
      t = t.replaceFirst(' ', 'T');
    }
    final dt = DateTime.parse(t);
    return dt.isUtc ? dt.toLocal() : dt;
  }

  void _startTicker() {
    _ticker?.cancel();
    _tick(); // تحديث أولي
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_startAt == null || _endAt == null) return;
    final now = DateTime.now();

    if (now.isBefore(_startAt!)) {
      phase.value = QuizPhase.before;
      remaining.value = _startAt!.difference(now);
    } else if (now.isAfter(_endAt!)) {
      phase.value = QuizPhase.ended;
      remaining.value = Duration.zero;
    } else {
      phase.value = QuizPhase.running;
      remaining.value = _endAt!.difference(now);
    }
  }

  // نسبة التقدّم الزمنية من البدء إلى الانتهاء (0..1)
  double get timeProgress {
    if (_startAt == null || _endAt == null) return 0;
    final total = _endAt!.difference(_startAt!).inMilliseconds;
    if (total <= 0) return 1;
    final now = DateTime.now();
    if (now.isBefore(_startAt!)) return 0;
    if (now.isAfter(_endAt!)) return 1;
    final elapsed = now.difference(_startAt!).inMilliseconds;
    return elapsed / total;
  }

  // عدد الأسئلة المجيبة
  int get answeredCount => selected.values.whereType<int>().length;

  bool get allAnswered =>
      quiz.value != null && answeredCount == quiz.value!.questions.length;

  bool get canSubmit =>
      phase.value == QuizPhase.running && !isSubmitting.value && allAnswered;

  void chooseAnswer(int questionId, int answerId) {
    selected[questionId] = answerId;
  }

  Future<void> submit() async {
    // منع الإرسال خارج الوقت
    if (phase.value != QuizPhase.running) {
      Get.snackbar('تنبيه', 'لا يمكن الإرسال الآن. الوقت غير نشط.');
      return;
    }

    // منع الإرسال مع إجابات ناقصة
    if (!allAnswered) {
      final total = quiz.value?.questions.length ?? 0;
      Get.snackbar('أكمل الإجابات',
          'جاوب على جميع الأسئلة (${answeredCount}/$total) ثم حاول مرة أخرى.');
      return;
    }

    try {
      isSubmitting.value = true;

      final answersPayload = selected.entries
          .map((e) => {"question_id": e.key, "answer_id": e.value})
          .toList();

      final res = await api.submitQuiz(quizId, answersPayload);
      if (res.isOk && res.body is Map) {
        final data = res.body['data'] ?? {};
        final result = data['final_result'] ?? 0;
        Get.off(() => const QuizResultPage(),
            arguments: {'quiz_id': quizId, 'score': result});
      } else {
        Get.snackbar('خطأ', 'تعذر إرسال الإجابات');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isSubmitting.value = false;
    }
  }
}

/// صفحة النتيجة (كما هي)
class QuizResultPage extends StatelessWidget {
  const QuizResultPage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map?;
    final score = args?['score'] ?? 0;
    final quizId = args?['quiz_id'];

    return Scaffold(
      appBar: AppBar(title: const Text('نتيجة الاختبار')),
      body: Center(
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 2,
          margin: const EdgeInsets.all(20),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events, size: 64),
                const SizedBox(height: 12),
                Text('أحسنت!',
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('النتيجة النهائية: $score',
                    style:
                        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
                const SizedBox(height: 16),
                Text('معرّف الاختبار: $quizId',
                    style: TextStyle(color: Colors.grey[700])),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.check),
                  label: const Text('تم'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
