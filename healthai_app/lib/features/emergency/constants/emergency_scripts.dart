/// 응급상황 안내 문구 상수
///
/// 중요: 이 문구들은 법적/의료적 안전을 위해 하드코딩되어 있습니다.
/// LLM 생성 금지 - 반드시 이 상수만 사용해야 합니다.
///
/// 포함하지 않는 요소:
/// - 진단 표현
/// - "괜찮아질 겁니다" 등 치료 성공 보장
/// - 약물/용량 언급
library;

import '../models/emergency_model.dart';

/// 응급 모드 진입 시 오프닝 문구 (1회만 출력)
const List<String> emergencyOpening = [
  '지금은 응급 상황입니다.',
  '가능하면 지금 바로\n119에 전화하세요.',
  '의료진이 도착할 때까지\n제가 함께 안내하겠습니다.',
];

/// 심정지 (의식 없음 + 호흡 없음) 시나리오 - KACPR 가이드라인 기반
class CardiacArrestScripts {
  /// 1단계: 반응 확인 (1회)
  static const List<String> step1CheckResponse = [
    '어깨를 두드리며\n"괜찮으세요?" 물어보세요.',
    '반응이 없으면 주변에\n도움을 요청하세요.',
    '119에 신고하고\n자동심장충격기를 요청하세요.',
  ];

  /// 2단계: 호흡 확인 (1회)
  static const List<String> step2CheckBreathing = [
    '가슴과 배의 움직임을\n10초간 확인하세요.',
    '정상 호흡이 없으면\n심폐소생술을 시작합니다.',
  ];

  /// 3단계: 가슴압박 준비 (1회)
  static const List<String> step3PrepareCompression = [
    '환자를 딱딱한\n바닥에 눕히세요.',
    '가슴 중앙, 젖꼭지 사이에\n손꿈치를 올리세요.',
    '양손을 깍지 끼고\n팔을 곧게 펴세요.',
  ];

  /// 4단계: 가슴압박 시작 (반복)
  static const String compressionStart = '지금부터 강하고 빠르게\n30번 누르세요.';

  /// 가슴압박 중 격려 문구 (10초마다 반복)
  static const List<String> compressionPrompts = [
    '강하게 누르세요.\n5센티 이상 깊이로.',
    '속도 유지.\n1분에 100번 이상.',
    '멈추지 마세요.\n계속 누르세요.',
  ];

  /// 인공호흡 안내 (선택사항)
  static const List<String> rescueBreaths = [
    '30번 압박 후 \n고개를 젖히세요.',
    '코를 막고 입에 숨을\n2번 불어넣으세요.',
    '가슴이 올라오는지 \n확인하세요.',
  ];

  /// 2분 사이클 완료 시
  static const List<String> cycleComplete = [
    '호흡을 확인하세요.',
    '호흡이 없으면 계속하세요.',
  ];

  /// AED 도착 시
  static const List<String> aedArrival = [
    '자동심장충격기를 켜세요.',
    '패드를 가슴에 부착하세요.',
    '기계의 음성 \n 지시를 따르세요.',
  ];
}

/// 기도폐쇄 (하임리히) 시나리오
class AirwayObstructionScripts {
  /// 상태 확인
  static const List<String> checkStatus = [
    '말을 할 수 있나요?',
    '기침을 할 수 있나요?',
  ];

  /// 의식 있는 환자 - 하임리히법 (반복)
  static const List<String> heimlichConscious = [
    '환자 뒤로 가세요.',
    '배꼽 위 명치 아래에\n주먹을 대세요.',
    '다른 손으로 주먹을\n감싸세요.',
    '위쪽 대각선으로 강하게\n밀어올리세요.',
    '이물질이 나올 때까지\n반복하세요.',
  ];

  /// 의식 없는 환자
  static const List<String> heimlichUnconscious = [
    '환자를 눕히세요.',
    '입안에 이물질이\n보이면 제거하세요.',
    '심폐소생술을 시작하세요.',
  ];
}

/// 대량출혈 시나리오
class MajorBleedingScripts {
  /// 지혈 (반복)
  static const List<String> directPressure = [
    '깨끗한 천으로 상처를\n강하게 누르세요.',
    '피가 스며들어도\n절대 떼지 마세요.',
    '천 위에 천을 더 덧대세요.',
    '계속 강하게 압박하세요.',
  ];

  /// 추가 조치
  static const List<String> additionalMeasures = [
    '가능하면 상처 부위를\n심장보다 높이 올리세요.',
    '환자를 따뜻하게 해주세요.',
    '의식 상태를 계속 \n확인하세요.',
  ];
}

/// 경련(발작) 시나리오
class SeizureScripts {
  /// 경련 중 (반복)
  static const List<String> duringSeizure = [
    '주변 위험한 물건을\n치우세요.',
    '머리 아래 부드러운 것을\n받치세요.',
    '억지로 붙잡거나\n누르지 마세요.',
    '입에 아무것도 넣지 마세요.',
    '경련 시작 시간을\n기억하세요.',
  ];

  /// 경련 후
  static const List<String> afterSeizure = [
    '경련이 멈추면 옆으로 눕히세요.',
    '호흡을 확인하세요.',
    '의식이 돌아올 때까지\n곁에 있으세요.',
  ];

  /// 5분 이상 지속 시
  static const String prolongedSeizure = '5분 이상 지속되면 즉시 119에 알리세요.';
}

/// 의식없음 + 호흡 있음 (회복자세) 시나리오
class UnconsciousScripts {
  /// 회복자세 (반복)
  static const List<String> recoveryPosition = [
    '호흡이 있는지 확인하세요.',
    '환자의 팔을 머리 위로\n올리세요.',
    '몸을 옆으로 돌리세요.',
    '고개를 뒤로 젖혀\n기도를 확보하세요.',
    '입이 아래를 향하게\n하세요.',
  ];

  /// 관찰 (반복)
  static const List<String> monitoring = [
    '호흡을 계속 확인하세요.',
    '의식 변화를 관찰하세요.',
    '구토물이 있으면\n닦아주세요.',
  ];
}

/// CPR 타이밍 설정 (2분 = 120초 사이클)
class CprTimings {
  /// 가슴압박 프롬프트 간격 (초)
  static const int compressionPromptInterval = 10;

  /// 2분 사이클 (초)
  static const int cycleDuration = 120;

  /// 압박 속도 (분당 100-120회 = 0.5-0.6초/회)
  static const int compressionsPerMinute = 110;
}

/// 중단 및 전환 문구
class TransitionScripts {
  /// 의료진 도착 시
  static const List<String> medicalArrival = [
    '의료진이 도착했습니다.',
    '수고하셨습니다. \n안내를 종료합니다.',
  ];

  /// 호흡 회복 시
  static const List<String> breathingRecovered = [
    '호흡이 돌아왔습니다.',
    '옆으로 눕히고 \n계속 관찰하세요.',
    '다시 호흡이 멈추면 \n바로 알려주세요.',
  ];
}

/// 119 연결 안내 문구
class Call119Scripts {
  static const String prompt = '119에 전화하시겠습니까?';
  static const String connecting = '119에 연결합니다.';
  static const String muteNotice = 'AI 안내가 잠시 중단됩니다. \n119 안내를 따르세요.';
}

/// 시나리오별 초기 스크립트 (1회 재생)
List<String> getScenarioStartScripts(EmergencyScenario scenario) {
  switch (scenario) {
    case EmergencyScenario.cardiacArrest:
      return [
        ...CardiacArrestScripts.step1CheckResponse,
        ...CardiacArrestScripts.step2CheckBreathing,
        ...CardiacArrestScripts.step3PrepareCompression,
        CardiacArrestScripts.compressionStart,
      ];
    case EmergencyScenario.airwayObstruction:
      return AirwayObstructionScripts.checkStatus;
    case EmergencyScenario.majorBleeding:
      return MajorBleedingScripts.directPressure;
    case EmergencyScenario.seizure:
      return SeizureScripts.duringSeizure;
    case EmergencyScenario.unconscious:
      return UnconsciousScripts.recoveryPosition;
  }
}

/// 시나리오별 반복 스크립트
List<String> getScenarioLoopScripts(EmergencyScenario scenario) {
  switch (scenario) {
    case EmergencyScenario.cardiacArrest:
      return CardiacArrestScripts.compressionPrompts;
    case EmergencyScenario.airwayObstruction:
      return AirwayObstructionScripts.heimlichConscious;
    case EmergencyScenario.majorBleeding:
      return MajorBleedingScripts.directPressure;
    case EmergencyScenario.seizure:
      return SeizureScripts.duringSeizure;
    case EmergencyScenario.unconscious:
      // 회복자세 + 관찰 모두 포함
      return [
        ...UnconsciousScripts.recoveryPosition,
        ...UnconsciousScripts.monitoring,
      ];
  }
}
