import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'healthkit_sync_screen.dart';
import 'health_connect_sync_screen.dart';

/// 플랫폼별 웨어러블 동기화 화면
/// iOS: HealthKit
/// Android: Health Connect
class WearableSyncScreen extends StatelessWidget {
  const WearableSyncScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 플랫폼별 화면 분기
    if (Platform.isIOS) {
      return const HealthKitSyncScreen();
    } else if (Platform.isAndroid) {
      return const HealthConnectSyncScreen();
    } else {
      return Scaffold(
        appBar: AppBar(title: const Text('웨어러블 동기화')),
        body: const Center(
          child: Text('지원하지 않는 플랫폼입니다'),
        ),
      );
    }
  }
}
