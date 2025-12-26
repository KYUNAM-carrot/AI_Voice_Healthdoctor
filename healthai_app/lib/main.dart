import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'core/router/app_router.dart';
import 'core/services/push_notification_service.dart';
import 'features/notification/services/notification_schedule_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 한국어 날짜 포맷팅 초기화
  await initializeDateFormatting('ko_KR', null);

  // Firebase 초기화
  await Firebase.initializeApp();

  // 푸시 알림 서비스 초기화
  final pushService = PushNotificationService();
  await pushService.initialize();

  // 저장된 알림 스케줄 설정 로드 및 재스케줄링
  await _rescheduleNotifications(pushService);

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

/// 저장된 알림 설정에 따라 알림 재스케줄링
/// 앱 시작 시 및 기기 재부팅 후 호출됨
Future<void> _rescheduleNotifications(PushNotificationService pushService) async {
  try {
    final scheduleService = NotificationScheduleService();
    final settings = await scheduleService.loadSettings();

    debugPrint('Rescheduling notifications on app start...');
    debugPrint('Morning routine: enabled=${settings.morningRoutineEnabled}, time=${settings.morningRoutineHour}:${settings.morningRoutineMinute}');
    debugPrint('Gratitude journal: enabled=${settings.gratitudeJournalEnabled}, time=${settings.gratitudeJournalHour}:${settings.gratitudeJournalMinute}');

    // 아침루틴 알림 스케줄링
    if (settings.morningRoutineEnabled) {
      await pushService.scheduleMorningRoutineNotification(
        hour: settings.morningRoutineHour,
        minute: settings.morningRoutineMinute,
      );
    } else {
      await pushService.cancelMorningRoutineNotification();
    }

    // 감사일기 알림 스케줄링
    if (settings.gratitudeJournalEnabled) {
      await pushService.scheduleGratitudeJournalNotification(
        hour: settings.gratitudeJournalHour,
        minute: settings.gratitudeJournalMinute,
      );
    } else {
      await pushService.cancelGratitudeJournalNotification();
    }

    debugPrint('Notifications rescheduled successfully');
  } catch (e) {
    debugPrint('Error rescheduling notifications: $e');
  }
}
