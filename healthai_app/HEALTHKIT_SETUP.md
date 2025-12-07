# HealthKit Setup Guide

## HealthKit Capability 활성화 방법

Flutter 앱에서 HealthKit을 사용하려면 Xcode에서 HealthKit Capability를 수동으로 활성화해야 합니다.

### 단계별 가이드

#### 1. Xcode에서 프로젝트 열기
```bash
cd healthai_app
open ios/Runner.xcworkspace
```

**중요**: `Runner.xcodeproj`가 아닌 `Runner.xcworkspace`를 열어야 합니다!

#### 2. Runner 타겟 선택
- 왼쪽 프로젝트 네비게이터에서 "Runner" 클릭
- 메인 창에서 "TARGETS" 아래 "Runner" 선택

#### 3. Signing & Capabilities 탭으로 이동
- 상단 탭에서 "Signing & Capabilities" 클릭

#### 4. Signing 설정 (필수)
- "Automatically manage signing" 체크박스 활성화
- Team 선택 (Apple Developer Account 필요)
- Bundle Identifier 확인: `com.healthai.healthaiApp`

#### 5. HealthKit Capability 추가
- "+ Capability" 버튼 클릭
- 검색창에 "HealthKit" 입력
- "HealthKit" 더블클릭하여 추가

#### 6. HealthKit 설정 확인
추가된 HealthKit 섹션에서 다음 옵션 확인:
- ☑️ Clinical Health Records (선택사항)
- ☑️ Background Delivery (백그라운드 동기화를 원할 경우)

#### 7. Info.plist 권한 확인
이미 설정되어 있는지 확인:
```xml
<key>NSHealthShareUsageDescription</key>
<string>건강 데이터를 읽어 AI 주치의에게 맞춤형 상담을 제공하기 위해 필요합니다.</string>

<key>NSHealthUpdateUsageDescription</key>
<string>건강 데이터를 기록하기 위해 필요합니다.</string>
```

✅ 이미 `ios/Runner/Info.plist`에 추가되어 있습니다!

## 테스트 방법

### 1. iOS 실기기 연결 (필수)
HealthKit은 **시뮬레이터에서 작동하지 않습니다**. 반드시 실제 iPhone이 필요합니다.

```bash
# 연결된 기기 확인
flutter devices

# 실기기로 실행
flutter run -d <device-id>
```

### 2. 건강 앱 테스트 데이터 추가

iPhone "건강" 앱에서 테스트 데이터를 수동으로 추가:

1. **걸음 수**
   - 건강 앱 → "요약" → "걸음수" 선택
   - 우측 상단 "데이터 추가" 클릭
   - 오늘 날짜에 10,000 걸음 입력

2. **심박수**
   - "요약" → "심박수" 선택
   - "데이터 추가" → 70-80 BPM 입력

3. **혈중 산소**
   - "요약" → "혈중 산소" 선택
   - "데이터 추가" → 98% 입력

4. **수면**
   - "요약" → "수면" 선택
   - "데이터 추가" → 어젯밤 7시간 입력

### 3. 앱에서 동기화 테스트

1. 앱 실행
2. "HealthKit 동기화" 버튼 클릭
3. HealthKit 권한 요청 팝업 → "허용" 클릭
4. 프로필 선택 후 "동기화" 버튼 클릭
5. 성공 메시지 확인: "동기화 완료: X개 추가"

### 4. Backend 확인

Backend API에서 동기화된 데이터 확인:
```bash
curl -H "Authorization: Bearer <token>" \
  http://localhost:8002/api/v1/wearables/profiles/<profile_id>
```

## 지원 데이터 타입

현재 구현된 HealthKit 데이터 타입:

| HealthKit 타입 | Backend 타입 | 단위 |
|---|---|---|
| STEPS | steps | 걸음 |
| HEART_RATE | heart_rate | BPM |
| BLOOD_OXYGEN | blood_oxygen | % |
| SLEEP_ASLEEP | sleep | 분 |
| ACTIVE_ENERGY_BURNED | calories | kcal |
| DISTANCE_WALKING_RUNNING | distance | km |

## 문제 해결

### 권한 요청이 표시되지 않음
- Info.plist에 권한 설명 추가 확인
- 앱 재설치 후 재시도
- iPhone 설정 → 개인정보 보호 → 건강 → 앱 확인

### "HealthKit not available" 오류
- 시뮬레이터가 아닌 실기기에서 실행 중인지 확인
- iOS 버전 8.0 이상인지 확인

### Capability 추가 실패
- Apple Developer Account 로그인 확인
- Team이 올바르게 선택되었는지 확인
- Bundle Identifier가 unique한지 확인

### 동기화 실패
- Backend 서버 실행 중인지 확인 (http://localhost:8002)
- 네트워크 연결 확인
- 로그인 토큰 유효성 확인

## 다음 단계

HealthKit 연동이 완료되면:
1. Android Health Connect 연동 (Day 39-41)
2. 건강 데이터 시각화 (Day 43-52)
3. AI 캐릭터와 건강 데이터 연계 상담 (Day 15-28)

## 참고 자료

- [Apple HealthKit Documentation](https://developer.apple.com/documentation/healthkit)
- [health Flutter package](https://pub.dev/packages/health)
- [Flutter iOS Development](https://docs.flutter.dev/deployment/ios)
