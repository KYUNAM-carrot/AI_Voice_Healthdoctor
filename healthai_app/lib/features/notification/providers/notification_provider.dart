import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/push_notification_service.dart';
import '../../../core/api/api_client.dart';

/// 푸시 알림 서비스 Provider
final pushNotificationServiceProvider = Provider<PushNotificationService>((ref) {
  return PushNotificationService();
});

/// FCM 토큰 Provider
final fcmTokenProvider = FutureProvider<String?>((ref) async {
  final service = ref.watch(pushNotificationServiceProvider);
  return service.fcmToken;
});

/// 알림 설정 상태
class NotificationSettings {
  final bool routineReminders;
  final bool healthAlerts;
  final bool conversationNotifications;
  final bool marketingNotifications;

  const NotificationSettings({
    this.routineReminders = true,
    this.healthAlerts = true,
    this.conversationNotifications = true,
    this.marketingNotifications = false,
  });

  NotificationSettings copyWith({
    bool? routineReminders,
    bool? healthAlerts,
    bool? conversationNotifications,
    bool? marketingNotifications,
  }) {
    return NotificationSettings(
      routineReminders: routineReminders ?? this.routineReminders,
      healthAlerts: healthAlerts ?? this.healthAlerts,
      conversationNotifications:
          conversationNotifications ?? this.conversationNotifications,
      marketingNotifications:
          marketingNotifications ?? this.marketingNotifications,
    );
  }
}

/// 알림 설정 Notifier
class NotificationSettingsNotifier extends StateNotifier<NotificationSettings> {
  final PushNotificationService _service;

  NotificationSettingsNotifier(this._service)
      : super(const NotificationSettings());

  /// 루틴 리마인더 토글
  Future<void> toggleRoutineReminders(bool enabled) async {
    state = state.copyWith(routineReminders: enabled);
    if (enabled) {
      await _service.subscribeToTopic('routine_reminders');
    } else {
      await _service.unsubscribeFromTopic('routine_reminders');
    }
  }

  /// 건강 알림 토글
  Future<void> toggleHealthAlerts(bool enabled) async {
    state = state.copyWith(healthAlerts: enabled);
    if (enabled) {
      await _service.subscribeToTopic('health_alerts');
    } else {
      await _service.unsubscribeFromTopic('health_alerts');
    }
  }

  /// 상담 알림 토글
  Future<void> toggleConversationNotifications(bool enabled) async {
    state = state.copyWith(conversationNotifications: enabled);
    if (enabled) {
      await _service.subscribeToTopic('conversations');
    } else {
      await _service.unsubscribeFromTopic('conversations');
    }
  }

  /// 마케팅 알림 토글
  Future<void> toggleMarketingNotifications(bool enabled) async {
    state = state.copyWith(marketingNotifications: enabled);
    if (enabled) {
      await _service.subscribeToTopic('marketing');
    } else {
      await _service.unsubscribeFromTopic('marketing');
    }
  }
}

/// 알림 설정 Provider
final notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsNotifier, NotificationSettings>(
        (ref) {
  final service = ref.watch(pushNotificationServiceProvider);
  return NotificationSettingsNotifier(service);
});

/// FCM 토큰을 서버에 등록하는 Provider
final registerFcmTokenProvider = FutureProvider.autoDispose<bool>((ref) async {
  final service = ref.watch(pushNotificationServiceProvider);
  final apiClient = ref.watch(apiClientProvider);
  final token = service.fcmToken;

  if (token == null) return false;

  try {
    await apiClient.post('/api/v1/users/fcm-token', data: {
      'token': token,
      'platform': _getPlatform(),
    });
    return true;
  } catch (e) {
    return false;
  }
});

String _getPlatform() {
  // Platform detection without dart:io import issues
  return 'unknown';
}
