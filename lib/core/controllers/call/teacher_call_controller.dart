import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:school_mangmante/views/stream/LivePage.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';
import 'package:intl/intl.dart';

import 'package:school_mangmante/core/service/storage_service.dart';

// ------------------------------
// LiveController (GetX)
// ------------------------------
class LiveController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final baseUrl = 'http://137.184.50.2';

  // Raw rooms data from the students API
  final rooms = <String, dynamic>{}
      .obs; // e.g. {"Primary Room 1": {"A": {..}, "B": {...}}}

  // UI selections
  final selectedRoom = RxnString();
  final selectedSection = RxnString();
  final subjects = <Map<String, dynamic>>[].obs;
  final selectedSubjectId = RxnInt();
  final selectedSectionId = RxnInt();

  // optional numeric section id (API often expects numeric IDs). We'll fill it automatically if present in the API.
  // final sectionIdController = TextEditingController();

  // schedule fields
  final selectedDate = Rxn<DateTime>();
  final selectedTime = Rxn<TimeOfDay>();
  final durationMinutes = 60.obs;

  // misc
  final isLoading = false.obs;
  final liveIdController =
      TextEditingController(); // manual live id field (keeps compatibility with existing UI)
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

  Future<void> fetchRooms() async {
    try {
      isLoading.value = true;
      final resp = await http.get(
          Uri.parse('$baseUrl/api/v1/mobile/teacher/students'),
          headers: headers);
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
    subjects.clear();
    // sectionIdController = '';
  }

  void onSectionChanged(String? sectionName) {
  selectedSection.value = sectionName;
  subjects.clear();
  selectedSectionId.value = null; // reset

  if (selectedRoom.value == null || selectedSection.value == null) return;

  final roomMap = rooms[selectedRoom.value];
  if (roomMap != null && roomMap[selectedSection.value] != null) {
    final sectionMap = Map<String, dynamic>.from(roomMap[selectedSection.value]);

    // load subjects
    if (sectionMap['subjects'] != null) {
      final list = List.from(sectionMap['subjects']);
      subjects.assignAll(list.map((e) => Map<String, dynamic>.from(e)).toList());
    }

    // extract numeric section id if present in the API payload
    int? sid;
    if (sectionMap['id'] != null) {
      sid = int.tryParse(sectionMap['id'].toString());
    } else if (sectionMap['section_id'] != null) {
      sid = int.tryParse(sectionMap['section_id'].toString());
    }

    selectedSectionId.value = sid;
    // optional: print for debug
    print('>> selected section id for $sectionName = $sid');
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

  Future<void> startScheduledLiveStream(BuildContext context) async {
    // Ensure we have section id, subject id, scheduled_at and headers
int? sectionId = selectedSectionId.value;
if (sectionId == null) {
  Get.snackbar('خطأ', 'لم يتم اختيار الشعبة أو لا يتوفر معرف رقمي لها.');
  return;
}
    // Try numeric from input first
    // if (sectionIdText.isNotEmpty) {
    //   sectionId = int.tryParse(sectionIdText);
    // }

    // If still null, try to extract from rooms map if user selected a room+section
    if (sectionId == null &&
        selectedRoom.value != null &&
        selectedSection.value != null) {
      try {
        final roomMap = rooms[selectedRoom.value];
        if (roomMap != null && roomMap[selectedSection.value] != null) {
          final sectionMap =
              Map<String, dynamic>.from(roomMap[selectedSection.value]);
          if (sectionMap['id'] != null)
            sectionId = int.tryParse(sectionMap['id'].toString());
          if (sectionId == null && sectionMap['section_id'] != null) {
            sectionId = int.tryParse(sectionMap['section_id'].toString());
          }
        }
      } catch (e) {
        // ignore parsing errors here
      }
    }

    // Subject id
    int? subjectId = selectedSubjectId.value;
    if (subjectId == null && subjects.isNotEmpty) {
      // fallback: maybe pick first subject (or force user to choose)
      subjectId = subjects.first['id'] is int
          ? subjects.first['id'] as int
          : int.tryParse(subjects.first['id']?.toString() ?? '');
    }

    // scheduled_at: try timeController then build from selectedDate/selectedTime
    String? scheduledAt = timeController.text.trim();
    if (scheduledAt.isEmpty) {
      final built =
          _buildScheduledAt(); // ensure you have this helper in controller
      if (built != null) scheduledAt = built;
    }

    // Validation before sending
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

    // Ensure headers include content-type
    final token = storage.token ?? '';
    final requestHeaders = {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    try {
      isLoading.value = true;

      // Debug: print request so you can see exactly what is sent
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
          // optionally refresh scheduled calls
          await fetchScheduledCalls();
        } else {
          Get.snackbar('خطأ', body['message'] ?? resp.body);
        }
      } else if (resp.statusCode == 422) {
        // Show server validation errors to user
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
          headers: headers);
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        if (body['success'] == true && body['data'] != null) {
          final list = List.from(body['data']);
          scheduledCalls.assignAll(
              list.map((e) => Map<String, dynamic>.from(e)).toList());
        } else {
          Get.snackbar(
              'خطأ', body['message'] ?? 'Failed to load scheduled calls');
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

  // existing private parser
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

  // public wrapper so other files can call it
  DateTime? parseServerDateTime(String? value) => _parseServerDateTime(value);

  // DateTime? _parseServerDateTime(String? value) {
  //   if (value == null) return null;
  //   try {
  //     // server format: "2025-08-19 09:30:00"
  //     final safe = value.replaceFirst(' ', 'T');
  //     return DateTime.parse(safe);
  //   } catch (_) {
  //     try {
  //       return DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
  //     } catch (e) {
  //       return null;
  //     }
  //   }
  // }

  bool canStartCall(Map<String, dynamic> scheduled) {
    final s = _parseServerDateTime(scheduled['scheduled_at']);
    if (s == null) return false;
    return DateTime.now().isAtSameMomentAs(s) || DateTime.now().isAfter(s);
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
          headers: headers);
      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        if (body['status'] == true && body['data'] != null) {
          final data = Map<String, dynamic>.from(body['data']);
          final channelName = data['channel_name']?.toString() ??
              scheduled['channel_name']?.toString();
          final userId = data['user_id'] ?? 0;

          // Navigate to live page as host
          Get.to(() => LivePage(), arguments: {
            'liveID': channelName,
            'isHost': true,
            'userId': userId
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
}
