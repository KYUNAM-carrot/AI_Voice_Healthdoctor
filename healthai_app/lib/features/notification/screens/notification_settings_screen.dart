import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/notification_provider.dart';
import '../providers/notification_schedule_provider.dart';
import '../services/notification_schedule_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  @override
  void initState() {
    super.initState();
    // 알림 스케줄 설정 로드
    Future.microtask(() {
      ref.read(notificationScheduleProvider.notifier).loadSettings();
    });
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);
    final scheduleSettings = ref.watch(notificationScheduleProvider);
    final scheduleNotifier = ref.read(notificationScheduleProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // FCM 토큰 상태
          _buildTokenStatusCard(),
          const SizedBox(height: AppTheme.spaceLg),

          // 알림 시간 설정 섹션
          const Text('알림 시간 설정', style: AppTheme.h3),
          const SizedBox(height: AppTheme.spaceMd),

          // 아침 건강루틴 알림
          _buildScheduleCard(
            icon: Icons.wb_sunny,
            iconColor: Colors.orange,
            title: '아침 건강루틴 알림',
            subtitle: '아침 루틴을 체크할 시간을 알려드려요',
            enabled: scheduleSettings.morningRoutineEnabled,
            time: scheduleSettings.morningRoutineTime,
            timeFormatted: scheduleSettings.morningRoutineTimeFormatted,
            onEnabledChanged: (value) {
              scheduleNotifier.setMorningRoutineEnabled(value);
            },
            onTimeTap: () => _showTimePicker(
              context,
              scheduleSettings.morningRoutineTime,
              (time) => scheduleNotifier.setMorningRoutineTime(time),
            ),
          ),

          const SizedBox(height: AppTheme.spaceMd),

          // 감사일기 알림
          _buildScheduleCard(
            icon: Icons.nightlight_round,
            iconColor: Colors.indigo,
            title: '감사일기 알림',
            subtitle: '오늘 감사했던 일을 기록할 시간이에요',
            enabled: scheduleSettings.gratitudeJournalEnabled,
            time: scheduleSettings.gratitudeJournalTime,
            timeFormatted: scheduleSettings.gratitudeJournalTimeFormatted,
            onEnabledChanged: (value) {
              scheduleNotifier.setGratitudeJournalEnabled(value);
            },
            onTimeTap: () => _showTimePicker(
              context,
              scheduleSettings.gratitudeJournalTime,
              (time) => scheduleNotifier.setGratitudeJournalTime(time),
            ),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 알림 카테고리
          const Text('알림 카테고리', style: AppTheme.h3),
          const SizedBox(height: AppTheme.spaceMd),

          // 루틴 리마인더
          _buildSwitchTile(
            title: '루틴 리마인더',
            subtitle: '아침 루틴, 감사일기 작성 알림',
            icon: Icons.alarm,
            value: settings.routineReminders,
            onChanged: (value) => settingsNotifier.toggleRoutineReminders(value),
          ),

          // 건강 알림
          _buildSwitchTile(
            title: '건강 알림',
            subtitle: '건강 지표 이상, 복약 리마인더',
            icon: Icons.favorite,
            value: settings.healthAlerts,
            onChanged: (value) => settingsNotifier.toggleHealthAlerts(value),
          ),

          // 상담 알림
          _buildSwitchTile(
            title: '상담 알림',
            subtitle: 'AI 상담 관련 알림',
            icon: Icons.chat_bubble,
            value: settings.conversationNotifications,
            onChanged: (value) =>
                settingsNotifier.toggleConversationNotifications(value),
          ),

          // 마케팅 알림
          _buildSwitchTile(
            title: '마케팅 알림',
            subtitle: '이벤트, 프로모션 정보',
            icon: Icons.campaign,
            value: settings.marketingNotifications,
            onChanged: (value) =>
                settingsNotifier.toggleMarketingNotifications(value),
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 테스트 알림 버튼
          const Text('알림 테스트', style: AppTheme.h3),
          const SizedBox(height: AppTheme.spaceMd),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendTestNotification(
                    title: '🌅 좋은 아침이에요!',
                    body: '오늘의 아침 건강루틴을 체크해보세요.',
                    type: 'morning_routine',
                  ),
                  icon: const Icon(Icons.wb_sunny, size: 18),
                  label: const Text('아침루틴'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _sendTestNotification(
                    title: '🌙 오늘 하루도 수고했어요',
                    body: '오늘 감사했던 일 3가지를 기록해보세요.',
                    type: 'gratitude_journal',
                  ),
                  icon: const Icon(Icons.nightlight_round, size: 18),
                  label: const Text('감사일기'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppTheme.spaceLg),

          // 안내 문구
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        '설정한 시간이 이미 지났다면 다음 날 해당 시간에 알림이 전송됩니다.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spaceSm),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Expanded(
                      child: Text(
                        '알림을 완전히 끄려면 기기의 설정에서 앱 알림을 비활성화해주세요.',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStatusCard() {
    final fcmTokenAsync = ref.watch(fcmTokenProvider);

    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                fcmTokenAsync.hasValue && fcmTokenAsync.value != null
                    ? Icons.check_circle
                    : Icons.error_outline,
                color: fcmTokenAsync.hasValue && fcmTokenAsync.value != null
                    ? AppTheme.success
                    : AppTheme.warning,
              ),
              const SizedBox(width: AppTheme.spaceSm),
              Text(
                fcmTokenAsync.hasValue && fcmTokenAsync.value != null
                    ? '푸시 알림 활성화됨'
                    : '푸시 알림 설정 필요',
                style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          if (fcmTokenAsync.hasValue && fcmTokenAsync.value != null) ...[
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              '디바이스가 푸시 알림을 수신할 준비가 되었습니다.',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return CustomCard(
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Row(
          children: [
            Icon(icon, color: AppTheme.primary),
            const SizedBox(width: AppTheme.spaceSm),
            Text(title, style: AppTheme.bodyLarge),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(left: 32),
          child: Text(
            subtitle,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
      ),
    );
  }

  /// 알림 시간 설정 카드
  Widget _buildScheduleCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool enabled,
    required TimeOfDay time,
    required String timeFormatted,
    required ValueChanged<bool> onEnabledChanged,
    required VoidCallback onTimeTap,
  }) {
    return CustomCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더: 아이콘, 제목, 토글
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: AppTheme.spaceMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: onEnabledChanged,
                activeColor: AppTheme.primary,
              ),
            ],
          ),

          // 시간 선택 버튼 (활성화 시에만 표시)
          if (enabled) ...[
            const SizedBox(height: AppTheme.spaceMd),
            const Divider(height: 1),
            const SizedBox(height: AppTheme.spaceMd),
            InkWell(
              onTap: onTimeTap,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spaceSm),
                    Text(
                      '알림 시간',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      timeFormatted,
                      style: AppTheme.bodyLarge.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.chevron_right,
                      color: AppTheme.textSecondary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// 시간 선택 다이얼로그
  Future<void> _showTimePicker(
    BuildContext context,
    TimeOfDay initialTime,
    ValueChanged<TimeOfDay> onTimeSelected,
  ) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: AppTheme.textPrimary,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onTimeSelected(picked);
    }
  }

  /// 테스트 알림 즉시 전송
  Future<void> _sendTestNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    final pushService = ref.read(pushNotificationServiceProvider);

    try {
      // 5초 후 알림 (즉시 알림 테스트)
      final scheduledTime = DateTime.now().add(const Duration(seconds: 5));

      await pushService.scheduleRoutineReminder(
        id: type == 'morning_routine' ? 9001 : 9002, // 테스트용 ID
        title: title,
        body: body,
        scheduledTime: scheduledTime,
        payload: '{"type": "$type", "test": true}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('5초 후에 "$title" 알림이 전송됩니다'),
            backgroundColor: AppTheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('Test notification error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('알림 전송 실패: $e'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }
}
