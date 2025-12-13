# AI Voice Health Doctor - Claude Code 프로젝트 가이드

## 프로젝트 개요

AI 건강 주치의 앱 - OpenAI Realtime API를 활용한 실시간 음성 상담 서비스

### 기술 스택
- **Frontend**: Flutter 3.x (Dart)
- **Backend**: FastAPI (Python 3.11+)
- **Database**: PostgreSQL 15, Redis 7
- **AI**: OpenAI Realtime API (GPT-4o-realtime)
- **Containerization**: Docker Compose

## 프로젝트 구조

```
AI_Voice_Healthdoctor/
├── healthai_app/           # Flutter 앱
│   ├── lib/
│   │   ├── core/           # 공통 모듈 (config, router, services, models)
│   │   └── features/       # 기능별 모듈
│   │       ├── character/  # 캐릭터 선택 화면
│   │       └── conversation/ # 음성 상담 화면
│   └── assets/
│       └── lottie/         # 캐릭터 애니메이션 JSON
│
├── healthai-backend/       # Python 백엔드 (Git Submodule)
│   ├── core_api/           # 메인 API 서버 (포트 8002)
│   ├── conversation_service/ # 음성 상담 서비스 (포트 8004)
│   │   ├── characters.py   # AI 캐릭터 정의 및 시스템 프롬프트
│   │   └── websocket_handler.py # WebSocket 처리
│   └── docker-compose.yml
│
└── AI캐릭터_lottie_json/   # Lottie 원본 파일
```

## 개발 환경 설정

### 백엔드 실행
```bash
cd healthai-backend
docker-compose up -d
```

### 서비스 포트
- Core API: http://localhost:8002
- Conversation Service: http://localhost:8004
- PostgreSQL: localhost:5433
- Redis: localhost:6380

### Flutter 앱 빌드
```bash
cd healthai_app
flutter pub get
flutter build apk --release
flutter install --release
```

## 핵심 파일 가이드

### Flutter 앱

| 파일 | 설명 |
|------|------|
| `lib/core/config/api_config.dart` | API 엔드포인트 설정 |
| `lib/core/router/app_router.dart` | 화면 라우팅 |
| `lib/features/conversation/screens/voice_conversation_screen.dart` | 음성 상담 메인 화면 |
| `lib/features/conversation/services/audio_service.dart` | 오디오 녹음/재생 처리 |
| `lib/features/conversation/services/conversation_websocket_service.dart` | WebSocket 통신 |

### 백엔드

| 파일 | 설명 |
|------|------|
| `conversation_service/characters.py` | 6명의 AI 캐릭터 정의, 시스템 프롬프트 |
| `conversation_service/websocket_handler.py` | OpenAI Realtime API 연동 |
| `conversation_service/main.py` | FastAPI 앱 엔트리포인트 |

## AI 캐릭터 목록

| ID | 이름 | 전문분야 | 음성 |
|----|------|---------|------|
| park_jihoon | 박지훈 | 내과 전문의 | ash |
| choi_hyunwoo | 최현우 | 정신건강의학과 전문의 | echo |
| oh_kyungmi | 오경미 | 임상영양사 | coral |
| lee_soojin | 이수진 | 여성건강 전문의 | shimmer |
| park_eunseo | 박은서 | 소아청소년과 전문의 | alloy |
| jung_yujin | 정유진 | 노인의학과 전문의 | sage |

## 개발 시 주의사항

### 에코 방지 메커니즘
음성 상담에서 AI 응답이 마이크에 다시 입력되는 에코를 방지하기 위해 3중 플래그 시스템 사용:
- `_isAiResponding`: AI가 현재 응답 중인지
- `_isTranscriptDone`: AI transcript가 완료되었는지
- `_isAudioBuffering`: 오디오 버퍼링 중인지

### 오디오 포맷
- 녹음/재생: PCM16, 24kHz, Mono
- OpenAI Realtime API 요구사항에 맞춤

### API 엔드포인트
Android 에뮬레이터에서는 `10.0.2.2` 사용, 실제 디바이스에서는 실제 IP 사용

## 자주 사용하는 명령어

```bash
# 백엔드 서비스 재시작
cd healthai-backend && docker-compose restart conversation

# 백엔드 로그 확인
docker-compose logs -f conversation

# Flutter 앱 릴리스 빌드 및 설치
cd healthai_app && flutter build apk --release && flutter install --release

# Flutter 디버그 모드 실행
flutter run -d <device_id>
```

## 환경 변수

백엔드 `.env` 파일 필수 항목:
```
OPENAI_API_KEY=sk-...
DATABASE_URL=postgresql://...
REDIS_URL=redis://...
```

## 커밋 컨벤션

```
feat: 새로운 기능 추가
fix: 버그 수정
refactor: 코드 리팩토링
docs: 문서 수정
style: 코드 포맷팅
test: 테스트 추가/수정
```

## 트러블슈팅

### WebSocket 연결 실패
1. 백엔드 서비스 실행 확인: `docker-compose ps`
2. 포트 8004 접근 가능 여부 확인
3. API 설정에서 올바른 호스트 주소 사용 확인

### 오디오 재생 안됨
1. 마이크 권한 확인
2. PCM16 → WAV 변환 로직 확인
3. AudioPlayer 초기화 상태 확인

### AI 응답 에코
1. 3중 플래그 상태 확인
2. 안전 타이머(1.5초) 동작 확인
3. 오디오 재생 완료 콜백 확인
