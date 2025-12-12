import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../characters/providers/characters_provider.dart';
import '../../family/providers/family_provider.dart';
import '../../routine/providers/routine_provider.dart';
import '../widgets/stat_card.dart';

/// 홈 화면 (대시보드) - UI/UX 가이드 v1.2 기반
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final charactersAsync = ref.watch(charactersProvider);
    // familyProfilesAsync는 나중에 가족 프로필 섹션에서 사용 예정
    ref.watch(familyProfilesProvider);
    final completionRate = ref.watch(routineCompletionRateProvider);
    final completedCount = ref.watch(completedRoutineCountProvider);
    final routineAsync = ref.watch(todayRoutineProvider);

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
              context.push('/settings');
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(charactersProvider);
          ref.invalidate(familyProfilesProvider);
          ref.invalidate(todayRoutineProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(AppTheme.spaceLg),
          children: [
            // 웰컴 메시지
            _buildWelcomeSection(context),
            const SizedBox(height: AppTheme.spaceLg),

            // 통계 카드 (2x2 그리드)
            _buildStatCardsSection(
              context,
              ref,
              completionRate,
              completedCount,
              routineAsync,
            ),
            const SizedBox(height: AppTheme.spaceXl),

            // 최근 상담
            _buildRecentConsultationSection(context),
            const SizedBox(height: AppTheme.spaceXl),

            // 건강 목표
            _buildHealthGoalsSection(context, routineAsync),
            const SizedBox(height: AppTheme.spaceXl),

            // AI 캐릭터 섹션
            _buildCharactersSection(context, charactersAsync),
            const SizedBox(height: AppTheme.space2xl),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.push('/characters');
        },
        child: const Icon(Icons.mic),
      ),
    );
  }

  Widget _buildWelcomeSection(BuildContext context) {
    final hour = DateTime.now().hour;
    String greeting;
    String emoji;

    if (hour < 12) {
      greeting = '좋은 아침이에요';
      emoji = '👋';
    } else if (hour < 18) {
      greeting = '좋은 오후에요';
      emoji = '☀️';
    } else {
      greeting = '좋은 저녁이에요';
      emoji = '🌙';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              '안녕하세요, 지영님',
              style: AppTheme.h2,
            ),
            const SizedBox(width: 4),
            Text(emoji, style: const TextStyle(fontSize: 20)),
          ],
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          greeting,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// 통계 카드 섹션 (2x2 그리드)
  Widget _buildStatCardsSection(
    BuildContext context,
    WidgetRef ref,
    double completionRate,
    int completedCount,
    AsyncValue routineAsync,
  ) {
    final totalCount = routineAsync.maybeWhen(
      data: (routine) => routine.items.length,
      orElse: () => 8,
    );
    final percentage = (completionRate * 100).toInt();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '루틴',
                value: '$completedCount/$totalCount',
                changeText: '$percentage%',
                isPositive: percentage >= 50,
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.primary,
                onTap: () => context.push('/routine'),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: StatCard(
                title: '걸음수',
                value: '8,234',
                changeText: '▲ 5%',
                isPositive: true,
                icon: Icons.directions_walk,
                iconColor: AppTheme.success,
                onTap: () => context.push('/health/wearable'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: '수면',
                value: '7.5h',
                subtitle: '양호',
                icon: Icons.bedtime_outlined,
                iconColor: Colors.indigo,
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: StatCard(
                title: '심박수',
                value: '72',
                subtitle: 'bpm · 정상',
                icon: Icons.favorite_outline,
                iconColor: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// 최근 상담 섹션
  Widget _buildRecentConsultationSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('최근 상담', style: AppTheme.h3),
            TextButton(
              onPressed: () {
                // TODO: 전체 상담 내역
              },
              child: const Text('더보기 >'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        _buildRecentConsultationCard(
          name: '박지훈',
          specialty: '내과',
          time: '2시간 전',
          preview: '혈압 관리 방법에 대해...',
          onTap: () {},
        ),
        _buildRecentConsultationCard(
          name: '최현우',
          specialty: '정신건강',
          time: '어제',
          preview: '스트레스 관리 팁...',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildRecentConsultationCard({
    required String name,
    required String specialty,
    required String time,
    required String preview,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        dense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMd,
          vertical: AppTheme.spaceXs,
        ),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: AppTheme.primary.withOpacity(0.1),
          child: const Icon(Icons.person, size: 20, color: AppTheme.primary),
        ),
        title: Row(
          children: [
            Text('$name · ', style: AppTheme.bodyMedium),
            Text(
              time,
              style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
            ),
          ],
        ),
        subtitle: Text(
          preview,
          style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: const Icon(Icons.chevron_right, size: 20),
        onTap: onTap,
      ),
    );
  }

  /// 건강 목표 섹션
  Widget _buildHealthGoalsSection(
    BuildContext context,
    AsyncValue routineAsync,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('건강 목표', style: AppTheme.h3),
        const SizedBox(height: AppTheme.spaceMd),
        _buildGoalProgressCard(
          title: '만보 걷기',
          emoji: '🎯',
          current: 8234,
          target: 10000,
          unit: '걸음',
        ),
        const SizedBox(height: AppTheme.spaceSm),
        _buildGoalProgressCard(
          title: '물 2L 마시기',
          emoji: '💧',
          current: 1.2,
          target: 2.0,
          unit: 'L',
        ),
      ],
    );
  }

  Widget _buildGoalProgressCard({
    required String title,
    required String emoji,
    required num current,
    required num target,
    required String unit,
  }) {
    final progress = (current / target).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppTheme.spaceSm),
              Text(title, style: AppTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppTheme.spaceSm),
          // 프로그레스 바
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(3),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      width: constraints.maxWidth * progress,
                      height: 6,
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: AppTheme.spaceXs),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$current / $target $unit',
                style: AppTheme.caption,
              ),
              Text(
                '$percentage%',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('AI 건강 주치의', style: AppTheme.h3),
            TextButton(
              onPressed: () => context.push('/characters'),
              child: const Text('전체 보기 >'),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceSm),
        charactersAsync.when(
          data: (characters) {
            // 6개 캐릭터 모두 표시 (3x2 그리드)
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.85,
                crossAxisSpacing: AppTheme.spaceSm,
                mainAxisSpacing: AppTheme.spaceSm,
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
    return GestureDetector(
      onTap: () {
        final displayName = '${character.name} ${character.specialty}';
        context.push(
          '/voice-conversation/${character.id}?name=${Uri.encodeComponent(displayName)}',
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceSm),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: AppTheme.shadowSm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.primary.withOpacity(0.1),
              child: Text(
                character.name.substring(0, 1),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceXs),
            Text(
              character.name,
              style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              character.specialty,
              style: AppTheme.caption.copyWith(fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.star, size: 10, color: AppTheme.warning),
                const SizedBox(width: 2),
                Text(
                  '${character.experienceYears}년',
                  style: AppTheme.caption.copyWith(fontSize: 9),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
