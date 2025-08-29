import 'package:get/get.dart';
import 'package:school_mangmante/core/service/storage_service.dart';

class ApiClient extends GetConnect {
  final StorageService storage;

  ApiClient(this.storage) {
    httpClient.baseUrl = 'http://137.184.50.2'; // عيّنها في StorageService
    httpClient.timeout = const Duration(seconds: 20);

    httpClient.addRequestModifier<dynamic>((request) {
      final token = storage.token;
      request.headers['Accept'] = 'application/json';
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.headers['Accept-Language'] = storage.language ?? 'ar';
      if (token != null && token.isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      return request;
    });
  }

  Future<Response> getNotes() => get('/api/v1/mobile/student/notes');
  Future<Response> getAttendances() =>
      get('/api/v1/mobile/student/attendances');
  Future<Response> getDictations() => get('/api/v1/mobile/student/dictations');
  Future<Response> getExams() => get('/api/v1/mobile/student/exams');
  Future<Response> getQuizzesSubmittable() =>
      get('/api/v1/mobile/student/quizzes/submittable');

  Future<Response> getQuizQuestions(int quizId) =>
      get('/api/v1/mobile/student/quizzes/$quizId/questions');

  Future<Response> submitQuiz(int quizId, List<Map<String, dynamic>> answers) =>
      post('/api/v1/mobile/student/quizzes/$quizId/submit',
          {'answers': answers});
}
