import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import '../models/emergency_model.dart';
import '../constants/emergency_scripts.dart';
import '../services/emergency_tts_service.dart';

/// 응급 세션 상태 관리 Provider
final emergencySessionProvider =
    StateNotifierProvider<EmergencySessionNotifier, EmergencySession?>((ref) {
  return EmergencySessionNotifier();
});

/// CPR 타이머 상태 Provider
final cprTimerProvider =
    StateNotifierProvider<CprTimerNotifier, CprTimerState>((ref) {
  return CprTimerNotifier();
});

/// 반복 안내 Provider (CPR 외 시나리오용)
final loopGuidanceProvider =
    StateNotifierProvider<LoopGuidanceNotifier, LoopGuidanceState>((ref) {
  return LoopGuidanceNotifier();
});

/// 현재 음성 안내 문구 Provider
final currentScriptProvider = StateProvider<String?>((ref) => null);

/// 119 통화 중 여부 Provider
final isCalling119Provider = StateProvider<bool>((ref) => false);

/// 응급 TTS 서비스 Provider
final emergencyTtsProvider = Provider<EmergencyTtsService>((ref) {
  final service = EmergencyTtsService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// CPR 타이머 상태
class CprTimerState {
  final bool isRunning;
  final int elapsedSeconds;
  final int cycleCount;
  final String? currentPrompt;
  final int promptIndex;

  const CprTimerState({
    this.isRunning = false,
    this.elapsedSeconds = 0,
    this.cycleCount = 0,
    this.currentPrompt,
    this.promptIndex = 0,
  });

  CprTimerState copyWith({
    bool? isRunning,
    int? elapsedSeconds,
    int? cycleCount,
    String? currentPrompt,
    int? promptIndex,
  }) {
    return CprTimerState(
      isRunning: isRunning ?? this.isRunning,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      cycleCount: cycleCount ?? this.cycleCount,
      currentPrompt: currentPrompt ?? this.currentPrompt,
      promptIndex: promptIndex ?? this.promptIndex,
    );
  }

  /// 현재 사이클 내 경과 시간 (0-120초)
  int get cycleElapsedSeconds => elapsedSeconds % CprTimings.cycleDuration;

  /// 2분 타이머 진행률 (0.0 ~ 1.0)
  double get progress => cycleElapsedSeconds / CprTimings.cycleDuration;

  /// 경과 시간 포맷 (MM:SS)
  String get elapsedTimeFormatted {
    final minutes = cycleElapsedSeconds ~/ 60;
    final seconds = cycleElapsedSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}

/// 반복 안내 상태 (CPR 외 시나리오용)
class LoopGuidanceState {
  final bool isRunning;
  final int currentIndex;
  final List<String> scripts;

  const LoopGuidanceState({
    this.isRunning = false,
    this.currentIndex = 0,
    this.scripts = const [],
  });

  LoopGuidanceState copyWith({
    bool? isRunning,
    int? currentIndex,
    List<String>? scripts,
  }) {
    return LoopGuidanceState(
      isRunning: isRunning ?? this.isRunning,
      currentIndex: currentIndex ?? this.currentIndex,
      scripts: scripts ?? this.scripts,
    );
  }
}

/// 응급 세션 상태 관리 Notifier
class EmergencySessionNotifier extends StateNotifier<EmergencySession?> {
  EmergencySessionNotifier() : super(null);

  /// 새 응급 세션 시작
  EmergencySession startSession() {
    final session = EmergencySession(
      id: const Uuid().v4(),
      state: EmergencyState.init,
    );
    session.addAction('세션 시작');
    state = session;
    return session;
  }

  /// 시나리오 선택
  void selectScenario(EmergencyScenario scenario) {
    if (state == null) return;

    state = state!.copyWith(
      scenario: scenario,
      state: EmergencyState.actionLoop,
    );
    state!.addAction('시나리오 선택: ${scenario.label}');
  }

  /// 상태 전환
  void transitionTo(EmergencyState newState) {
    if (state == null) return;

    state = state!.copyWith(state: newState);
    state!.addAction('상태 전환: ${newState.name}');
  }

  /// 119 전화 완료 기록
  void markCalled119() {
    if (state == null) return;

    state = state!.copyWith(called119: true);
    state!.addAction('119 전화 완료');
  }

  /// CPR 사이클 증가
  void incrementCprCycle() {
    if (state == null) return;

    state = state!.copyWith(
      cprCycleCount: state!.cprCycleCount + 1,
      lastCprCycleStart: DateTime.now(),
    );
    state!.addAction('CPR 사이클 ${state!.cprCycleCount} 시작');
  }

  /// 세션 종료
  void endSession() {
    if (state == null) return;

    state!.addAction('세션 종료');
    state = state!.copyWith(state: EmergencyState.ended);
  }

  /// 세션 초기화 (리셋)
  void reset() {
    state = null;
  }
}

/// CPR 타이머 Notifier (10초 간격 프롬프트)
class CprTimerNotifier extends StateNotifier<CprTimerState> {
  CprTimerNotifier() : super(const CprTimerState());

  Timer? _timer;
  Function(String)? _onPromptCallback;

  /// 타이머 시작
  void start({Function(String)? onPrompt}) {
    _onPromptCallback = onPrompt;

    if (_timer != null) {
      _timer!.cancel();
    }

    state = state.copyWith(
      isRunning: true,
      elapsedSeconds: 0,
      promptIndex: 0,
    );

    // 초기 프롬프트 발화
    _emitPrompt();

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newElapsed = state.elapsedSeconds + 1;
      final cycleElapsed = newElapsed % CprTimings.cycleDuration;

      // 새 사이클 시작 체크 (2분마다)
      if (cycleElapsed == 0 && newElapsed > 0) {
        state = state.copyWith(
          elapsedSeconds: newElapsed,
          cycleCount: state.cycleCount + 1,
          promptIndex: 0,
        );
        // 사이클 완료 문구
        _emitCycleComplete();
      } else {
        state = state.copyWith(elapsedSeconds: newElapsed);

        // 10초마다 프롬프트 발화
        if (cycleElapsed > 0 &&
            cycleElapsed % CprTimings.compressionPromptInterval == 0) {
          _emitPrompt();
        }
      }
    });
  }

  /// 프롬프트 발화
  void _emitPrompt() {
    final prompts = CardiacArrestScripts.compressionPrompts;
    final index = state.promptIndex % prompts.length;
    final prompt = prompts[index];

    state = state.copyWith(
      currentPrompt: prompt,
      promptIndex: state.promptIndex + 1,
    );

    debugPrint('🔔 [CPR] 프롬프트 $index: "$prompt"');
    _onPromptCallback?.call(prompt);
  }

  /// 사이클 완료 문구 발화
  void _emitCycleComplete() {
    final prompt = CardiacArrestScripts.cycleComplete.first;
    state = state.copyWith(currentPrompt: prompt);
    debugPrint('🔄 [CPR] 사이클 완료: "$prompt"');
    _onPromptCallback?.call(prompt);
  }

  /// 타이머 일시정지
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// 타이머 재개
  void resume({Function(String)? onPrompt}) {
    if (state.isRunning) return;

    _onPromptCallback = onPrompt;
    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newElapsed = state.elapsedSeconds + 1;
      final cycleElapsed = newElapsed % CprTimings.cycleDuration;

      if (cycleElapsed == 0 && newElapsed > 0) {
        state = state.copyWith(
          elapsedSeconds: newElapsed,
          cycleCount: state.cycleCount + 1,
          promptIndex: 0,
        );
        _emitCycleComplete();
      } else {
        state = state.copyWith(elapsedSeconds: newElapsed);

        if (cycleElapsed > 0 &&
            cycleElapsed % CprTimings.compressionPromptInterval == 0) {
          _emitPrompt();
        }
      }
    });
  }

  /// 타이머 정지 및 리셋
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const CprTimerState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 반복 안내 Notifier (CPR 외 시나리오용)
class LoopGuidanceNotifier extends StateNotifier<LoopGuidanceState> {
  LoopGuidanceNotifier() : super(const LoopGuidanceState());

  Timer? _timer;
  Function(String)? _onPromptCallback;

  /// 반복 안내 시작
  void start({
    required List<String> scripts,
    required Function(String) onPrompt,
    int intervalSeconds = 8, // 각 문구 간 간격 (초)
  }) {
    _onPromptCallback = onPrompt;

    if (_timer != null) {
      _timer!.cancel();
    }

    state = LoopGuidanceState(
      isRunning: true,
      currentIndex: 0,
      scripts: scripts,
    );

    // 첫 번째 문구 즉시 발화
    _emitCurrentPrompt();

    // intervalSeconds 간격으로 다음 문구 발화
    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      if (!state.isRunning) {
        timer.cancel();
        return;
      }

      // 다음 인덱스 (순환)
      final nextIndex = (state.currentIndex + 1) % state.scripts.length;
      state = state.copyWith(currentIndex: nextIndex);
      _emitCurrentPrompt();
    });
  }

  /// 현재 문구 발화
  void _emitCurrentPrompt() {
    if (state.scripts.isEmpty) return;

    final prompt = state.scripts[state.currentIndex];
    debugPrint('🔁 [Loop] 문구 ${state.currentIndex}: "$prompt"');
    _onPromptCallback?.call(prompt);
  }

  /// 일시정지
  void pause() {
    _timer?.cancel();
    state = state.copyWith(isRunning: false);
  }

  /// 재개
  void resume({int intervalSeconds = 8}) {
    if (state.isRunning || state.scripts.isEmpty) return;

    state = state.copyWith(isRunning: true);

    _timer = Timer.periodic(Duration(seconds: intervalSeconds), (timer) {
      if (!state.isRunning) {
        timer.cancel();
        return;
      }

      final nextIndex = (state.currentIndex + 1) % state.scripts.length;
      state = state.copyWith(currentIndex: nextIndex);
      _emitCurrentPrompt();
    });
  }

  /// 정지
  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const LoopGuidanceState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

/// 119 전화 걸기 기능
Future<bool> call119() async {
  final Uri phoneUri = Uri(scheme: 'tel', path: '119');

  try {
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
      return true;
    } else {
      debugPrint('Cannot launch phone call to 119');
      return false;
    }
  } catch (e) {
    debugPrint('Error calling 119: $e');
    return false;
  }
}
