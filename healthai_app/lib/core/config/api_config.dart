/// API 엔드포인트 설정
///
/// 에뮬레이터와 실제 기기를 자동으로 감지하여 올바른 IP 주소 사용
import 'dart:io';

class ApiConfig {
  /// 프로덕션 모드 여부
  /// 프로덕션 배포 시 true로 변경
  static const bool isProduction = false;

  /// 프로덕션 도메인 (HTTPS)
  static const String productionDomain = 'api.healthai.example.com';

  /// 호스트 주소 (포트 제외)
  static String get _host {
    if (isProduction) {
      return productionDomain;
    }

    final isEmulator = Platform.environment.containsKey('ANDROID_EMULATOR') ||
        Platform.isAndroid && _isAndroidEmulator();

    if (isEmulator) {
      return '10.0.2.2';
    } else {
      return '192.168.35.217';
    }
  }

  /// 프로토콜 (프로덕션: HTTPS, 개발: HTTP)
  static String get _protocol => isProduction ? 'https' : 'http';

  /// WebSocket 프로토콜 (프로덕션: WSS, 개발: WS)
  static String get _wsProtocol => isProduction ? 'wss' : 'ws';

  /// Core API 베이스 URL (인증, 사용자, 루틴 등)
  /// 개발: http://host:8002, 프로덕션: https://domain
  static String get baseUrl => isProduction
      ? '$_protocol://$_host'
      : '$_protocol://$_host:8002';

  /// Conversation Service 베이스 URL (음성 상담)
  /// 개발: http://host:8004, 프로덕션: https://domain/conversation
  static String get conversationBaseUrl => isProduction
      ? '$_protocol://$_host/conversation'
      : '$_protocol://$_host:8004';

  /// WebSocket URL (Conversation Service)
  static String get websocketBaseUrl => isProduction
      ? '$_wsProtocol://$_host/conversation'
      : '$_wsProtocol://$_host:8004';

  /// Android 에뮬레이터 여부 확인 (간단한 휴리스틱)
  static bool _isAndroidEmulator() {
    try {
      // 에뮬레이터는 일반적으로 특정 환경 변수를 가짐
      return Platform.environment.containsKey('ANDROID_EMULATOR');
    } catch (e) {
      return false;
    }
  }

  // Conversation Service 엔드포인트 (캐릭터, 음성상담)
  static String get charactersEndpoint => '$conversationBaseUrl/characters';
  static String characterEndpoint(String characterId) => '$conversationBaseUrl/characters/$characterId';
  static String welcomeAudioEndpoint(String characterId) =>
      '$conversationBaseUrl/characters/$characterId/welcome-audio';

  // Routine 엔드포인트
  static String get routinesEndpoint => '$baseUrl/api/v1/routines';
  static String get routineItemsEndpoint => '$routinesEndpoint/items';
  static String get todayRoutineEndpoint => '$routinesEndpoint/today';
  static String routineByDateEndpoint(String date) => '$routinesEndpoint/$date';
  static String get weeklyStatsEndpoint => '$routinesEndpoint/stats/weekly';
  static String monthlyStatsEndpoint(int year, int month) =>
      '$routinesEndpoint/stats/monthly?year=$year&month=$month';
  static String routineByIdEndpoint(String checkId) => '$routinesEndpoint/$checkId';

  // WebSocket 엔드포인트
  static String conversationWebSocket(String conversationId) =>
      '$websocketBaseUrl/ws/conversations/$conversationId';

  // User 엔드포인트
  static String get userMeEndpoint => '$baseUrl/api/v1/users/me';
}
