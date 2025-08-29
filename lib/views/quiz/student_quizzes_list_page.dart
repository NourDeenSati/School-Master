import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:school_mangmante/core/controllers/quiz/quiz_take_controller.dart';
import 'package:school_mangmante/core/controllers/quiz/quizzes_controller.dart';

class StudentQuizzesListPage extends StatelessWidget {
  StudentQuizzesListPage({super.key});

  final QuizzesController c = Get.put(QuizzesController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: const Text('الاختبارات المتاحة')),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (c.quizzes.isEmpty) {
          return const Center(child: Text('لا يوجد اختبارات متاحة حالياً'));
        }
        return RefreshIndicator(
          onRefresh: c.fetchSubmittable,
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: c.quizzes.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final q = c.quizzes[i];
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 1.5,
                child: Padding(
                  padding: const EdgeInsets.all(14.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(q.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.menu_book, size: 16),
                          const SizedBox(width: 6),
                          Text(q.subjectName),
                          const Spacer(),
                          const Icon(Icons.help_outline, size: 16),
                          const SizedBox(width: 4),
                          Text('${q.totalQuestions} سؤال'),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.schedule, size: 16),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${q.startTime}  →  ${q.endTime}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: ElevatedButton.icon(
                          onPressed: () => Get.to(() => QuizTakePage(quizId: q.id)),
                          icon: const Icon(Icons.play_arrow),
                          label: const Text('الدخول'),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      }),
    );
  }
}

class QuizTakePage extends StatelessWidget {
  final int quizId;
  QuizTakePage({super.key, required this.quizId});

  late final QuizTakeController c = Get.put(QuizTakeController(quizId));

  String _fmt(Duration d) {
    final h = d.inHours.remainder(100).toString().padLeft(2, '0');
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('بدء الاختبار')),
      body: Obx(() {
        if (c.isLoading.value || c.quiz.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final quiz = c.quiz.value!;
        final total = quiz.questions.length;

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: c.fetchQuiz,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // رأس + بانر العدّاد
                    Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      child: Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(quiz.name,
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.menu_book, size: 16),
                                const SizedBox(width: 6),
                                Text(quiz.subjectName),
                                const Spacer(),
                                const Icon(Icons.help_outline, size: 16),
                                const SizedBox(width: 4),
                                Text('$total سؤال'),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.schedule, size: 16),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '${quiz.startTime} → ${quiz.endTime}',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),

                            // بانر العدّ التنازلي
                            Obx(() {
                              final ph = c.phase.value;
                              final rem = c.remaining.value;
                              String title;
                              if (ph == QuizPhase.before) {
                                title = 'يبدأ خلال: ${_fmt(rem)}';
                              } else if (ph == QuizPhase.running) {
                                title = 'الوقت المتبقي: ${_fmt(rem)}';
                              } else {
                                title = 'انتهى الوقت';
                              }
                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: ph == QuizPhase.ended
                                            ? Colors.red
                                            : cs.primary,
                                      )),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: LinearProgressIndicator(
                                      value: ph == QuizPhase.before
                                          ? 0
                                          : (ph == QuizPhase.ended ? 1 : c.timeProgress.clamp(0, 1)),
                                      minHeight: 8,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    // تنبيه إتمام جميع الإجابات
                    Obx(() {
                      final ok = c.allAnswered;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: ok ? Colors.green.withOpacity(0.08) : Colors.orange.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(ok ? Icons.check_circle : Icons.info, size: 18, color: ok ? Colors.green : Colors.orange),
                            const SizedBox(width: 8),
                            Text(
                              ok
                                ? 'جميل! جاوبت على جميع الأسئلة.'
                                : 'أجب على جميع الأسئلة قبل الإرسال.',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Spacer(),
                            Obx(() => Text('${c.answeredCount}/$total')),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 12),

                    // الأسئلة (نمط Google Form)
                    ...quiz.questions.map((q) => _QuestionCard(
                          question: q,
                          selectedAnswerId: c.selected[q.id],
                          onSelect: (answerId) => c.chooseAnswer(q.id, answerId),
                          cs: cs,
                        )),
                  ],
                ),
              ),
            ),

            // زر الإرسال مثبت أسفل الشاشة (يعطّل قبل البدء/بعد الانتهاء/عند نقص الإجابات)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 8,
                        offset: const Offset(0, -2),
                      )
                    ],
                  ),
                  child: Obx(() => ElevatedButton.icon(
                        onPressed: c.canSubmit
                            ? () async {
                                final confirmed = await Get.dialog<bool>(
                                  AlertDialog(
                                    title: const Text('تأكيد الإرسال'),
                                    content: const Text('هل تريد إرسال جميع الإجابات الآن؟'),
                                    actions: [
                                      TextButton(
                                          onPressed: () => Get.back(result: false),
                                          child: const Text('إلغاء')),
                                      ElevatedButton(
                                          onPressed: () => Get.back(result: true),
                                          child: const Text('إرسال')),
                                    ],
                                  ),
                                );
                                if (confirmed == true) {
                                  await c.submit();
                                }
                              }
                            : null,
                        icon: const Icon(Icons.send),
                        label: c.isSubmitting.value
                            ? const Text('جارٍ الإرسال...')
                            : const Text('إرسال الإجابات'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      )),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _QuestionCard extends StatelessWidget {
  final dynamic question; // QuizQuestion
  final int? selectedAnswerId;
  final void Function(int answerId) onSelect;
  final ColorScheme cs;

  const _QuestionCard({
    required this.question,
    required this.selectedAnswerId,
    required this.onSelect,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // عنوان السؤال + الدرجة
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    question.text,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: cs.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.workspace_premium, size: 14),
                      const SizedBox(width: 4),
                      Text('${question.mark}'),
                    ],
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),

            // الاختيارات (Radio)
            ...question.answers.map<Widget>((a) {
              return RadioListTile<int>(
                value: a.id,
                groupValue: selectedAnswerId,
                onChanged: (v) => v != null ? onSelect(v) : null,
                title: Text(a.text),
                dense: true,
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
