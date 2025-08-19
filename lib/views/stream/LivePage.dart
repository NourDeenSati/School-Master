import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final String liveID = args['liveID']?.toString() ?? '';
    final bool isHost = args['isHost'] == true;
    final int userId = args['userId'] ?? 0;

    final config = isHost ? ZegoUIKitPrebuiltLiveStreamingConfig.host() : ZegoUIKitPrebuiltLiveStreamingConfig.audience();

    if (isHost) {
      config.turnOnCameraWhenJoining = true;
      config.turnOnMicrophoneWhenJoining = true;
    }

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveStreaming(
        appID: 193940000,
        appSign: '2bf3b657d36911d853156cb0d442fc6e59e46aecaa4918c5bf3362a1ec258847',
        userID: userId.toString(),
        userName: 'user_name${userId}',
        liveID: liveID,
        config: config,
      ),
    );
  }
}