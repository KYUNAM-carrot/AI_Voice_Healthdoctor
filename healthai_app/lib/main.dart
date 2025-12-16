import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 날짜 포맷팅 초기화
  await initializeDateFormatting('ko_KR', null);

  // Firebase 초기화
  await Firebase.initializeApp();

  // 푸시 알림 서비스 초기화
  await PushNotificationService().initialize();

  // 카카오 SDK 초기화
  // TODO: 카카오 개발자 콘솔에서 앱 키를 발급받아 교체하세요
  // https://developers.kakao.com/console/app
  KakaoSdk.init(
    nativeAppKey: 'b7b7f5e24a7994d43a45a88ce35ad39d',  // 네이티브 앱 키
    javaScriptAppKey: 'f39492ec6ca9e9bec63ae80348263c3a',  // JavaScript 키 (웹용)
  );

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Voice AI Health Doctor',
      theme: AppTheme.lightTheme,
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}
