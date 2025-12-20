# AI Voice Health Doctor - Claude Code 프로젝트 가이드

## 프로젝트 개요

AI 건강 주치의 앱 - OpenAI Realtime API를 활용한 실시간 음성 상담 서비스

### 참조 문서
이 프로젝트의 상세 기획 및 설계 문서:
- **PRD v1.3** - Product Requirements Document (제품 요구사항 정의서)
- **TRD v1.3** - Technical Requirements Document (기술 요구사항 정의서)
- **AI캐릭터 시스템프롬프트 가이드 v1.2** - AI 캐릭터별 페르소나 및 대화 가이드
- **개발 체크리스트 v1.3** - 기능별 개발 완료 체크리스트
- **UI/UX 디자인 가이드 v1.2** - 화면별 디자인 명세 및 사용자 경험 가이드

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

## Fly.io 배포

### 사전 준비
```bash
# Fly.io CLI 설치 (Windows)
powershell -Command "irm https://fly.io/install.ps1 | iex"

# 로그인
fly auth login

# 프로젝트 초기화
fly launch --no-deploy
```

### 데이터베이스 설정
```bash
# PostgreSQL 데이터베이스 생성
fly postgres create --name healthai-db --region nrt

# 데이터베이스 연결
fly postgres attach healthai-db

# Redis 생성
fly redis create --name healthai-redis --region nrt
```

### 환경 변수 설정
```bash
# Secrets 설정
fly secrets set OPENAI_API_KEY=sk-...
fly secrets set DATABASE_URL=postgresql://...
fly secrets set REDIS_URL=redis://...

# Secrets 확인
fly secrets list
```

### 배포 명령어
```bash
# 백엔드 배포 (healthai-backend 폴더에서)
cd healthai-backend

# Core API 배포
fly deploy -c fly.core.toml

# Conversation Service 배포
fly deploy -c fly.conversation.toml

# 배포 상태 확인
fly status
fly logs

# 앱 열기
fly open
```

### fly.toml 설정 예시

**fly.core.toml** (Core API):
```toml
app = "healthai-core"
primary_region = "nrt"

[build]
  dockerfile = "Dockerfile.core"

[env]
  PORT = "8002"

[http_service]
  internal_port = 8002
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
  processes = ["app"]

[[services]]
  protocol = "tcp"
  internal_port = 8002

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]

[checks]
  [checks.alive]
    grace_period = "30s"
    interval = "15s"
    method = "GET"
    path = "/api/v1/health"
    timeout = "10s"
    type = "http"
```

**fly.conversation.toml** (Conversation Service):
```toml
app = "healthai-conversation"
primary_region = "nrt"

[build]
  dockerfile = "Dockerfile.conversation"

[env]
  PORT = "8004"

[http_service]
  internal_port = 8004
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 0
  processes = ["app"]

[[services]]
  protocol = "tcp"
  internal_port = 8004

  [[services.ports]]
    port = 80
    handlers = ["http"]

  [[services.ports]]
    port = 443
    handlers = ["tls", "http"]
```

### 프로덕션 URL
- Core API: https://healthai-core.fly.dev
- Conversation Service: https://healthai-conversation.fly.dev

### Flutter 앱 API 설정 (프로덕션)
`lib/core/config/api_config.dart`에서 프로덕션 URL 설정:
```dart
static const String baseUrl = 'https://healthai-core.fly.dev';
static const String conversationWsUrl = 'wss://healthai-conversation.fly.dev';
```

### 유용한 Fly.io 명령어
```bash
# 앱 스케일링
fly scale count 2  # 2개 인스턴스로 확장

# 머신 재시작
fly machine restart

# 데이터베이스 접속
fly postgres connect -a healthai-db

# 리소스 모니터링
fly dashboard
```

## 윈도우즈 환경 개발 가이드

### 터미널 종류 및 차이점

#### 1. PowerShell (권장)
- 최신 윈도우즈 기본 터미널
- .NET 기반, 강력한 스크립팅 기능
- 대소문자 구분 안 함
- 별칭(Alias) 지원: `ls` = `Get-ChildItem`

```powershell
# Docker 명령어
docker-compose up -d
docker-compose logs -f conversation

# 파일 작업
ls                    # 파일 목록
cd healthai-backend   # 디렉토리 이동
cat .env              # 파일 내용 보기
```

#### 2. CMD (Command Prompt)
- 레거시 윈도우즈 터미널
- 제한적인 기능
- Unix 명령어 대부분 지원 안 함

```cmd
# DIR 명령어 사용
dir                   # 파일 목록 (ls 대신)
type .env             # 파일 내용 보기 (cat 대신)
del filename          # 파일 삭제 (rm 대신)
```

#### 3. Git Bash (개발 권장)
- Git 설치 시 포함
- Unix 스타일 명령어 지원
- Linux/Mac과 동일한 명령어 사용 가능

```bash
# Unix 스타일 명령어
ls -la
cat .env
rm -rf folder
grep "pattern" file.txt
```

### 경로 구분자 차이

**윈도우즈**: 백슬래시 (`\`)
```
D:\Dev_project\AI_Voice_Healthdoctor\healthai_app
```

**Unix/Git Bash**: 슬래시 (`/`)
```
D:/Dev_project/AI_Voice_Healthdoctor/healthai_app
```

**중요**:
- PowerShell/CMD에서는 두 가지 모두 작동
- 코드에서는 항상 `/` 사용 권장 (크로스 플랫폼)

### 주요 명령어 비교표

| 작업 | PowerShell/Git Bash | CMD | 설명 |
|------|-------------------|-----|------|
| 파일 목록 | `ls` | `dir` | 디렉토리 내용 보기 |
| 디렉토리 이동 | `cd` | `cd` | 디렉토리 변경 |
| 파일 내용 보기 | `cat` | `type` | 파일 내용 출력 |
| 파일 복사 | `cp` | `copy` | 파일 복사 |
| 파일 삭제 | `rm` | `del` | 파일 삭제 |
| 디렉토리 생성 | `mkdir` | `mkdir` | 폴더 생성 |
| 디렉토리 삭제 | `rm -rf` | `rmdir /s` | 폴더 삭제 |
| 현재 경로 | `pwd` | `cd` | 현재 디렉토리 경로 |
| 환경 변수 | `$env:VAR` | `%VAR%` | 환경 변수 접근 |
| 명령어 이력 | `history` | `doskey /history` | 명령어 기록 |
| 파일 찾기 | `Get-ChildItem -Recurse` | `dir /s` | 재귀 검색 |

### Flutter 개발 시 윈도우즈 명령어

```powershell
# Android 에뮬레이터 목록
flutter emulators

# 특정 에뮬레이터 실행
flutter emulators --launch Pixel_5_API_33

# 연결된 디바이스 확인
flutter devices

# 릴리스 빌드 (PowerShell)
cd healthai_app
flutter clean
flutter pub get
flutter build apk --release

# APK 파일 위치 (윈도우즈)
# build\app\outputs\flutter-apk\app-release.apk
```

### Docker 명령어 (윈도우즈)

```powershell
# Docker Desktop 실행 확인
docker --version

# 컨테이너 실행
cd healthai-backend
docker-compose up -d

# 로그 확인 (PowerShell)
docker-compose logs -f conversation

# 컨테이너 재시작
docker-compose restart core_api

# 컨테이너 중지 및 삭제
docker-compose down

# 볼륨까지 삭제
docker-compose down -v

# 특정 컨테이너 접속
docker-compose exec core_api bash
```

### 윈도우즈에서 Git 명령어

```bash
# Git Bash 권장 (Unix 스타일)
git status
git add .
git commit -m "feat: 새 기능 추가"
git push origin master

# 서브모듈 업데이트
git submodule update --remote

# 한글 파일명 처리
git config --global core.quotepath false
```

### 환경 변수 설정

**PowerShell (임시)**:
```powershell
$env:OPENAI_API_KEY = "sk-..."
$env:DATABASE_URL = "postgresql://..."
```

**PowerShell (영구)**:
```powershell
[System.Environment]::SetEnvironmentVariable('OPENAI_API_KEY', 'sk-...', 'User')
```

**시스템 설정**:
1. `시스템 > 고급 시스템 설정 > 환경 변수`
2. 사용자 변수 또는 시스템 변수에 추가

### 윈도우즈 개발 팁

1. **Windows Terminal 사용 권장**
   - PowerShell, CMD, Git Bash를 탭으로 전환
   - 다운로드: Microsoft Store에서 "Windows Terminal" 검색

2. **Git Bash를 기본 터미널로 설정**
   - VS Code: Settings > Terminal > Default Profile > Git Bash

3. **파일 경로 자동 완성**
   - PowerShell: `Tab` 키
   - Git Bash: `Tab` 키 (대소문자 구분)

4. **긴 경로 문제 해결**
   ```powershell
   # 관리자 권한 PowerShell에서 실행
   New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
   ```

5. **Docker Desktop 설정**
   - WSL 2 백엔드 사용 권장
   - Settings > Resources > File Sharing에 프로젝트 경로 추가
