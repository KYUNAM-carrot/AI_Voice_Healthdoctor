import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';

/// 온보딩 화면 - 앱 최초 실행 시 표시
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _nextPage() {
    if (_currentPage < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // 건너뛰기 버튼
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: Text(
                  '건너뛰기',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            ),

            // 페이지뷰
            Expanded(
              child: PageView(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                ],
              ),
            ),

            // 하단 네비게이션
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceXl),
              child: Column(
                children: [
                  // 페이지 인디케이터
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(3, (index) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppTheme.primary
                              : AppTheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: AppTheme.spaceLg),

                  // 다음/시작하기 버튼
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.fromHeight(56),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                        ),
                      ),
                      child: Text(
                        _currentPage == 2 ? '시작하기' : '다음',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 온보딩 페이지 1: 음성으로 건강 상담
class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘/일러스트
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withOpacity(0.2),
                  AppTheme.primary.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(120),
            ),
            child: const Icon(
              Icons.mic_rounded,
              size: 120,
              color: AppTheme.primary,
            ),
          ),
          const SizedBox(height: AppTheme.space2xl),

          // 제목
          const Text(
            '음성으로 건강 상담',
            style: AppTheme.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          // 설명
          Text(
            '전문 AI 주치의와 실시간 음성 대화로\n건강 고민을 편하게 상담하세요',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceXl),

          // 특징 강조
          _buildFeatureRow(
            Icons.psychology_outlined,
            '6명의 전문 AI 의료진',
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildFeatureRow(
            Icons.access_time_rounded,
            '24시간 언제든지',
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildFeatureRow(
            Icons.verified_user_outlined,
            '안전한 건강 정보',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          size: 20,
          color: AppTheme.primary,
        ),
        const SizedBox(width: AppTheme.spaceSm),
        Text(
          text,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// 온보딩 페이지 2: 가족 건강 관리
class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘/일러스트
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.success.withOpacity(0.2),
                  AppTheme.success.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(120),
            ),
            child: const Icon(
              Icons.family_restroom_rounded,
              size: 120,
              color: AppTheme.success,
            ),
          ),
          const SizedBox(height: AppTheme.space2xl),

          // 제목
          const Text(
            '가족 모두의 건강',
            style: AppTheme.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          // 설명
          Text(
            '가족 구성원별 프로필을 만들고\n맞춤형 건강 관리를 받아보세요',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceXl),

          // 가족 아바타 예시
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildFamilyAvatar('👨', '아빠', AppTheme.primary),
              const SizedBox(width: AppTheme.spaceMd),
              _buildFamilyAvatar('👩', '엄마', AppTheme.accent),
              const SizedBox(width: AppTheme.spaceMd),
              _buildFamilyAvatar('👦', '아들', AppTheme.info),
              const SizedBox(width: AppTheme.spaceMd),
              _buildFamilyAvatar('👧', '딸', AppTheme.warning),
            ],
          ),
          const SizedBox(height: AppTheme.spaceXl),

          // 특징
          _buildFeatureChip('개인별 맞춤 상담'),
          const SizedBox(height: AppTheme.spaceSm),
          _buildFeatureChip('가족 건강 히스토리 관리'),
        ],
      ),
    );
  }

  Widget _buildFamilyAvatar(String emoji, String label, Color color) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: color.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
        ),
        const SizedBox(height: AppTheme.spaceXs),
        Text(
          label,
          style: AppTheme.caption.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spaceMd,
        vertical: AppTheme.spaceSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.success.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        border: Border.all(
          color: AppTheme.success.withOpacity(0.3),
        ),
      ),
      child: Text(
        text,
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.success,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// 온보딩 페이지 3: 24시간 건강 모니터링
class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spaceXl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘/일러스트
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.info.withOpacity(0.2),
                  AppTheme.accent.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(120),
            ),
            child: const Icon(
              Icons.health_and_safety_rounded,
              size: 120,
              color: AppTheme.info,
            ),
          ),
          const SizedBox(height: AppTheme.space2xl),

          // 제목
          const Text(
            '24시간 건강 모니터링',
            style: AppTheme.h1,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceMd),

          // 설명
          Text(
            '아침 루틴부터 웨어러블 연동까지\n매일의 건강 습관을 함께 관리해요',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spaceXl),

          // 기능 카드
          _buildFeatureCard(
            Icons.wb_sunny_outlined,
            '아침 건강 루틴',
            '매일 아침 건강 습관 체크',
            AppTheme.warning,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildFeatureCard(
            Icons.watch_outlined,
            '웨어러블 연동',
            '걸음수, 심박수, 수면 데이터',
            AppTheme.info,
          ),
          const SizedBox(height: AppTheme.spaceMd),
          _buildFeatureCard(
            Icons.auto_stories_outlined,
            '감사 일기',
            '긍정적인 마음 건강 관리',
            AppTheme.accent,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spaceMd),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(width: AppTheme.spaceMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.subtitle.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
