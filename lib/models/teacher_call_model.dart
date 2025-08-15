class CallModel {
  final bool status;
  final String message;
  final CallData? data;

  CallModel({
    required this.status,
    required this.message,
    this.data,
  });

  factory CallModel.fromJson(Map<String, dynamic> json) {
    return CallModel(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? CallData.fromJson(json['data']) : null,
    );
  }
}

class CallData {
  final int callId;
  final String channelName;
  final String token;

  CallData({
    required this.callId,
    required this.channelName,
    required this.token,
  });

  factory CallData.fromJson(Map<String, dynamic> json) {
    return CallData(
      callId: json['call_id'] ?? 0,
      channelName: json['channel_name'] ?? '',
      token: json['token'] ?? '',
    );
  }
}
