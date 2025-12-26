import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';
import '../router/app_router.dart';

/// 백그라운드 메시지 핸들러 (top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Background message: ${message.messageId}');
}

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  // 알림 ID 상수
  static const int morningRoutineNotificationId = 1001;
  static const int gratitudeJournalNotificationId = 1002;

  // 알림 채널 설정 (Android)
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'healthai_high_importance',
    'HealthAI 알림',
    description: '건강 알림 및 루틴 리마인더',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
  );

  /// Timezone 초기화
  Future<void> initializeTimezone() async {
    tz_data.initializeTimeZones();
    try {
      final String timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName));
      debugPrint('Timezone initialized: $timeZoneName');
    } catch (e) {
      debugPrint('Error initializing timezone: $e');
      // 기본값으로 Asia/Seoul 사용
      tz.setLocalLocation(tz.getLocation('Asia/Seoul'));
    }
  }

  /// 푸시 알림 초기화
  Future<void> initialize() async {
    // 0. Timezone 초기화
    await initializeTimezone();

    // 1. 권한 요청
    await _requestPermission();

    // 2. 로컬 알림 초기화
    await _initLocalNotifications();

    // 3. FCM 토큰 가져오기
    await _getToken();

    // 4. 토큰 갱신 리스너
    _messaging.onTokenRefresh.listen((token) {
      _fcmToken = token;
      debugPrint('FCM Token refreshed: $token');
      _sendTokenToServer(token);
    });

    // 5. 포그라운드 메시지 핸들러
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // 6. 앱 실행 시 알림 클릭 처리
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // 7. 종료 상태에서 알림 클릭으로 앱 실행 시 처리
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  /// 권한 요청
  Future<bool> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: true,
      carPlay: false,
      criticalAlert: false,
    );

    final isAuthorized =
        settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional;

    debugPrint('Push notification permission: ${settings.authorizationStatus}');
    return isAuthorized;
  }

  /// 로컬 알림 초기화
  Future<void> _initLocalNotifications() async {
    // Android 초기화 설정
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS 초기화 설정
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Android 알림 채널 생성 및 권한 요청
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlugin != null) {
        // 알림 채널 생성
        await androidPlugin.createNotificationChannel(_channel);

        // Android 12+ 에서 정확한 알림 스케줄링 권한 요청
        final exactAlarmGranted = await androidPlugin.requestExactAlarmsPermission();
        debugPrint('Exact alarm permission granted: $exactAlarmGranted');

        // 알림 권한 요청 (Android 13+)
        final notificationGranted = await androidPlugin.requestNotificationsPermission();
        debugPrint('Notification permission granted: $notificationGranted');
      }
    }
  }

  /// FCM 토큰 가져오기
  Future<String?> _getToken() async {
    try {
      _fcmToken = await _messaging.getToken();
      debugPrint('FCM Token: $_fcmToken');

      if (_fcmToken != null) {
        await _sendTokenToServer(_fcmToken!);
      }
      return _fcmToken;
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  /// 서버에 FCM 토큰 전송
  Future<void> _sendTokenToServer(String token) async {
    // TODO: 백엔드 API로 토큰 전송
    // 이 토큰을 사용하여 서버에서 특정 사용자에게 푸시 알림 전송 가능
    debugPrint('Sending FCM token to server: $token');
  }

  /// 포그라운드 메시지 처리
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    debugPrint('Foreground message: ${message.notification?.title}');

    final notification = message.notification;
    final android = message.notification?.android;

    // 포그라운드에서 알림 표시
    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channel.id,
            _channel.name,
            channelDescription: _channel.description,
            icon: android?.smallIcon ?? '@mipmap/ic_launcher',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );
    }
  }

  /// 알림 클릭 처리 (FCM)
  void _handleNotificationTap(RemoteMessage message) {
    debugPrint('Notification tapped: ${message.data}');
    _processNotificationData(message.data);
  }

  /// 알림 클릭 처리 (로컬)
  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Local notification tapped: ${response.payload}');
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _processNotificationData(data);
      } catch (e) {
        debugPrint('Error parsing notification payload: $e');
      }
    }
  }

  /// 알림 데이터 처리 및 화면 이동
  void _processNotificationData(Map<String, dynamic> data) {
    final type = data['type'] as String?;
    final targetId = data['target_id'] as String?;

    debugPrint('Processing notification: type=$type, targetId=$targetId');

    // GoRouter를 통해 화면 이동
    final router = globalRouter;
    if (router == null) {
      debugPrint('Router not available yet');
      return;
    }

    // 목표 경로 결정
    String? targetPath;
    switch (type) {
      case 'morning_routine':
        debugPrint('Navigating to morning routine screen');
        targetPath = '/routine';
        break;
      case 'gratitude_journal':
        debugPrint('Navigating to gratitude diary screen');
        targetPath = '/gratitude';
        break;
      case 'routine_reminder':
        debugPrint('Navigate to routine: $targetId');
        targetPath = '/routine';
        break;
      case 'health_alert':
        debugPrint('Navigate to health alert: $targetId');
        targetPath = null; // 홈으로만 이동
        break;
      case 'conversation':
        debugPrint('Navigate to conversation: $targetId');
        targetPath = '/characters';
        break;
      default:
        debugPrint('Navigate to home');
        targetPath = null; // 홈으로만 이동
    }

    // 홈 화면을 기본으로 설정하고, 목표 화면을 스택에 추가
    // 이렇게 하면 뒤로 가기 시 홈 화면으로 돌아감
    router.go('/home');
    if (targetPath != null) {
      // 약간의 지연 후 push하여 홈 화면이 먼저 로드되도록 함
      Future.delayed(const Duration(milliseconds: 100), () {
        router.push(targetPath!);
      });
    }
  }

  /// 특정 토픽 구독
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  /// 토픽 구독 해제
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    debugPrint('Unsubscribed from topic: $topic');
  }

  /// 다음 스케줄 시간 계산 (매일 반복)
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // 이미 지난 시간이면 다음 날로 설정
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    return scheduledDate;
  }

  /// 아침 건강루틴 알림 스케줄링
  Future<void> scheduleMorningRoutineNotification({
    required int hour,
    required int minute,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);
    debugPrint('Scheduling morning routine notification at: $scheduledTime');

    await _localNotifications.zonedSchedule(
      morningRoutineNotificationId,
      '🌅 좋은 아침이에요!',
      '오늘의 아침 건강루틴을 체크해보세요.',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
      payload: jsonEncode({'type': 'morning_routine'}),
    );

    debugPrint('Morning routine notification scheduled successfully');
  }

  /// 감사일기 알림 스케줄링
  Future<void> scheduleGratitudeJournalNotification({
    required int hour,
    required int minute,
  }) async {
    final scheduledTime = _nextInstanceOfTime(hour, minute);
    debugPrint('Scheduling gratitude journal notification at: $scheduledTime');

    await _localNotifications.zonedSchedule(
      gratitudeJournalNotificationId,
      '🌙 오늘 하루도 수고했어요',
      '오늘 감사했던 일 3가지를 기록해보세요.',
      scheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time, // 매일 반복
      payload: jsonEncode({'type': 'gratitude_journal'}),
    );

    debugPrint('Gratitude journal notification scheduled successfully');
  }

  /// 아침루틴 알림 취소
  Future<void> cancelMorningRoutineNotification() async {
    await _localNotifications.cancel(morningRoutineNotificationId);
    debugPrint('Morning routine notification cancelled');
  }

  /// 감사일기 알림 취소
  Future<void> cancelGratitudeJournalNotification() async {
    await _localNotifications.cancel(gratitudeJournalNotificationId);
    debugPrint('Gratitude journal notification cancelled');
  }

  /// 로컬 알림 스케줄링 (루틴 리마인더용 - 레거시)
  Future<void> scheduleRoutineReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
    String? payload,
  }) async {
    final tzScheduledTime = tz.TZDateTime.from(scheduledTime, tz.local);

    await _localNotifications.zonedSchedule(
      id,
      title,
      body,
      tzScheduledTime,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  /// 모든 예약된 알림 취소
  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// 특정 알림 취소
  Future<void> cancelNotification(int id) async {
    await _localNotifications.cancel(id);
  }
}
