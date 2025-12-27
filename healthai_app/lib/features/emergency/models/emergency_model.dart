/// 응급 상황 시나리오 종류
enum EmergencyScenario {
  cardiacArrest('심정지', '의식과 호흡이 없는 상태'),
  airwayObstruction('기도폐쇄', '이물질로 기도가 막힌 상태'),
  majorBleeding('대량출혈', '심한 외부 출혈 상태'),
  seizure('경련', '발작/경련 상태'),
  unconscious('의식없음', '의식이 없으나 호흡은 있는 상태');

  const EmergencyScenario(this.label, this.description);

  final String label;
  final String description;
}

/// 응급 상태 머신 상태
enum EmergencyState {
  idle,           // 대기 상태
  init,           // 초기화 중
  scenarioSelect, // 시나리오 선택 단계
  actionLoop,     // 응급처치 안내 루프
  cprLoop,        // CPR 2분 루프 (심정지 전용)
  medicalHandoff, // 의료진 인계
  ended,          // 종료
}

/// 응급 세션 정보
class EmergencySession {
  final String id;
  EmergencyScenario? scenario;
  EmergencyState state;
  final DateTime startedAt;
  bool called119;
  final List<String> actionHistory;
  int cprCycleCount;
  DateTime? lastCprCycleStart;

  EmergencySession({
    required this.id,
    this.scenario,
    this.state = EmergencyState.idle,
    DateTime? startedAt,
    this.called119 = false,
    List<String>? actionHistory,
    this.cprCycleCount = 0,
    this.lastCprCycleStart,
  })  : startedAt = startedAt ?? DateTime.now(),
        actionHistory = actionHistory ?? [];

  /// 액션 기록 추가
  void addAction(String action) {
    actionHistory.add('[${DateTime.now().toIso8601String()}] $action');
  }

  /// 세션 복사 (상태 변경용)
  EmergencySession copyWith({
    String? id,
    EmergencyScenario? scenario,
    EmergencyState? state,
    DateTime? startedAt,
    bool? called119,
    List<String>? actionHistory,
    int? cprCycleCount,
    DateTime? lastCprCycleStart,
  }) {
    return EmergencySession(
      id: id ?? this.id,
      scenario: scenario ?? this.scenario,
      state: state ?? this.state,
      startedAt: startedAt ?? this.startedAt,
      called119: called119 ?? this.called119,
      actionHistory: actionHistory ?? List.from(this.actionHistory),
      cprCycleCount: cprCycleCount ?? this.cprCycleCount,
      lastCprCycleStart: lastCprCycleStart ?? this.lastCprCycleStart,
    );
  }
}
