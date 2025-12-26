import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_provider.dart';
import '../../health/providers/auto_sync_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('설정'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        children: [
          // 내 프로필 섹션
          _buildProfileSection(context, ref, user),
          const SizedBox(height: AppTheme.spaceLg),

          // 알림 설정
          _buildSection(
            context,
            title: '알림',
            items: [
              _SettingsItem(
                icon: Icons.notifications_outlined,
                title: '알림 설정',
                subtitle: '푸시 알림 및 리마인더 관리',
                onTap: () => context.push('/notification-settings'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // 구독 관리
          _buildSection(
            context,
            title: '구독 관리',
            items: [
              _SettingsItem(
                icon: Icons.card_membership,
                title: '구독 플랜 관리',
                subtitle: _getSubscriptionLabel(user?.subscriptionTier ?? 'free'),
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
                icon: Icons.smart_toy_outlined,
                title: 'AI 주치의 선택',
                subtitle: '건강 상담 시작하기',
                onTap: () => context.push('/characters'),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // 건강 데이터 연동
          _buildHealthDataSection(context, ref),
          const SizedBox(height: AppTheme.spaceLg),

          // 앱 정보
          _buildSection(
            context,
            title: '앱 정보',
            items: [
              _SettingsItem(
                icon: Icons.info_outline,
                title: '버전 정보',
                subtitle: 'v1.0.0',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.description_outlined,
                title: '이용약관',
                subtitle: '서비스 이용약관 확인',
                onTap: () {},
              ),
              _SettingsItem(
                icon: Icons.privacy_tip_outlined,
                title: '개인정보 처리방침',
                subtitle: '개인정보 보호 정책',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spaceLg),

          // 관리자 메뉴 (관리자만 표시)
          _buildAdminSection(context, ref),

          // 로그아웃 버튼
          _buildLogoutButton(context, ref),
          const SizedBox(height: AppTheme.spaceMd),
        ],
      ),
    );
  }

  /// 내 프로필 섹션
  Widget _buildProfileSection(
    BuildContext context,
    WidgetRef ref,
    dynamic user,
  ) {
    // 로컬에 저장된 프로필 이미지 확인
    final profileData = user != null ? ref.watch(profileProvider(user.userId)) : null;
    final localImagePath = profileData?.profileImagePath;
    final hasLocalImage = localImagePath != null && File(localImagePath).existsSync();

    // 이미지 Provider 결정 (로컬 이미지 우선)
    ImageProvider? imageProvider;
    if (hasLocalImage) {
      imageProvider = FileImage(File(localImagePath));
    } else if (user?.profileImageUrl != null) {
      imageProvider = NetworkImage(user!.profileImageUrl!);
    }

    return CustomCard(
      child: InkWell(
        onTap: () => context.push('/profile'),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spaceMd),
          child: Row(
            children: [
              // 프로필 이미지
              CircleAvatar(
                radius: 30,
                backgroundColor: AppTheme.primary.withOpacity(0.2),
                backgroundImage: imageProvider,
                child: imageProvider == null
                    ? Text(
                        user?.name.isNotEmpty == true
                            ? user!.name[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: AppTheme.spaceMd),

              // 사용자 정보
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user?.name ?? '사용자',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '이메일 없음',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: _getSubscriptionColor(user?.subscriptionTier ?? 'free'),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getSubscriptionLabel(user?.subscriptionTier ?? 'free'),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 편집 아이콘
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 건강 데이터 연동 섹션 (자동 동기화 토글 포함)
  Widget _buildHealthDataSection(BuildContext context, WidgetRef ref) {
    final autoSyncSetting = ref.watch(autoSyncSettingProvider);
    final lastSyncTimeAsync = ref.watch(lastSyncTimeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceSm),
          child: Text(
            '건강 데이터 연동',
            style: AppTheme.h3.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceSm),
        CustomCard(
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              // 자동 동기화 토글
              ListTile(
                leading: const Icon(
                  Icons.sync,
                  color: AppTheme.primary,
                ),
                title: const Text('자동 동기화'),
                subtitle: lastSyncTimeAsync.when(
                  data: (lastSync) {
                    if (lastSync == null) {
                      return const Text('앱 시작 시 건강 데이터 자동 동기화');
                    }
                    final timeAgo = _formatTimeAgo(lastSync);
                    return Text('마지막 동기화: $timeAgo');
                  },
                  loading: () => const Text('앱 시작 시 건강 데이터 자동 동기화'),
                  error: (_, __) => const Text('앱 시작 시 건강 데이터 자동 동기화'),
                ),
                trailing: autoSyncSetting.when(
                  data: (enabled) => Switch(
                    value: enabled,
                    onChanged: (value) {
                      ref.read(autoSyncSettingProvider.notifier).setEnabled(value);
                    },
                    activeColor: AppTheme.primary,
                  ),
                  loading: () => const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => Switch(
                    value: true,
                    onChanged: (value) {
                      ref.read(autoSyncSettingProvider.notifier).setEnabled(value);
                    },
                    activeColor: AppTheme.primary,
                  ),
                ),
              ),
              const Divider(height: 1),
              // HealthKit (iOS)
              ListTile(
                leading: const Icon(
                  Icons.health_and_safety,
                  color: AppTheme.primary,
                ),
                title: const Text('HealthKit 동기화 (iOS)'),
                subtitle: const Text('Apple HealthKit 데이터 연동'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/health/healthkit'),
              ),
              const Divider(height: 1),
              // Health Connect (Android)
              ListTile(
                leading: const Icon(
                  Icons.monitor_heart,
                  color: AppTheme.primary,
                ),
                title: const Text('Health Connect (Android)'),
                subtitle: const Text('Google Health Connect 데이터 연동'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/health/health-connect'),
              ),
              const Divider(height: 1),
              // 웨어러블 통합 동기화
              ListTile(
                leading: const Icon(
                  Icons.watch,
                  color: AppTheme.primary,
                ),
                title: const Text('웨어러블 통합 동기화'),
                subtitle: const Text('플랫폼 통합 건강 데이터 관리'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/health/wearable'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// 시간 포맷팅 (예: "5분 전", "2시간 전")
  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return '방금 전';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays == 1) {
      return '어제';
    } else {
      return '${difference.inDays}일 전';
    }
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

  /// 관리자 섹션 (관리자만 표시)
  Widget _buildAdminSection(BuildContext context, WidgetRef ref) {
    final isAdminAsync = ref.watch(isAdminProvider);

    return isAdminAsync.when(
      data: (isAdmin) {
        if (!isAdmin) {
          return const SizedBox.shrink(); // 관리자가 아니면 표시하지 않음
        }
        return Column(
          children: [
            _buildSection(
              context,
              title: '관리자',
              items: [
                _SettingsItem(
                  icon: Icons.admin_panel_settings,
                  title: '관리자 대시보드',
                  subtitle: '회원 및 탈퇴 관리',
                  onTap: () => context.push('/admin'),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceLg),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  /// 로그아웃 버튼
  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return CustomCard(
      padding: EdgeInsets.zero,
      child: ListTile(
        leading: const Icon(
          Icons.logout,
          color: Colors.red,
        ),
        title: const Text(
          '로그아웃',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () => _showLogoutDialog(context, ref),
      ),
    );
  }

  /// 로그아웃 확인 다이얼로그
  Future<void> _showLogoutDialog(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃 하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
      // 로그아웃 후 로그인 페이지로 이동 (router redirect가 자동 처리)
    }
  }

  String _getSubscriptionLabel(String tier) {
    switch (tier) {
      case 'free':
        return '무료';
      case 'basic':
        return '베이직';
      case 'premium':
        return '프리미엄';
      case 'family':
        return '패밀리';
      default:
        return tier;
    }
  }

  Color _getSubscriptionColor(String tier) {
    switch (tier) {
      case 'free':
        return Colors.grey;
      case 'basic':
        return Colors.blue;
      case 'premium':
        return Colors.purple;
      case 'family':
        return Colors.orange;
      default:
        return Colors.grey;
    }
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
