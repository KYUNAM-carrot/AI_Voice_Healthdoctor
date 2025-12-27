import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../models/emergency_model.dart';
import '../providers/emergency_provider.dart';
import '../constants/emergency_scripts.dart';
import '../widgets/scenario_selector.dart';
import '../widgets/cpr_timer.dart';

/// 응급상황 보조 화면
class EmergencyScreen extends ConsumerStatefulWidget {
  const EmergencyScreen({super.key});

  @override
  ConsumerState<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends ConsumerState<EmergencyScreen> {
  bool _showedOpening = false;
  bool _ttsInitialized = false;
  bool _isPlayingScripts = false;
  bool _cancelCurrentPlayback = false; // 현재 재생 취소 플래그

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initTts();
      ref.read(emergencySessionProvider.notifier).startSession();
      _playOpeningScripts();
    });
  }

  /// TTS 서비스 초기화
  Future<void> _initTts() async {
    if (_ttsInitialized) return;
    try {
      final ttsService = ref.read(emergencyTtsProvider);
      await ttsService.initialize();
      _ttsInitialized = true;
      debugPrint('✅ [Emergency] TTS 초기화 완료');
    } catch (e) {
      debugPrint('❌ [Emergency] TTS 초기화 실패: $e');
    }
  }

  @override
  void dispose() {
    // 모든 타이머/안내 정지
    ref.read(cprTimerProvider.notifier).stop();
    ref.read(loopGuidanceProvider.notifier).stop();
    if (_ttsInitialized) {
      ref.read(emergencyTtsProvider).stop();
    }
    super.dispose();
  }

  /// 오프닝 문구 재생
  Future<void> _playOpeningScripts() async {
    if (_showedOpening) return;
    _showedOpening = true;

    await _playScriptsSequentially(emergencyOpening);
  }

  /// 스크립트 순차 재생 (텍스트-음성 동기화)
  Future<void> _playScriptsSequentially(List<String> scripts) async {
    if (_isPlayingScripts) {
      // 이미 재생 중이면 취소하고 대기
      _cancelCurrentPlayback = true;
      await Future.delayed(const Duration(milliseconds: 300));
    }

    _isPlayingScripts = true;
    _cancelCurrentPlayback = false;

    debugPrint('📜 [Emergency] 순차 재생 시작: ${scripts.length}개');

    for (int i = 0; i < scripts.length && mounted && !_cancelCurrentPlayback; i++) {
      final script = scripts[i];
      debugPrint('📜 [Emergency] [$i] "$script"');

      // UI 텍스트와 음성을 동시에 시작
      ref.read(currentScriptProvider.notifier).state = script;

      // 강제 UI 리빌드
      if (mounted) {
        setState(() {});
      }

      await _speakAndWait(script);

      // 취소 확인
      if (_cancelCurrentPlayback) {
        debugPrint('📜 [Emergency] 재생 취소됨');
        break;
      }

      // 다음 문구 전 짧은 간격
      if (i < scripts.length - 1 && mounted && !_cancelCurrentPlayback) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }

    _isPlayingScripts = false;
    debugPrint('📜 [Emergency] 순차 재생 완료');
  }

  /// 음성 재생 및 완료 대기
  Future<void> _speakAndWait(String script) async {
    if (!_ttsInitialized) {
      await _initTts();
    }
    if (!_ttsInitialized) return;

    try {
      final ttsService = ref.read(emergencyTtsProvider);
      await ttsService.speak(script);
    } catch (e) {
      debugPrint('❌ [Emergency] 음성 재생 실패: $e');
    }
  }

  /// 프롬프트 콜백 (타이머에서 호출) - UI와 음성 동기화
  void _onPromptCallback(String prompt) {
    if (!mounted) return;

    debugPrint('🔔 [Emergency] 프롬프트 콜백 수신: "$prompt"');

    // UI 업데이트 - 직접 상태 변경
    ref.read(currentScriptProvider.notifier).state = prompt;

    // 강제 UI 리빌드를 위해 setState 호출
    if (mounted) {
      setState(() {});
    }

    // 음성 재생 (비동기, await 안 함 - 타이머가 계속 진행해야 함)
    _speakAndWait(prompt);
  }

  /// 시나리오 선택 처리
  Future<void> _onScenarioSelected(EmergencyScenario scenario) async {
    // 현재 재생 중인 오프닝 스크립트 중지
    _cancelCurrentPlayback = true;
    if (_ttsInitialized) {
      await ref.read(emergencyTtsProvider).stop();
    }
    await Future.delayed(const Duration(milliseconds: 200));

    ref.read(emergencySessionProvider.notifier).selectScenario(scenario);

    // 시나리오별 초기 스크립트 재생
    final startScripts = getScenarioStartScripts(scenario);
    await _playScriptsSequentially(startScripts);

    if (!mounted) return;

    // 시나리오별 반복 안내 시작
    if (scenario == EmergencyScenario.cardiacArrest) {
      // 심정지: CPR 타이머 시작 (10초 간격 프롬프트)
      debugPrint('🚨 [Emergency] CPR 타이머 시작');
      ref.read(cprTimerProvider.notifier).start(
        onPrompt: _onPromptCallback,
      );
    } else {
      // 다른 시나리오: 반복 안내 시작 (8초 간격)
      final loopScripts = getScenarioLoopScripts(scenario);
      debugPrint('🔁 [Emergency] 반복 안내 시작: ${loopScripts.length}개 문구');
      ref.read(loopGuidanceProvider.notifier).start(
        scripts: loopScripts,
        onPrompt: _onPromptCallback,
        intervalSeconds: 8,
      );
    }
  }

  /// 119 전화 걸기
  Future<void> _call119() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.phone, color: Color(0xFFFF0000)),
            SizedBox(width: 8),
            Text('119 신고', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          '119에 전화하시겠습니까?\n\n전화 연결 중에는 AI 안내가 일시 중단됩니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('취소'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF0000),
            ),
            child: const Text(
              '119 전화하기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(isCalling119Provider.notifier).state = true;
      ref.read(emergencySessionProvider.notifier).markCalled119();

      // 안내 일시정지
      ref.read(currentScriptProvider.notifier).state =
          Call119Scripts.muteNotice;
      ref.read(cprTimerProvider.notifier).pause();
      ref.read(loopGuidanceProvider.notifier).pause();

      await call119();

      ref.read(isCalling119Provider.notifier).state = false;
    }
  }

  /// 의료진 도착 처리
  void _onMedicalArrival() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Row(
          children: [
            Icon(Icons.medical_services, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('의료진 도착', style: TextStyle(color: Colors.white)),
          ],
        ),
        content: const Text(
          '의료진이 도착했습니까?\n\n확인 시 응급 안내가 종료됩니다.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('아니오'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _endSession();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text(
              '예, 도착했습니다',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  /// 세션 종료
  Future<void> _endSession() async {
    // 모든 안내 정지
    ref.read(cprTimerProvider.notifier).stop();
    ref.read(loopGuidanceProvider.notifier).stop();
    ref.read(emergencySessionProvider.notifier).endSession();

    // 종료 문구 재생
    await _playScriptsSequentially(TransitionScripts.medicalArrival);

    // 홈으로 이동
    if (mounted) {
      context.go('/home');
    }
  }

  /// 뒤로가기 버튼 처리
  Future<bool> _onWillPop() async {
    _showExitConfirmation();
    return false; // 기본 뒤로가기 동작 방지
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(emergencySessionProvider);
    final currentScript = ref.watch(currentScriptProvider);
    final isCalling119 = ref.watch(isCalling119Provider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showExitConfirmation();
        }
      },
      child: Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Color(0xFFFF4444)),
            SizedBox(width: 8),
            Text(
              '응급상황 보조',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => _showExitConfirmation(),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 119 전화 버튼 (항상 최상단 고정)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: _build119Button(isCalling119),
            ),

            // 스크롤 가능한 본문
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // 현재 안내 문구 표시
                    if (currentScript != null)
                      _buildCurrentScriptCard(currentScript),

                    const SizedBox(height: 14),

                    // 시나리오 선택 또는 진행 중 UI
                    if (session?.scenario == null)
                      ScenarioSelector(
                        onScenarioSelected: _onScenarioSelected,
                      )
                    else ...[
                      // 선택된 시나리오 + 의료진 도착 버튼
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SelectedScenarioChip(scenario: session!.scenario!),
                          const SizedBox(width: 8),
                          MedicalArrivalChip(onTap: _onMedicalArrival),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // 심정지인 경우 CPR 타이머 표시
                      if (session.scenario == EmergencyScenario.cardiacArrest)
                        CprTimerWidget(onPrompt: _onPromptCallback),

                      // 다른 시나리오의 경우 행동 안내 목록
                      if (session.scenario != EmergencyScenario.cardiacArrest)
                        _buildActionGuideList(session.scenario!),
                    ],

                    const SizedBox(height: 20),
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

  /// 119 전화 버튼
  Widget _build119Button(bool isCalling) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isCalling ? null : _call119,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isCalling ? Colors.grey[800] : const Color(0xFFFF0000),
            borderRadius: BorderRadius.circular(12),
            boxShadow: isCalling
                ? null
                : [
                    BoxShadow(
                      color: const Color(0xFFFF0000).withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isCalling ? Icons.phone_in_talk : Icons.phone,
                color: Colors.white,
                size: 26,
              ),
              const SizedBox(width: 10),
              Text(
                isCalling ? '119 통화 중...' : '119 전화하기',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 현재 안내 문구 카드 (고정 높이 120px)
  Widget _buildCurrentScriptCard(String script) {
    return Container(
      width: double.infinity,
      height: 120,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFFF4444).withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Center(
        child: Text(
          script,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  /// 행동 안내 목록 (심정지 외 시나리오)
  Widget _buildActionGuideList(EmergencyScenario scenario) {
    final scripts = getScenarioLoopScripts(scenario);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.repeat, color: Colors.orange, size: 14),
              const SizedBox(width: 6),
              const Text(
                '반복 안내 중',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...scripts.asMap().entries.map((entry) {
            final index = entry.key;
            final script = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF4444).withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4444),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      script.replaceAll('\n', ' '), // 줄바꿈 제거하여 한 줄로 표시
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// 종료 확인 다이얼로그
  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2A2A2A),
        title: const Text(
          '응급 안내 종료',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          '정말 응급 안내를 종료하시겠습니까?\n\n아직 응급 상황이라면 계속 안내를 받으세요.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('계속 안내받기'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(cprTimerProvider.notifier).stop();
              ref.read(loopGuidanceProvider.notifier).stop();
              ref.read(emergencySessionProvider.notifier).reset();
              context.go('/home');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[700],
            ),
            child: const Text(
              '종료하기',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
