/// API 엔드포인트 설정
///
/// 에뮬레이터와 실제 기기를 자동으로 감지하여 올바른 IP 주소 사용
import 'dart:io';

class ApiConfig {
  /// 백엔드 서버 베이스 URL
  ///
  /// - 에뮬레이터: 10.0.2.2 (localhost 매핑)
  /// - 실제 기기: 192.168.35.217 (PC의 로컬 IP)
  static String get baseUrl {
    // Android 에뮬레이터 감지
    // 에뮬레이터는 "Android SDK built for x86" 또는 "sdk_gphone" 같은 모델명을 가짐
    final isEmulator = Platform.environment.containsKey('ANDROID_EMULATOR') ||
        Platform.isAndroid && _isAndroidEmulator();

    if (isEmulator) {
      // 에뮬레이터: localhost는 10.0.2.2로 매핑됨
      return 'http://10.0.2.2:8004';
    } else {
      // 실제 기기: PC의 로컬 네트워크 IP 사용
      return 'http://192.168.35.217:8004';
    }
  }

  /// WebSocket URL
  static String get websocketBaseUrl {
    return baseUrl.replaceFirst('http://', 'ws://');
  }

  /// Android 에뮬레이터 여부 확인 (간단한 휴리스틱)
  static bool _isAndroidEmulator() {
    try {
      // 에뮬레이터는 일반적으로 특정 환경 변수를 가짐
      return Platform.environment.containsKey('ANDROID_EMULATOR');
    } catch (e) {
      return false;
    }
  }

  // API 엔드포인트들
  static String get charactersEndpoint => '$baseUrl/characters';
  static String characterEndpoint(String characterId) => '$baseUrl/characters/$characterId';
  static String welcomeAudioEndpoint(String characterId) =>
      '$baseUrl/characters/$characterId/welcome-audio';

  // WebSocket 엔드포인트
  static String conversationWebSocket(String conversationId) =>
      '$websocketBaseUrl/ws/conversations/$conversationId';
}
