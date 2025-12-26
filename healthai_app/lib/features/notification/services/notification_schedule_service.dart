import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 알림 스케줄 설정 모델
class NotificationScheduleSettings {
  final bool morningRoutineEnabled;
  final int morningRoutineHour;
  final int morningRoutineMinute;
  final bool gratitudeJournalEnabled;
  final int gratitudeJournalHour;
  final int gratitudeJournalMinute;

  const NotificationScheduleSettings({
    this.morningRoutineEnabled = true,
    this.morningRoutineHour = 7,
    this.morningRoutineMinute = 0,
    this.gratitudeJournalEnabled = true,
    this.gratitudeJournalHour = 21,
    this.gratitudeJournalMinute = 0,
  });

  TimeOfDay get morningRoutineTime => TimeOfDay(
        hour: morningRoutineHour,
        minute: morningRoutineMinute,
      );

  TimeOfDay get gratitudeJournalTime => TimeOfDay(
        hour: gratitudeJournalHour,
        minute: gratitudeJournalMinute,
      );

  NotificationScheduleSettings copyWith({
    bool? morningRoutineEnabled,
    int? morningRoutineHour,
    int? morningRoutineMinute,
    bool? gratitudeJournalEnabled,
    int? gratitudeJournalHour,
    int? gratitudeJournalMinute,
  }) {
    return NotificationScheduleSettings(
      morningRoutineEnabled:
          morningRoutineEnabled ?? this.morningRoutineEnabled,
      morningRoutineHour: morningRoutineHour ?? this.morningRoutineHour,
      morningRoutineMinute: morningRoutineMinute ?? this.morningRoutineMinute,
      gratitudeJournalEnabled:
          gratitudeJournalEnabled ?? this.gratitudeJournalEnabled,
      gratitudeJournalHour: gratitudeJournalHour ?? this.gratitudeJournalHour,
      gratitudeJournalMinute:
          gratitudeJournalMinute ?? this.gratitudeJournalMinute,
    );
  }

  /// 시간 포맷팅 (예: 오전 7:00, 오후 9:00)
  String formatTime(TimeOfDay time) {
    final hour = time.hour;
    final minute = time.minute;
    final period = hour < 12 ? '오전' : '오후';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$period $displayHour:$displayMinute';
  }

  String get morningRoutineTimeFormatted => formatTime(morningRoutineTime);
  String get gratitudeJournalTimeFormatted => formatTime(gratitudeJournalTime);
}

/// 알림 스케줄 저장/로드 서비스
class NotificationScheduleService {
  static const String _keyMorningRoutineEnabled = 'morning_routine_notification_enabled';
  static const String _keyMorningRoutineHour = 'morning_routine_notification_hour';
  static const String _keyMorningRoutineMinute = 'morning_routine_notification_minute';
  static const String _keyGratitudeJournalEnabled = 'gratitude_journal_notification_enabled';
  static const String _keyGratitudeJournalHour = 'gratitude_journal_notification_hour';
  static const String _keyGratitudeJournalMinute = 'gratitude_journal_notification_minute';

  /// 알림 설정 로드
  Future<NotificationScheduleSettings> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      return NotificationScheduleSettings(
        morningRoutineEnabled: prefs.getBool(_keyMorningRoutineEnabled) ?? true,
        morningRoutineHour: prefs.getInt(_keyMorningRoutineHour) ?? 7,
        morningRoutineMinute: prefs.getInt(_keyMorningRoutineMinute) ?? 0,
        gratitudeJournalEnabled:
            prefs.getBool(_keyGratitudeJournalEnabled) ?? true,
        gratitudeJournalHour: prefs.getInt(_keyGratitudeJournalHour) ?? 21,
        gratitudeJournalMinute: prefs.getInt(_keyGratitudeJournalMinute) ?? 0,
      );
    } catch (e) {
      debugPrint('Error loading notification settings: $e');
      return const NotificationScheduleSettings();
    }
  }

  /// 알림 설정 저장
  Future<void> saveSettings(NotificationScheduleSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setBool(
          _keyMorningRoutineEnabled, settings.morningRoutineEnabled);
      await prefs.setInt(_keyMorningRoutineHour, settings.morningRoutineHour);
      await prefs.setInt(
          _keyMorningRoutineMinute, settings.morningRoutineMinute);
      await prefs.setBool(
          _keyGratitudeJournalEnabled, settings.gratitudeJournalEnabled);
      await prefs.setInt(
          _keyGratitudeJournalHour, settings.gratitudeJournalHour);
      await prefs.setInt(
          _keyGratitudeJournalMinute, settings.gratitudeJournalMinute);

      debugPrint('Notification settings saved successfully');
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  /// 아침루틴 알림 활성화 상태 저장
  Future<void> setMorningRoutineEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMorningRoutineEnabled, enabled);
  }

  /// 아침루틴 알림 시간 저장
  Future<void> setMorningRoutineTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyMorningRoutineHour, hour);
    await prefs.setInt(_keyMorningRoutineMinute, minute);
  }

  /// 감사일기 알림 활성화 상태 저장
  Future<void> setGratitudeJournalEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyGratitudeJournalEnabled, enabled);
  }

  /// 감사일기 알림 시간 저장
  Future<void> setGratitudeJournalTime(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyGratitudeJournalHour, hour);
    await prefs.setInt(_keyGratitudeJournalMinute, minute);
  }
}
