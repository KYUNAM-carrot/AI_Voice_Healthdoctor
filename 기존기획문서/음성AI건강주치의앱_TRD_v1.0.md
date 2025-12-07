# 음성 AI 건강주치의 앱 - Technical Requirements Document (TRD)

**Version:** 1.0  
**작성일:** 2025년 12월  
**상태:** Draft  
**관련 문서:** PRD v1.0

---

## 목차

1. [기술 개요](#1-기술-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [기술 스택](#3-기술-스택)
4. [데이터베이스 설계](#4-데이터베이스-설계)
5. [API 설계](#5-api-설계)
6. [AI/ML 파이프라인](#6-aiml-파이프라인)
7. [음성 처리 시스템](#7-음성-처리-시스템)
8. [웨어러블 연동](#8-웨어러블-연동)
9. [보안 설계](#9-보안-설계)
10. [인프라 및 배포](#10-인프라-및-배포)
11. [모니터링 및 로깅](#11-모니터링-및-로깅)
12. [개발 환경 설정](#12-개발-환경-설정)
13. [부록](#13-부록)

---

## 1. 기술 개요

### 1.1 프로젝트 요약

| 항목 | 내용 |
|------|------|
| **프로젝트명** | 음성 AI 건강주치의 앱 |
| **플랫폼** | Android / iOS (Cross-platform) |
| **프레임워크** | Flutter 3.x (Dart 3.x) |
| **개발 기간** | 16주 (MVP) |
| **개발 인원** | 1인 |
| **월 예산** | 500만원 ~ 1,000만원 |

### 1.2 기술적 목표

- **음성 지연시간**: 500ms 이내 (OpenAI Realtime API)
- **앱 시작 시간**: 3초 이내 (Cold Start)
- **API 응답 시간**: 2초 이내 (95th percentile)
- **동시 접속자**: 1,000명 이상
- **가용성**: 99.5% uptime

### 1.3 기술 결정 근거

#### Flutter 선택 이유 (vs React Native)

| 평가 항목 | Flutter | React Native | 선택 |
|----------|---------|--------------|------|
| 음성 실시간 처리 | Dart 비동기 우수, 낮은 레이턴시 | JS 브릿지 오버헤드 | ✅ Flutter |
| Health API 통합 | `health` 패키지 (통합) | 별도 패키지 2개 | ✅ Flutter |
| UI 일관성 | 자체 렌더링, 완벽한 일관성 | 플랫폼별 미세 차이 | ✅ Flutter |
| 성능 | 네이티브 컴파일 | JS 브릿지 | ✅ Flutter |
| 접근성 (WCAG) | Semantics 위젯 세밀 제어 | 기본 지원 | ✅ Flutter |

---

## 2. 시스템 아키텍처

### 2.1 고수준 아키텍처

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              CLIENT LAYER                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────────────────┐  │
│  │  Flutter App    │  │  Flutter App    │  │     Health Platform         │  │
│  │  (Android)      │  │  (iOS)          │  │  (HealthKit/Health Connect) │  │
│  └────────┬────────┘  └────────┬────────┘  └──────────────┬──────────────┘  │
│           │                    │                          │                  │
└───────────┼────────────────────┼──────────────────────────┼──────────────────┘
            │                    │                          │
            └────────────────────┼──────────────────────────┘
                                 │
                    ┌────────────┴────────────┐
                    │      API Gateway        │
                    │   (Nginx / Traefik)     │
                    └────────────┬────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────────────────┐
│                          BACKEND LAYER                                       │
├────────────────────────────────┼────────────────────────────────────────────┤
│           ┌────────────────────┴────────────────────┐                        │
│           │                                         │                        │
│  ┌────────┴────────┐  ┌─────────────────┐  ┌───────┴───────┐                │
│  │  Auth Service   │  │  User Service   │  │ Health Service│                │
│  │  (FastAPI)      │  │  (FastAPI)      │  │  (FastAPI)    │                │
│  └─────────────────┘  └─────────────────┘  └───────────────┘                │
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐              │
│  │  AI Service     │  │ Product Service │  │ Analytics Svc   │              │
│  │  (FastAPI)      │  │  (FastAPI)      │  │  (FastAPI)      │              │
│  └─────────────────┘  └─────────────────┘  └─────────────────┘              │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────────────────┐
│                           DATA LAYER                                         │
├────────────────────────────────┼────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌───────┴───────┐  ┌─────────────────┐                │
│  │   PostgreSQL    │  │    Redis      │  │   Chroma DB     │                │
│  │  (Primary DB)   │  │   (Cache)     │  │  (Vector DB)    │                │
│  └─────────────────┘  └───────────────┘  └─────────────────┘                │
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                                   │
│  │  Firebase       │  │   S3/MinIO     │                                   │
│  │  (Auth, FCM)    │  │  (File Storage)│                                   │
│  └─────────────────┘  └─────────────────┘                                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
                                 │
┌────────────────────────────────┼────────────────────────────────────────────┐
│                        EXTERNAL SERVICES                                     │
├────────────────────────────────┼────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌───────┴───────┐  ┌─────────────────┐                │
│  │  OpenAI API     │  │  Coupang API  │  │   iHerb API     │                │
│  │  (Realtime,GPT) │  │  (Affiliate)  │  │  (Affiliate)    │                │
│  └─────────────────┘  └───────────────┘  └─────────────────┘                │
│                                                                              │
│  ┌─────────────────┐  ┌─────────────────┐                                   │
│  │  Google AdMob   │  │  Kakao AdFit   │                                   │
│  └─────────────────┘  └─────────────────┘                                   │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘
```

### 2.2 마이크로서비스 구성

| 서비스 | 역할 | 주요 기능 | 포트 |
|--------|------|-----------|------|
| **Auth Service** | 인증/인가 | 회원가입, 로그인, 토큰 관리, SNS 연동 | 8001 |
| **User Service** | 사용자 관리 | 프로필, 가족 관리, 설정 | 8002 |
| **Health Service** | 건강 데이터 | 웨어러블 데이터, 상담 기록, 루틴 | 8003 |
| **AI Service** | AI 처리 | 캐릭터, RAG, 상담 분석 | 8004 |
| **Product Service** | 제품 추천 | 건강기능식품 DB, 추천 알고리즘 | 8005 |
| **Analytics Service** | 분석/통계 | 사용자 행동, 비즈니스 메트릭 | 8006 |

### 2.3 데이터 흐름

```
┌──────────────────────────────────────────────────────────────────┐
│                    음성 상담 데이터 흐름                          │
└──────────────────────────────────────────────────────────────────┘

[사용자 음성 입력]
       │
       ▼
┌─────────────────┐
│  Flutter App    │ ── 마이크 입력 (PCM 16kHz)
└────────┬────────┘
         │ WebSocket
         ▼
┌─────────────────┐
│  AI Service     │ ── 세션 관리, 컨텍스트 주입
└────────┬────────┘
         │ WebSocket
         ▼
┌─────────────────┐
│ OpenAI Realtime │ ── 음성 인식 + 응답 생성 + TTS
│      API        │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  RAG Pipeline   │ ── 의료 지식 검색 (Chroma DB)
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Safety Filter   │ ── 응급상황 감지, 금지 응답 필터링
└────────┬────────┘
         │
         ▼
[AI 음성 응답] ──▶ [사용자]
```

---

## 3. 기술 스택

### 3.1 Frontend (Mobile App)

| 카테고리 | 기술 | 버전 | 용도 |
|----------|------|------|------|
| **Framework** | Flutter | 3.x | 크로스플랫폼 앱 개발 |
| **Language** | Dart | 3.x | 애플리케이션 로직 |
| **상태관리** | Riverpod | 2.x | 전역 상태 관리 |
| **라우팅** | go_router | 최신 | 선언적 라우팅 |
| **HTTP** | dio | 5.x | REST API 통신 |
| **WebSocket** | web_socket_channel | 최신 | 실시간 음성 통신 |
| **오디오** | flutter_sound | 최신 | 오디오 녹음/재생 |
| **헬스데이터** | health | 최신 | HealthKit/Health Connect |
| **로컬저장소** | hive | 최신 | 로컬 캐싱 |
| **결제** | in_app_purchase | 최신 | IAP 처리 |
| **분석** | firebase_analytics | 최신 | 사용자 행동 분석 |
| **광고** | google_mobile_ads | 최신 | AdMob 연동 |
| **푸시** | firebase_messaging | 최신 | FCM 푸시 알림 |

### 3.2 Backend

| 카테고리 | 기술 | 버전 | 용도 |
|----------|------|------|------|
| **Framework** | FastAPI | 0.100+ | REST API 서버 |
| **Language** | Python | 3.11+ | 백엔드 로직 |
| **ORM** | SQLAlchemy | 2.x | 데이터베이스 ORM |
| **Migration** | Alembic | 최신 | DB 마이그레이션 |
| **Validation** | Pydantic | 2.x | 데이터 검증 |
| **Auth** | python-jose | 최신 | JWT 토큰 |
| **Password** | passlib[bcrypt] | 최신 | 비밀번호 해싱 |
| **Task Queue** | Celery | 5.x | 비동기 작업 |
| **WebSocket** | websockets | 최신 | 실시간 통신 |

### 3.3 Database & Storage

| 카테고리 | 기술 | 용도 |
|----------|------|------|
| **Primary DB** | PostgreSQL 15 | 관계형 데이터 저장 |
| **Vector DB** | Chroma DB | RAG 벡터 검색 |
| **Cache** | Redis 7 | 세션, 캐싱 |
| **File Storage** | MinIO / S3 | 미디어 파일 저장 |
| **Auth** | Firebase Auth | SNS 로그인 연동 |

### 3.4 AI/ML

| 카테고리 | 기술 | 용도 |
|----------|------|------|
| **Voice AI** | OpenAI Realtime API | 실시간 음성 대화 |
| **LLM** | GPT-4o | 텍스트 분석, 요약 |
| **Embeddings** | text-embedding-3-small | 벡터 임베딩 |
| **RAG** | LangChain | RAG 파이프라인 |

### 3.5 Infrastructure

| 카테고리 | 기술 | 용도 |
|----------|------|------|
| **Cloud (초기)** | Render | MVP 배포 |
| **Cloud (확장)** | AWS | 프로덕션 스케일 |
| **Container** | Docker | 컨테이너화 |
| **Orchestration** | Docker Compose | 로컬 개발 |
| **CI/CD** | GitHub Actions | 자동화 파이프라인 |
| **Reverse Proxy** | Nginx / Traefik | 로드밸런싱 |

### 3.6 패키지 의존성 (Flutter)

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  
  # 상태관리
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  
  # 라우팅
  go_router: ^12.0.0
  
  # 네트워크
  dio: ^5.3.0
  web_socket_channel: ^2.4.0
  
  # 오디오
  flutter_sound: ^9.2.0
  permission_handler: ^11.0.0
  
  # 헬스데이터
  health: ^8.0.0
  
  # 로컬 저장소
  hive: ^2.2.0
  hive_flutter: ^1.1.0
  shared_preferences: ^2.2.0
  flutter_secure_storage: ^9.0.0
  
  # Firebase
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  firebase_messaging: ^14.7.0
  firebase_analytics: ^10.7.0
  
  # 결제
  in_app_purchase: ^3.1.0
  
  # 광고
  google_mobile_ads: ^4.0.0
  
  # UI
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0
  shimmer: ^3.0.0
  fl_chart: ^0.65.0
  
  # 유틸리티
  intl: ^0.18.0
  uuid: ^4.2.0
  logger: ^2.0.0
  connectivity_plus: ^5.0.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  riverpod_generator: ^2.3.0
  build_runner: ^2.4.0
  hive_generator: ^2.0.0
  mockito: ^5.4.0
```

### 3.7 패키지 의존성 (Backend)

```txt
# requirements.txt
fastapi==0.104.1
uvicorn[standard]==0.24.0
python-multipart==0.0.6

# Database
sqlalchemy==2.0.23
asyncpg==0.29.0
alembic==1.12.1
redis==5.0.1

# Auth
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
firebase-admin==6.2.0

# AI/ML
openai==1.3.0
langchain==0.0.340
chromadb==0.4.18
tiktoken==0.5.1

# Utilities
pydantic==2.5.2
pydantic-settings==2.1.0
python-dotenv==1.0.0
httpx==0.25.2
aiohttp==3.9.1

# Task Queue
celery==5.3.4
flower==2.0.1

# Monitoring
sentry-sdk[fastapi]==1.38.0
prometheus-client==0.19.0

# Testing
pytest==7.4.3
pytest-asyncio==0.21.1
httpx==0.25.2
```

---

## 4. 데이터베이스 설계

### 4.1 ERD (Entity Relationship Diagram)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                              USER DOMAIN                                     │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────┐       ┌──────────────────┐       ┌──────────────────┐     │
│  │    users     │       │  family_profiles │       │ health_profiles  │     │
│  ├──────────────┤       ├──────────────────┤       ├──────────────────┤     │
│  │ id (PK)      │──┐    │ id (PK)          │──┐    │ id (PK)          │     │
│  │ email        │  │    │ user_id (FK)     │  │    │ family_id (FK)   │     │
│  │ password_hash│  └───▶│ nickname         │  └───▶│ height           │     │
│  │ name         │       │ relationship     │       │ weight           │     │
│  │ created_at   │       │ birth_date       │       │ chronic_diseases │     │
│  │ updated_at   │       │ gender           │       │ medications      │     │
│  │ is_active    │       │ age_months       │       │ allergies        │     │
│  │ subscription │       │ created_at       │       │ updated_at       │     │
│  └──────────────┘       └──────────────────┘       └──────────────────┘     │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           CONSULTATION DOMAIN                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐       ┌──────────────────┐                            │
│  │ consultations    │       │ consultation_msgs│                            │
│  ├──────────────────┤       ├──────────────────┤                            │
│  │ id (PK)          │──┐    │ id (PK)          │                            │
│  │ user_id (FK)     │  │    │ consultation_id  │                            │
│  │ family_id (FK)   │  └───▶│ role             │                            │
│  │ character_id     │       │ content          │                            │
│  │ started_at       │       │ audio_url        │                            │
│  │ ended_at         │       │ created_at       │                            │
│  │ duration_seconds │       └──────────────────┘                            │
│  │ summary          │                                                        │
│  │ topics[]         │       ┌──────────────────┐                            │
│  │ status           │       │  ai_characters   │                            │
│  └──────────────────┘       ├──────────────────┤                            │
│                             │ id (PK)          │                            │
│                             │ name             │                            │
│                             │ specialty        │                            │
│                             │ personality      │                            │
│                             │ voice_id         │                            │
│                             │ system_prompt    │                            │
│                             │ is_active        │                            │
│                             └──────────────────┘                            │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            HEALTH DATA DOMAIN                                │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐ │
│  │ wearable_data    │       │  daily_routines  │       │ gratitude_diaries│ │
│  ├──────────────────┤       ├──────────────────┤       ├──────────────────┤ │
│  │ id (PK)          │       │ id (PK)          │       │ id (PK)          │ │
│  │ family_id (FK)   │       │ family_id (FK)   │       │ user_id (FK)     │ │
│  │ data_type        │       │ date             │       │ date             │ │
│  │ value            │       │ routine_type     │       │ entries[]        │ │
│  │ unit             │       │ completed        │       │ created_at       │ │
│  │ recorded_at      │       │ completed_at     │       └──────────────────┘ │
│  │ source           │       └──────────────────┘                            │
│  └──────────────────┘                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                            PRODUCT DOMAIN                                    │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐       ┌──────────────────┐       ┌──────────────────┐ │
│  │    products      │       │ product_clicks   │       │ recommendations  │ │
│  ├──────────────────┤       ├──────────────────┤       ├──────────────────┤ │
│  │ id (PK)          │       │ id (PK)          │       │ id (PK)          │ │
│  │ name             │       │ user_id (FK)     │       │ consultation_id  │ │
│  │ description      │       │ product_id (FK)  │       │ product_id (FK)  │ │
│  │ category         │       │ clicked_at       │       │ reason           │ │
│  │ ingredients[]    │       │ converted        │       │ safety_checked   │ │
│  │ contraindications│       │ conversion_value │       │ created_at       │ │
│  │ affiliate_url    │       └──────────────────┘       └──────────────────┘ │
│  │ platform         │                                                        │
│  │ price            │                                                        │
│  │ image_url        │                                                        │
│  │ is_active        │                                                        │
│  └──────────────────┘                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                          SUBSCRIPTION DOMAIN                                 │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌──────────────────┐       ┌──────────────────┐                            │
│  │  subscriptions   │       │ subscription_logs│                            │
│  ├──────────────────┤       ├──────────────────┤                            │
│  │ id (PK)          │──┐    │ id (PK)          │                            │
│  │ user_id (FK)     │  │    │ subscription_id  │                            │
│  │ tier             │  └───▶│ action           │                            │
│  │ status           │       │ old_tier         │                            │
│  │ started_at       │       │ new_tier         │                            │
│  │ expires_at       │       │ created_at       │                            │
│  │ platform         │       └──────────────────┘                            │
│  │ receipt_data     │                                                        │
│  └──────────────────┘                                                        │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

### 4.2 테이블 상세 정의

#### 4.2.1 users 테이블

```sql
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255),  -- NULL for SNS login
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    
    -- SNS 연동
    provider VARCHAR(20),  -- 'email', 'kakao', 'google', 'apple'
    provider_id VARCHAR(255),
    
    -- 구독 정보
    subscription_tier VARCHAR(20) DEFAULT 'free',  -- free, basic, premium, family
    subscription_expires_at TIMESTAMP WITH TIME ZONE,
    
    -- 설정
    notification_enabled BOOLEAN DEFAULT true,
    language VARCHAR(10) DEFAULT 'ko',
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    last_login_at TIMESTAMP WITH TIME ZONE,
    is_active BOOLEAN DEFAULT true,
    deleted_at TIMESTAMP WITH TIME ZONE,
    
    CONSTRAINT unique_provider UNIQUE (provider, provider_id)
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_provider ON users(provider, provider_id);
```

#### 4.2.2 family_profiles 테이블

```sql
CREATE TABLE family_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    
    -- 기본 정보
    nickname VARCHAR(50) NOT NULL,  -- 애칭: 아빠, 엄마, 첫째아들 등
    relationship VARCHAR(30) NOT NULL,  -- self, father, mother, son, daughter, etc.
    birth_date DATE,
    age_months INTEGER,  -- 미성년자용 (개월수)
    gender VARCHAR(10),  -- male, female, other
    
    -- 프로필 이미지
    avatar_url VARCHAR(500),
    
    -- 웨어러블 연동
    wearable_enabled BOOLEAN DEFAULT false,
    
    -- 순서 (가족 목록 표시용)
    display_order INTEGER DEFAULT 0,
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true,
    
    CONSTRAINT unique_user_nickname UNIQUE (user_id, nickname)
);

CREATE INDEX idx_family_profiles_user_id ON family_profiles(user_id);
```

#### 4.2.3 health_profiles 테이블

```sql
CREATE TABLE health_profiles (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES family_profiles(id) ON DELETE CASCADE,
    
    -- 신체 정보
    height DECIMAL(5,2),  -- cm
    weight DECIMAL(5,2),  -- kg
    
    -- 건강 상태 (JSON Array)
    chronic_diseases JSONB DEFAULT '[]',  -- ["고혈압", "당뇨병"]
    medications JSONB DEFAULT '[]',  -- [{"name": "약이름", "dosage": "복용량", "frequency": "복용주기"}]
    allergies JSONB DEFAULT '[]',  -- ["땅콩", "갑각류"]
    
    -- 생활 습관
    smoking_status VARCHAR(20),  -- never, former, current
    alcohol_frequency VARCHAR(20),  -- never, rarely, weekly, daily
    exercise_frequency VARCHAR(20),  -- never, rarely, weekly, daily
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    
    CONSTRAINT unique_family_health UNIQUE (family_id)
);

CREATE INDEX idx_health_profiles_family_id ON health_profiles(family_id);
```

#### 4.2.4 consultations 테이블

```sql
CREATE TABLE consultations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    family_id UUID NOT NULL REFERENCES family_profiles(id) ON DELETE CASCADE,
    
    -- 상담 정보
    character_id VARCHAR(50) NOT NULL,  -- 박지훈, 최현우 등
    
    -- 시간 정보
    started_at TIMESTAMP WITH TIME ZONE NOT NULL,
    ended_at TIMESTAMP WITH TIME ZONE,
    duration_seconds INTEGER,
    
    -- 상담 내용 요약
    summary TEXT,
    topics JSONB DEFAULT '[]',  -- ["수면장애", "스트레스"]
    keywords JSONB DEFAULT '[]',  -- 검색용 키워드
    
    -- 상태
    status VARCHAR(20) DEFAULT 'active',  -- active, completed, interrupted
    termination_reason VARCHAR(50),  -- user_ended, time_limit, error, emergency
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_consultations_user_id ON consultations(user_id);
CREATE INDEX idx_consultations_family_id ON consultations(family_id);
CREATE INDEX idx_consultations_started_at ON consultations(started_at);
CREATE INDEX idx_consultations_character_id ON consultations(character_id);
```

#### 4.2.5 wearable_data 테이블

```sql
CREATE TABLE wearable_data (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    family_id UUID NOT NULL REFERENCES family_profiles(id) ON DELETE CASCADE,
    
    -- 데이터 유형
    data_type VARCHAR(30) NOT NULL,  -- steps, sleep, heart_rate, blood_pressure, blood_glucose
    
    -- 값
    value DECIMAL(10,2) NOT NULL,
    unit VARCHAR(20) NOT NULL,  -- steps, minutes, bpm, mmHg, mg/dL
    
    -- 추가 데이터 (혈압 등 복합 데이터용)
    metadata JSONB,  -- {"systolic": 120, "diastolic": 80}
    
    -- 측정 시간
    recorded_at TIMESTAMP WITH TIME ZONE NOT NULL,
    
    -- 출처
    source VARCHAR(30) NOT NULL,  -- health_connect, healthkit, manual
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_wearable_data_family_id ON wearable_data(family_id);
CREATE INDEX idx_wearable_data_type ON wearable_data(data_type);
CREATE INDEX idx_wearable_data_recorded_at ON wearable_data(recorded_at);

-- 파티셔닝 (월별)
-- 데이터 증가 시 파티셔닝 적용 고려
```

#### 4.2.6 products 테이블

```sql
CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- 기본 정보
    name VARCHAR(200) NOT NULL,
    description TEXT,
    category VARCHAR(50) NOT NULL,  -- vitamin, mineral, probiotic, omega3, etc.
    
    -- 성분 정보
    ingredients JSONB NOT NULL DEFAULT '[]',  -- [{"name": "비타민C", "amount": "1000mg"}]
    
    -- 안전 정보
    contraindications JSONB DEFAULT '[]',  -- 금기사항
    drug_interactions JSONB DEFAULT '[]',  -- 약물 상호작용
    
    -- 제휴 정보
    platform VARCHAR(20) NOT NULL,  -- coupang, iherb
    affiliate_url VARCHAR(500) NOT NULL,
    external_id VARCHAR(100),  -- 플랫폼 내 상품 ID
    
    -- 가격/이미지
    price DECIMAL(10,2),
    currency VARCHAR(3) DEFAULT 'KRW',
    image_url VARCHAR(500),
    
    -- 상태
    is_active BOOLEAN DEFAULT true,
    last_synced_at TIMESTAMP WITH TIME ZONE,
    
    -- 메타데이터
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_platform ON products(platform);
CREATE INDEX idx_products_is_active ON products(is_active);
```

### 4.3 데이터 암호화

```python
# 암호화 대상 필드
ENCRYPTED_FIELDS = {
    'users': ['phone'],
    'health_profiles': ['chronic_diseases', 'medications', 'allergies'],
    'consultations': ['summary'],
}

# 암호화 방식: AES-256-GCM
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.ciphers.aead import AESGCM

class FieldEncryption:
    def __init__(self, key: bytes):
        self.aesgcm = AESGCM(key)
    
    def encrypt(self, plaintext: str) -> bytes:
        nonce = os.urandom(12)
        ciphertext = self.aesgcm.encrypt(nonce, plaintext.encode(), None)
        return nonce + ciphertext
    
    def decrypt(self, ciphertext: bytes) -> str:
        nonce = ciphertext[:12]
        encrypted = ciphertext[12:]
        return self.aesgcm.decrypt(nonce, encrypted, None).decode()
```

---

## 5. API 설계

### 5.1 API 개요

- **Base URL**: `https://api.healthai.app/v1`
- **인증**: Bearer Token (JWT)
- **형식**: JSON (application/json)
- **버전관리**: URL Path (`/v1`, `/v2`)

### 5.2 인증 API

#### POST /auth/register
회원가입

```json
// Request
{
    "email": "user@example.com",
    "password": "SecurePass123!",
    "name": "홍길동",
    "agree_terms": true,
    "agree_privacy": true
}

// Response 201
{
    "success": true,
    "data": {
        "user_id": "uuid",
        "email": "user@example.com",
        "name": "홍길동"
    }
}
```

#### POST /auth/login
로그인

```json
// Request
{
    "email": "user@example.com",
    "password": "SecurePass123!"
}

// Response 200
{
    "success": true,
    "data": {
        "access_token": "eyJhbG...",
        "refresh_token": "eyJhbG...",
        "token_type": "Bearer",
        "expires_in": 3600,
        "user": {
            "id": "uuid",
            "email": "user@example.com",
            "name": "홍길동",
            "subscription_tier": "free"
        }
    }
}
```

#### POST /auth/social/{provider}
SNS 로그인 (kakao, google, apple)

```json
// Request
{
    "id_token": "SNS_ID_TOKEN",
    "access_token": "SNS_ACCESS_TOKEN"
}

// Response 200
{
    "success": true,
    "data": {
        "access_token": "eyJhbG...",
        "refresh_token": "eyJhbG...",
        "is_new_user": false,
        "user": { ... }
    }
}
```

#### POST /auth/refresh
토큰 갱신

```json
// Request
{
    "refresh_token": "eyJhbG..."
}

// Response 200
{
    "success": true,
    "data": {
        "access_token": "eyJhbG...",
        "expires_in": 3600
    }
}
```

### 5.3 사용자/가족 API

#### GET /users/me
내 정보 조회

```json
// Response 200
{
    "success": true,
    "data": {
        "id": "uuid",
        "email": "user@example.com",
        "name": "홍길동",
        "subscription_tier": "basic",
        "subscription_expires_at": "2025-01-15T00:00:00Z",
        "notification_enabled": true,
        "created_at": "2024-01-01T00:00:00Z"
    }
}
```

#### GET /family
가족 프로필 목록

```json
// Response 200
{
    "success": true,
    "data": {
        "profiles": [
            {
                "id": "uuid",
                "nickname": "나",
                "relationship": "self",
                "gender": "male",
                "age": 45,
                "wearable_enabled": true,
                "health_profile": {
                    "height": 175.5,
                    "weight": 70.2,
                    "chronic_diseases": ["고혈압"],
                    "medications": [],
                    "allergies": []
                }
            },
            {
                "id": "uuid",
                "nickname": "아내",
                "relationship": "spouse",
                "gender": "female",
                "age": 43,
                "wearable_enabled": false,
                "health_profile": { ... }
            }
        ],
        "limits": {
            "current": 2,
            "max": 4  // 구독 티어에 따름
        }
    }
}
```

#### POST /family
가족 프로필 추가

```json
// Request
{
    "nickname": "첫째아들",
    "relationship": "son",
    "birth_date": "2010-05-15",
    "gender": "male"
}

// Response 201
{
    "success": true,
    "data": {
        "id": "uuid",
        "nickname": "첫째아들",
        ...
    }
}
```

#### PUT /family/{family_id}/health
건강 프로필 수정

```json
// Request
{
    "height": 175.5,
    "weight": 70.2,
    "chronic_diseases": ["고혈압", "고지혈증"],
    "medications": [
        {
            "name": "아모디핀",
            "dosage": "5mg",
            "frequency": "1일 1회"
        }
    ],
    "allergies": ["땅콩"]
}

// Response 200
{
    "success": true,
    "data": { ... }
}
```

### 5.4 상담 API

#### GET /characters
AI 캐릭터 목록

```json
// Response 200
{
    "success": true,
    "data": {
        "characters": [
            {
                "id": "park_jihoon",
                "name": "박지훈",
                "specialty": "내과",
                "description": "만성질환 관리 및 일반 내과 상담 전문가",
                "personality": "신뢰감, 차분함, 논리적",
                "avatar_url": "https://..."
            },
            {
                "id": "choi_hyunwoo",
                "name": "최현우",
                "specialty": "정신건강",
                "description": "스트레스, 수면, 정서 상담 전문가",
                "personality": "공감적, 따뜻함, 경청",
                "avatar_url": "https://..."
            },
            // ... 6명
        ]
    }
}
```

#### POST /consultations
상담 세션 시작

```json
// Request
{
    "character_id": "park_jihoon",
    "family_id": "uuid"  // 상담 대상 가족 프로필
}

// Response 201
{
    "success": true,
    "data": {
        "consultation_id": "uuid",
        "websocket_url": "wss://api.healthai.app/ws/consultation/{consultation_id}",
        "token": "ws_auth_token",
        "session_limit_seconds": 300,  // 무료: 5분
        "disclaimer": "이 서비스는 의료 진단을 제공하지 않습니다..."
    }
}
```

#### GET /consultations
상담 이력 조회

```json
// Query Parameters
// family_id: uuid (optional)
// start_date: 2024-01-01 (optional)
// end_date: 2024-12-31 (optional)
// page: 1
// limit: 20

// Response 200
{
    "success": true,
    "data": {
        "consultations": [
            {
                "id": "uuid",
                "family_nickname": "나",
                "character_name": "박지훈",
                "started_at": "2024-12-01T10:30:00Z",
                "duration_seconds": 280,
                "summary": "수면 장애와 피로감에 대한 상담...",
                "topics": ["수면장애", "피로"]
            }
        ],
        "pagination": {
            "page": 1,
            "limit": 20,
            "total": 45,
            "total_pages": 3
        }
    }
}
```

#### GET /consultations/{id}
상담 상세 조회

```json
// Response 200
{
    "success": true,
    "data": {
        "id": "uuid",
        "family": {
            "id": "uuid",
            "nickname": "나"
        },
        "character": {
            "id": "park_jihoon",
            "name": "박지훈"
        },
        "started_at": "2024-12-01T10:30:00Z",
        "ended_at": "2024-12-01T10:35:00Z",
        "duration_seconds": 280,
        "status": "completed",
        "summary": "수면 장애와 피로감에 대한 상담...",
        "topics": ["수면장애", "피로"],
        "messages": [
            {
                "role": "assistant",
                "content": "안녕하세요, 내과 전문의 박지훈입니다...",
                "timestamp": "2024-12-01T10:30:05Z"
            },
            {
                "role": "user",
                "content": "요즘 잠을 잘 못 자서...",
                "timestamp": "2024-12-01T10:30:30Z"
            }
            // ...
        ],
        "recommendations": [
            {
                "product_id": "uuid",
                "product_name": "마그네슘 400mg",
                "reason": "수면 품질 개선에 도움"
            }
        ]
    }
}
```

### 5.5 WebSocket API (음성 상담)

#### 연결
```
wss://api.healthai.app/ws/consultation/{consultation_id}?token={ws_auth_token}
```

#### 클라이언트 → 서버 메시지

```json
// 음성 데이터 전송
{
    "type": "audio",
    "data": "base64_encoded_pcm_audio",
    "timestamp": 1701420600000
}

// 텍스트 메시지 (대체 입력)
{
    "type": "text",
    "content": "안녕하세요"
}

// 인터럽트 (AI 응답 중단)
{
    "type": "interrupt"
}

// 세션 종료
{
    "type": "end_session"
}
```

#### 서버 → 클라이언트 메시지

```json
// AI 음성 응답
{
    "type": "audio",
    "data": "base64_encoded_audio",
    "transcript": "네, 말씀하신 증상에 대해...",
    "is_final": false
}

// AI 텍스트 응답 완료
{
    "type": "transcript",
    "content": "네, 말씀하신 증상에 대해 자세히 설명드리겠습니다.",
    "is_final": true
}

// 제품 추천
{
    "type": "recommendation",
    "products": [
        {
            "id": "uuid",
            "name": "마그네슘 400mg",
            "image_url": "https://...",
            "affiliate_url": "https://..."
        }
    ]
}

// 응급 상황 감지
{
    "type": "emergency",
    "level": 1,
    "message": "증상이 심각해 보입니다. 즉시 119에 연락하시거나...",
    "action": "call_119"
}

// 세션 정보
{
    "type": "session_info",
    "remaining_seconds": 180,
    "warning": false  // 1분 남으면 true
}

// 에러
{
    "type": "error",
    "code": "SESSION_EXPIRED",
    "message": "세션이 만료되었습니다."
}
```

### 5.6 건강 데이터 API

#### POST /health/sync
웨어러블 데이터 동기화

```json
// Request
{
    "family_id": "uuid",
    "data": [
        {
            "type": "steps",
            "value": 8500,
            "unit": "steps",
            "recorded_at": "2024-12-01T23:59:59Z",
            "source": "health_connect"
        },
        {
            "type": "heart_rate",
            "value": 72,
            "unit": "bpm",
            "recorded_at": "2024-12-01T14:30:00Z",
            "source": "health_connect"
        },
        {
            "type": "blood_pressure",
            "value": 120,
            "unit": "mmHg",
            "metadata": {
                "systolic": 120,
                "diastolic": 80
            },
            "recorded_at": "2024-12-01T08:00:00Z",
            "source": "manual"
        }
    ]
}

// Response 201
{
    "success": true,
    "data": {
        "synced_count": 3,
        "last_sync_at": "2024-12-01T23:59:59Z"
    }
}
```

#### GET /health/stats
건강 통계 조회

```json
// Query Parameters
// family_id: uuid
// data_types: steps,heart_rate,sleep
// period: week|month|year
// start_date: 2024-12-01

// Response 200
{
    "success": true,
    "data": {
        "period": "week",
        "start_date": "2024-12-01",
        "end_date": "2024-12-07",
        "stats": {
            "steps": {
                "average": 7500,
                "total": 52500,
                "min": 3200,
                "max": 12000,
                "trend": "up",  // up, down, stable
                "daily": [
                    { "date": "2024-12-01", "value": 8500 },
                    { "date": "2024-12-02", "value": 6200 },
                    // ...
                ]
            },
            "heart_rate": {
                "average": 72,
                "min": 58,
                "max": 95,
                "resting_average": 62,
                "trend": "stable"
            },
            "sleep": {
                "average_minutes": 420,
                "average_quality": "good",  // poor, fair, good, excellent
                "trend": "up"
            }
        }
    }
}
```

### 5.7 제품 추천 API

#### GET /products/search
제품 검색

```json
// Query Parameters
// query: 비타민C
// category: vitamin
// page: 1
// limit: 20

// Response 200
{
    "success": true,
    "data": {
        "products": [
            {
                "id": "uuid",
                "name": "고함량 비타민C 1000mg",
                "category": "vitamin",
                "description": "...",
                "price": 25000,
                "currency": "KRW",
                "platform": "coupang",
                "image_url": "https://...",
                "affiliate_url": "https://..."
            }
        ],
        "pagination": { ... }
    }
}
```

#### POST /products/{id}/click
제품 클릭 추적

```json
// Request
{
    "consultation_id": "uuid",  // optional
    "source": "consultation"  // consultation, search, recommendation
}

// Response 200
{
    "success": true,
    "data": {
        "redirect_url": "https://affiliate.link/..."
    }
}
```

### 5.8 루틴/감사일기 API

#### GET /routines/today
오늘 루틴 조회

```json
// Response 200
{
    "success": true,
    "data": {
        "date": "2024-12-01",
        "routines": [
            {
                "id": "wake_up",
                "name": "기상",
                "completed": true,
                "completed_at": "2024-12-01T07:00:00Z"
            },
            {
                "id": "water",
                "name": "물 한 잔",
                "completed": false,
                "completed_at": null
            },
            {
                "id": "stretching",
                "name": "스트레칭",
                "completed": false,
                "completed_at": null
            }
        ],
        "completion_rate": 0.33
    }
}
```

#### POST /routines/{routine_id}/complete
루틴 완료 체크

```json
// Response 200
{
    "success": true,
    "data": {
        "routine_id": "water",
        "completed": true,
        "completed_at": "2024-12-01T07:15:00Z",
        "daily_completion_rate": 0.67
    }
}
```

#### POST /gratitude
감사일기 작성

```json
// Request
{
    "entries": [
        "오늘 날씨가 좋아서 산책했다",
        "점심을 맛있게 먹었다",
        "친구에게 좋은 소식을 들었다"
    ]
}

// Response 201
{
    "success": true,
    "data": {
        "id": "uuid",
        "date": "2024-12-01",
        "entries": [...],
        "streak_days": 7  // 연속 작성일
    }
}
```

### 5.9 구독 API

#### GET /subscription
구독 상태 조회

```json
// Response 200
{
    "success": true,
    "data": {
        "tier": "basic",
        "status": "active",
        "started_at": "2024-11-01T00:00:00Z",
        "expires_at": "2024-12-01T00:00:00Z",
        "auto_renew": true,
        "platform": "google_play",
        "features": {
            "family_limit": 4,
            "consultation_time_limit": 900,
            "ad_free": true,
            "advanced_stats": false
        }
    }
}
```

#### POST /subscription/verify
인앱 결제 검증

```json
// Request
{
    "platform": "google_play",  // google_play, app_store
    "product_id": "basic_monthly",
    "purchase_token": "...",
    "receipt_data": "..."  // iOS only
}

// Response 200
{
    "success": true,
    "data": {
        "verified": true,
        "tier": "basic",
        "expires_at": "2025-01-01T00:00:00Z"
    }
}
```

### 5.10 에러 응답 형식

```json
{
    "success": false,
    "error": {
        "code": "AUTH_001",
        "message": "인증 토큰이 만료되었습니다.",
        "details": {
            "expired_at": "2024-12-01T00:00:00Z"
        }
    }
}
```

#### 에러 코드 체계

| 코드 범위 | 카테고리 | 예시 |
|----------|----------|------|
| AUTH_0XX | 인증/인가 | AUTH_001: 토큰 만료 |
| USER_0XX | 사용자 | USER_001: 사용자 없음 |
| FAM_0XX | 가족 | FAM_001: 프로필 한도 초과 |
| CONS_0XX | 상담 | CONS_001: 세션 만료 |
| PROD_0XX | 제품 | PROD_001: 제품 없음 |
| SUB_0XX | 구독 | SUB_001: 결제 실패 |
| SYS_0XX | 시스템 | SYS_001: 내부 오류 |

---

## 6. AI/ML 파이프라인

### 6.1 RAG 시스템 아키텍처

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          RAG Pipeline Architecture                           │
└─────────────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────────────┐
│                           DATA INGESTION LAYER                               │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│  ┌─────────────────┐       ┌─────────────────┐       ┌─────────────────┐    │
│  │   NHIS 건강정보  │       │  만성질환 가이드 │       │  제품 안전정보   │    │
│  │   (47개 증상)    │       │   (6개 질환)     │       │   (성분/상호작용) │    │
│  └────────┬────────┘       └────────┬────────┘       └────────┬────────┘    │
│           │                         │                         │              │
│           └─────────────────────────┼─────────────────────────┘              │
│                                     │                                        │
│                          ┌──────────┴──────────┐                            │
│                          │   Document Loader    │                            │
│                          │   (Trafilatura +     │                            │
│                          │    BeautifulSoup)    │                            │
│                          └──────────┬──────────┘                            │
│                                     │                                        │
└─────────────────────────────────────┼────────────────────────────────────────┘
                                      │
┌─────────────────────────────────────┼────────────────────────────────────────┐
│                           PROCESSING LAYER                                   │
├─────────────────────────────────────┼────────────────────────────────────────┤
│                                     │                                        │
│                          ┌──────────┴──────────┐                            │
│                          │   Text Chunking     │                            │
│                          │   (6단계 구조화)     │                            │
│                          └──────────┬──────────┘                            │
│                                     │                                        │
│    ┌────────────────────────────────┼────────────────────────────────────┐  │
│    │                                │                                    │  │
│    ▼                                ▼                                    ▼  │
│ ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐     │
│ │기초의학   │  │행동지침   │  │증상원인   │  │예방관리   │  │주의사항   │     │
│ │정보      │  │권고      │  │         │  │법        │  │         │     │
│ └──────────┘  └──────────┘  └──────────┘  └──────────┘  └──────────┘     │
│                                     │                                        │
│                          ┌──────────┴──────────┐                            │
│                          │  OpenAI Embeddings  │                            │
│                          │ (text-embedding-3-  │                            │
│                          │       small)        │                            │
│                          └──────────┬──────────┘                            │
│                                     │                                        │
└─────────────────────────────────────┼────────────────────────────────────────┘
                                      │
┌─────────────────────────────────────┼────────────────────────────────────────┐
│                            STORAGE LAYER                                     │
├─────────────────────────────────────┼────────────────────────────────────────┤
│                                     │                                        │
│                          ┌──────────┴──────────┐                            │
│                          │     Chroma DB       │                            │
│                          │  (Vector Database)  │                            │
│                          └──────────┬──────────┘                            │
│                                     │                                        │
│    Collections:                     │                                        │
│    - symptoms (47개 증상)           │                                        │
│    - chronic_diseases (6개 질환)    │                                        │
│    - products (건강기능식품)         │                                        │
│    - safety (안전/금기사항)          │                                        │
│                                     │                                        │
└─────────────────────────────────────┼────────────────────────────────────────┘
                                      │
┌─────────────────────────────────────┼────────────────────────────────────────┐
│                           RETRIEVAL LAYER                                    │
├─────────────────────────────────────┼────────────────────────────────────────┤
│                                     │                                        │
│  ┌─────────────────┐     ┌──────────┴──────────┐     ┌─────────────────┐    │
│  │  Query Analysis │────▶│  Semantic Search    │────▶│  Re-ranking     │    │
│  │  (의도 분석)     │     │  (벡터 유사도)       │     │  (관련도 정렬)   │    │
│  └─────────────────┘     └─────────────────────┘     └────────┬────────┘    │
│                                                               │              │
│                                                    ┌──────────┴──────────┐  │
│                                                    │   Context Builder   │  │
│                                                    │   (컨텍스트 조합)    │  │
│                                                    └──────────┬──────────┘  │
│                                                               │              │
└───────────────────────────────────────────────────────────────┼──────────────┘
                                                                │
                                                     ┌──────────┴──────────┐
                                                     │    LLM (GPT-4o)     │
                                                     │   (응답 생성)        │
                                                     └─────────────────────┘
```

### 6.2 지식베이스 데이터 구조

```python
# 증상별 문서 구조
class SymptomDocument:
    symptom_name: str  # "두통"
    article_no: str    # "10830550"
    category: str      # "머리"
    
    sections: List[Section]
    # - 기초의학정보: 질환 정의, 개요
    # - 행동지침권고: 권고사항, 대처법
    # - 주요증상원인: 증상 목록, 원인
    # - 예방관리법: 예방법, 생활습관
    # - 주의사항: 경고, 위험신호
    # - 상세정보: 추가 정보, 출처
    
    metadata: Dict
    # - source_url
    # - last_updated
    # - version

# 47개 증상 목록
SYMPTOMS = {
    "머리": [
        "콧물/코막힘/부비동염", "어지럼증", "기침/가래", "인후통",
        "안면신경마비", "이명", "눈충혈/눈곱", "두통", "쉰목소리",
        "이가아프고시림", "잇몸붓고피남"
    ],
    "몸통": [
        "설사", "흉통", "소화불량/속쓰림", "배뇨장애", "복통",
        "호흡곤란/숨참", "변비", "혈뇨", "혈변", "월경이상/이상자궁출혈",
        "빈뇨/요실금/야뇨", "빈맥/두근거림"
    ],
    "근골격계": [
        "허리통증", "다리저림/종아리쥐남", "다리통증",
        "팔다리근력약화", "근육통", "관절통/무릎통증/목통증"
    ],
    "정신건강": [
        "우울/기분변화", "기억력/인지기능저하"
    ],
    "전신/일반": [
        "오심/구토", "수면장애/불면증", "피부발진/가려움증", "멍",
        "화상", "탈모", "체중감소", "부종/체중증가", "혈압상승",
        "발열", "황달", "식욕부진", "감기", "피로", "떨림/진전", "실신"
    ]
}

# 6개 만성질환 가이드
CHRONIC_DISEASES = [
    {
        "name": "고혈압",
        "category": "순환기질환",
        "keywords": ["고혈압", "혈압", "두통", "어지럼증"]
    },
    {
        "name": "당뇨병",
        "category": "내분비질환",
        "keywords": ["당뇨병", "혈당", "인슐린", "다뇨"]
    },
    {
        "name": "고지혈증",
        "category": "순환기질환",
        "keywords": ["고지혈증", "콜레스테롤", "동맥경화"]
    },
    {
        "name": "관절염",
        "category": "근골격계질환",
        "keywords": ["관절염", "관절통", "류마티스"]
    },
    {
        "name": "우울증",
        "category": "정신건강",
        "keywords": ["우울증", "우울감", "무기력", "수면장애"]
    },
    {
        "name": "치매",
        "category": "신경정신과",
        "keywords": ["치매", "인지기능", "기억력", "알츠하이머"]
    }
]
```

### 6.3 AI 캐릭터 시스템 프롬프트 구조

```python
CHARACTER_SYSTEM_PROMPTS = {
    "park_jihoon": """
## 역할
당신은 내과 전문의 '박지훈'입니다.

## 성격 특성
- 신뢰감 있고 차분한 말투
- 논리적이고 체계적인 설명
- 전문적이면서도 이해하기 쉬운 표현

## 전문 영역
- 만성질환 관리 (고혈압, 당뇨, 고지혈증)
- 일반 내과 질환 상담
- 건강검진 결과 해석

## 응답 지침
1. 환자의 증상을 경청하고 공감 표현
2. 관련 의학 정보를 쉽게 설명
3. 생활습관 개선 조언 제공
4. 필요시 전문의 진료 권유

## 금지 사항 (절대 위반 불가)
- 특정 질병 확정 진단 금지
- 약물 처방 또는 복용량 지시 금지
- 병원 방문 대체 발언 금지

## 응급 상황 대응
- Level 1 키워드 감지 시: 즉시 119 안내
- Level 2 키워드 감지 시: 위기상담전화 안내
- Level 3 키워드 감지 시: 의료기관 방문 강력 권고

## 면책 조항
모든 상담 시작 시 다음 내용 전달:
"저는 AI 건강 상담사로, 의학적 진단이나 처방을 제공하지 않습니다. 
증상이 심하거나 지속되면 반드시 의료기관을 방문해주세요."
""",

    "choi_hyunwoo": """
## 역할
당신은 정신건강의학과 전문의 '최현우'입니다.

## 성격 특성
- 공감적이고 따뜻한 말투
- 경청과 수용적 태도
- 비판단적 접근

## 전문 영역
- 스트레스 관리
- 수면 장애 상담
- 정서적 어려움 지원
- 번아웃 예방

## 응답 지침
1. 감정을 먼저 인정하고 공감
2. 판단하지 않고 경청
3. 실천 가능한 작은 조언 제공
4. 전문 도움 필요 시 자원 안내

## 자살/자해 대응 프로토콜
- 자살 관련 언급 감지 시:
  - 공감 표현 + 안전 확인
  - 정신건강위기상담전화 1577-0199 안내
  - 자살예방상담전화 1393 안내
  - 대화 유지하며 전문 도움 연결 권유
""",

    # ... (나머지 4명의 캐릭터 시스템 프롬프트)
}
```

### 6.4 안전 필터링 시스템

```python
class SafetyFilter:
    """AI 응답 안전성 검증"""
    
    # 응급 상황 키워드
    EMERGENCY_KEYWORDS = {
        "level_1": [  # 즉시 119
            "가슴이 찢어지", "의식을 잃", "심한 출혈",
            "호흡이 안", "숨을 못 쉬", "경련", "발작"
        ],
        "level_2": [  # 정신건강 위기
            "자살", "죽고 싶", "자해", "살고 싶지 않",
            "더 이상 못 살", "모든 게 끝", "사라지고 싶"
        ],
        "level_3": [  # 의료기관 권고
            "3일 이상 고열", "갑자기 시력", "갑작스런 마비",
            "심한 두통", "피를 토", "검은 변"
        ]
    }
    
    # 금지 응답 패턴
    PROHIBITED_PATTERNS = [
        r"당신은 .+병입니다",
        r"당신은 .+증입니다",
        r"진단 결과.+",
        r".+을 처방합니다",
        r".+mg.*복용",
        r"병원에 가지 않아도",
        r"의사 대신",
    ]
    
    def check_emergency(self, text: str) -> Optional[EmergencyResponse]:
        """응급 상황 감지"""
        for level, keywords in self.EMERGENCY_KEYWORDS.items():
            for keyword in keywords:
                if keyword in text:
                    return EmergencyResponse(
                        level=level,
                        keyword=keyword,
                        action=self._get_emergency_action(level)
                    )
        return None
    
    def filter_response(self, response: str) -> str:
        """금지 패턴 필터링"""
        for pattern in self.PROHIBITED_PATTERNS:
            if re.search(pattern, response):
                # 해당 부분 수정 또는 경고 추가
                response = self._sanitize_response(response, pattern)
        return response
    
    def _get_emergency_action(self, level: str) -> dict:
        actions = {
            "level_1": {
                "type": "emergency_call",
                "message": "증상이 심각해 보입니다. 즉시 119에 연락하시거나 가까운 응급실을 방문해주세요.",
                "numbers": ["119"]
            },
            "level_2": {
                "type": "crisis_support",
                "message": "많이 힘드시죠. 전문 상담사와 이야기해보시는 건 어떨까요?",
                "numbers": ["1577-0199", "1393"]
            },
            "level_3": {
                "type": "medical_visit",
                "message": "증상이 걱정됩니다. 가까운 시일 내에 의료기관을 방문하시길 권합니다.",
                "numbers": []
            }
        }
        return actions.get(level)
```

### 6.5 제품 추천 알고리즘

```python
class ProductRecommendationEngine:
    """건강기능식품 추천 엔진"""
    
    TRIGGER_THRESHOLD = 2  # 키워드 2회 언급 시 추천
    
    def __init__(self, chroma_client, safety_checker):
        self.chroma = chroma_client
        self.safety = safety_checker
        self.keyword_counter = defaultdict(int)
    
    async def process_conversation(
        self, 
        message: str, 
        health_profile: HealthProfile
    ) -> Optional[List[ProductRecommendation]]:
        """대화에서 추천 트리거 감지 및 제품 추천"""
        
        # 1. 키워드 추출
        keywords = self._extract_health_keywords(message)
        
        # 2. 키워드 카운트 업데이트
        for kw in keywords:
            self.keyword_counter[kw] += 1
        
        # 3. 트리거 조건 확인
        triggered_keywords = [
            kw for kw, count in self.keyword_counter.items()
            if count >= self.TRIGGER_THRESHOLD
        ]
        
        # 4. 명시적 요청 확인
        explicit_request = self._check_explicit_request(message)
        
        if not triggered_keywords and not explicit_request:
            return None
        
        # 5. 관련 제품 검색
        query = " ".join(triggered_keywords) if triggered_keywords else message
        products = await self._search_products(query)
        
        # 6. 안전성 검증
        safe_products = []
        for product in products:
            safety_result = await self.safety.check_product_safety(
                product=product,
                chronic_diseases=health_profile.chronic_diseases,
                medications=health_profile.medications,
                allergies=health_profile.allergies
            )
            
            if safety_result.is_safe:
                safe_products.append(ProductRecommendation(
                    product=product,
                    reason=self._generate_reason(product, triggered_keywords),
                    safety_notes=safety_result.notes
                ))
        
        # 7. 키워드 카운터 리셋
        for kw in triggered_keywords:
            self.keyword_counter[kw] = 0
        
        return safe_products[:3]  # 최대 3개 추천
    
    async def _search_products(self, query: str) -> List[Product]:
        """벡터 검색으로 관련 제품 조회"""
        results = self.chroma.query(
            collection="products",
            query_texts=[query],
            n_results=10
        )
        return [Product.from_dict(r) for r in results]
    
    def _check_explicit_request(self, message: str) -> bool:
        """명시적 제품 추천 요청 확인"""
        patterns = [
            r"영양제.*추천",
            r"건강기능식품.*추천",
            r"어떤.*먹으면",
            r"뭘.*먹어야",
            r"추천.*해주",
        ]
        return any(re.search(p, message) for p in patterns)
```

---

## 7. 음성 처리 시스템

### 7.1 OpenAI Realtime API 연동

```python
# backend/services/voice_service.py

import asyncio
import websockets
import json
from openai import AsyncOpenAI

class VoiceConsultationService:
    """음성 상담 서비스"""
    
    def __init__(self):
        self.client = AsyncOpenAI()
        self.sessions: Dict[str, VoiceSession] = {}
    
    async def create_session(
        self,
        consultation_id: str,
        character_id: str,
        family_profile: FamilyProfile,
        health_profile: HealthProfile
    ) -> VoiceSession:
        """음성 상담 세션 생성"""
        
        # 캐릭터 시스템 프롬프트 조회
        system_prompt = CHARACTER_SYSTEM_PROMPTS[character_id]
        
        # 사용자 컨텍스트 생성
        user_context = self._build_user_context(
            family_profile, health_profile
        )
        
        # OpenAI Realtime 세션 생성
        session = await self.client.beta.realtime.sessions.create(
            model="gpt-4o-realtime-preview",
            modalities=["audio", "text"],
            voice=CHARACTER_VOICES[character_id],
            instructions=f"{system_prompt}\n\n{user_context}",
            input_audio_format="pcm16",
            output_audio_format="pcm16",
            input_audio_transcription={
                "model": "whisper-1"
            },
            turn_detection={
                "type": "server_vad",
                "threshold": 0.5,
                "prefix_padding_ms": 300,
                "silence_duration_ms": 500
            }
        )
        
        voice_session = VoiceSession(
            consultation_id=consultation_id,
            openai_session=session,
            character_id=character_id,
            started_at=datetime.utcnow()
        )
        
        self.sessions[consultation_id] = voice_session
        return voice_session
    
    async def handle_websocket(
        self,
        websocket: WebSocket,
        consultation_id: str
    ):
        """WebSocket 연결 처리"""
        
        session = self.sessions.get(consultation_id)
        if not session:
            await websocket.close(code=4001, reason="Session not found")
            return
        
        try:
            async with self.client.beta.realtime.connect(
                session=session.openai_session
            ) as openai_ws:
                
                # 병렬로 양방향 스트리밍 처리
                await asyncio.gather(
                    self._forward_to_openai(websocket, openai_ws, session),
                    self._forward_from_openai(websocket, openai_ws, session)
                )
                
        except Exception as e:
            logger.error(f"WebSocket error: {e}")
            await websocket.send_json({
                "type": "error",
                "code": "CONNECTION_ERROR",
                "message": str(e)
            })
    
    async def _forward_to_openai(
        self,
        client_ws: WebSocket,
        openai_ws,
        session: VoiceSession
    ):
        """클라이언트 → OpenAI 오디오 전달"""
        
        async for message in client_ws:
            data = json.loads(message)
            
            if data["type"] == "audio":
                # 오디오 데이터 전달
                await openai_ws.send({
                    "type": "input_audio_buffer.append",
                    "audio": data["data"]
                })
                
            elif data["type"] == "interrupt":
                # AI 응답 중단
                await openai_ws.send({
                    "type": "response.cancel"
                })
                
            elif data["type"] == "end_session":
                # 세션 종료
                await self._end_session(session)
                break
    
    async def _forward_from_openai(
        self,
        client_ws: WebSocket,
        openai_ws,
        session: VoiceSession
    ):
        """OpenAI → 클라이언트 응답 전달"""
        
        async for event in openai_ws:
            if event["type"] == "response.audio.delta":
                # AI 오디오 응답
                await client_ws.send_json({
                    "type": "audio",
                    "data": event["delta"],
                    "is_final": False
                })
                
            elif event["type"] == "response.audio_transcript.done":
                # 텍스트 변환 완료
                transcript = event["transcript"]
                
                # 안전 필터링
                filtered = await self.safety_filter.filter_response(transcript)
                
                # 응급 상황 체크
                emergency = self.safety_filter.check_emergency(
                    session.last_user_message
                )
                if emergency:
                    await client_ws.send_json({
                        "type": "emergency",
                        "level": emergency.level,
                        "message": emergency.action["message"],
                        "numbers": emergency.action["numbers"]
                    })
                
                await client_ws.send_json({
                    "type": "transcript",
                    "content": filtered,
                    "is_final": True
                })
                
                # 메시지 저장
                await self._save_message(session, "assistant", filtered)
                
            elif event["type"] == "input_audio_buffer.speech_stopped":
                # 사용자 발화 종료 → 변환된 텍스트
                user_text = event.get("transcript", "")
                session.last_user_message = user_text
                await self._save_message(session, "user", user_text)
                
                # 제품 추천 체크
                recommendations = await self.product_engine.process_conversation(
                    user_text, session.health_profile
                )
                if recommendations:
                    await client_ws.send_json({
                        "type": "recommendation",
                        "products": [r.to_dict() for r in recommendations]
                    })
    
    def _build_user_context(
        self,
        family: FamilyProfile,
        health: HealthProfile
    ) -> str:
        """사용자 컨텍스트 문자열 생성"""
        
        context_parts = [
            f"## 상담 대상 정보",
            f"- 호칭: {family.nickname}",
            f"- 나이: {family.age}세" if family.age else f"- 개월수: {family.age_months}개월",
            f"- 성별: {family.gender}",
        ]
        
        if health.height and health.weight:
            bmi = health.weight / ((health.height / 100) ** 2)
            context_parts.append(f"- 신장/체중: {health.height}cm / {health.weight}kg (BMI: {bmi:.1f})")
        
        if health.chronic_diseases:
            context_parts.append(f"- 만성질환: {', '.join(health.chronic_diseases)}")
        
        if health.medications:
            meds = [f"{m['name']} {m['dosage']}" for m in health.medications]
            context_parts.append(f"- 복용 약물: {', '.join(meds)}")
        
        if health.allergies:
            context_parts.append(f"- 알레르기: {', '.join(health.allergies)}")
        
        return "\n".join(context_parts)
```

### 7.2 Flutter 음성 클라이언트

```dart
// lib/services/voice_consultation_service.dart

import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class VoiceConsultationService {
  WebSocketChannel? _channel;
  FlutterSoundRecorder? _recorder;
  FlutterSoundPlayer? _player;
  
  StreamController<VoiceEvent>? _eventController;
  Stream<VoiceEvent> get events => _eventController!.stream;
  
  Timer? _sessionTimer;
  int _remainingSeconds = 0;
  
  Future<void> startSession({
    required String consultationId,
    required String wsToken,
    required int sessionLimitSeconds,
  }) async {
    _eventController = StreamController<VoiceEvent>.broadcast();
    _remainingSeconds = sessionLimitSeconds;
    
    // 레코더/플레이어 초기화
    _recorder = FlutterSoundRecorder();
    _player = FlutterSoundPlayer();
    await _recorder!.openRecorder();
    await _player!.openPlayer();
    
    // WebSocket 연결
    final wsUrl = 'wss://api.healthai.app/ws/consultation/$consultationId?token=$wsToken';
    _channel = WebSocketChannel.connect(Uri.parse(wsUrl));
    
    // 메시지 수신 처리
    _channel!.stream.listen(
      _handleServerMessage,
      onError: _handleError,
      onDone: _handleDisconnect,
    );
    
    // 세션 타이머 시작
    _startSessionTimer();
    
    // 오디오 녹음 시작
    await _startRecording();
  }
  
  Future<void> _startRecording() async {
    await _recorder!.startRecorder(
      toStream: _audioStreamController.sink,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 16000,
    );
    
    // 오디오 스트림을 WebSocket으로 전송
    _audioStreamController.stream.listen((buffer) {
      if (_channel != null) {
        _channel!.sink.add(jsonEncode({
          'type': 'audio',
          'data': base64Encode(buffer),
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        }));
      }
    });
  }
  
  void _handleServerMessage(dynamic message) {
    final data = jsonDecode(message as String);
    
    switch (data['type']) {
      case 'audio':
        // AI 오디오 응답 재생
        final audioBytes = base64Decode(data['data']);
        _playAudio(audioBytes);
        break;
        
      case 'transcript':
        // 텍스트 응답
        _eventController!.add(TranscriptEvent(
          content: data['content'],
          isFinal: data['is_final'],
        ));
        break;
        
      case 'recommendation':
        // 제품 추천
        final products = (data['products'] as List)
            .map((p) => Product.fromJson(p))
            .toList();
        _eventController!.add(RecommendationEvent(products: products));
        break;
        
      case 'emergency':
        // 응급 상황
        _eventController!.add(EmergencyEvent(
          level: data['level'],
          message: data['message'],
          numbers: List<String>.from(data['numbers']),
        ));
        break;
        
      case 'session_info':
        // 세션 정보 업데이트
        _remainingSeconds = data['remaining_seconds'];
        _eventController!.add(SessionInfoEvent(
          remainingSeconds: _remainingSeconds,
          warning: data['warning'],
        ));
        break;
        
      case 'error':
        _eventController!.add(ErrorEvent(
          code: data['code'],
          message: data['message'],
        ));
        break;
    }
  }
  
  Future<void> _playAudio(Uint8List audioData) async {
    await _player!.startPlayer(
      fromDataBuffer: audioData,
      codec: Codec.pcm16,
      numChannels: 1,
      sampleRate: 24000,  // OpenAI output sample rate
    );
  }
  
  void interrupt() {
    // AI 응답 중단
    _channel?.sink.add(jsonEncode({'type': 'interrupt'}));
    _player?.stopPlayer();
  }
  
  void _startSessionTimer() {
    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _remainingSeconds--;
      
      if (_remainingSeconds <= 60 && _remainingSeconds % 30 == 0) {
        // 1분 이하일 때 30초마다 경고
        _eventController!.add(SessionInfoEvent(
          remainingSeconds: _remainingSeconds,
          warning: true,
        ));
      }
      
      if (_remainingSeconds <= 0) {
        endSession(reason: 'time_limit');
      }
    });
  }
  
  Future<void> endSession({String reason = 'user_ended'}) async {
    _sessionTimer?.cancel();
    
    _channel?.sink.add(jsonEncode({'type': 'end_session'}));
    
    await _recorder?.stopRecorder();
    await _player?.stopPlayer();
    await _recorder?.closeRecorder();
    await _player?.closePlayer();
    
    await _channel?.sink.close();
    await _eventController?.close();
  }
}

// 이벤트 클래스들
abstract class VoiceEvent {}

class TranscriptEvent extends VoiceEvent {
  final String content;
  final bool isFinal;
  TranscriptEvent({required this.content, required this.isFinal});
}

class RecommendationEvent extends VoiceEvent {
  final List<Product> products;
  RecommendationEvent({required this.products});
}

class EmergencyEvent extends VoiceEvent {
  final String level;
  final String message;
  final List<String> numbers;
  EmergencyEvent({required this.level, required this.message, required this.numbers});
}

class SessionInfoEvent extends VoiceEvent {
  final int remainingSeconds;
  final bool warning;
  SessionInfoEvent({required this.remainingSeconds, required this.warning});
}

class ErrorEvent extends VoiceEvent {
  final String code;
  final String message;
  ErrorEvent({required this.code, required this.message});
}
```

---

## 8. 웨어러블 연동

### 8.1 Flutter Health 패키지 구현

```dart
// lib/services/health_data_service.dart

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthDataService {
  final HealthFactory _health = HealthFactory();
  
  // 수집 대상 데이터 타입
  static const List<HealthDataType> dataTypes = [
    HealthDataType.STEPS,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.SLEEP_AWAKE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.HEART_RATE,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
    HealthDataType.WEIGHT,
    HealthDataType.HEIGHT,
  ];
  
  /// 권한 요청
  Future<bool> requestPermissions() async {
    // Android: Activity Recognition 권한
    if (Platform.isAndroid) {
      final activityStatus = await Permission.activityRecognition.request();
      if (!activityStatus.isGranted) return false;
    }
    
    // Health 데이터 접근 권한
    final permissions = dataTypes.map((type) => 
      HealthDataAccess.READ
    ).toList();
    
    final granted = await _health.requestAuthorization(
      dataTypes,
      permissions: permissions,
    );
    
    return granted;
  }
  
  /// 데이터 동기화
  Future<List<HealthData>> syncHealthData({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final List<HealthData> results = [];
    
    try {
      // 각 데이터 타입별 조회
      for (final type in dataTypes) {
        final data = await _health.getHealthDataFromTypes(
          startDate,
          endDate,
          [type],
        );
        
        for (final point in data) {
          results.add(HealthData(
            type: _mapHealthType(point.type),
            value: point.value.toDouble(),
            unit: _mapUnit(point.type),
            recordedAt: point.dateFrom,
            source: _getSourceName(),
            metadata: _extractMetadata(point),
          ));
        }
      }
      
      // 중복 제거
      final uniqueData = _removeDuplicates(results);
      
      return uniqueData;
    } catch (e) {
      logger.error('Health data sync failed: $e');
      rethrow;
    }
  }
  
  /// 오늘 걸음수 조회
  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day);
    
    final steps = await _health.getTotalStepsInInterval(midnight, now);
    return steps ?? 0;
  }
  
  /// 수면 데이터 조회
  Future<SleepSummary> getSleepData(DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    final sleepTypes = [
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_AWAKE,
      HealthDataType.SLEEP_IN_BED,
    ];
    
    final data = await _health.getHealthDataFromTypes(
      startOfDay,
      endOfDay,
      sleepTypes,
    );
    
    int asleepMinutes = 0;
    int awakeMinutes = 0;
    int inBedMinutes = 0;
    
    for (final point in data) {
      final duration = point.dateTo.difference(point.dateFrom).inMinutes;
      
      switch (point.type) {
        case HealthDataType.SLEEP_ASLEEP:
          asleepMinutes += duration;
          break;
        case HealthDataType.SLEEP_AWAKE:
          awakeMinutes += duration;
          break;
        case HealthDataType.SLEEP_IN_BED:
          inBedMinutes += duration;
          break;
        default:
          break;
      }
    }
    
    return SleepSummary(
      totalMinutes: inBedMinutes,
      asleepMinutes: asleepMinutes,
      awakeMinutes: awakeMinutes,
      efficiency: inBedMinutes > 0 
          ? (asleepMinutes / inBedMinutes * 100).round() 
          : 0,
    );
  }
  
  String _mapHealthType(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'steps';
      case HealthDataType.HEART_RATE:
        return 'heart_rate';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'blood_pressure';
      case HealthDataType.BLOOD_GLUCOSE:
        return 'blood_glucose';
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_IN_BED:
        return 'sleep';
      default:
        return type.name.toLowerCase();
    }
  }
  
  String _mapUnit(HealthDataType type) {
    switch (type) {
      case HealthDataType.STEPS:
        return 'steps';
      case HealthDataType.HEART_RATE:
        return 'bpm';
      case HealthDataType.BLOOD_PRESSURE_SYSTOLIC:
      case HealthDataType.BLOOD_PRESSURE_DIASTOLIC:
        return 'mmHg';
      case HealthDataType.BLOOD_GLUCOSE:
        return 'mg/dL';
      case HealthDataType.SLEEP_ASLEEP:
      case HealthDataType.SLEEP_AWAKE:
      case HealthDataType.SLEEP_IN_BED:
        return 'minutes';
      case HealthDataType.WEIGHT:
        return 'kg';
      case HealthDataType.HEIGHT:
        return 'cm';
      default:
        return '';
    }
  }
  
  String _getSourceName() {
    if (Platform.isAndroid) {
      return 'health_connect';
    } else if (Platform.isIOS) {
      return 'healthkit';
    }
    return 'unknown';
  }
}

// 데이터 모델
class HealthData {
  final String type;
  final double value;
  final String unit;
  final DateTime recordedAt;
  final String source;
  final Map<String, dynamic>? metadata;
  
  HealthData({
    required this.type,
    required this.value,
    required this.unit,
    required this.recordedAt,
    required this.source,
    this.metadata,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'value': value,
    'unit': unit,
    'recorded_at': recordedAt.toIso8601String(),
    'source': source,
    'metadata': metadata,
  };
}

class SleepSummary {
  final int totalMinutes;
  final int asleepMinutes;
  final int awakeMinutes;
  final int efficiency;
  
  SleepSummary({
    required this.totalMinutes,
    required this.asleepMinutes,
    required this.awakeMinutes,
    required this.efficiency,
  });
}
```

### 8.2 백그라운드 동기화

```dart
// lib/services/background_sync_service.dart

import 'package:workmanager/workmanager.dart';

class BackgroundSyncService {
  static const String healthSyncTask = 'health_sync_task';
  
  static Future<void> initialize() async {
    await Workmanager().initialize(
      callbackDispatcher,
      isInDebugMode: kDebugMode,
    );
    
    // 주기적 동기화 등록 (15분마다)
    await Workmanager().registerPeriodicTask(
      healthSyncTask,
      healthSyncTask,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: true,
      ),
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    switch (task) {
      case BackgroundSyncService.healthSyncTask:
        return await _syncHealthData();
      default:
        return Future.value(true);
    }
  });
}

Future<bool> _syncHealthData() async {
  try {
    final healthService = HealthDataService();
    final apiService = ApiService();
    
    // 마지막 동기화 이후 데이터 조회
    final lastSync = await _getLastSyncTime();
    final now = DateTime.now();
    
    final data = await healthService.syncHealthData(
      startDate: lastSync,
      endDate: now,
    );
    
    if (data.isNotEmpty) {
      // 서버로 전송
      await apiService.syncHealthData(data);
      await _saveLastSyncTime(now);
    }
    
    return true;
  } catch (e) {
    logger.error('Background health sync failed: $e');
    return false;
  }
}
```

---

## 9. 보안 설계

### 9.1 인증 흐름

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                          Authentication Flow                                 │
└─────────────────────────────────────────────────────────────────────────────┘

[이메일 로그인]
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│  Client │─────▶│  API    │─────▶│  Auth   │─────▶│  DB     │
│  (App)  │      │ Gateway │      │ Service │      │(Postgres)│
└─────────┘      └─────────┘      └─────────┘      └─────────┘
     │                                  │
     │  1. POST /auth/login             │
     │     {email, password}            │
     │─────────────────────────────────▶│
     │                                  │ 2. Verify password (bcrypt)
     │                                  │
     │                                  │ 3. Generate JWT tokens
     │  4. {access_token, refresh_token}│
     │◀─────────────────────────────────│
     │                                  │
     │  5. Store refresh_token          │
     │     (Secure Storage)             │
     │                                  │


[SNS 로그인 (Kakao 예시)]
┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐      ┌─────────┐
│  Client │      │  Kakao  │      │  API    │      │ Firebase│      │  Auth   │
│  (App)  │      │  OAuth  │      │ Gateway │      │  Auth   │      │ Service │
└─────────┘      └─────────┘      └─────────┘      └─────────┘      └─────────┘
     │                │                                  │                │
     │ 1. Login with Kakao                               │                │
     │───────────────▶│                                  │                │
     │                │                                  │                │
     │ 2. Kakao Access Token                             │                │
     │◀───────────────│                                  │                │
     │                                                   │                │
     │ 3. Sign in with custom token                      │                │
     │──────────────────────────────────────────────────▶│                │
     │                                                   │                │
     │ 4. Firebase ID Token                              │                │
     │◀──────────────────────────────────────────────────│                │
     │                                                                    │
     │ 5. POST /auth/social/kakao {id_token}                              │
     │───────────────────────────────────────────────────────────────────▶│
     │                                                                    │
     │                                                   │ 6. Verify Firebase token
     │                                                   │    Create/Update user
     │                                                                    │
     │ 7. {access_token, refresh_token}                                   │
     │◀───────────────────────────────────────────────────────────────────│


[토큰 갱신]
┌─────────┐      ┌─────────┐      ┌─────────┐
│  Client │      │  API    │      │  Auth   │
│  (App)  │      │ Gateway │      │ Service │
└─────────┘      └─────────┘      └─────────┘
     │                                  │
     │  1. Access Token 만료 감지        │
     │                                  │
     │  2. POST /auth/refresh           │
     │     {refresh_token}              │
     │─────────────────────────────────▶│
     │                                  │ 3. Verify refresh_token
     │                                  │    (Redis 블랙리스트 확인)
     │                                  │
     │                                  │ 4. Generate new access_token
     │  5. {access_token}               │
     │◀─────────────────────────────────│
```

### 9.2 JWT 토큰 구조

```python
# Access Token (1시간)
{
    "header": {
        "alg": "RS256",
        "typ": "JWT"
    },
    "payload": {
        "sub": "user_uuid",
        "email": "user@example.com",
        "tier": "basic",
        "iat": 1701420600,
        "exp": 1701424200,
        "jti": "unique_token_id"
    }
}

# Refresh Token (7일)
{
    "header": {
        "alg": "RS256",
        "typ": "JWT"
    },
    "payload": {
        "sub": "user_uuid",
        "type": "refresh",
        "iat": 1701420600,
        "exp": 1702025400,
        "jti": "unique_token_id"
    }
}
```

### 9.3 데이터 암호화

```python
# backend/core/security.py

from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.ciphers.aead import AESGCM
import os
import base64

class DataEncryption:
    """민감 데이터 암호화"""
    
    def __init__(self, key: bytes):
        self.aesgcm = AESGCM(key)
    
    def encrypt(self, plaintext: str) -> str:
        """AES-256-GCM 암호화"""
        nonce = os.urandom(12)
        ciphertext = self.aesgcm.encrypt(
            nonce, 
            plaintext.encode('utf-8'), 
            None
        )
        return base64.b64encode(nonce + ciphertext).decode('utf-8')
    
    def decrypt(self, encrypted: str) -> str:
        """AES-256-GCM 복호화"""
        data = base64.b64decode(encrypted.encode('utf-8'))
        nonce = data[:12]
        ciphertext = data[12:]
        plaintext = self.aesgcm.decrypt(nonce, ciphertext, None)
        return plaintext.decode('utf-8')

# 암호화 대상 필드
ENCRYPTED_FIELDS = {
    'users': ['phone'],
    'health_profiles': ['chronic_diseases', 'medications', 'allergies'],
    'consultations': ['summary'],
    'consultation_messages': ['content'],
}

# SQLAlchemy 암호화 타입
class EncryptedString(TypeDecorator):
    impl = String
    cache_ok = True
    
    def __init__(self, encryption: DataEncryption):
        self.encryption = encryption
        super().__init__()
    
    def process_bind_param(self, value, dialect):
        if value is not None:
            return self.encryption.encrypt(value)
        return value
    
    def process_result_value(self, value, dialect):
        if value is not None:
            return self.encryption.decrypt(value)
        return value
```

### 9.4 API 보안

```python
# backend/core/middleware.py

from fastapi import Request, HTTPException
from fastapi.security import HTTPBearer
from slowapi import Limiter
from slowapi.util import get_remote_address

# Rate Limiting
limiter = Limiter(key_func=get_remote_address)

# API 제한 설정
RATE_LIMITS = {
    "default": "100/minute",
    "auth": "10/minute",
    "consultation": "20/minute",
    "health_sync": "60/hour",
}

# CORS 설정
CORS_CONFIG = {
    "allow_origins": [
        "https://healthai.app",
        "capacitor://localhost",  # iOS
        "http://localhost",  # Android
    ],
    "allow_methods": ["GET", "POST", "PUT", "DELETE"],
    "allow_headers": ["*"],
    "allow_credentials": True,
}

# 요청 검증 미들웨어
class SecurityMiddleware:
    async def __call__(self, request: Request, call_next):
        # 1. Request ID 생성
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id
        
        # 2. IP 검증 (블랙리스트)
        client_ip = get_remote_address(request)
        if await self._is_blocked_ip(client_ip):
            raise HTTPException(status_code=403, detail="Blocked")
        
        # 3. User-Agent 검증
        user_agent = request.headers.get("user-agent", "")
        if not self._is_valid_user_agent(user_agent):
            raise HTTPException(status_code=403, detail="Invalid client")
        
        # 4. 요청 로깅
        logger.info(f"[{request_id}] {request.method} {request.url.path}")
        
        # 5. 요청 처리
        response = await call_next(request)
        
        # 6. 보안 헤더 추가
        response.headers["X-Request-ID"] = request_id
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["X-XSS-Protection"] = "1; mode=block"
        
        return response
```

### 9.5 Flutter 보안 저장소

```dart
// lib/core/secure_storage.dart

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );
  
  // 키 정의
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  
  /// Access Token 저장
  static Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }
  
  /// Access Token 조회
  static Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }
  
  /// Refresh Token 저장
  static Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }
  
  /// Refresh Token 조회
  static Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }
  
  /// 모든 토큰 삭제 (로그아웃)
  static Future<void> clearTokens() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userIdKey);
  }
  
  /// 전체 삭제
  static Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}
```

---

## 10. 인프라 및 배포

### 10.1 인프라 구성 (초기 - Render)

```yaml
# render.yaml

services:
  # API Gateway
  - type: web
    name: api-gateway
    env: docker
    dockerfilePath: ./docker/Dockerfile.gateway
    envVars:
      - key: PORT
        value: 8000
    healthCheckPath: /health
    
  # Auth Service
  - type: web
    name: auth-service
    env: docker
    dockerfilePath: ./docker/Dockerfile.auth
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: healthai-db
          property: connectionString
      - key: REDIS_URL
        fromService:
          name: redis
          type: redis
          property: connectionString
    
  # AI Service
  - type: web
    name: ai-service
    env: docker
    dockerfilePath: ./docker/Dockerfile.ai
    plan: standard  # GPU 필요 없음 (OpenAI API 사용)
    envVars:
      - key: OPENAI_API_KEY
        sync: false
      - key: CHROMA_HOST
        value: chroma-db

databases:
  # PostgreSQL
  - name: healthai-db
    plan: starter
    postgresMajorVersion: 15
    
  # Redis
  - name: redis
    type: redis
    plan: starter
```

### 10.2 Docker 구성

```dockerfile
# docker/Dockerfile.api

FROM python:3.11-slim

WORKDIR /app

# 시스템 의존성
RUN apt-get update && apt-get install -y \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 소스 코드
COPY . .

# 실행
EXPOSE 8000
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

```yaml
# docker-compose.yml (로컬 개발)

version: '3.8'

services:
  # API Gateway
  api-gateway:
    build:
      context: .
      dockerfile: docker/Dockerfile.gateway
    ports:
      - "8000:8000"
    environment:
      - AUTH_SERVICE_URL=http://auth-service:8001
      - USER_SERVICE_URL=http://user-service:8002
      - AI_SERVICE_URL=http://ai-service:8004
    depends_on:
      - auth-service
      - user-service
      - ai-service
  
  # Auth Service
  auth-service:
    build:
      context: .
      dockerfile: docker/Dockerfile.auth
    ports:
      - "8001:8001"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/healthai
      - REDIS_URL=redis://redis:6379
    depends_on:
      - postgres
      - redis
  
  # User Service
  user-service:
    build:
      context: .
      dockerfile: docker/Dockerfile.user
    ports:
      - "8002:8002"
    environment:
      - DATABASE_URL=postgresql://postgres:postgres@postgres:5432/healthai
    depends_on:
      - postgres
  
  # AI Service
  ai-service:
    build:
      context: .
      dockerfile: docker/Dockerfile.ai
    ports:
      - "8004:8004"
    environment:
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - CHROMA_HOST=chroma
    depends_on:
      - chroma
  
  # PostgreSQL
  postgres:
    image: postgres:15
    environment:
      - POSTGRES_USER=postgres
      - POSTGRES_PASSWORD=postgres
      - POSTGRES_DB=healthai
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - "5432:5432"
  
  # Redis
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
  
  # Chroma DB
  chroma:
    image: chromadb/chroma:latest
    ports:
      - "8005:8000"
    volumes:
      - chroma_data:/chroma/chroma

volumes:
  postgres_data:
  redis_data:
  chroma_data:
```

### 10.3 CI/CD 파이프라인

```yaml
# .github/workflows/deploy.yml

name: Deploy to Production

on:
  push:
    branches: [main]
  workflow_dispatch:

env:
  FLUTTER_VERSION: '3.16.0'

jobs:
  # 백엔드 테스트
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-asyncio pytest-cov
      
      - name: Run tests
        run: |
          pytest tests/ --cov=app --cov-report=xml
      
      - name: Upload coverage
        uses: codecov/codecov-action@v3
  
  # Flutter 빌드 (Android)
  build-android:
    runs-on: ubuntu-latest
    needs: test-backend
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build APK
        run: flutter build apk --release
      
      - name: Build App Bundle
        run: flutter build appbundle --release
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: android-release
          path: |
            build/app/outputs/flutter-apk/app-release.apk
            build/app/outputs/bundle/release/app-release.aab
  
  # Flutter 빌드 (iOS)
  build-ios:
    runs-on: macos-latest
    needs: test-backend
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: ${{ env.FLUTTER_VERSION }}
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build iOS
        run: flutter build ios --release --no-codesign
      
      - name: Upload artifacts
        uses: actions/upload-artifact@v3
        with:
          name: ios-release
          path: build/ios/iphoneos/Runner.app
  
  # 백엔드 배포 (Render)
  deploy-backend:
    runs-on: ubuntu-latest
    needs: [test-backend]
    steps:
      - name: Deploy to Render
        env:
          RENDER_API_KEY: ${{ secrets.RENDER_API_KEY }}
        run: |
          curl -X POST "https://api.render.com/v1/services/${{ secrets.RENDER_SERVICE_ID }}/deploys" \
            -H "Authorization: Bearer $RENDER_API_KEY"
```

### 10.4 확장 계획 (AWS)

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                         AWS Production Architecture                          │
└─────────────────────────────────────────────────────────────────────────────┘

                              ┌─────────────────┐
                              │   CloudFront    │
                              │     (CDN)       │
                              └────────┬────────┘
                                       │
                              ┌────────┴────────┐
                              │       ALB       │
                              │ (Load Balancer) │
                              └────────┬────────┘
                                       │
┌──────────────────────────────────────┼──────────────────────────────────────┐
│                                  VPC │                                       │
│    ┌─────────────────────────────────┼─────────────────────────────────┐    │
│    │                        Private Subnet                              │    │
│    │                                 │                                  │    │
│    │    ┌────────────────────────────┴────────────────────────────┐    │    │
│    │    │                         EKS Cluster                      │    │    │
│    │    │                                                          │    │    │
│    │    │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐│    │    │
│    │    │  │   Auth   │  │   User   │  │    AI    │  │ Product  ││    │    │
│    │    │  │ Service  │  │ Service  │  │ Service  │  │ Service  ││    │    │
│    │    │  │  (3x)    │  │  (2x)    │  │  (3x)    │  │  (2x)    ││    │    │
│    │    │  └──────────┘  └──────────┘  └──────────┘  └──────────┘│    │    │
│    │    │                                                          │    │    │
│    │    └──────────────────────────────────────────────────────────┘    │    │
│    │                                                                    │    │
│    │    ┌──────────┐  ┌──────────┐  ┌──────────┐                       │    │
│    │    │   RDS    │  │ ElastiC- │  │   S3     │                       │    │
│    │    │(Postgres)│  │  ache    │  │ (Files)  │                       │    │
│    │    │ (Multi-AZ)│ │ (Redis)  │  │          │                       │    │
│    │    └──────────┘  └──────────┘  └──────────┘                       │    │
│    │                                                                    │    │
│    └────────────────────────────────────────────────────────────────────┘    │
│                                                                              │
└──────────────────────────────────────────────────────────────────────────────┘

예상 비용 (월간):
- EKS: ~$73
- RDS (db.t3.medium): ~$50
- ElastiCache (cache.t3.micro): ~$15
- ALB: ~$20
- S3: ~$5
- CloudFront: ~$10
- 기타: ~$27
-----------------
총: ~$200/월 (초기)
```

---

## 11. 모니터링 및 로깅

### 11.1 모니터링 스택

```yaml
# 모니터링 구성
monitoring:
  # 애플리케이션 모니터링
  application:
    - Sentry (에러 추적)
    - Firebase Crashlytics (앱 크래시)
    
  # 인프라 모니터링
  infrastructure:
    - Render Metrics (초기)
    - CloudWatch (AWS 이후)
    
  # 비즈니스 메트릭
  business:
    - Firebase Analytics
    - Mixpanel (선택)
    
  # 로그 관리
  logging:
    - CloudWatch Logs (AWS)
    - Render Logs (초기)
```

### 11.2 로깅 구조

```python
# backend/core/logging.py

import structlog
from pythonjsonlogger import jsonlogger

# 구조화된 로깅 설정
structlog.configure(
    processors=[
        structlog.stdlib.filter_by_level,
        structlog.stdlib.add_logger_name,
        structlog.stdlib.add_log_level,
        structlog.stdlib.PositionalArgumentsFormatter(),
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.UnicodeDecoder(),
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.stdlib.BoundLogger,
    context_class=dict,
    logger_factory=structlog.stdlib.LoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# 사용 예시
logger.info(
    "consultation_started",
    user_id=user_id,
    character_id=character_id,
    family_id=family_id,
    session_limit=session_limit
)
```

### 11.3 핵심 메트릭

```python
# 추적할 핵심 메트릭
METRICS = {
    # 사용자 메트릭
    "user": [
        "daily_active_users",
        "monthly_active_users",
        "new_registrations",
        "retention_rate_d1_d7_d30",
    ],
    
    # 상담 메트릭
    "consultation": [
        "sessions_per_day",
        "avg_session_duration",
        "sessions_by_character",
        "emergency_triggers",
    ],
    
    # 수익 메트릭
    "revenue": [
        "subscription_conversions",
        "mrr",
        "arpu",
        "product_click_rate",
        "affiliate_conversions",
    ],
    
    # 기술 메트릭
    "technical": [
        "api_latency_p95",
        "voice_latency_p95",
        "error_rate",
        "uptime",
    ],
}
```

---

## 12. 개발 환경 설정

### 12.1 필수 도구

```bash
# 시스템 요구사항
- macOS 12+ / Windows 10+ / Ubuntu 20.04+
- 8GB RAM 이상
- 20GB 디스크 공간

# 필수 설치
1. Flutter SDK 3.16+
2. Dart SDK 3.2+
3. Android Studio / Xcode
4. Docker Desktop
5. Python 3.11+
6. PostgreSQL 15 (로컬 또는 Docker)
7. Redis 7 (Docker)

# 추천 IDE/에디터
- VS Code + Flutter Extension
- Android Studio (Android 개발)
- Xcode (iOS 개발)

# VS Code 확장
- Flutter
- Dart
- Python
- Docker
- GitLens
- Thunder Client (API 테스트)
```

### 12.2 프로젝트 구조

```
healthai-app/
├── mobile/                    # Flutter 앱
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app/
│   │   │   ├── app.dart
│   │   │   └── routes.dart
│   │   ├── core/
│   │   │   ├── config/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   ├── network/
│   │   │   └── utils/
│   │   ├── features/
│   │   │   ├── auth/
│   │   │   ├── consultation/
│   │   │   ├── family/
│   │   │   ├── health/
│   │   │   ├── products/
│   │   │   ├── routine/
│   │   │   └── settings/
│   │   └── shared/
│   │       ├── widgets/
│   │       └── providers/
│   ├── test/
│   ├── android/
│   ├── ios/
│   └── pubspec.yaml
│
├── backend/                   # FastAPI 백엔드
│   ├── app/
│   │   ├── main.py
│   │   ├── core/
│   │   │   ├── config.py
│   │   │   ├── security.py
│   │   │   └── database.py
│   │   ├── services/
│   │   │   ├── auth/
│   │   │   ├── user/
│   │   │   ├── health/
│   │   │   ├── ai/
│   │   │   ├── product/
│   │   │   └── analytics/
│   │   ├── models/
│   │   ├── schemas/
│   │   └── api/
│   │       └── v1/
│   ├── tests/
│   ├── alembic/
│   └── requirements.txt
│
├── ai/                        # AI/ML 파이프라인
│   ├── knowledge_base/
│   │   ├── scrapers/
│   │   ├── processors/
│   │   └── embeddings/
│   ├── rag/
│   │   ├── retriever.py
│   │   └── generator.py
│   ├── safety/
│   │   ├── filters.py
│   │   └── emergency.py
│   └── characters/
│       └── prompts/
│
├── infrastructure/            # 인프라 설정
│   ├── docker/
│   ├── kubernetes/
│   ├── terraform/
│   └── scripts/
│
├── docs/                      # 문서
│   ├── api/
│   ├── architecture/
│   └── guides/
│
├── .github/
│   └── workflows/
│
├── docker-compose.yml
├── README.md
└── Makefile
```

### 12.3 환경 변수

```bash
# .env.example

# 앱 설정
APP_ENV=development
DEBUG=true
SECRET_KEY=your-secret-key-here

# 데이터베이스
DATABASE_URL=postgresql://postgres:postgres@localhost:5432/healthai
REDIS_URL=redis://localhost:6379

# OpenAI
OPENAI_API_KEY=sk-...

# Firebase
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=...
FIREBASE_CLIENT_EMAIL=...

# SNS 로그인
KAKAO_APP_KEY=...
GOOGLE_CLIENT_ID=...
APPLE_CLIENT_ID=...

# 제휴
COUPANG_PARTNERS_ACCESS_KEY=...
COUPANG_PARTNERS_SECRET_KEY=...
IHERB_AFFILIATE_ID=...

# 광고
ADMOB_APP_ID=...
KAKAO_ADFIT_ID=...

# 암호화
ENCRYPTION_KEY=...
```

### 12.4 로컬 개발 시작

```bash
# 1. 저장소 클론
git clone https://github.com/yourname/healthai-app.git
cd healthai-app

# 2. 백엔드 설정
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cp .env.example .env  # 환경 변수 설정

# 3. Docker 서비스 시작 (DB, Redis, Chroma)
docker-compose up -d postgres redis chroma

# 4. DB 마이그레이션
alembic upgrade head

# 5. 백엔드 실행
uvicorn app.main:app --reload --port 8000

# 6. Flutter 앱 설정 (새 터미널)
cd mobile
flutter pub get
cp .env.example .env  # 환경 변수 설정

# 7. Flutter 앱 실행
flutter run

# 8. 테스트 실행
# 백엔드
pytest tests/ -v

# Flutter
flutter test
```

---

## 13. 부록

### 13.1 API 응답 코드

| HTTP 코드 | 설명 | 사용 상황 |
|-----------|------|----------|
| 200 | OK | 성공적인 조회/수정 |
| 201 | Created | 성공적인 생성 |
| 204 | No Content | 성공적인 삭제 |
| 400 | Bad Request | 잘못된 요청 형식 |
| 401 | Unauthorized | 인증 필요 |
| 403 | Forbidden | 권한 없음 |
| 404 | Not Found | 리소스 없음 |
| 409 | Conflict | 리소스 충돌 |
| 422 | Unprocessable Entity | 유효성 검증 실패 |
| 429 | Too Many Requests | 요청 제한 초과 |
| 500 | Internal Server Error | 서버 오류 |

### 13.2 데이터 타입 매핑

| Flutter (Dart) | Python | PostgreSQL |
|----------------|--------|------------|
| String | str | VARCHAR/TEXT |
| int | int | INTEGER/BIGINT |
| double | float | DECIMAL/FLOAT |
| bool | bool | BOOLEAN |
| DateTime | datetime | TIMESTAMP |
| List | list | JSONB/ARRAY |
| Map | dict | JSONB |

### 13.3 버전 히스토리

| 버전 | 일자 | 작성자 | 변경사항 |
|------|------|--------|----------|
| 1.0 | 2025-12 | - | 최초 작성 |

---

**문서 끝**
