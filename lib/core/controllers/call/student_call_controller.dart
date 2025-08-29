import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:school_mangmante/core/service/storage_service.dart';
import 'package:school_mangmante/views/stream/LivePage.dart';

class StudentCallController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final baseUrl = 'http://137.184.50.2';

  // UI state
  final isLoading = false.obs;
  final scheduledCalls = <Map<String, dynamic>>[].obs;
  final currentCallId = RxnInt();

  // volatile cache per session (نحاول أيضًا حفظه دائمًا في التخزين)
  String? _lastZegoUserId;
  String? _lastUserName;

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
    // استرجع أي قيم مخزنة سابقًا
    try {
      _lastZegoUserId = _pickNonEmpty(_storageRead('lastZegoUserId'));
      _lastUserName   = _pickNonEmpty(_storageRead('lastUserName'));
    } catch (_) {}
    fetchScheduledCallsForStudent();
  }

  // ---------------- Storage helpers (تعامل عام لأننا لا نعرف API التخزين لديك) ----------------
  dynamic _storageRead(String key) {
    try {
      // غطّي أكثر من نمط: get / read
      if ((storage as dynamic).get != null) {
        return (storage as dynamic).get(key);
      }
    } catch (_) {}
    try {
      if ((storage as dynamic).read != null) {
        return (storage as dynamic).read(key);
      }
    } catch (_) {}
    return null;
  }

  void _storageWrite(String key, dynamic value) {
    try {
      if ((storage as dynamic).set != null) {
        (storage as dynamic).set(key, value);
        return;
      }
    } catch (_) {}
    try {
      if ((storage as dynamic).write != null) {
        (storage as dynamic).write(key, value);
        return;
      }
    } catch (_) {}
  }

  // ---------------- Generic helpers ----------------
  String? _pickNonEmpty(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    return s.isEmpty ? null : s;
  }

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
    if (dt == null) return d!;
    return DateFormat('yyyy-MM-dd HH:mm').format(dt);
  }

  bool canJoinCall(Map<String, dynamic> item) {
    final status = (item['status'] ?? '').toString().toLowerCase();
    final hasCallId = item['call_id'] != null;
    // الانضمام فقط عندما بدأ الأستاذ فعليًا
    return (status == 'started') && hasCallId;
  }

  // لا تغيّر شكل الـ liveID إطلاقًا
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
      final s = _pickNonEmpty(v);
      if (s != null) return s;
    }
    return null;
  }

  bool _isAlreadyInCallMessage(dynamic msg) {
    final s = (msg ?? '').toString().toLowerCase();
    return s.contains('already in the call') || s.contains('بالفعل في المكالمة');
  }

  // يلتقط userId بأي تسمية وعلى أي مستوى
  String? _extractUserIdFlexible(Map<String, dynamic> d) {
    for (final k in [
      'zego_user_id','zegoUserId','zegoUserID',
      'user_id','userId','uid','id',
    ]) {
      final v = _pickNonEmpty(d[k]);
      if (v != null) return v;
    }
    final user = d['user'];
    if (user is Map) {
      for (final k in ['id','user_id','userId','uid','zego_user_id','zegoUserId']) {
        final v = _pickNonEmpty(user[k]);
        if (v != null) return v;
      }
    }
    return null;
  }

  String? _extractUserNameFlexible(Map<String, dynamic> d) {
    for (final k in ['user_name','username','name','userName']) {
      final v = _pickNonEmpty(d[k]);
      if (v != null) return v;
    }
    final user = d['user'];
    if (user is Map) {
      for (final k in ['user_name','username','name','userName']) {
        final v = _pickNonEmpty(user[k]);
        if (v != null) return v;
      }
    }
    return null;
  }

  // حاول استخراج userId من الـ JWT إن كان الـ token على شكل JWT
  String? _extractUserIdFromJwt(String? bearer) {
    if (bearer == null) return null;
    final parts = bearer.split(' ');
    final raw = parts.length == 2 ? parts[1] : parts[0];
    if (!raw.contains('.')) return null; // ليس JWT
    try {
      final payloadB64 = raw.split('.')[1];
      // padding
      String norm(String s) {
        final m = s.length % 4;
        return m == 0 ? s : s + '=' * (4 - m);
      }
      final jsonStr = utf8.decode(base64Url.decode(norm(payloadB64)));
      final map = json.decode(jsonStr);
      final candidates = [
        'sub','user_id','userId','uid','id'
      ];
      for (final k in candidates) {
        final v = _pickNonEmpty(map[k]);
        if (v != null) return v;
      }
    } catch (_) {}
    return null;
  }

  // حاول استخراج userId من بروفايل مخزن محليًا
  String? _extractUserIdFromLocalProfile() {
    final candidates = ['profile','user','account','me'];
    for (final c in candidates) {
      final p = _storageRead(c);
      if (p is Map) {
        for (final k in ['id','user_id','userId','uid']) {
          final v = _pickNonEmpty(p[k]);
          if (v != null) return v;
        }
      }
    }
    for (final k in ['student_id','studentId','user_id','userId','uid','id','zego_uid','zegoUserId','lastZegoUserId']) {
      final v = _pickNonEmpty(_storageRead(k));
      if (v != null) return v;
    }
    return null;
  }

  String? _bestEffortUserId(Map<String, dynamic> data) {
    return _extractUserIdFlexible(data)
        ?? _lastZegoUserId
        ?? _pickNonEmpty(_storageRead('lastZegoUserId'))
        ?? _extractUserIdFromLocalProfile()
        ?? _extractUserIdFromJwt(storage.token);
  }

  // ---------------- API ----------------
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

  /// لا نفتح صفحة البث إلا بعد تأكيد الانضمام من السيرفر.
  Future<void> joinCall(Map<String, dynamic> item) async {
    if (!canJoinCall(item)) {
      Get.snackbar('غير متاح', 'البث لم يبدأ بعد أو المعرف غير صالح.');
      return;
    }

    final rawId = item['call_id'];
    final int? callId = (rawId is int) ? rawId : int.tryParse('$rawId');
    if (callId == null) {
      Get.snackbar('فشل التحقق','call_id غير متوفر بعد. حدّث الصفحة أو اطلب من الأستاذ بدء البث.');
      return;
    }

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

        debugPrint('JOIN keys: ${data.keys}');
        if (data['user'] is Map) {
          debugPrint('JOIN user keys: ${(data['user'] as Map).keys}');
        }

        // server channel_name (بدون تعديل)
        final serverChannel = _pickNonEmpty(data['channel_name']);
        if (serverChannel != null) {
          liveID = serverChannel;
        }

        final alreadyInCall = _isAlreadyInCallMessage(message);

        // اجلب userId بأفضل جهد (يغطي حالة already-in-call بلا بيانات)
        final String? userID = _bestEffortUserId(data);
        final String? userNameStr =
            _extractUserNameFlexible(data) ??
            _pickNonEmpty(_storageRead('lastUserName')) ??
            _pickNonEmpty(_storageRead('username')) ??
            _pickNonEmpty(_storageRead('name'));

        // التوكن قد لا يأتي في already-in-call
        final zegoToken = _extractZegoToken(data);

        // في حالة already-in-call قد لا يكون success=true لكن نسمح بالمتابعة
        final canProceed = success || alreadyInCall;

        if (!canProceed) {
          final msg = (message?.toString().trim().isNotEmpty ?? false)
              ? message.toString()
              : 'تعذر الانضمام للبث.';
          Get.snackbar('فشل الانضمام', msg);
          return;
        }

        if (userID == null || userID.isEmpty) {
          // هذه الحالة تحدث عندما يعيد السيرفر فقط (call_id, channel_name)
          // وليس لدينا أي أثر محلي/JWT يدل على userId.
          Get.snackbar(
            'userID مفقود',
            'الخادم لا يعيد user_id في حالة "already in the call"، '
            'ولم أجد معرف المستخدم محليًا/في التوكن. '
            'يلزم أن يعيده الخادم أو نخزّنه محليًا بعد أول انضمام ناجح.',
            duration: const Duration(seconds: 6),
          );
          return;
        }

        // خزّن آخر قيم معروفة للاحتياط بالجلسات القادمة
        _lastZegoUserId = userID;
        _storageWrite('lastZegoUserId', userID);
        if (userNameStr != null) {
          _lastUserName = userNameStr;
          _storageWrite('lastUserName', userNameStr);
        }

        currentCallId.value = callId;

        await Get.to(
          () => const LivePage(),
          arguments: <String, dynamic>{
            'liveID': liveID,
            'isHost': false,
            'callId': callId,
            'userId': userID.trim(),
            if (userNameStr != null && userNameStr.isNotEmpty) 'userName': userNameStr,
            if (zegoToken != null) 'zegoToken': zegoToken,
            'alreadyInCall': alreadyInCall,
          },
        );
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
