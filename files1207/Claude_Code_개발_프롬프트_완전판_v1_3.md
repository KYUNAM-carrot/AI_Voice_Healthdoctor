# Claude Code 개발 프롬프트 완전판 v1.3

## 📋 문서 정보

**버전:** v1.3  
**최종 업데이트:** 2025-12-07  
**프로젝트:** Voice AI Health Doctor (음성 AI 건강 주치의)  
**대상:** Claude Code (AI 코딩 어시스턴트)

---

## 🎯 프로젝트 개요

### 핵심 가치 제안
**"6명의 AI 건강 주치의와 실시간 음성 상담"**

- 📱 **Flutter 앱**: React Native 대신 Flutter 채택 (크로스 플랫폼, 빠른 개발)
- 🎙️ **OpenAI Realtime API**: 실시간 음성 대화 (gpt-realtime-2025-08-28)
- 👥 **6명 AI 캐릭터**: 각기 다른 전문 분야와 음성 (박지훈-sage, 최현우-echo, 오경미-Cedar, 이수진-Marin, 박은서-shimmer, 정유진-alloy)
- 🌅 **아침 루틴**: 8가지 체크리스트 + 감사 일기
- ⌚ **웨어러블 연동**: Apple HealthKit, Android Health Connect
- 💰 **구독 모델**: RevenueCat (FREE/BASIC/PREMIUM/FAMILY)
- ☁️ **Fly.io 배포**: 홍콩 리전, 월 $20 (70% 비용 절감)

### 주요 변경사항 (v1.2 → v1.3)
1. **아키텍처 통합**: 7개 마이크로서비스 → 2개 (Core API + Conversation Service)
2. **배포 환경**: Replit → Fly.io (Hong Kong)
3. **비용 최적화**: $70/월 → $20/월 (70% 감소)
4. **AI 캐릭터 확대**: 4명 → 6명 (Cedar, Marin 추가)
5. **UI/UX 개선**: 20-50세 타겟, 정보 밀도 2배, 폰트 크기 감소

---

## 📚 문서 구조

이 개발 프롬프트는 **8개의 독립 가이드 문서**로 구성되어 있습니다:

### ✅ 완성된 가이드 문서

| 문서 | 내용 | 기간 | 파일 |
|------|------|------|------|
| **Day 1-8** | 인프라, 인증, 데이터베이스 | Week 1-2 | (이전 v1.2 완성) |
| **Day 9-14** | 가족 프로필 관리 | Week 3 | `Day_09-14_가족프로필관리_완전가이드.md` |
| **Day 15-28** | OpenAI Realtime API & AI 캐릭터 | Week 4-5 | `Day_15-28_OpenAI_Realtime_AI캐릭터_완전가이드.md` |
| **Day 29-42** | 웨어러블 & 건강 데이터 | Week 5-6 | `Day_29-42_웨어러블_건강데이터_완전가이드.md` |
| **Day 43-52** | RevenueCat & Flutter UI | Week 7-8 | `Day_43-52_RevenueCat_Flutter_UI_완전가이드.md` |
| **Day 53-56** | Fly.io 배포 & CI/CD | Week 9 | `Day_53-56_Fly_io_배포_완전가이드.md` |
| **Phase 1.5** | 아침 루틴 기능 | Day 57-61 | `Phase_1_5_아침루틴_완전가이드.md` |
| **Phase 2-5** | 고급 기능 (영양제, AI 코칭, 커뮤니티, 다국어) | Day 62-105 | `Phase_2-5_고급기능_개요.md` |

---

## 🚀 빠른 시작 (Quick Start)

### 1단계: 환경 설정
```bash
# 프로젝트 클론
git clone https://github.com/your-repo/voice-ai-health-doctor.git
cd voice-ai-health-doctor

# Docker Compose 실행
docker-compose up -d

# 데이터베이스 마이그레이션
docker-compose exec core_api alembic upgrade head

# 시드 데이터 실행
docker-compose exec core_api python scripts/seed_characters.py
docker-compose exec core_api python scripts/generate_intro_voices.py
docker-compose exec core_api python scripts/seed_morning_routine_items.py
```

### 2단계: 개발 가이드 선택
현재 개발 단계에 맞는 가이드 문서를 열어보세요:

```bash
# 예: Day 15-28 (OpenAI Realtime API)
open /mnt/user-data/outputs/Day_15-28_OpenAI_Realtime_AI캐릭터_완전가이드.md

# 예: Phase 1.5 (아침 루틴)
open /mnt/user-data/outputs/Phase_1_5_아침루틴_완전가이드.md
```

### 3단계: Claude Code에 프롬프트 제공
1. 해당 가이드 문서 전체를 복사
2. Claude Code에 붙여넣기
3. "Day XX 시작해줘" 라고 요청

---

## 📅 개발 로드맵

### Phase 1: MVP (Day 1-56, 8주)

#### ✅ Week 1-2: 인프라 & 인증 (Day 1-8)
- Docker Compose 환경
- PostgreSQL, Redis 설정
- FastAPI 프로젝트 구조
- 소셜 로그인 (Kakao, Google, Apple)
- JWT 인증

#### ✅ Week 3: 가족 프로필 (Day 9-14)
- User Service API
- Family Profile CRUD
- 구독 플랜별 제한 (FREE: 2, BASIC: 5, PREMIUM/FAMILY: 무제한)

#### ✅ Week 4-5: AI 캐릭터 & 음성 대화 (Day 15-28)
- OpenAI Realtime API 통합
- 6명 AI 캐릭터 (박지훈, 최현우, 오경미, 이수진, 박은서, 정유진)
- WebSocket 실시간 대화
- TTS 자기소개 음성 생성

#### ✅ Week 5-6: 건강 데이터 (Day 29-42)
- 건강 데이터 수동 입력 (혈압, 혈당, 체중 등)
- 웨어러블 데이터 동기화 API
- Apple HealthKit, Android Health Connect

#### ✅ Week 7-8: 구독 & Flutter UI (Day 43-52)
- RevenueCat 구독 시스템
- Flutter 테마 & 디자인 시스템 (정보 밀도 2배)
- 홈 화면, 가족 프로필, AI 대화 화면

#### ✅ Week 9: 배포 (Day 53-56)
- Fly.io 배포 (Hong Kong)
- GitHub Actions CI/CD
- Sentry 모니터링
- Health Check

### Phase 1.5: 아침 루틴 (Day 57-61, 1주)
- 8가지 체크리스트
- 감사 일기
- 연속 일수 추적
- 푸시 알림 (7:00 AM)

### Phase 2: 영양제 추천 (Day 62-70, 1.5주)
- InBody 데이터 분석
- 영양제 데이터베이스
- AI 추천 알고리즘

### Phase 3: AI 건강 코칭 (Day 71-84, 2주)
- Chroma DB 벡터 저장소
- 건강 지식 베이스
- RAG 기반 조언

### Phase 4: 커뮤니티 (Day 85-98, 2주)
- 게시판
- 챌린지 시스템
- 랭킹

### Phase 5: 다국어 (Day 99-105, 1주)
- 한/영/일/중 지원
- AI 캐릭터 다국어 프롬프트

---

## 🏗️ 기술 스택

### Backend
```yaml
Language: Python 3.11
Framework: FastAPI 0.115.0
Database: PostgreSQL 15
Cache: Redis 7
Vector Store: Chroma DB
ORM: SQLAlchemy 2.0
Migration: Alembic 1.14.0
```

### Frontend
```yaml
Framework: Flutter 3.24+
State Management: Riverpod 2.5.0
Navigation: Go Router 14.0.0
Subscription: RevenueCat (purchases_flutter 6.29.1)
```

### AI & Voice
```yaml
OpenAI: Realtime API (gpt-realtime-2025-08-28)
TTS: OpenAI TTS (tts-1, 0.95 speed)
Voices: sage, echo, Cedar, Marin, shimmer, alloy
```

### Infrastructure
```yaml
Hosting: Fly.io (Hong Kong)
Storage: Cloudflare R2
CDN: Cloudflare
CI/CD: GitHub Actions
Monitoring: Sentry
Cost: $20/month
```

---

## 📊 데이터베이스 스키마

### 핵심 테이블 (15개)

```sql
-- 인증 & 사용자
users
social_logins
subscriptions

-- 가족 & 프로필
family_profiles

-- AI 캐릭터
ai_characters

-- 건강 데이터
health_data
wearable_data

-- 아침 루틴
morning_routine_check_items
morning_routine_checks
gratitude_journals
morning_routine_notifications

-- 대화
conversations
conversation_messages

-- Phase 2+
inbody_measurements
supplements
```

---

## 🔗 API 엔드포인트 (Phase 1 완성)

### Core API (Port 8000)

#### 인증
```
POST   /api/v1/auth/login/kakao
POST   /api/v1/auth/login/google
POST   /api/v1/auth/login/apple
POST   /api/v1/auth/refresh
```

#### 사용자
```
GET    /api/v1/users/me
PATCH  /api/v1/users/me
DELETE /api/v1/users/me
```

#### 가족 프로필
```
GET    /api/v1/families
POST   /api/v1/families
GET    /api/v1/families/{id}
PATCH  /api/v1/families/{id}
DELETE /api/v1/families/{id}
```

#### AI 캐릭터
```
GET    /api/v1/characters
GET    /api/v1/characters/{id}
GET    /api/v1/characters/{id}/introduction
```

#### 건강 데이터
```
POST   /api/v1/health
GET    /api/v1/health/profiles/{id}
PATCH  /api/v1/health/{id}
DELETE /api/v1/health/{id}
```

#### 웨어러블
```
POST   /api/v1/wearables/sync
GET    /api/v1/wearables/profiles/{id}
GET    /api/v1/wearables/profiles/{id}/stats/daily
```

#### 아침 루틴
```
GET    /api/v1/morning-routine/today
PATCH  /api/v1/morning-routine/today
POST   /api/v1/morning-routine/gratitude
GET    /api/v1/morning-routine/stats
```

#### 구독
```
GET    /api/v1/subscriptions/me
POST   /api/v1/subscriptions/sync
```

### Conversation Service (Port 8001)

#### WebSocket
```
WS     ws://localhost:8001/ws/conversations/{character_id}
```

---

## 💰 구독 플랜

| 플랜 | 가격 | 가족 프로필 | AI 대화 | 데이터 보관 | 고급 분석 |
|------|------|------------|---------|------------|----------|
| **FREE** | 무료 | 2명 | 10회/월 | 30일 | ❌ |
| **BASIC** | ₩3,900/월 | 5명 | 100회/월 | 90일 | ❌ |
| **PREMIUM** | ₩5,900/월 | 무제한 | 무제한 | 365일 | ✅ |
| **FAMILY** | ₩9,900/월 | 무제한 | 무제한 | 365일 | ✅ |

---

## 👥 AI 캐릭터

| 이름 | 전문 분야 | 나이대 | 음성 | 특징 |
|------|----------|--------|------|------|
| **박지훈** | 내과 | 50대 | sage | 20년 경력, 만성질환 관리 |
| **최현우** | 정신건강 | 40대 | echo | 15년 경력, 스트레스/불면 |
| **오경미** | 영양사 | 30대 | Cedar | 12년 경력, 식단/영양제 |
| **이수진** | 여성건강 | 40대 | Marin | 18년 경력, 갱년기 |
| **박은서** | 소아청소년 | 40대 | shimmer | 15년 경력, 성장발달 |
| **정유진** | 노인의학 | 60대 | alloy | 25년 경력, 치매예방 |

---

## 🎨 UI/UX 디자인 시스템

### 컬러 팔레트
```
Primary: #6C5CE7 (보라색)
Secondary: #00B894 (민트색)
Accent: #FFB8B8 (핑크색)
Background: #FDFCFF (연보라)
Text: #2D3436 (진한 회색)
```

### 타이포그래피 (정보 밀도 2배)
```
H1: 24px (큰 제목)
H2: 20px (중간 제목)
H3: 16px (작은 제목)
Body1: 14px (본문)
Body2: 12px (작은 본문)
Caption: 11px (캡션)
```

### 스페이싱 (20-30% 감소)
```
XS: 4px
SM: 8px
MD: 12px
LG: 16px
XL: 20px
2XL: 24px
```

---

## ✅ 사용 방법

### Claude Code에서 사용하기

1. **특정 Day 개발 시작**
```
Day 15-28 가이드 문서를 복사하여 Claude Code에 붙여넣고:
"Day 15 시작해줘"
```

2. **단계별 진행**
- Claude Code가 각 Day의 체크리스트를 따라 개발
- 파일 작성, 테스트, 보고서 자동 생성
- 완료 후 다음 Day로 이동

3. **보고서 확인**
- 각 Day 완료 후 "Day XX 완료 보고서" 요청
- 작성된 파일, API 엔드포인트, 테스트 결과 확인

---

## 📦 배포된 URL

```
Core API: https://voice-ai-core-api.fly.dev
Conversation Service: https://voice-ai-conversation.fly.dev

API 문서: https://voice-ai-core-api.fly.dev/docs
WebSocket: wss://voice-ai-conversation.fly.dev/ws/conversations/{character_id}
```

---

## 📄 라이선스

MIT License

---

**이 문서는 Voice AI Health Doctor 프로젝트의 완전한 개발 가이드입니다.**  
**모든 가이드 문서는 `/mnt/user-data/outputs/` 디렉토리에서 확인할 수 있습니다.**

**프로젝트 성공을 기원합니다! 🚀**
