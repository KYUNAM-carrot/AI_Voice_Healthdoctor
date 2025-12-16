import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../providers/notification_provider.dart';

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(notificationSettingsProvider);
    final settingsNotifier = ref.read(notificationSettingsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('알림 설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        children: [
          // FCM 토큰 상태
          _buildTokenStatusCard(ref),
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

          // 안내 문구
          Container(
            padding: const EdgeInsets.all(AppTheme.spaceMd),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Row(
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
          ),
        ],
      ),
    );
  }

  Widget _buildTokenStatusCard(WidgetRef ref) {
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
}
