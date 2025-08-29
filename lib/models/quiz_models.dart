class SubmittableQuiz {
  final int id;
  final String name;
  final String subjectName;
  final String startTime; // "2025-08-21 14:00:00"
  final String endTime;   // "2025-08-21 14:30:00"
  final int totalQuestions;

  SubmittableQuiz({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.totalQuestions,
  });

  factory SubmittableQuiz.fromJson(Map<String, dynamic> j) => SubmittableQuiz(
        id: j['id'],
        name: j['name'] ?? '',
        subjectName: j['subject']?['name'] ?? '',
        startTime: j['start_time']?.toString() ?? '',
        endTime: j['end_time']?.toString() ?? '',
        totalQuestions: j['total_questions'] ?? 0,
      );
}

class QuizAnswerOption {
  final int id;
  final String text;

  QuizAnswerOption({required this.id, required this.text});

  factory QuizAnswerOption.fromJson(Map<String, dynamic> j) =>
      QuizAnswerOption(id: j['id'], text: j['text'] ?? '');
}

class QuizQuestion {
  final int id;
  final String text;
  final num mark;
  final List<QuizAnswerOption> answers;

  QuizQuestion({
    required this.id,
    required this.text,
    required this.mark,
    required this.answers,
  });

  factory QuizQuestion.fromJson(Map<String, dynamic> j) => QuizQuestion(
        id: j['id'],
        text: j['text'] ?? '',
        mark: j['mark'] ?? 0,
        answers: (j['answers'] as List? ?? [])
            .map((a) => QuizAnswerOption.fromJson(a))
            .toList(),
      );
}

class QuizDetail {
  final int id;
  final String name;
  final String subjectName;
  final String startTime; // ISO: "2025-08-21T11:00:00.000000Z"
  final String endTime;
  final List<QuizQuestion> questions;

  QuizDetail({
    required this.id,
    required this.name,
    required this.subjectName,
    required this.startTime,
    required this.endTime,
    required this.questions,
  });

  factory QuizDetail.fromJson(Map<String, dynamic> jsonRoot) {
    final data = jsonRoot['data'] ?? {};
    final q = data['quiz'] ?? {};

    return QuizDetail(
      id: q['id'] ?? 0,
      name: q['name'] ?? '',
      subjectName: q['subject']?['name'] ?? '',
      startTime: q['start_time']?.toString() ?? '',
      endTime: q['end_time']?.toString() ?? '',
      questions: (q['questions'] as List? ?? [])
          .map((e) => QuizQuestion.fromJson(e))
          .toList(),
    );
  }
}
