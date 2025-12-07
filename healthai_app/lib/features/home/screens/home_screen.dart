import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../characters/providers/characters_provider.dart';
import '../../family/providers/family_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);
    final familyProfilesAsync = ref.watch(familyProfilesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('음성 AI 건강주치의'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // TODO: 알림 화면 이동
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: 설정 화면 이동
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(charactersProvider);
          ref.invalidate(familyProfilesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            // 웰컴 메시지
            _buildWelcomeSection(context),
            const SizedBox(height: AppTheme.spaceLg),

            // 가족 프로필 섹션
            _buildFamilySection(context, ref, familyProfilesAsync),
            const SizedBox(height: AppTheme.space2xl),

            // AI 캐릭터 섹션
            _buildCharactersSection(context, charactersAsync),
            const SizedBox(height: AppTheme.space2xl),

            // 최근 활동
            _buildRecentActivitySection(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // TODO: 빠른 상담 시작
        },
        icon: const Icon(Icons.mic),
        label: const Text('빠른 상담'),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;

    if (hour < 12) {
      greeting = '좋은 아침이에요 ☀️';
    } else if (hour < 18) {
      greeting = '좋은 오후에요 ☕';
    } else {
      greeting = '좋은 저녁이에요 🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          greeting,
          style: AppTheme.h1,
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          '오늘도 건강한 하루 보내세요',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFamilySection(
    BuildContext context,
    WidgetRef ref,
    AsyncValue profilesAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('가족 프로필', style: AppTheme.h2),
            TextButton(
              onPressed: () {
                // TODO: 가족 프로필 목록 화면
              },
              child: const Text('전체 보기'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        profilesAsync.when(
          data: (profiles) {
            if (profiles.isEmpty) {
              return CustomCard(
                child: Column(
                  children: [
                    const Icon(
                      Icons.people_outline,
                      size: 48,
                      color: AppTheme.textTertiary,
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    Text(
                      '가족 프로필을 추가해보세요',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceMd),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: 프로필 추가
                      },
                      child: const Text('프로필 추가'),
                    ),
                  ],
                ),
              );
            }

            return SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: profiles.length,
                itemBuilder: (context, index) {
                  final profile = profiles[index];
                  return _buildFamilyProfileCard(context, profile);
                },
              ),
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => const ErrorMessage(message: '프로필을 불러올 수 없습니다'),
        ),
      ],
    );
  }

  Widget _buildFamilyProfileCard(BuildContext context, dynamic profile) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppTheme.spaceMd),
      child: Column(
        children: [
          ProfileAvatar(
            imageUrl: profile.profileImageUrl,
            name: profile.name,
            size: 60,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            profile.name,
            style: AppTheme.bodySmall,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCharactersSection(
    BuildContext context,
    AsyncValue charactersAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('AI 건강 주치의', style: AppTheme.h2),
        const SizedBox(height: AppTheme.spaceSm),
        Text(
          '전문 AI 주치의와 상담해보세요',
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        charactersAsync.when(
          data: (characters) {
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.85,
                crossAxisSpacing: AppTheme.spaceMd,
                mainAxisSpacing: AppTheme.spaceMd,
              ),
              itemCount: characters.length,
              itemBuilder: (context, index) {
                final character = characters[index];
                return _buildCharacterCard(context, character);
              },
            );
          },
          loading: () => const Center(child: LoadingIndicator()),
          error: (e, _) => const ErrorMessage(message: 'AI 주치의를 불러올 수 없습니다'),
        ),
      ],
    );
  }

  Widget _buildCharacterCard(BuildContext context, dynamic character) {
    return CustomCard(
      onTap: () {
        // TODO: AI 대화 화면 이동
      },
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ProfileAvatar(
            imageUrl: character.profileImageUrl,
            name: character.name,
            size: 48,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            character.name,
            style: AppTheme.h3,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Text(
            character.specialty,
            style: AppTheme.caption,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(
                Icons.star,
                size: 14,
                color: AppTheme.warning,
              ),
              const SizedBox(width: 2),
              Text(
                '${character.experienceYears}년 경력',
                style: AppTheme.caption,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('최근 활동', style: AppTheme.h2),
        const SizedBox(height: AppTheme.spaceMd),
        CustomCard(
          padding: EdgeInsets.zero,
          child: ListTile(
            leading: const Icon(Icons.chat_bubble_outline),
            title: const Text('박지훈 주치의와 상담'),
            subtitle: const Text('어제 오후 3:24'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: 대화 내역 보기
            },
          ),
        ),
      ],
    );
  }
}
