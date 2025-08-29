import 'package:get/get.dart';
import 'package:school_mangmante/core/service/api_student.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/models/quiz_models.dart';

class QuizzesController extends GetxController {
  final isLoading = false.obs;
  final quizzes = <SubmittableQuiz>[].obs;

  late final ApiClient api;

  @override
  void onInit() {
    super.onInit();
    api = ApiClient(Get.find<StorageService>());
    fetchSubmittable();
  }

  Future<void> fetchSubmittable() async {
    try {
      isLoading.value = true;
      final res = await api.getQuizzesSubmittable();
      if (res.isOk && res.body is Map) {
        final data = res.body['data'] ?? {};
        final list = (data['quizzes'] as List? ?? []);
        quizzes.value =
            list.map((e) => SubmittableQuiz.fromJson(e)).toList();
      } else {
        Get.snackbar('خطأ', 'تعذر تحميل الاختبارات');
      }
    } catch (e) {
      Get.snackbar('خطأ', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
