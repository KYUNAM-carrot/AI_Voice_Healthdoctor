import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('설정 및 화면 테스트'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        children: [
          // 구독 관리
          _buildSection(
            context,
            title: '구독 관리',
            items: [
              _SettingsItem(
                icon: Icons.card_membership,
                title: '구독 플랜 관리',
                subtitle: 'RevenueCat 구독 화면',
                onTap: () => context.push('/subscription'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // 가족 및 AI 상담
          _buildSection(
            context,
            title: '가족 및 AI 상담',
            items: [
              _SettingsItem(
                icon: Icons.family_restroom,
                title: '가족 프로필',
                subtitle: '가족 구성원 관리',
                onTap: () => context.push('/families'),
              ),
              _SettingsItem(
                icon: Icons.chat_bubble_outline,
                title: 'AI 상담 (최현우 의사)',
                subtitle: '의사와 건강 상담',
                onTap: () => context.push('/conversation/choi_hyunwoo'),
              ),
              _SettingsItem(
                icon: Icons.psychology_outlined,
                title: 'AI 상담 (정유진 상담사)',
                subtitle: '정신건강 상담',
                onTap: () => context.push('/conversation/jung_yujin'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // 건강 데이터 연동
          _buildSection(
            context,
            title: '건강 데이터 연동',
            items: [
              _SettingsItem(
                icon: Icons.health_and_safety,
                title: 'HealthKit 동기화 (iOS)',
                subtitle: 'Apple HealthKit 데이터 연동',
                onTap: () => context.push('/health/healthkit'),
              ),
              _SettingsItem(
                icon: Icons.monitor_heart,
                title: 'Health Connect (Android)',
                subtitle: 'Google Health Connect 데이터 연동',
                onTap: () => context.push('/health/health-connect'),
              ),
              _SettingsItem(
                icon: Icons.watch,
                title: '웨어러블 통합 동기화',
                subtitle: '플랫폼 통합 건강 데이터 관리',
                onTap: () => context.push('/health/wearable'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // 앱 정보
          _buildSection(
            context,
            title: '앱 정보',
            items: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: '버전 정보',
                subtitle: 'v1.0.0 (Day 43-52 구현)',
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required List<_SettingsItem> items,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
          child: Text(
            title,
            style: AppTheme.h3.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return Column(
                children: [
                  if (index > 0) const Divider(height: 1),
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: AppTheme.primary,
                    ),
                    title: Text(item.title),
                    subtitle: item.subtitle != null
                        ? Text(item.subtitle!)
                        : null,
                    trailing: const Icon(Icons.chevron_right),
                    onTap: item.onTap,
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _SettingsItem {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  _SettingsItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });
}
