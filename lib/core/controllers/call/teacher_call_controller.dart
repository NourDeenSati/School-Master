import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/views/stream/LivePage.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:intl/intl.dart';
import 'package:school_mangmante/core/service/storage_service.dart';

// ------------------------------
// LiveController (GetX) - Teacher
// ------------------------------
class LiveController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final baseUrl = 'http://137.184.50.2';

  // Raw rooms data from the students API
  final rooms = <String, dynamic>{}.obs; // e.g. {"Primary Room 1": {"A": {..}, "B": {...}}}
  final currentCallId = RxnInt();

  // UI selections
  final selectedRoom = RxnString();
  final selectedSection = RxnString();
  final subjects = <Map<String, dynamic>>[].obs;
  final selectedSubjectId = RxnInt();
  final selectedSectionId = RxnInt();

  // schedule fields
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final durationMinutes = 60.obs;

  // misc
  final isLoading = false.obs;
  final liveIdController = TextEditingController(); // manual live id field
  final timeController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    fetchRooms();
  }

  Map<String, String> get headers {
    final token = storage.token ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // ---- helpers ----
  String? _extractZegoToken(Map<String, dynamic> data) {
    for (final k in ['token', 'zego_token', 'room_token', 'roomToken', 'zegoToken']) {
      final v = data[k];
      if (v != null && v.toString().trim().isNotEmpty) return v.toString().trim();
    }
    return null;
  }

  DateTime? _parseServerDateTime(String? value) {
    if (value == null) return null;
    try {
      final safe = value.replaceFirst(' ', 'T');
      return DateTime.parse(safe);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
      } catch (e) {
        return null;
      }
    }
  }

  DateTime? parseServerDateTime(String? value) => _parseServerDateTime(value);

  // ---- teacher actions ----
  Future<void> endLiveCall(int callId) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/api/v1/mobile/teacher/call/$callId/end'),
        headers: headers,
      );

      print('<< End Call Status: ${resp.statusCode}');
      print('<< End Call Body: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        if (body['status'] == true || body['success'] == true) {
          Get.snackbar('تم الإنهاء', body['message'] ?? 'تم إنهاء البث');
        } else {
          Get.snackbar('خطأ', body['message'] ?? resp.body);
        }
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Exception end call: $e');
    }
  }

  Future<bool> deleteScheduledCall(int callId) async {
    try {
      isLoading.value = true;
      final uri = Uri.parse('$baseUrl/api/v1/mobile/teacher/scheduled-call/$callId');
      final resp = await http.delete(uri, headers: headers);

      if (resp.statusCode == 200 || resp.statusCode == 204) {
        scheduledCalls.removeWhere((e) =>
            (e['id'] == callId) ||
            (e['call_id'] == callId) ||
            ('${e['id']}' == '$callId') ||
            ('${e['call_id']}' == '$callId'));
        Get.snackbar('تم الحذف', 'تم حذف المكالمة رقم $callId بنجاح');
        return true;
      } else {
        String msg = 'HTTP ${resp.statusCode}';
        try {
          final body = json.decode(resp.body);
          msg = body['message']?.toString() ?? msg;
        } catch (_) {}
        Get.snackbar('تعذّر الحذف', msg);
        return false;
      }
    } catch (e) {
      Get.snackbar('تعذّر الحذف', e.toString());
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRooms() async {
    try {
      isLoading.value = true;
      final resp = await http.get(
        Uri.parse('$baseUrl/api/v1/mobile/teacher/students'),
        headers: headers,
      );
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body['success'] == true && body['data'] != null) {
          rooms.value = Map<String, dynamic>.from(body['data']);
          // Reset selections
          selectedRoom.value = null;
          selectedSection.value = null;
          subjects.clear();
        } else {
          Get.snackbar('خطأ', body['message'] ?? 'Failed to load rooms');
        }
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void onRoomChanged(String? roomName) {
    selectedRoom.value = roomName;
    selectedSection.value = null;
    selectedSectionId.value = null;
    selectedSubjectId.value = null; // <-- مهم
    subjects.clear();
  }

  void onSectionChanged(String? sectionName) {
    selectedSection.value = sectionName;
    selectedSubjectId.value = null; // <-- مهم
    subjects.clear();
    selectedSectionId.value = null;

    if (selectedRoom.value == null || selectedSection.value == null) return;

    final roomMap = rooms[selectedRoom.value];
    if (roomMap != null && roomMap[selectedSection.value] != null) {
      final sectionMap = Map<String, dynamic>.from(roomMap[selectedSection.value]);

      // تحميل المواد مع إزالة التكرارات وتوحيد النوع إلى int
      if (sectionMap['subjects'] != null) {
        final list = List.from(sectionMap['subjects']);
        final seen = <int>{};
        final cleaned = <Map<String, dynamic>>[];

        for (final e in list) {
          final m = Map<String, dynamic>.from(e);
          final id = m['id'] is int ? m['id'] as int : int.tryParse('${m['id']}');
          if (id == null) continue;
          if (seen.add(id)) {
            m['id'] = id; // ثبّت النوع
            cleaned.add(m);
          }
        }
        subjects.assignAll(cleaned);
      }

      // استخراج section id كما هو عندك
      int? sid;
      if (sectionMap['id'] != null) {
        sid = int.tryParse(sectionMap['id'].toString());
      } else if (sectionMap['section_id'] != null) {
        sid = int.tryParse(sectionMap['section_id'].toString());
      }
      selectedSectionId.value = sid;
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now.subtract(const Duration(days: 365)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) selectedDate.value = picked;
    _updateTimeField();
  }

  Future<void> pickTime(BuildContext context) async {
    final initial = TimeOfDay.now();
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked != null) selectedTime.value = picked;
    _updateTimeField();
  }

  void _updateTimeField() {
    if (selectedDate.value != null && selectedTime.value != null) {
      final dt = DateTime(
        selectedDate.value!.year,
        selectedDate.value!.month,
        selectedDate.value!.day,
        selectedTime.value!.hour,
        selectedTime.value!.minute,
      );
      final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
      timeController.text = fmt.format(dt);
    }
  }

  String? _buildScheduledAt() {
    if (selectedDate.value == null || selectedTime.value == null) return null;
    final dt = DateTime(
      selectedDate.value!.year,
      selectedDate.value!.month,
      selectedDate.value!.day,
      selectedTime.value!.hour,
      selectedTime.value!.minute,
    );
    final fmt = DateFormat('yyyy-MM-dd HH:mm:ss');
    return fmt.format(dt);
  }

  // إنشاء جدول بث جديد
  Future<void> startScheduledLiveStream(BuildContext context) async {
    int? sectionId = selectedSectionId.value;
    if (sectionId == null) {
      Get.snackbar('خطأ', 'لم يتم اختيار الشعبة أو لا يتوفر معرف رقمي لها.');
      return;
    }

    int? subjectId = selectedSubjectId.value;
    if (subjectId == null && subjects.isNotEmpty) {
      subjectId = subjects.first['id'] is int
          ? subjects.first['id'] as int
          : int.tryParse(subjects.first['id']?.toString() ?? '');
    }

    String? scheduledAt = timeController.text.trim();
    if (scheduledAt.isEmpty) {
      final built = _buildScheduledAt();
      if (built != null) scheduledAt = built;
    }

    if (sectionId == null) {
      Get.snackbar('خطأ', 'معرّف الشعبة (section_id) مفقود أو غير صالح.');
      return;
    }
    if (subjectId == null) {
      Get.snackbar('خطأ', 'اختر مادة (subject_id).');
      return;
    }
    if (scheduledAt == null || scheduledAt.isEmpty) {
      Get.snackbar('خطأ', 'حدد تاريخ ووقت البث (scheduled_at).');
      return;
    }

    final payload = {
      'section_id': sectionId,
      'subject_id': subjectId,
      'scheduled_at': scheduledAt, // e.g. "2025-08-14 09:30:00"
      'duration_minutes': durationMinutes.value,
    };

    final token = storage.token ?? '';
    final requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      isLoading.value = true;

      print('>> Scheduling payload: ${json.encode(payload)}');
      print('>> Headers: $requestHeaders');

      final resp = await http.post(
        Uri.parse('$baseUrl/api/v1/mobile/teacher/call/schedule'),
        headers: requestHeaders,
        body: json.encode(payload),
      );

      print('<< Status: ${resp.statusCode}');
      print('<< Body: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        if (body['status'] == true || body['success'] == true) {
          Get.snackbar('نجاح', body['message'] ?? 'تم جدولة البث');
          await fetchScheduledCalls();
        } else {
          Get.snackbar('خطأ', body['message'] ?? resp.body);
        }
      } else if (resp.statusCode == 422) {
        final body = json.decode(resp.body);
        final msg = body['message'] ?? 'Validation error';
        final errors = body['errors'];
        final errorStr = (errors is Map)
            ? errors.entries.map((e) => '${e.key}: ${e.value}').join('\n')
            : '';
        Get.snackbar('Validation failed', '$msg\n$errorStr');
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Exception scheduling: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch scheduled calls
  final scheduledCalls = <Map<String, dynamic>>[].obs;

  Future<void> fetchScheduledCalls() async {
    try {
      isLoading.value = true;
      final resp = await http.get(
        Uri.parse('$baseUrl/api/v1/mobile/teacher/call/scheduled-calls'),
        headers: headers,
      );
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body['success'] == true && body['data'] != null) {
          final list = List.from(body['data']);
          scheduledCalls.assignAll(
              list.map((e) => Map<String, dynamic>.from(e)).toList());
        } else {
          Get.snackbar('خطأ', body['message'] ?? 'Failed to load scheduled calls');
        }
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  // بدء بث لمكالمة مجدولة موجودة
  bool canStartCall(Map<String, dynamic> scheduled) {
    final s = _parseServerDateTime(scheduled['scheduled_at']);
    if (s == null) return false;
    final now = DateTime.now();
    return now.isAtSameMomentAs(s) || now.isAfter(s);
  }

  Future<void> startScheduledCall(
      Map<String, dynamic> scheduled, BuildContext context) async {
    final id = scheduled['id'];
    if (id == null) {
      Get.snackbar('خطأ', 'لا يوجد معرف للبث المجدول');
      return;
    }

    try {
      isLoading.value = true;
      final resp = await http.post(
        Uri.parse('$baseUrl/api/v1/mobile/teacher/scheduled-call/$id/start'),
        headers: headers,
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        if (body['status'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data']);

          // ✅ التقاط callId من الريسبونس: جرّب 'call_id' ثم 'id'
          final rawCallId = data.containsKey('call_id') ? data['call_id'] : data['id'];
          int? callId = rawCallId is int ? rawCallId : int.tryParse('$rawCallId');

          // قناة البث
          final serverChannel = (data['channel_name'] ?? '').toString().trim();
          final channelName =
              serverChannel.isNotEmpty ? serverChannel : (callId != null ? 'call_$callId' : '');

          // user_id كسلسلة (يتطابق مع توقيع التوكن)
          final String userIdStr = '${data['user_id'] ?? ''}'.trim();

          // التوكن من السيرفر
          final String? zegoToken = _extractZegoToken(data);

          // خزّنه داخل الكنترولر
          currentCallId.value = callId;

          // مرّر كل شيء للواجهة
          Get.to(() => const LivePage(), arguments: {
            'liveID': channelName,
            'isHost': true,
            'userId': userIdStr,
            'callId': callId,
            if (zegoToken != null) 'zegoToken': zegoToken, // << مهم
          });
        } else {
          Get.snackbar('خطأ', body['message'] ?? resp.body);
        }
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> endScheduledCall(int callId) async {
    try {
      final resp = await http.post(
        Uri.parse('$baseUrl/api/v1/mobile/teacher/call/$callId/end'),
        headers: headers,
      );

      print('<< End Call Status: ${resp.statusCode}');
      print('<< End Call Body: ${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        if (body['status'] == true || body['success'] == true) {
          Get.snackbar('تم الإنهاء', body['message'] ?? 'تم إنهاء البث');
        } else {
          Get.snackbar('خطأ', body['message'] ?? resp.body);
        }
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } catch (e) {
      Get.snackbar('Error', e.toString());
      print('Exception end call: $e');
    }
  }
}
