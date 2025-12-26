import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/notification_schedule_service.dart';
import 'notification_provider.dart';

/// NotificationScheduleService Provider
final notificationScheduleServiceProvider =
    Provider<NotificationScheduleService>((ref) {
  return NotificationScheduleService();
});

/// 알림 스케줄 설정 StateNotifier
class NotificationScheduleNotifier
    extends StateNotifier<NotificationScheduleSettings> {
  final NotificationScheduleService _scheduleService;
  final PushNotificationService _pushService;

  NotificationScheduleNotifier(this._scheduleService, this._pushService)
      : super(const NotificationScheduleSettings());

  /// 설정 로드
  Future<void> loadSettings() async {
    state = await _scheduleService.loadSettings();
    debugPrint('Notification settings loaded: morning=${state.morningRoutineEnabled}, gratitude=${state.gratitudeJournalEnabled}');
  }

  /// 아침루틴 알림 활성화/비활성화
  Future<void> setMorningRoutineEnabled(bool enabled) async {
    state = state.copyWith(morningRoutineEnabled: enabled);
    await _scheduleService.setMorningRoutineEnabled(enabled);

    if (enabled) {
      await _pushService.scheduleMorningRoutineNotification(
        hour: state.morningRoutineHour,
        minute: state.morningRoutineMinute,
      );
    } else {
      await _pushService.cancelMorningRoutineNotification();
    }
  }

  /// 아침루틴 알림 시간 변경
  Future<void> setMorningRoutineTime(TimeOfDay time) async {
    state = state.copyWith(
      morningRoutineHour: time.hour,
      morningRoutineMinute: time.minute,
    );
    await _scheduleService.setMorningRoutineTime(time.hour, time.minute);

    if (state.morningRoutineEnabled) {
      await _pushService.scheduleMorningRoutineNotification(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  /// 감사일기 알림 활성화/비활성화
  Future<void> setGratitudeJournalEnabled(bool enabled) async {
    state = state.copyWith(gratitudeJournalEnabled: enabled);
    await _scheduleService.setGratitudeJournalEnabled(enabled);

    if (enabled) {
      await _pushService.scheduleGratitudeJournalNotification(
        hour: state.gratitudeJournalHour,
        minute: state.gratitudeJournalMinute,
      );
    } else {
      await _pushService.cancelGratitudeJournalNotification();
    }
  }

  /// 감사일기 알림 시간 변경
  Future<void> setGratitudeJournalTime(TimeOfDay time) async {
    state = state.copyWith(
      gratitudeJournalHour: time.hour,
      gratitudeJournalMinute: time.minute,
    );
    await _scheduleService.setGratitudeJournalTime(time.hour, time.minute);

    if (state.gratitudeJournalEnabled) {
      await _pushService.scheduleGratitudeJournalNotification(
        hour: time.hour,
        minute: time.minute,
      );
    }
  }

  /// 모든 알림 재스케줄 (앱 시작 시 호출)
  Future<void> rescheduleAllNotifications() async {
    debugPrint('Rescheduling all notifications...');

    if (state.morningRoutineEnabled) {
      await _pushService.scheduleMorningRoutineNotification(
        hour: state.morningRoutineHour,
        minute: state.morningRoutineMinute,
      );
    }

    if (state.gratitudeJournalEnabled) {
      await _pushService.scheduleGratitudeJournalNotification(
        hour: state.gratitudeJournalHour,
        minute: state.gratitudeJournalMinute,
      );
    }

    debugPrint('All notifications rescheduled');
  }
}

/// 알림 스케줄 StateNotifierProvider
final notificationScheduleProvider = StateNotifierProvider<
    NotificationScheduleNotifier, NotificationScheduleSettings>((ref) {
  final scheduleService = ref.watch(notificationScheduleServiceProvider);
  final pushService = ref.watch(pushNotificationServiceProvider);
  return NotificationScheduleNotifier(scheduleService, pushService);
});
