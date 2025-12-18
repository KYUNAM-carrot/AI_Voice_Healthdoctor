import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common_widgets.dart';
import '../../../core/services/conversation_history_service.dart';
import '../../characters/providers/characters_provider.dart';
import '../../family/providers/family_provider.dart';
import '../../family/widgets/family_profile_selector.dart';
import '../../routine/providers/routine_provider.dart';
import '../../auth/providers/auth_provider.dart';

/// 홈 화면 - 세계 최고 수준의 음성 건강상담 앱
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  List<ConversationHistory> _recentHistories = [];
  bool _isLoadingHistories = true;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // AI 주치의 자동 스크롤
  final ScrollController _doctorScrollController = ScrollController();
  late Timer _autoScrollTimer;
  int _currentDoctorIndex = 0;
  int _totalDoctors = 0;
  static const double _cardWidth = 108.0; // 카드 너비 + 간격

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRecentHistories();

    // 펄스 애니메이션 (음성 상담 버튼용)
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // AI 주치의 자동 스크롤 타이머 (3초 간격)
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      _autoScrollDoctors();
    });

    // 수동 스크롤 감지
    _doctorScrollController.addListener(_onDoctorScroll);
  }

  void _onDoctorScroll() {
    if (!_doctorScrollController.hasClients) return;
    final offset = _doctorScrollController.offset;
    final newIndex = (offset / _cardWidth).round().clamp(0, (_totalDoctors - 3).clamp(0, _totalDoctors));
    if (newIndex != _currentDoctorIndex) {
      setState(() {
        _currentDoctorIndex = newIndex;
      });
    }
  }

  void _autoScrollDoctors() {
    if (_totalDoctors <= 3 || !_doctorScrollController.hasClients) return;

    int nextIndex = _currentDoctorIndex + 1;
    // 마지막 3개가 보이면 처음으로 돌아감
    if (nextIndex > _totalDoctors - 3) {
      nextIndex = 0;
    }

    setState(() {
      _currentDoctorIndex = nextIndex;
    });

    final targetOffset = nextIndex * _cardWidth;
    _doctorScrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pulseController.dispose();
    _autoScrollTimer.cancel();
    _doctorScrollController.removeListener(_onDoctorScroll);
    _doctorScrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // 앱이 다시 활성화될 때 최근 상담 목록 갱신
    if (state == AppLifecycleState.resumed) {
      _loadRecentHistories();
    }
  }

  Future<void> _loadRecentHistories() async {
    final histories = await ConversationHistoryService.getRecentHistories(limit: 3);
    if (mounted) {
      setState(() {
        _recentHistories = histories;
        _isLoadingHistories = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final charactersAsync = ref.watch(charactersProvider);
    ref.watch(familyProfilesProvider);
    final completionRate = ref.watch(routineCompletionRateProvider);
    final completedCount = ref.watch(completedRoutineCountProvider);
    final routineAsync = ref.watch(todayRoutineProvider);
    final currentUser = ref.watch(currentUserProvider);
    final userName = currentUser?.name ?? '사용자';

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: AppTheme.background,
        body: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(charactersProvider);
            ref.invalidate(familyProfilesProvider);
            ref.invalidate(todayRoutineProvider);
            await _loadRecentHistories();
          },
          child: CustomScrollView(
            slivers: [
              // 커스텀 앱바 with 그라데이션 헤더
              _buildSliverAppBar(context, userName),

              // 콘텐츠
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppTheme.spaceLg),

                      // 음성 상담 히어로 카드
                      _buildVoiceConsultationHero(context),
                      const SizedBox(height: AppTheme.spaceXl),

                      // 빠른 액션 그리드
                      _buildQuickActions(context),
                      const SizedBox(height: AppTheme.spaceXl),

                      // 건강 대시보드
                      _buildHealthDashboard(
                        context, completionRate, completedCount, routineAsync,
                      ),
                      const SizedBox(height: AppTheme.spaceXl),

                      // AI 주치의 슬라이더
                      _buildAIDoctorsSection(context, charactersAsync),
                      const SizedBox(height: AppTheme.spaceXl),

                      // 최근 상담
                      _buildRecentConsultations(context),
                      const SizedBox(height: AppTheme.space3xl),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, String userName) {
    final hour = DateTime.now().hour;
    String greeting = hour < 12 ? '좋은 아침이에요 ☀️' : hour < 18 ? '좋은 오후에요 🌤️' : '좋은 저녁이에요 🌙';

    return SliverAppBar(
      expandedHeight: 145,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          // 스크롤에 따른 투명도 계산
          final expandRatio = ((constraints.maxHeight - kToolbarHeight) /
                  (145 - kToolbarHeight))
              .clamp(0.0, 1.0);

          return FlexibleSpaceBar(
            titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
            title: AnimatedOpacity(
              opacity: expandRatio < 0.5 ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: const Text(
                'AI 건강주치의',
                style: TextStyle(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 17,
                ),
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
              ),
              child: SafeArea(
                child: AnimatedOpacity(
                  opacity: expandRatio,
                  duration: const Duration(milliseconds: 200),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 앱 타이틀
                        Row(
                          children: [
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: const Text(
                                'AI 건강주치의',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // 인사말
                        Text(
                          greeting,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              '안녕하세요 ',
                              style: AppTheme.h2.copyWith(fontSize: 18),
                            ),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  AppTheme.primaryGradient.createShader(bounds),
                              child: Text(
                                '$userName님 😊',
                                style: AppTheme.h2.copyWith(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              boxShadow: AppTheme.shadowSm,
            ),
            child: const Icon(Icons.notifications_outlined, size: 20),
          ),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              boxShadow: AppTheme.shadowSm,
            ),
            child: const Icon(Icons.settings_outlined, size: 20),
          ),
          onPressed: () => context.push('/settings'),
        ),
        const SizedBox(width: AppTheme.spaceLg),
      ],
    );
  }

  /// 음성 상담 히어로 카드
  Widget _buildVoiceConsultationHero(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: child,
        );
      },
      child: GestureDetector(
        onTap: () => context.push('/characters'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            boxShadow: AppTheme.shadowLg,
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5, height: 5,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4ADE80),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Text(
                            'AI 건강주치의 대기중',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spaceSm),
                    const Text(
                      '지금 바로\n건강 상담하기',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '각 분야별 전문 AI 건강주치의가 24시간 대기중',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.85),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.mic,
                  color: AppTheme.primary,
                  size: 26,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 빠른 액션 그리드
  Widget _buildQuickActions(BuildContext context) {
    final row1Actions = [
      _QuickAction(
        icon: Icons.wb_sunny_outlined,
        label: '아침 건강루틴',
        color: const Color(0xFF00B894),
        onTap: () => context.push('/routine'),
      ),
      _QuickAction(
        icon: Icons.auto_stories_outlined,
        label: '감사일기',
        color: const Color(0xFFFDCB6E),
        onTap: () => context.push('/gratitude'),
      ),
      _QuickAction(
        icon: Icons.calendar_month_outlined,
        label: '루틴 기록',
        color: const Color(0xFF74B9FF),
        onTap: () => context.push('/routine-calendar'),
      ),
      _QuickAction(
        icon: Icons.bar_chart_outlined,
        label: '루틴 통계',
        color: const Color(0xFFA29BFE),
        onTap: () => context.push('/routine-stats'),
      ),
    ];

    final row2Actions = [
      _QuickAction(
        icon: Icons.family_restroom_outlined,
        label: '가족관리',
        color: const Color(0xFF6C5CE7),
        onTap: () => context.push('/families'),
      ),
      _QuickAction(
        icon: Icons.watch_outlined,
        label: '웨어러블',
        color: const Color(0xFFFF7675),
        onTap: () => context.push('/health/wearable'),
      ),
      _QuickAction(
        icon: Icons.history_outlined,
        label: '상담 기록',
        color: const Color(0xFF00CEC9),
        onTap: () => context.push('/conversation-history'),
      ),
      _QuickAction(
        icon: Icons.settings_outlined,
        label: '설정',
        color: const Color(0xFF636E72),
        onTap: () => context.push('/settings'),
      ),
    ];

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row1Actions.map((action) => _buildQuickActionItem(action)).toList(),
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: row2Actions.map((action) => _buildQuickActionItem(action)).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionItem(_QuickAction action) {
    return GestureDetector(
      onTap: action.onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: action.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: action.color.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Icon(action.icon, color: action.color, size: 24),
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            action.label,
            style: AppTheme.caption.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  /// 건강 대시보드
  Widget _buildHealthDashboard(
    BuildContext context,
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('오늘의 건강', style: AppTheme.h3),
            TextButton(
              onPressed: () => context.push('/health/wearable'),
              child: Text(
                '상세보기',
                style: AppTheme.caption.copyWith(color: AppTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.check_circle_outline,
                iconColor: AppTheme.primary,
                title: '루틴 달성',
                value: '$completedCount/$totalCount',
                subtitle: '$percentage% 완료',
                progress: completionRate,
                progressColor: AppTheme.primary,
                onTap: () => context.push('/routine'),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.directions_walk,
                iconColor: AppTheme.success,
                title: '걸음수',
                value: '8,234',
                subtitle: '목표 10,000',
                progress: 0.82,
                progressColor: AppTheme.success,
                onTap: () => context.push('/health/wearable'),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        Row(
          children: [
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.bedtime_outlined,
                iconColor: const Color(0xFF74B9FF),
                title: '수면',
                value: '7.5h',
                subtitle: '양호',
                progress: 0.94,
                progressColor: const Color(0xFF74B9FF),
              ),
            ),
            const SizedBox(width: AppTheme.spaceMd),
            Expanded(
              child: _buildHealthMetricCard(
                icon: Icons.favorite_outline,
                iconColor: const Color(0xFFFF7675),
                title: '심박수',
                value: '72',
                subtitle: 'BPM · 정상',
                progress: 0.72,
                progressColor: const Color(0xFFFF7675),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHealthMetricCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required double progress,
    required Color progressColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spaceLg),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                Text(
                  title,
                  style: AppTheme.caption.copyWith(color: AppTheme.textTertiary),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spaceMd),
            Text(
              value,
              style: AppTheme.h2.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTheme.caption.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppTheme.spaceMd),
            // 프로그레스 바
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: progressColor.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// AI 주치의 섹션 (3개 표시 + 자동 스크롤)
  Widget _buildAIDoctorsSection(BuildContext context, AsyncValue charactersAsync) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('AI 건강 주치의', style: AppTheme.h3),
            TextButton(
              onPressed: () => context.push('/characters'),
              child: Text(
                '전체보기',
                style: AppTheme.caption.copyWith(color: AppTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        SizedBox(
          height: 150,
          child: charactersAsync.when(
            data: (characters) {
              // 총 캐릭터 수 업데이트
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (_totalDoctors != characters.length) {
                  _totalDoctors = characters.length;
                }
              });

              return Column(
                children: [
                  // 3개가 동시에 보이는 ListView
                  Expanded(
                    child: ListView.separated(
                      controller: _doctorScrollController,
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: characters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        final character = characters[index];
                        return _buildDoctorCard(context, character, index);
                      },
                    ),
                  ),
                  // 스크롤 인디케이터 (4개 이상일 때만 표시)
                  if (characters.length > 3) ...[
                    const SizedBox(height: AppTheme.spaceSm),
                    _buildScrollIndicator(characters.length),
                  ],
                ],
              );
            },
            loading: () => const Center(child: LoadingIndicator()),
            error: (e, _) => const ErrorMessage(message: 'AI 건강주치의를 불러올 수 없습니다'),
          ),
        ),
      ],
    );
  }

  /// 스크롤 인디케이터
  Widget _buildScrollIndicator(int count) {
    // 스크롤 가능한 위치 수 (count - 2, 최소 1)
    final positions = (count - 2).clamp(1, count);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(positions, (index) {
        final isActive = index == _currentDoctorIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isActive ? 16 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }

  Widget _buildDoctorCard(BuildContext context, dynamic character, int index) {
    // 캐릭터별 색상
    final colors = [
      const Color(0xFF667EEA), // 보라
      const Color(0xFF00B894), // 민트
      const Color(0xFFFF7675), // 코랄
      const Color(0xFFFDCB6E), // 노랑
      const Color(0xFF74B9FF), // 파랑
      const Color(0xFFA29BFE), // 라벤더
    ];
    final color = colors[index % colors.length];

    return GestureDetector(
      onTap: () async {
        final displayName = '${character.name} ${character.specialty}';

        // 가족 프로필 선택 다이얼로그 표시
        final selectedProfile = await showFamilyProfileSelector(
          context: context,
          characterName: displayName,
        );

        // 프로필이 선택되면 상담 화면으로 이동
        if (selectedProfile != null && context.mounted) {
          context.push(
            '/voice-conversation/${character.id}'
            '?name=${Uri.encodeComponent(displayName)}'
            '&profileId=${selectedProfile.id}'
            '&profileName=${Uri.encodeComponent(selectedProfile.name)}',
          );
        }
      },
      child: Container(
        width: 100,
        padding: const EdgeInsets.all(AppTheme.spaceMd),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          border: Border.all(color: color.withOpacity(0.3), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [color, color.withOpacity(0.7)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  character.name.substring(0, 1),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppTheme.spaceSm),
            Text(
              character.name,
              style: AppTheme.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              character.specialty,
              style: AppTheme.label.copyWith(
                fontSize: 10,
                color: color,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// 최근 상담 섹션
  Widget _buildRecentConsultations(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('최근 상담', style: AppTheme.h3),
            TextButton(
              onPressed: () => context.push('/conversation-history'),
              child: Text(
                '전체보기',
                style: AppTheme.caption.copyWith(color: AppTheme.primary),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spaceMd),
        if (_isLoadingHistories)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          )
        else if (_recentHistories.isEmpty)
          _buildEmptyConsultations()
        else
          ..._recentHistories.map((history) => _buildConsultationCard(
            context: context,
            name: history.characterName,
            familyProfileName: history.familyProfileName,
            time: _formatRelativeTime(history.startTime),
            preview: history.summary ?? _getPreviewText(history.messages),
            onTap: () => context.push('/conversation-history/${history.id}'),
          )),
      ],
    );
  }

  Widget _buildEmptyConsultations() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.space2xl),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.cardBorder),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 32,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.spaceLg),
          const Text(
            '아직 상담 기록이 없습니다',
            style: AppTheme.subtitle,
          ),
          const SizedBox(height: AppTheme.spaceSm),
          Text(
            'AI 건강주치의와 첫 건강 상담을 시작해보세요',
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textTertiary),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationCard({
    required BuildContext context,
    required String name,
    String? familyProfileName,
    required String time,
    required String preview,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spaceSm),
      decoration: AppTheme.cardDecoration,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spaceLg),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Center(
                    child: Text(
                      name.isNotEmpty ? name.substring(0, 1) : 'AI',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spaceMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            name,
                            style: AppTheme.bodyMedium.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (familyProfileName != null) ...[
                            const SizedBox(width: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                familyProfileName,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: AppTheme.primary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                          const Spacer(),
                          Text(
                            time,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.textTertiary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preview,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppTheme.spaceSm),
                Icon(
                  Icons.chevron_right,
                  color: AppTheme.textTertiary,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return '방금 전';
    if (difference.inMinutes < 60) return '${difference.inMinutes}분 전';
    if (difference.inHours < 24) return '${difference.inHours}시간 전';
    if (difference.inDays == 1) return '어제';
    if (difference.inDays < 7) return '${difference.inDays}일 전';
    return '${date.month}월 ${date.day}일';
  }

  String _getPreviewText(List<ConversationHistoryMessage> messages) {
    if (messages.isEmpty) return '대화 내용 없음';
    final userMessage = messages.firstWhere(
      (m) => m.isUser,
      orElse: () => messages.first,
    );
    return userMessage.text.length > 50
        ? '${userMessage.text.substring(0, 50)}...'
        : userMessage.text;
  }
}

class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  _QuickAction({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}
