import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 온보딩 화면 - 세계 최고 수준의 프리미엄 디자인
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _floatController;
  late AnimationController _pulseController;
  late Animation<double> _floatAnimation;
  late Animation<double> _pulseAnimation;

  static const int _totalPages = 5;

  // 프리미엄 다크 테마 색상
  static const Color _bgDark = Color(0xFF0A0E21);
  static const Color _bgLight = Color(0xFF1A1F38);
  static const Color _accentEmergency = Color(0xFFFF4D6D);
  static const Color _accentExpert = Color(0xFF4D9FFF);
  static const Color _accentPersonal = Color(0xFF00D9A5);
  static const Color _accentRoutine = Color(0xFFFFAB4D);
  static const Color _accentFamily = Color(0xFFB388FF);

  @override
  void initState() {
    super.initState();

    _floatController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _floatAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _floatController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) {
      context.go('/login');
    }
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  Color _getAccentColor(int index) {
    switch (index) {
      case 0: return _accentEmergency;
      case 1: return _accentExpert;
      case 2: return _accentPersonal;
      case 3: return _accentRoutine;
      case 4: return _accentFamily;
      default: return _accentExpert;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_bgLight, _bgDark],
            stops: [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 상단 헤더
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // 페이지 인디케이터
                    Row(
                      children: List.generate(_totalPages, (index) {
                        final isActive = _currentPage == index;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          width: isActive ? 20 : 6,
                          height: 6,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: isActive
                                ? _getAccentColor(_currentPage)
                                : Colors.white.withOpacity(0.2),
                          ),
                        );
                      }),
                    ),
                    // 건너뛰기 버튼
                    GestureDetector(
                      onTap: _completeOnboarding,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: const Text(
                          '건너뛰기',
                          style: TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 페이지뷰
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (index) => setState(() => _currentPage = index),
                  children: [
                    _PageEmergency(
                      pulseAnimation: _pulseAnimation,
                      accentColor: _accentEmergency,
                    ),
                    _PageExpert(
                      floatAnimation: _floatAnimation,
                      accentColor: _accentExpert,
                    ),
                    _PagePersonalized(
                      floatAnimation: _floatAnimation,
                      accentColor: _accentPersonal,
                    ),
                    _PageRoutine(
                      floatAnimation: _floatAnimation,
                      accentColor: _accentRoutine,
                    ),
                    _PageFamily(
                      floatAnimation: _floatAnimation,
                      accentColor: _accentFamily,
                    ),
                  ],
                ),
              ),

              // 하단 버튼
              Padding(
                padding: EdgeInsets.fromLTRB(24, 12, 24, bottomPadding + 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _nextPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getAccentColor(_currentPage),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      _currentPage == _totalPages - 1 ? '시작하기' : '다음',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 페이지 1: 응급상황 보조
class _PageEmergency extends StatelessWidget {
  final Animation<double> pulseAnimation;
  final Color accentColor;

  const _PageEmergency({
    required this.pulseAnimation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // 응급 아이콘
          AnimatedBuilder(
            animation: pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: pulseAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.emergency_rounded, size: 60, color: Colors.white),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // 타이틀
          const Text(
            '응급상황 보조 안내',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 설명
          Text(
            '119 신고 연결과 함께\n의료진 도착 전까지\n응급처치를 음성 안내합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // 기능 태그들
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: [
              _FeatureChip(icon: Icons.favorite_rounded, label: 'CPR 가이드', color: accentColor),
              _FeatureChip(icon: Icons.phone_rounded, label: '119 연결', color: accentColor),
              _FeatureChip(icon: Icons.mic_rounded, label: '상황별 음성 안내', color: accentColor),
            ],
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

/// 페이지 2: 전문가 AI 건강주치의
class _PageExpert extends StatelessWidget {
  final Animation<double> floatAnimation;
  final Color accentColor;

  const _PageExpert({
    required this.floatAnimation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // AI 아이콘
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.psychology_alt_rounded, size: 60, color: Colors.white),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // 타이틀 (한 줄로)
          const Text(
            '전문가 AI 건강주치의',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 설명 (한 줄씩)
          Text(
            '각 분야 전문가로 구성된 AI 주치의가\n의학 전문자료 기반으로 상담합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // 전문 분야 (2줄)
          Wrap(
            spacing: 6,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: const [
              _ExpertBadge(emoji: '🏥', label: '내과'),
              _ExpertBadge(emoji: '🧠', label: '정신건강'),
              _ExpertBadge(emoji: '🥗', label: '영양'),
              _ExpertBadge(emoji: '🌿', label: '한의약'),
              _ExpertBadge(emoji: '👶', label: '소아청소년'),
              _ExpertBadge(emoji: '👩‍⚕️', label: '여성건강'),
              _ExpertBadge(emoji: '🧓', label: '노인의학'),
            ],
          ),

          const SizedBox(height: 16),

          // RAG 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: accentColor.withOpacity(0.15),
              border: Border.all(color: accentColor.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 16, color: accentColor),
                const SizedBox(width: 6),
                Text(
                  'RAG 기반 전문자료 참조',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

/// 페이지 3: 개인화 건강상담
class _PagePersonalized extends StatelessWidget {
  final Animation<double> floatAnimation;
  final Color accentColor;

  const _PagePersonalized({
    required this.floatAnimation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // 웨어러블 아이콘
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.watch_rounded, size: 60, color: Colors.white),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // 타이틀
          const Text(
            '개인화 건강상담',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 설명
          Text(
            '웨어러블 기기의 건강 데이터를 연동하여\n나만을 위한 맞춤형 상담을 제공합니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // 건강 데이터 카드들
          Row(
            children: [
              Expanded(
                child: _DataCard(
                  icon: Icons.favorite_rounded,
                  value: '72',
                  unit: 'BPM',
                  color: const Color(0xFFFF4D6D),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DataCard(
                  icon: Icons.directions_walk_rounded,
                  value: '8,432',
                  unit: '걸음',
                  color: accentColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _DataCard(
                  icon: Icons.bedtime_rounded,
                  value: '7.5',
                  unit: '시간',
                  color: const Color(0xFF4D9FFF),
                ),
              ),
            ],
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

/// 페이지 4: 건강한 생활 루틴
class _PageRoutine extends StatelessWidget {
  final Animation<double> floatAnimation;
  final Color accentColor;

  const _PageRoutine({
    required this.floatAnimation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // 태양 아이콘
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.wb_sunny_rounded, size: 60, color: Colors.white),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // 타이틀
          const Text(
            '건강한 생활 루틴',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 설명
          Text(
            '아침 건강 체크와 감사 일기로\n몸과 마음의 건강한 습관을 만들어갑니다',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 24),

          // 루틴 항목들
          _RoutineItem(
            icon: Icons.alarm_rounded,
            title: '아침 건강루틴 체크와 계획',
            desc: '아침 건강루틴 체크와 목표설정으로 활기찬 하루 시작',
            color: accentColor,
          ),
          const SizedBox(height: 10),
          _RoutineItem(
            icon: Icons.auto_stories_rounded,
            title: '감사 일기',
            desc: '하루의 감사함을 기록하며 마음 건강',
            color: const Color(0xFFFF6B9D),
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}

/// 페이지 5: 가족 모두의 건강
class _PageFamily extends StatelessWidget {
  final Animation<double> floatAnimation;
  final Color accentColor;

  const _PageFamily({
    required this.floatAnimation,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const Spacer(flex: 3),

          // 가족 아이콘
          AnimatedBuilder(
            animation: floatAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, -floatAnimation.value),
                child: child,
              );
            },
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [accentColor, accentColor.withOpacity(0.8)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: accentColor.withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.family_restroom_rounded, size: 60, color: Colors.white),
              ),
            ),
          ),

          const Spacer(flex: 2),

          // 타이틀
          const Text(
            '가족 모두의 건강',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),

          // 설명
          Text(
            '가족 구성원별 프로필을 만들고\n가족의 건강을 함께 관리하세요',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
              height: 1.5,
            ),
          ),

          const SizedBox(height: 28),

          // 가족 멤버
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              _FamilyAvatar(emoji: '👨', label: '아빠', color: Color(0xFF4D9FFF)),
              SizedBox(width: 16),
              _FamilyAvatar(emoji: '👩', label: '엄마', color: Color(0xFFB388FF)),
              SizedBox(width: 16),
              _FamilyAvatar(emoji: '👦', label: '아들', color: Color(0xFF00D9A5)),
              SizedBox(width: 16),
              _FamilyAvatar(emoji: '👧', label: '딸', color: Color(0xFFFF6B9D)),
            ],
          ),

          const SizedBox(height: 20),

          // 특징 태그
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _FeatureChip(icon: Icons.person_rounded, label: '개인별 맞춤', color: accentColor),
              const SizedBox(width: 8),
              _FeatureChip(icon: Icons.history_rounded, label: '건강 히스토리', color: accentColor),
            ],
          ),

          const Spacer(flex: 3),
        ],
      ),
    );
  }
}


// ====== 공통 위젯 컴포넌트 ======

/// 기능 태그 칩
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _FeatureChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 전문가 배지
class _ExpertBadge extends StatelessWidget {
  final String emoji;
  final String label;

  const _ExpertBadge({
    required this.emoji,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.white.withOpacity(0.08),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// 건강 데이터 카드
class _DataCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String unit;
  final Color color;

  const _DataCard({
    required this.icon,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            unit,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }
}

/// 루틴 항목
class _RoutineItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;

  const _RoutineItem({
    required this.icon,
    required this.title,
    required this.desc,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: color.withOpacity(0.1),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: color.withOpacity(0.2),
            ),
            child: Icon(icon, size: 22, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.6),
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

/// 가족 아바타
class _FamilyAvatar extends StatelessWidget {
  final String emoji;
  final String label;
  final Color color;

  const _FamilyAvatar({
    required this.emoji,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.15),
            border: Border.all(color: color.withOpacity(0.4), width: 2),
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 24)),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.white.withOpacity(0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
