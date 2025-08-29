import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LivePage extends StatelessWidget {
  const LivePage({super.key});

  static const int zegoAppID = 1755363553;
  static const String AppSign = 'd242dabfc0efa6ea523d82b349ae456c5634be4a69a1d286d3aabcf4ede7eb8b';
  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map? ?? {};
    final liveID = (args['liveID'] ?? '').toString();
    final userID = (args['userId'] ?? args['userID'] ?? '').toString();
    final userName = (args['userName'] ?? userID).toString();
    final isHost = args['isHost'] == true;
    final zegoToken = (args['zegoToken'] ?? '').toString(); // ← String غير-null

    final hostConfig = ZegoUIKitPrebuiltLiveStreamingConfig.host()
      ..turnOnCameraWhenJoining = true
      ..turnOnMicrophoneWhenJoining = true;

    final audienceConfig = ZegoUIKitPrebuiltLiveStreamingConfig.audience();

    return Scaffold(
      body: Stack(
        children: [
          ZegoUIKitPrebuiltLiveStreaming(
            appID: zegoAppID,
            appSign: AppSign,
            // token: zegoToken,      // يجب أن يأتي من السيرفر
            userID: userID,
            userName: userName,
            liveID: liveID,
            config: isHost ? hostConfig : audienceConfig,
          ),
          if (isHost)
            Positioned(
              top: 40,
              left: 16,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.55),
                    borderRadius: BorderRadius.circular(8),
                  ),
                
                ),
              ),
            ),
        ],
      ),
    );
  }
}
