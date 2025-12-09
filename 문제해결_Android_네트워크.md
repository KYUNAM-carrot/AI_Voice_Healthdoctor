# Android 에뮬레이터 네트워크 연결 문제 해결

## 🔴 발생한 문제

**증상:**
- Flutter 앱에서 "AI 주치의 선택" 버튼 클릭 시 "오류가 발생했습니다" 메시지 표시
- 에러 로그: `Connection refused, address = localhost, port = 8002`

**원인:**
Android 에뮬레이터에서 `localhost`는 **에뮬레이터 자체**를 가리킵니다. 따라서 호스트 PC에서 실행 중인 백엔드 서버(localhost:8002)에 접근할 수 없습니다.

---

## ✅ 해결 방법

### 1. Android 에뮬레이터에서 호스트 PC 접근

Android 에뮬레이터는 특별한 IP 주소를 제공합니다:

| IP 주소 | 의미 |
|---------|------|
| `10.0.2.2` | 호스트 PC의 `localhost` |
| `10.0.2.3` | 에뮬레이터의 DNS 서버 |
| `127.0.0.1` | 에뮬레이터 자체 (localhost) |

**해결책:** `localhost` 대신 `10.0.2.2` 사용

### 2. 코드 수정

#### 수정 전 (잘못된 코드)
```dart
// lib/core/services/character_api_service.dart
static const String baseUrl = 'http://localhost:8002';
```

#### 수정 후 (올바른 코드)
```dart
// lib/core/services/character_api_service.dart
static const String baseUrl = 'http://10.0.2.2:8002';
```

---

## 🖥️ 플랫폼별 localhost 접근 방법

| 플랫폼 | localhost 대신 사용할 주소 |
|--------|---------------------------|
| **Android 에뮬레이터** | `10.0.2.2` |
| **iOS 시뮬레이터** | `localhost` (그대로 사용 가능) |
| **실제 Android 기기** | PC의 실제 IP 주소 (예: `192.168.0.100`) |
| **실제 iOS 기기** | PC의 실제 IP 주소 (예: `192.168.0.100`) |
| **Web (Chrome)** | `localhost` (그대로 사용 가능) |

---

## 🔧 플랫폼별 동적 URL 설정 (권장)

실제 프로덕션 코드에서는 플랫폼을 감지해서 동적으로 URL을 설정하는 것이 좋습니다:

```dart
import 'dart:io';
import 'package:flutter/foundation.dart';

class CharacterApiService {
  static String get baseUrl {
    // 프로덕션 환경
    if (kReleaseMode) {
      return 'https://api.healthai.com';
    }

    // 개발 환경
    if (kIsWeb) {
      // Web: localhost 그대로 사용
      return 'http://localhost:8002';
    } else if (Platform.isAndroid) {
      // Android 에뮬레이터: 10.0.2.2 사용
      return 'http://10.0.2.2:8002';
    } else if (Platform.isIOS) {
      // iOS 시뮬레이터: localhost 사용
      return 'http://localhost:8002';
    } else {
      // 기타 플랫폼
      return 'http://localhost:8002';
    }
  }
}
```

---

## 📱 실제 기기에서 테스트하는 경우

### PC의 IP 주소 확인 방법

**Windows:**
```bash
ipconfig

# 결과 예시:
# IPv4 주소 . . . . . . . . : 192.168.0.100
```

**Mac/Linux:**
```bash
ifconfig

# 또는
ip addr show
```

### 방화벽 설정

백엔드 서버가 실행 중인데도 연결이 안 되면:

**Windows 방화벽:**
1. Windows Defender 방화벽 열기
2. "인바운드 규칙" → "새 규칙"
3. 포트 8002 허용

**Mac:**
```bash
# 방화벽 설정에서 Python 허용
```

### 실제 기기 연결 테스트

```dart
// 실제 기기용 설정
static const String baseUrl = 'http://192.168.0.100:8002'; // PC IP 주소
```

---

## ✅ 테스트 방법

### 1. 백엔드 서버가 실행 중인지 확인
```bash
# Windows PowerShell
Invoke-WebRequest -Uri http://localhost:8002/health

# 결과: {"status":"healthy"}
```

### 2. 에뮬레이터에서 연결 테스트
Android 에뮬레이터에서:
```
브라우저 열기 → http://10.0.2.2:8002/health 접속
```

성공하면: `{"status":"healthy"}` 표시

### 3. Flutter 앱 재시작
```bash
cd D:/Dev_project/AI_Voice_Healthdoctor/healthai_app
flutter run
```

---

## 🐛 추가 문제 해결

### 문제: 여전히 연결 안 됨

**체크리스트:**
1. [ ] 백엔드 서버가 실행 중인가? (`python test_server.py`)
2. [ ] 포트 8002가 열려 있는가?
3. [ ] 방화벽이 8002 포트를 차단하고 있지 않은가?
4. [ ] `baseUrl`을 올바르게 수정했는가? (`10.0.2.2`)
5. [ ] Flutter 앱을 재시작했는가?

### 문제: iOS 시뮬레이터에서 안 됨

iOS는 `localhost`를 그대로 사용하면 됩니다:
```dart
static const String baseUrl = 'http://localhost:8002';
```

---

## 📚 참고 자료

- [Android 에뮬레이터 네트워킹](https://developer.android.com/studio/run/emulator-networking)
- [Flutter 네트워크 디버깅](https://flutter.dev/docs/development/data-and-backend/networking)

---

**작성일:** 2025-12-10
**문제:** Android 에뮬레이터 localhost 연결 실패
**해결:** `localhost` → `10.0.2.2` 변경
