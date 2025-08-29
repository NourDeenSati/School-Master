import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/views/stream/LivePage.dart';

class StudentCallController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final baseUrl = 'http://137.184.50.2';

  // حالة الواجهة
  final isLoading = false.obs;
  final scheduledCalls = <Map<String, dynamic>>[].obs;
  final currentCallId = RxnInt();

  Map<String, String> get headers {
    final token = storage.token ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Map<String, String> get jsonHeaders {
    final token = storage.token ?? '';
    return {
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  @override
  void onInit() {
    super.onInit();
    fetchScheduledCallsForStudent();
  }

  // --- Helpers ---
  DateTime? _parseServerDateTime(String? value) {
    if (value == null) return null;
    try {
      final safe = value.replaceFirst(' ', 'T');
      return DateTime.parse(safe);
    } catch (_) {
      try {
        return DateFormat('yyyy-MM-dd HH:mm:ss').parse(value);
      } catch (_) {
        return null;
      }
    }
  }

  String formatDate(String? d) {
    if (d == null) return '';
    final dt = _parseServerDateTime(d);
    if (dt == null) return d;
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  bool canJoinCall(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    final hasCallId = item['call_id'] != null;
    // الانضمام فقط عندما بدأ الأستاذ فعليًا
    return (status == 'started') && hasCallId;
  }

  // لا تغيّر شكل الـ liveID إطلاقًا (حتى لا يحدث عدم تطابق مع الطرف الآخر)
  String _liveIdExact(String? channelName, int callId) {
    final s = (channelName ?? '').toString().trim();
    return s.isEmpty ? 'call_$callId' : s;
  }

  String? _extractZegoToken(Map<String, dynamic> data) {
    for (final k in [
      'token',
      'zego_token',
      'room_token',
      'roomToken',
      'zegoToken',
    ]) {
      final v = data[k];
      if (v != null && v.toString().trim().isNotEmpty) {
        return v.toString().trim();
      }
    }
    return null;
  }

  bool _isAlreadyInCallMessage(dynamic msg) {
    final s = (msg ?? '').toString().toLowerCase();
    return s.contains('already in the call') || s.contains('بالفعل في المكالمة');
  }

  // --- API: جلب البثوث المتاحة للطالب ---
  Future<void> fetchScheduledCallsForStudent() async {
    try {
      isLoading.value = true;
      final resp = await http.get(
        Uri.parse('$baseUrl/api/v1/mobile/student/call/scheduled-calls'),
        headers: headers,
      );
      if (resp.statusCode == 200) {
        final body = json.decode(resp.body);
        final ok = (body['success'] == true) || (body['status'] == true);
        if (ok && body['data'] != null) {
          final list = List.from(body['data']);
          scheduledCalls.assignAll(
            list.map((e) => Map<String, dynamic>.from(e as Map)).toList(),
          );
        } else {
          Get.snackbar('خطأ', body['message']?.toString() ?? 'تعذر التحميل');
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

  /// يمنع فتح صفحة البث قبل التأكّد من نجاح الانضمام على السيرفر،
  /// ويمرّر userID/userName من السيرفر كما هي (تطابق توقيع التوكن).
  Future<void> joinCall(Map<String, dynamic> item) async {
    if (!canJoinCall(item)) {
      Get.snackbar('غير متاح', 'البث لم يبدأ بعد أو المعرف غير صالح.');
      return;
    }

    final rawId = item['call_id'];
    final int? callId = (rawId is int) ? rawId : int.tryParse('$rawId');
    if (callId == null) {
      Get.snackbar(
        'فشل التحقق',
        'call_id غير متوفر بعد. حدّث الصفحة أو اطلب من الأستاذ بدء البث.',
      );
      return;
    }

    // لا نبدّل أي حرف في liveID
    String liveID = _liveIdExact(item['channel_name'], callId);

    isLoading.value = true;
    try {
      final uri = Uri.parse('$baseUrl/api/v1/mobile/student/call/join');
      final reqBody = json.encode({'call_id': callId});

      final resp = await http
          .post(uri, headers: jsonHeaders, body: reqBody)
          .timeout(const Duration(seconds: 12));

      debugPrint('[joinCall] status=${resp.statusCode}');
      debugPrint('[joinCall] body=${resp.body}');

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final body = json.decode(resp.body);
        final success = (body['success'] == true) || (body['status'] == true);
        final message = body['message'];
        final data = Map<String, dynamic>.from(body['data'] ?? {});

        // استخدم channel_name من السيرفر لو وُجد (بدون تعديل)
        final serverChannel = (data['channel_name'] ?? '').toString().trim();
        if (serverChannel.isNotEmpty) {
          liveID = serverChannel;
        }

        // ⚠️ أهم شيء: userID/userName كما تم التوقيع لهما في السيرفر
        final String? zegoUserIdStr = (data['zego_user_id'] as String?)?.trim();
        final int? userIdInt = (data['user_id'] is int)
            ? data['user_id'] as int
            : int.tryParse('${data['user_id'] ?? ''}');
        final String userNameStr =
            (data['user_name'] ?? data['username'] ?? '').toString().trim();

        // حدّد userID النهائي كسلسلة *بدون* تعديل
        final String? userID = zegoUserIdStr ??
            (userIdInt?.toString()) ??
            (userNameStr.isNotEmpty ? userNameStr : null);

        if (userID == null || userID.isEmpty) {
          Get.snackbar('فشل الانضمام', 'userID من السيرفر مفقود.');
          return;
        }

        // استخرج التوكن
        final zegoToken = _extractZegoToken(data);
        if (zegoToken == null || zegoToken.isEmpty) {
          // في حالة "already in call" قد لا يرجع التوكن؛ اسمح بالدخول
          final alreadyInCall = _isAlreadyInCallMessage(message);
          if (!success && !alreadyInCall) {
            Get.snackbar('فشل الانضمام', 'لم نستلم Zego Token من الخادم.');
            return;
          }
        }

        final alreadyInCall = _isAlreadyInCallMessage(message);

        if (success || alreadyInCall) {
          currentCallId.value = callId;

          await Get.to(
            () => const LivePage(),
            arguments: <String, dynamic>{
              'liveID': liveID,
              'isHost': false,
              'callId': callId,
              'userId': userID, // <<<<<< مهم جدًا
              if (userNameStr.isNotEmpty) 'userName': userNameStr,
              if (zegoToken != null) 'zegoToken': zegoToken,
              'alreadyInCall': alreadyInCall,
            },
          );
        } else {
          final msg = (message?.toString().trim().isNotEmpty ?? false)
              ? message.toString()
              : 'تعذر الانضمام للبث.';
          Get.snackbar('فشل الانضمام', msg);
        }
      } else {
        Get.snackbar('HTTP ${resp.statusCode}', resp.body);
      }
    } on TimeoutException {
      Get.snackbar('انتهت المهلة', 'الشبكة بطيئة أو الخدمة لا تستجيب حالياً.');
    } catch (e) {
      Get.snackbar('Error', e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
