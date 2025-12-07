# 음성 AI 건강주치의 앱 - Technical Requirements Document (TRD)

**Version:** 1.1  
**작성일:** 2025년 12월 4일  
**작성자:** 당근  
**상태:** Approved for Development  
**관련 문서:** PRD v1.1, AI캐릭터 프롬프트 가이드 v1.1

---

## 문서 변경 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|-----------|--------|
| 1.1 | 2025-12-04 | OpenAI Realtime API 최신 정보 반영, 캐릭터 자기소개 API 추가, 일정 수정 | 당근 |
| 1.0 | 2025-12-03 | 초안 작성 | 당근 |

---

## 목차

1. [기술 개요](#1-기술-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [기술 스택](#3-기술-스택)
4. [데이터베이스 설계](#4-데이터베이스-설계)
5. [API 설계](#5-api-설계)
6. [OpenAI Realtime API 통합](#6-openai-realtime-api-통합)
7. [AI/ML 파이프라인](#7-aiml-파이프라인)
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
| **프레임워크** | Flutter 3.24+ (Dart 3.5+) |
| **백엔드** | Python 3.11 + FastAPI |
| **데이터베이스** | PostgreSQL 15, Redis 7 |
| **AI/ML** | OpenAI Realtime API, Claude API, Chroma DB |
| **개발 기간** | 8주 (MVP) |
| **개발 인원** | 1인 |
| **월 예산** | $7,000-$10,000 |

### 1.2 기술적 목표

| 지표 | 목표 | 측정 방법 |
|------|------|----------|
| **음성 지연시간** | < 500ms (p95) | OpenAI API 로그 |
| **앱 시작 시간** | < 3초 (Cold Start) | Firebase Performance |
| **API 응답 시간** | < 2초 (p95) | APM 도구 |
| **동시 접속자** | 1,000명 | 부하 테스트 |
| **가용성** | 99.5% uptime | 모니터링 시스템 |

### 1.3 Flutter 선택 이유

| 평가 항목 | Flutter | React Native | 선택 |
|----------|---------|--------------|------|
| **음성 실시간 처리** | Dart 비동기 우수, 낮은 레이턴시 | JS 브릿지 오버헤드 | ✅ Flutter |
| **Health API 통합** | `health` 패키지 (HealthKit + Health Connect 통합) | 별도 패키지 2개 | ✅ Flutter |
| **UI 일관성** | 자체 렌더링, 완벽한 일관성 | 플랫폼별 미세 차이 | ✅ Flutter |
| **성능** | 네이티브 컴파일 (ARM64) | JS 브릿지 | ✅ Flutter |
| **접근성 (WCAG)** | Semantics 위젯 세밀 제어 | 기본 지원 | ✅ Flutter |

---

## 2. 시스템 아키텍처

### 2.1 전체 아키텍처 다이어그램

```
┌──────────────────────────────────────────────────────────────┐
│                     Client Layer                             │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────┐         ┌─────────────────┐           │
│  │   Flutter App   │         │   Flutter App   │           │
│  │     (iOS)       │         │   (Android)     │           │
│  │                 │         │                 │           │
│  │  - Riverpod     │         │  - Riverpod     │           │
│  │  - go_router    │         │  - go_router    │           │
│  │  - dio          │         │  - dio          │           │
│  │  - HealthKit    │         │  - Health       │           │
│  │                 │         │    Connect      │           │
│  └────────┬────────┘         └────────┬────────┘           │
│           │                           │                     │
│           └───────────┬───────────────┘                     │
│                       │                                     │
└───────────────────────┼─────────────────────────────────────┘
                        │
                        │ HTTPS/WSS
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                   API Gateway Layer                          │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│              AWS ALB (Application Load Balancer)            │
│              - TLS 1.3 Termination                          │
│              - Rate Limiting                                │
│              - WAF (Web Application Firewall)               │
│                                                              │
└───────────────────────┬──────────────────────────────────────┘
                        │
                        ▼
┌──────────────────────────────────────────────────────────────┐
│                 Backend Services Layer                       │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │    Auth      │  │     User     │  │   Family     │      │
│  │   Service    │  │   Service    │  │   Service    │      │
│  │              │  │              │  │              │      │
│  │  FastAPI     │  │  FastAPI     │  │  FastAPI     │      │
│  │  Port: 8001  │  │  Port: 8002  │  │  Port: 8003  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
│  ┌──────┴────────┬─────────┴────────┬─────────┴──────┐      │
│  │               │                  │                 │      │
│  ▼               ▼                  ▼                 ▼      │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐      │
│  │ Conversation │  │   Wearable   │  │ Subscription │      │
│  │   Service    │  │   Service    │  │   Service    │      │
│  │              │  │              │  │              │      │
│  │  FastAPI     │  │  FastAPI     │  │  FastAPI     │      │
│  │  Port: 8004  │  │  Port: 8005  │  │  Port: 8006  │      │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘      │
│         │                  │                  │              │
└─────────┼──────────────────┼──────────────────┼──────────────┘
          │                  │                  │
          ▼                  ▼                  ▼
┌──────────────────────────────────────────────────────────────┐
│                    Data Layer                                │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────────────────────────────┐    │
│  │            PostgreSQL 15 (Primary)                   │    │
│  │  - users, families, conversations, health_data      │    │
│  │  - RDS (AWS) / Managed PostgreSQL                   │    │
│  └───────────────────────┬─────────────────────────────┘    │
│                          │                                   │
│  ┌───────────────────────┴─────────────────────────────┐    │
│  │              Redis 7 (Cache + Queue)                 │    │
│  │  - Session cache                                     │    │
│  │  - API rate limiting                                │    │
│  │  - Conversation context buffer                       │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                              │
│  ┌──────────────────────────────────────────────────────┐    │
│  │           Chroma DB (Vector Store)                   │    │
│  │  - Medical knowledge embeddings                      │    │
│  │  - RAG retrieval                                     │    │
│  └──────────────────────────────────────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
          │
          ▼
┌──────────────────────────────────────────────────────────────┐
│                 External Services Layer                      │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   OpenAI    │  │   Claude    │  │  RevenueCat │         │
│  │  Realtime   │  │     API     │  │  (Payment)  │         │
│  │     API     │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                              │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │  Firebase   │  │   Sentry    │  │   AdMob /   │         │
│  │ Analytics   │  │  (Error)    │  │  Kakao Ad   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

### 2.2 마이크로서비스 설계

| 서비스 | 책임 | 포트 | 데이터베이스 |
|--------|------|------|--------------|
| **Auth Service** | 사용자 인증, JWT 토큰 발급 | 8001 | PostgreSQL |
| **User Service** | 사용자 프로필, 건강 정보 관리 | 8002 | PostgreSQL |
| **Family Service** | 가족 프로필, 관계 관리 | 8003 | PostgreSQL |
| **Conversation Service** | 음성 상담 세션, OpenAI 연동 | 8004 | PostgreSQL, Redis |
| **Wearable Service** | 웨어러블 데이터 수집, 분석 | 8005 | PostgreSQL |
| **Subscription Service** | 구독 관리, RevenueCat 연동 | 8006 | PostgreSQL |
| **Routine Service** | 아침 루틴 체크, 통계, 알림 | 8007 | PostgreSQL, Redis ⭐ NEW |

---

## 3. 기술 스택

### 3.1 Frontend (Mobile App)

| 영역 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **프레임워크** | Flutter | 3.24+ | Cross-platform UI |
| **언어** | Dart | 3.5+ | |
| **상태 관리** | Riverpod | 2.5+ | 전역 상태 관리 |
| **네비게이션** | go_router | 14.0+ | 선언적 라우팅 |
| **HTTP 클라이언트** | dio | 5.4+ | REST API 통신 |
| **WebSocket** | web_socket_channel | 3.0+ | OpenAI Realtime API |
| **오디오** | flutter_sound | 9.11+ | 음성 녹음/재생 |
| **웨어러블** | health | 10.2+ | HealthKit + Health Connect |
| **로컬 저장소** | shared_preferences | 2.2+ | 사용자 설정 |
| **보안 저장소** | flutter_secure_storage | 9.2+ | 토큰, 민감 정보 |
| **결제** | in_app_purchase | 3.2+ | 구독 결제 (RevenueCat) |
| **분석** | firebase_analytics | 11.3+ | 사용자 행동 분석 |
| **오류 추적** | sentry_flutter | 8.9+ | 크래시 리포팅 |

### 3.2 Backend

| 영역 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **프레임워크** | FastAPI | 0.115+ | RESTful API |
| **언어** | Python | 3.11+ | |
| **비동기** | asyncio, aiohttp | - | 비동기 처리 |
| **ORM** | SQLAlchemy | 2.0+ | Database ORM |
| **마이그레이션** | Alembic | 1.14+ | DB 스키마 버전 관리 |
| **인증** | PyJWT | 2.9+ | JWT 토큰 |
| **검증** | Pydantic | 2.9+ | 데이터 검증 |
| **테스트** | pytest | 8.3+ | 단위 테스트 |
| **OpenAI** | openai | 1.54+ | Realtime API SDK |
| **Vector DB** | chromadb | 0.5+ | RAG 시스템 |

### 3.3 Database

| 영역 | 기술 | 버전 | 용도 |
|------|------|------|------|
| **주 DB** | PostgreSQL | 15+ | 관계형 데이터 |
| **캐시** | Redis | 7+ | 세션, API rate limit |
| **Vector DB** | Chroma DB | 0.5+ | 의료 지식 임베딩 |

### 3.4 Infrastructure

| 영역 | 기술 | 용도 |
|------|------|------|
| **컨테이너** | Docker | 서비스 컨테이너화 |
| **오케스트레이션** | Docker Compose (로컬), AWS ECS (프로덕션) | 컨테이너 관리 |
| **로드 밸런서** | AWS ALB | 트래픽 분산 |
| **DNS** | AWS Route 53 | 도메인 관리 |
| **CDN** | AWS CloudFront | 정적 파일 배포 |
| **모니터링** | Prometheus + Grafana | 시스템 모니터링 |
| **로깅** | ELK Stack (Elasticsearch, Logstash, Kibana) | 중앙 로깅 |
| **CI/CD** | GitHub Actions | 자동 배포 |

---

## 4. 데이터베이스 설계

### 4.1 ERD (Entity-Relationship Diagram)

```
┌─────────────┐       ┌──────────────────┐       ┌─────────────────┐
│   users     │───────│  family_profiles │───────│  conversations  │
└─────────────┘  1:N  └──────────────────┘  1:N  └─────────────────┘
      │                      │                            │
      │                      │                            │
      │ 1:N                  │ 1:N                        │ 1:N
      ▼                      ▼                            ▼
┌─────────────┐       ┌──────────────────┐       ┌─────────────────┐
│subscriptions│       │  health_data     │       │ conv_messages   │
└─────────────┘       └──────────────────┘       └─────────────────┘
                              │
                              │ 1:N
                              ▼
                      ┌──────────────────┐
                      │  wearable_data   │
                      └──────────────────┘
```

### 4.2 테이블 정의

#### 4.2.1 users

사용자 계정 정보

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK, 사용자 고유 ID |
| email | VARCHAR(255) | NULL | 이메일 (소셜 로그인 시 NULL 가능) |
| social_provider | VARCHAR(50) | NULL | 소셜 로그인 제공자 (kakao, google, apple) |
| social_id | VARCHAR(255) | NULL | 소셜 로그인 고유 ID |
| nickname | VARCHAR(100) | NULL | 사용자 닉네임 |
| profile_image_url | TEXT | NULL | 프로필 이미지 URL |
| created_at | TIMESTAMPTZ | NOT NULL | 계정 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |
| last_login_at | TIMESTAMPTZ | NULL | 마지막 로그인 시각 |
| is_active | BOOLEAN | NOT NULL | 계정 활성화 여부 (기본: TRUE) |

**인덱스:**
- PRIMARY KEY (id)
- UNIQUE (social_provider, social_id)
- INDEX (email)

---

#### 4.2.2 family_profiles

가족 구성원 프로필

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK, 프로필 고유 ID |
| user_id | UUID | NOT NULL | FK (users.id), 소유자 |
| nickname | VARCHAR(100) | NOT NULL | 가족 구성원 닉네임 (예: "엄마", "아빠") |
| relationship | VARCHAR(50) | NOT NULL | 관계 (self, parent, spouse, child) |
| birth_date | DATE | NULL | 생년월일 |
| gender | VARCHAR(10) | NULL | 성별 (male, female, other) |
| height_cm | DECIMAL(5,2) | NULL | 키 (cm) |
| weight_kg | DECIMAL(5,2) | NULL | 몸무게 (kg) |
| is_primary | BOOLEAN | NOT NULL | 본인 프로필 여부 (기본: FALSE) |
| created_at | TIMESTAMPTZ | NOT NULL | 프로필 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (user_id)
- UNIQUE (user_id, is_primary) WHERE is_primary = TRUE (본인 프로필은 1개만)

**제약:**
- 무료 사용자: 본인 + 1명 (총 2개 프로필)
- 프리미엄/패밀리: 무제한

---

#### 4.2.3 health_data

가족 구성원별 건강 정보

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK |
| family_profile_id | UUID | NOT NULL | FK (family_profiles.id) |
| data_type | VARCHAR(50) | NOT NULL | 데이터 유형 (disease, medication, allergy, habit) |
| data_key | VARCHAR(100) | NOT NULL | 데이터 키 (예: "diabetes", "hypertension") |
| data_value | TEXT | NULL | 데이터 값 (JSON 형식 가능) |
| created_at | TIMESTAMPTZ | NOT NULL | 기록 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (family_profile_id, data_type)

**예시 데이터:**
```json
{
  "data_type": "disease",
  "data_key": "diabetes_type2",
  "data_value": "{\"diagnosed_at\": \"2020-01-15\", \"severity\": \"moderate\"}"
}
```

---

#### 4.2.4 conversations

음성 상담 세션

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK, 대화 세션 ID |
| family_profile_id | UUID | NOT NULL | FK (family_profiles.id), 상담 대상 |
| character_id | VARCHAR(50) | NOT NULL | AI 캐릭터 ID (park_jihoon, choi_hyunwoo, ...) |
| session_id | VARCHAR(255) | NULL | OpenAI Realtime API 세션 ID |
| started_at | TIMESTAMPTZ | NOT NULL | 상담 시작 시각 |
| ended_at | TIMESTAMPTZ | NULL | 상담 종료 시각 |
| duration_seconds | INTEGER | NULL | 상담 시간 (초) |
| summary | TEXT | NULL | AI 생성 요약 |
| status | VARCHAR(50) | NOT NULL | 상태 (ongoing, completed, interrupted) |
| created_at | TIMESTAMPTZ | NOT NULL | 레코드 생성 시각 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (family_profile_id, started_at)
- INDEX (session_id)

---

#### 4.2.5 conversation_messages

대화 메시지 (턴별 저장)

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK |
| conversation_id | UUID | NOT NULL | FK (conversations.id) |
| role | VARCHAR(20) | NOT NULL | 역할 (user, assistant) |
| content_text | TEXT | NULL | 텍스트 변환된 내용 |
| content_audio_url | TEXT | NULL | 오디오 파일 S3 URL |
| timestamp | TIMESTAMPTZ | NOT NULL | 메시지 시각 |
| turn_index | INTEGER | NOT NULL | 턴 순서 (0부터 시작) |
| tokens_used | INTEGER | NULL | 사용된 토큰 수 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (conversation_id, turn_index)

---

#### 4.2.6 wearable_data

웨어러블 기기 데이터

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK |
| family_profile_id | UUID | NOT NULL | FK (family_profiles.id) |
| data_type | VARCHAR(50) | NOT NULL | 데이터 유형 (steps, heart_rate, sleep, blood_pressure, blood_glucose) |
| value | DECIMAL(10,2) | NOT NULL | 측정 값 |
| unit | VARCHAR(20) | NULL | 단위 (bpm, mmHg, mg/dL, steps, minutes) |
| measured_at | TIMESTAMPTZ | NOT NULL | 측정 시각 |
| source | VARCHAR(50) | NULL | 데이터 소스 (apple_health, health_connect) |
| created_at | TIMESTAMPTZ | NOT NULL | 레코드 생성 시각 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (family_profile_id, data_type, measured_at)

---

#### 4.2.7 subscriptions

구독 정보

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK |
| user_id | UUID | NOT NULL | FK (users.id) |
| plan_tier | VARCHAR(50) | NOT NULL | 구독 플랜 (free, basic, premium, family) |
| platform | VARCHAR(20) | NOT NULL | 플랫폼 (ios, android) |
| revenuecat_customer_id | VARCHAR(255) | NULL | RevenueCat 고객 ID |
| original_transaction_id | VARCHAR(255) | NULL | 원본 거래 ID |
| started_at | TIMESTAMPTZ | NOT NULL | 구독 시작 시각 |
| expires_at | TIMESTAMPTZ | NULL | 구독 만료 시각 (NULL: 무료) |
| is_active | BOOLEAN | NOT NULL | 활성 상태 (기본: TRUE) |
| created_at | TIMESTAMPTZ | NOT NULL | 레코드 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (user_id, is_active)
- UNIQUE (revenuecat_customer_id)

---

#### 4.2.8 morning_routines

아침 루틴 마스터 테이블

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | INTEGER | NOT NULL | PK, 루틴 항목 ID (1~8) |
| name | VARCHAR(100) | NOT NULL | 루틴 이름 (예: "이불 정리") |
| icon_emoji | VARCHAR(10) | NULL | 이모지 아이콘 (예: "🛏️") |
| display_order | INTEGER | NOT NULL | 표시 순서 |
| is_active | BOOLEAN | NOT NULL | 활성 상태 (기본: TRUE) |

**초기 데이터:**
```sql
INSERT INTO morning_routines (id, name, icon_emoji, display_order) VALUES
(1, '이불 정리', '🛏️', 1),
(2, '공복에 물 마시기', '💧', 2),
(3, '명상, 독서', '🧘', 3),
(4, '한 동작 운동', '🏃', 4),
(5, '차 마시기', '☕', 5),
(6, '건강을 위한 영양제 먹기', '💊', 6),
(7, '모닝 러닝', '🏃‍♂️', 7),
(8, '오늘 할 일 정리, 아침일기 쓰기', '📝', 8);
```

**인덱스:**
- PRIMARY KEY (id)

---

#### 4.2.9 routine_check_records

사용자별 아침 루틴 체크 기록

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK |
| family_profile_id | UUID | NOT NULL | FK (family_profiles.id), 기록 대상 |
| check_date | DATE | NOT NULL | 체크 날짜 (예: 2026-02-12) |
| routine_checks | JSONB | NOT NULL | 루틴 체크 상태 (JSON 배열) |
| mood | INTEGER | NULL | 오늘의 기분 (1~5) |
| energy_level | INTEGER | NULL | 에너지 레벨 (1~5) |
| goal_of_day | TEXT | NULL | 오늘 반드시 이룰 목표 1가지 |
| schedules | JSONB | NULL | 오늘 하루 주요 일정 3가지 (JSON 배열) |
| gratitude_items | JSONB | NULL | 감사 일기 3가지 (JSON 배열) |
| created_at | TIMESTAMPTZ | NOT NULL | 기록 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |

**인덱스:**
- PRIMARY KEY (id)
- UNIQUE (family_profile_id, check_date)
- INDEX (family_profile_id, check_date)

**routine_checks JSON 구조:**
```json
[
  {"routine_id": 1, "checked": true, "checked_at": "2026-02-12T08:30:00Z"},
  {"routine_id": 2, "checked": true, "checked_at": "2026-02-12T08:31:00Z"},
  {"routine_id": 3, "checked": false, "checked_at": null},
  {"routine_id": 4, "checked": true, "checked_at": "2026-02-12T08:45:00Z"},
  {"routine_id": 5, "checked": false, "checked_at": null},
  {"routine_id": 6, "checked": true, "checked_at": "2026-02-12T09:00:00Z"},
  {"routine_id": 7, "checked": false, "checked_at": null},
  {"routine_id": 8, "checked": true, "checked_at": "2026-02-12T09:15:00Z"}
]
```

**schedules JSON 구조:**
```json
[
  {"time": "10:00", "description": "팀 회의"},
  {"time": "14:00", "description": "병원 진료"},
  {"time": "19:00", "description": "친구 약속"}
]
```

**gratitude_items JSON 구조:**
```json
[
  "햇살 좋은 날씨",
  "가족의 건강",
  "맛있는 아침 식사"
]
```

---

#### 4.2.10 routine_notifications

루틴 알림 설정

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | UUID | NOT NULL | PK |
| family_profile_id | UUID | NOT NULL | FK (family_profiles.id), 알림 대상 |
| is_enabled | BOOLEAN | NOT NULL | 알림 활성화 여부 (기본: TRUE) |
| notification_time | TIME | NOT NULL | 알림 시간 (예: 08:00:00, 기본값) |
| created_at | TIMESTAMPTZ | NOT NULL | 레코드 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |

**인덱스:**
- PRIMARY KEY (id)
- UNIQUE (family_profile_id)
- INDEX (is_enabled, notification_time)

---

#### 4.2.11 ai_characters

AI 캐릭터 정보 (마스터 테이블)

| 컬럼명 | 타입 | Null | 설명 |
|--------|------|------|------|
| id | VARCHAR(50) | NOT NULL | PK, 캐릭터 ID (park_jihoon, choi_hyunwoo, ...) |
| name | VARCHAR(100) | NOT NULL | 캐릭터 이름 |
| specialty | VARCHAR(100) | NOT NULL | 전문 분야 |
| gender | VARCHAR(10) | NOT NULL | 성별 |
| age_range | VARCHAR(20) | NULL | 연령대 (예: "40s", "50s") |
| openai_voice | VARCHAR(50) | NOT NULL | OpenAI 음성 (sage, echo, Cedar, Marin, shimmer, alloy) |
| system_prompt | TEXT | NOT NULL | 시스템 프롬프트 |
| introduction_audio_url | TEXT | NULL | 자기소개 음성 파일 URL |
| profile_image_url | TEXT | NULL | 프로필 이미지 URL |
| is_active | BOOLEAN | NOT NULL | 활성 상태 (기본: TRUE) |
| created_at | TIMESTAMPTZ | NOT NULL | 레코드 생성 시각 |
| updated_at | TIMESTAMPTZ | NOT NULL | 마지막 업데이트 시각 |

**인덱스:**
- PRIMARY KEY (id)
- INDEX (is_active)

---

### 4.3 데이터베이스 마이그레이션

**도구:** Alembic

**마이그레이션 스크립트 예시:**

```bash
# 초기 마이그레이션 생성
alembic revision --autogenerate -m "Create initial tables"

# 마이그레이션 적용
alembic upgrade head

# 롤백
alembic downgrade -1
```

---

## 5. API 설계

### 5.1 API 명세 개요

| 서비스 | Base URL | 설명 |
|--------|----------|------|
| Auth | `/api/v1/auth` | 인증 및 JWT 토큰 |
| User | `/api/v1/users` | 사용자 프로필 |
| Family | `/api/v1/families` | 가족 프로필 |
| Conversation | `/api/v1/conversations` | 음성 상담 |
| Wearable | `/api/v1/wearables` | 웨어러블 데이터 |
| Subscription | `/api/v1/subscriptions` | 구독 관리 |
| Characters | `/api/v1/characters` | AI 캐릭터 정보 |
| Routines | `/api/v1/routines` | 아침 루틴 체크 ⭐ NEW |

### 5.2 인증 (Auth Service)

#### POST /api/v1/auth/login/social

소셜 로그인 (카카오/Google/Apple)

**Request:**
```json
{
  "provider": "kakao",
  "token": "eyJhbGciOiJI...",
  "device_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600,
  "user": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "김미영",
    "email": "user@example.com",
    "profile_image_url": "https://..."
  }
}
```

---

#### POST /api/v1/auth/refresh

토큰 갱신

**Request:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

---

### 5.3 가족 프로필 (Family Service)

#### GET /api/v1/families

가족 프로필 목록 조회

**Headers:**
- `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "profiles": [
    {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "nickname": "나",
      "relationship": "self",
      "birth_date": "1976-05-20",
      "gender": "female",
      "height_cm": 162.5,
      "weight_kg": 58.3,
      "is_primary": true
    },
    {
      "id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
      "nickname": "엄마",
      "relationship": "parent",
      "birth_date": "1950-03-15",
      "gender": "female",
      "height_cm": 158.0,
      "weight_kg": 60.0,
      "is_primary": false
    }
  ],
  "total_count": 2,
  "max_allowed": 2
}
```

---

#### POST /api/v1/families

가족 프로필 추가

**Request:**
```json
{
  "nickname": "아빠",
  "relationship": "parent",
  "birth_date": "1948-12-10",
  "gender": "male",
  "height_cm": 172.0,
  "weight_kg": 75.0
}
```

**Response (201):**
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "nickname": "아빠",
  "relationship": "parent",
  "birth_date": "1948-12-10",
  "gender": "male",
  "height_cm": 172.0,
  "weight_kg": 75.0,
  "is_primary": false,
  "created_at": "2025-12-04T10:30:00Z"
}
```

**Error (403):**
```json
{
  "error": "PROFILE_LIMIT_EXCEEDED",
  "message": "무료 플랜은 본인 + 1명까지만 추가 가능합니다. 프리미엄 플랜으로 업그레이드하세요."
}
```

---

### 5.4 음성 상담 (Conversation Service)

#### POST /api/v1/conversations/start

음성 상담 세션 시작

**Request:**
```json
{
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "character_id": "park_jihoon"
}
```

**Response (200):**
```json
{
  "conversation_id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "session_id": "sess_abc123xyz",
  "character": {
    "id": "park_jihoon",
    "name": "박지훈",
    "specialty": "내과 (만성질환 관리)",
    "voice": "sage"
  },
  "websocket_url": "wss://api.yourdomain.com/ws/conversations/9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "started_at": "2025-12-04T10:35:00Z",
  "max_duration_seconds": 300
}
```

---

#### GET /api/v1/conversations/{conversation_id}

음성 상담 세션 상세 조회

**Response (200):**
```json
{
  "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "family_profile": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "nickname": "나"
  },
  "character": {
    "id": "park_jihoon",
    "name": "박지훈"
  },
  "started_at": "2025-12-04T10:35:00Z",
  "ended_at": "2025-12-04T10:42:30Z",
  "duration_seconds": 450,
  "summary": "혈당 관리 상담. 최근 공복 혈당 130으로 약간 높은 편. 식습관 개선 권장.",
  "status": "completed"
}
```

---

### 5.5 AI 캐릭터 (Character Service)

#### GET /api/v1/characters

AI 캐릭터 목록 조회

**Response (200):**
```json
{
  "characters": [
    {
      "id": "park_jihoon",
      "name": "박지훈",
      "specialty": "내과 (만성질환 관리)",
      "gender": "male",
      "age_range": "50s",
      "openai_voice": "sage",
      "introduction_audio_url": "https://cdn.yourdomain.com/characters/park_jihoon_intro.mp3",
      "profile_image_url": "https://cdn.yourdomain.com/characters/park_jihoon.jpg"
    },
    {
      "id": "oh_kyungmi",
      "name": "오경미",
      "specialty": "영양 (식이요법, 영양제)",
      "gender": "female",
      "age_range": "30s",
      "openai_voice": "Cedar",
      "introduction_audio_url": "https://cdn.yourdomain.com/characters/oh_kyungmi_intro.mp3",
      "profile_image_url": "https://cdn.yourdomain.com/characters/oh_kyungmi.jpg"
    }
  ],
  "total_count": 6
}
```

---

#### GET /api/v1/characters/{character_id}/introduction

캐릭터 자기소개 음성 파일 URL 조회 ⭐ NEW

**Response (200):**
```json
{
  "character_id": "park_jihoon",
  "introduction_audio_url": "https://cdn.yourdomain.com/characters/park_jihoon_intro.mp3",
  "duration_seconds": 28,
  "transcript": "안녕하세요, 내과 전문의 박지훈입니다. 20년간 만성질환 관리를 전문으로 해왔습니다..."
}
```

---

### 5.6 웨어러블 (Wearable Service)

#### POST /api/v1/wearables/sync

웨어러블 데이터 동기화

**Request:**
```json
{
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "data": [
    {
      "data_type": "steps",
      "value": 8543,
      "unit": "steps",
      "measured_at": "2025-12-04T09:00:00Z",
      "source": "apple_health"
    },
    {
      "data_type": "heart_rate",
      "value": 72,
      "unit": "bpm",
      "measured_at": "2025-12-04T09:05:00Z",
      "source": "apple_health"
    }
  ]
}
```

**Response (200):**
```json
{
  "synced_count": 2,
  "message": "데이터 동기화 완료"
}
```

---

### 5.7 구독 (Subscription Service)

#### POST /api/v1/subscriptions/webhook

RevenueCat 웹훅 수신

**Request (from RevenueCat):**
```json
{
  "event": {
    "type": "INITIAL_PURCHASE",
    "app_user_id": "550e8400-e29b-41d4-a716-446655440000",
    "product_id": "premium_monthly",
    "purchased_at": "2025-12-04T10:00:00Z",
    "expiration_at": "2026-01-04T10:00:00Z"
  }
}
```

**Response (200):**
```json
{
  "message": "Webhook processed"
}
```

---

### 5.8 루틴 (Routine Service) ⭐ NEW

#### GET /api/v1/routines/items

아침 루틴 항목 목록 조회

**Headers:**
- `Authorization: Bearer <access_token>`

**Response (200):**
```json
{
  "routines": [
    {
      "id": 1,
      "name": "이불 정리",
      "icon_emoji": "🛏️",
      "display_order": 1
    },
    {
      "id": 2,
      "name": "공복에 물 마시기",
      "icon_emoji": "💧",
      "display_order": 2
    },
    {
      "id": 3,
      "name": "명상, 독서",
      "icon_emoji": "🧘",
      "display_order": 3
    },
    {
      "id": 4,
      "name": "한 동작 운동",
      "icon_emoji": "🏃",
      "display_order": 4
    },
    {
      "id": 5,
      "name": "차 마시기",
      "icon_emoji": "☕",
      "display_order": 5
    },
    {
      "id": 6,
      "name": "건강을 위한 영양제 먹기",
      "icon_emoji": "💊",
      "display_order": 6
    },
    {
      "id": 7,
      "name": "모닝 러닝",
      "icon_emoji": "🏃‍♂️",
      "display_order": 7
    },
    {
      "id": 8,
      "name": "오늘 할 일 정리, 아침일기 쓰기",
      "icon_emoji": "📝",
      "display_order": 8
    }
  ],
  "total_count": 8
}
```

---

#### POST /api/v1/routines/check

오늘의 루틴 체크 기록 생성/업데이트

**Request:**
```json
{
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "check_date": "2026-02-12",
  "routine_checks": [
    {"routine_id": 1, "checked": true},
    {"routine_id": 2, "checked": true},
    {"routine_id": 3, "checked": false},
    {"routine_id": 4, "checked": true},
    {"routine_id": 5, "checked": false},
    {"routine_id": 6, "checked": true},
    {"routine_id": 7, "checked": false},
    {"routine_id": 8, "checked": true}
  ],
  "mood": 4,
  "energy_level": 3,
  "goal_of_day": "오후 3시까지 프로젝트 기획서 완성하기",
  "schedules": [
    {"time": "10:00", "description": "팀 회의"},
    {"time": "14:00", "description": "병원 진료"},
    {"time": "19:00", "description": "친구 약속"}
  ],
  "gratitude_items": [
    "햇살 좋은 날씨",
    "가족의 건강",
    "맛있는 아침 식사"
  ]
}
```

**Response (200):**
```json
{
  "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "check_date": "2026-02-12",
  "completion_rate": 0.625,
  "completed_count": 5,
  "total_count": 8,
  "message": "오늘 루틴 5/8 완료! 멋져요! 🎉"
}
```

---

#### GET /api/v1/routines/check/today

오늘의 루틴 체크 기록 조회

**Headers:**
- `Authorization: Bearer <access_token>`

**Query Parameters:**
- `family_profile_id` (required): 가족 프로필 ID

**Response (200):**
```json
{
  "id": "9b1deb4d-3b7d-4bad-9bdd-2b0d7b3dcb6d",
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "check_date": "2026-02-12",
  "routine_checks": [
    {"routine_id": 1, "checked": true, "checked_at": "2026-02-12T08:30:00Z"},
    {"routine_id": 2, "checked": true, "checked_at": "2026-02-12T08:31:00Z"},
    {"routine_id": 3, "checked": false, "checked_at": null},
    {"routine_id": 4, "checked": true, "checked_at": "2026-02-12T08:45:00Z"},
    {"routine_id": 5, "checked": false, "checked_at": null},
    {"routine_id": 6, "checked": true, "checked_at": "2026-02-12T09:00:00Z"},
    {"routine_id": 7, "checked": false, "checked_at": null},
    {"routine_id": 8, "checked": true, "checked_at": "2026-02-12T09:15:00Z"}
  ],
  "mood": 4,
  "energy_level": 3,
  "goal_of_day": "오후 3시까지 프로젝트 기획서 완성하기",
  "schedules": [
    {"time": "10:00", "description": "팀 회의"},
    {"time": "14:00", "description": "병원 진료"},
    {"time": "19:00", "description": "친구 약속"}
  ],
  "gratitude_items": [
    "햇살 좋은 날씨",
    "가족의 건강",
    "맛있는 아침 식사"
  ],
  "completion_rate": 0.625,
  "created_at": "2026-02-12T08:30:00Z",
  "updated_at": "2026-02-12T09:15:00Z"
}
```

**Response (404):** 오늘 기록이 없는 경우
```json
{
  "error": "NOT_FOUND",
  "message": "오늘의 루틴 기록이 없습니다"
}
```

---

#### GET /api/v1/routines/stats/weekly

주간 루틴 통계

**Query Parameters:**
- `family_profile_id` (required): 가족 프로필 ID
- `start_date` (optional): 시작 날짜 (기본값: 이번 주 월요일)

**Response (200):**
```json
{
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "week_start": "2026-02-10",
  "week_end": "2026-02-16",
  "daily_stats": [
    {
      "date": "2026-02-10",
      "completion_rate": 0.75,
      "completed_count": 6,
      "total_count": 8
    },
    {
      "date": "2026-02-11",
      "completion_rate": 0.875,
      "completed_count": 7,
      "total_count": 8
    },
    {
      "date": "2026-02-12",
      "completion_rate": 0.625,
      "completed_count": 5,
      "total_count": 8
    }
  ],
  "weekly_average": 0.75,
  "streak_days": 3,
  "most_completed_routine": {
    "routine_id": 2,
    "name": "공복에 물 마시기",
    "completion_rate": 1.0
  }
}
```

---

#### POST /api/v1/routines/notifications

루틴 알림 설정 생성/업데이트

**Request:**
```json
{
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "is_enabled": true,
  "notification_time": "08:00:00"
}
```

**Response (200):**
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "is_enabled": true,
  "notification_time": "08:00:00",
  "message": "매일 아침 8시에 알림이 발송됩니다"
}
```

---

#### GET /api/v1/routines/notifications

루틴 알림 설정 조회

**Query Parameters:**
- `family_profile_id` (required): 가족 프로필 ID

**Response (200):**
```json
{
  "id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "family_profile_id": "550e8400-e29b-41d4-a716-446655440000",
  "is_enabled": true,
  "notification_time": "08:00:00"
}
```

---

## 6. OpenAI Realtime API 통합

### 6.1 OpenAI Realtime API 개요 (2025년 8월 업데이트)

| 항목 | 내용 |
|------|------|
| **모델** | gpt-realtime-2025-08-28 (Generally Available) |
| **지원 모달리티** | audio, text |
| **최대 컨텍스트** | 32,768 tokens |
| **최대 응답 토큰** | 4,096 tokens |
| **음성 지원** | alloy, echo, shimmer, Cedar ⭐ NEW, Marin ⭐ NEW, sage (fable은 Realtime API 미지원) |

### 6.2 가격 (2025년 8월 20% 인하)

| 항목 | 가격 | 비고 |
|------|------|------|
| **오디오 입력** | $32 / 1M tokens | 분당 약 $0.05 |
| **오디오 출력** | $64 / 1M tokens | 분당 약 $0.19 |
| **텍스트 입력** | $10 / 1M tokens | |
| **텍스트 출력** | $40 / 1M tokens | |
| **캐시된 입력** | $0.40 / 1M tokens | 98.75% 할인 |

**10분 상담 예상 비용:**
- 입력 (5분): $0.50
- 출력 (5분): $1.90
- **합계: $2.40**

### 6.3 세션 설정 예시 (Python)

```python
import asyncio
import websockets
import json

async def start_realtime_session(character_id: str):
    uri = "wss://api.openai.com/v1/realtime?model=gpt-realtime-2025-08-28"
    headers = {
        "Authorization": f"Bearer {OPENAI_API_KEY}",
        "OpenAI-Beta": "realtime=v1"
    }
    
    async with websockets.connect(uri, additional_headers=headers) as websocket:
        # 세션 설정
        session_config = {
            "type": "session.update",
            "session": {
                "model": "gpt-realtime-2025-08-28",
                "modalities": ["text", "audio"],
                "instructions": get_character_prompt(character_id),  # 캐릭터별 프롬프트
                "voice": get_character_voice(character_id),  # 캐릭터별 음성
                "input_audio_format": "pcm16",
                "output_audio_format": "pcm16",
                "input_audio_transcription": {
                    "model": "whisper-1"
                },
                "turn_detection": {
                    "type": "server_vad",
                    "threshold": 0.5,
                    "silence_duration_ms": 500,
                    "idle_timeout_ms": 15000  # 15초 무응답 시 "아직 계시나요?" 프롬프트
                },
                "temperature": 0.8,
                "max_response_output_tokens": 4096
            }
        }
        
        await websocket.send(json.dumps(session_config))
        
        # 세션 시작
        while True:
            response = await websocket.recv()
            data = json.loads(response)
            
            if data["type"] == "session.created":
                print(f"세션 생성 완료: {data['session']['id']}")
                break
        
        return websocket

def get_character_voice(character_id: str) -> str:
    """캐릭터 ID에 맞는 OpenAI 음성 반환"""
    voice_mapping = {
        "park_jihoon": "sage",
        "choi_hyunwoo": "echo",
        "oh_kyungmi": "Cedar",  # ⭐ NEW
        "lee_soojin": "Marin",  # ⭐ NEW
        "kim_haeun": "shimmer",
        "jung_yujin": "alloy"
    }
    return voice_mapping.get(character_id, "alloy")
```

### 6.4 WebSocket 메시지 흐름

```
Client (Flutter)           Backend (FastAPI)           OpenAI Realtime API
       │                           │                           │
       │ 1. POST /conversations/start                         │
       ├─────────────────────────>│                           │
       │                           │ 2. WebSocket 연결 요청     │
       │                           ├──────────────────────────>│
       │                           │ 3. session.created       │
       │                           │<──────────────────────────┤
       │ 4. WebSocket 연결 (WSS)   │                           │
       │<──────────────────────────┤                           │
       │                           │                           │
       │ 5. 오디오 스트림 (PCM16)   │                           │
       ├─────────────────────────>│ 6. 오디오 전달            │
       │                           ├──────────────────────────>│
       │                           │ 7. response.audio_delta  │
       │                           │<──────────────────────────┤
       │ 8. 오디오 응답             │                           │
       │<──────────────────────────┤                           │
       │                           │                           │
```

---

## 7. AI/ML 파이프라인

### 7.1 RAG (Retrieval-Augmented Generation) 시스템

**목적:** OpenAI Realtime API에 의료 지식 베이스를 연동하여 환각(Hallucination) 방지

**아키텍처:**

```
사용자 질문
    │
    ▼
┌─────────────────────┐
│  Conversation       │
│  Service            │
└──────┬──────────────┘
       │
       │ 1. 질문 텍스트 추출
       ▼
┌─────────────────────┐
│  Embedding          │
│  (OpenAI Ada)       │
└──────┬──────────────┘
       │
       │ 2. 임베딩 생성
       ▼
┌─────────────────────┐
│  Chroma DB          │
│  (Vector Store)     │
└──────┬──────────────┘
       │
       │ 3. 유사도 검색 (Top 3)
       ▼
┌─────────────────────┐
│  Retrieved Docs     │
│  - 식약처 가이드     │
│  - WHO 권장사항      │
│  - 대한의학회 지침   │
└──────┬──────────────┘
       │
       │ 4. 컨텍스트로 추가
       ▼
┌─────────────────────┐
│  OpenAI Realtime    │
│  API (+ Context)    │
└──────┬──────────────┘
       │
       │ 5. 검증된 답변 생성
       ▼
    사용자
```

### 7.2 의료 지식 데이터 소스

| 출처 | 데이터 양 | 업데이트 주기 |
|------|----------|--------------|
| **식품의약품안전처** | 약 500개 질병 가이드 | 분기별 |
| **WHO** | 주요 건강 주제 200개 | 반기별 |
| **대한의학회** | 진료 가이드라인 100개 | 반기별 |
| **국민건강보험공단** | 만성질환 관리 자료 | 월별 |

### 7.3 Chroma DB 설정

```python
import chromadb
from chromadb.config import Settings

client = chromadb.PersistentClient(
    path="/data/chroma_db",
    settings=Settings(
        allow_reset=True,
        anonymized_telemetry=False
    )
)

# 컬렉션 생성
medical_knowledge = client.create_collection(
    name="medical_knowledge",
    metadata={"hnsw:space": "cosine"}
)

# 문서 추가 (예시)
medical_knowledge.add(
    documents=[
        "당뇨병 환자는 혈당 수치를 정기적으로 측정해야 합니다. 공복 혈당 100mg/dL 미만이 정상입니다.",
        "고혈압 관리에는 저염식이 중요합니다. 하루 나트륨 섭취량을 2,000mg 이하로 제한하세요."
    ],
    ids=["doc1", "doc2"],
    metadatas=[
        {"source": "식약처", "category": "diabetes"},
        {"source": "WHO", "category": "hypertension"}
    ]
)

# 검색 (예시)
results = medical_knowledge.query(
    query_texts=["혈당이 높으면 어떻게 해야 하나요?"],
    n_results=3
)
```

---

## 8. 웨어러블 연동

### 8.1 Apple HealthKit (iOS)

**패키지:** `health` (pub.dev)

**권한 요청:**
```dart
import 'package:health/health.dart';

Future<void> requestHealthPermission() async {
  final types = [
    HealthDataType.STEPS,
    HealthDataType.HEART_RATE,
    HealthDataType.SLEEP_IN_BED,
    HealthDataType.BLOOD_PRESSURE_SYSTOLIC,
    HealthDataType.BLOOD_PRESSURE_DIASTOLIC,
    HealthDataType.BLOOD_GLUCOSE,
  ];
  
  final permissions = types.map((e) => HealthDataAccess.READ).toList();
  
  bool authorized = await Health().requestAuthorization(types, permissions: permissions);
  
  if (!authorized) {
    print('HealthKit 권한 거부됨');
  }
}
```

**데이터 수집:**
```dart
Future<void> fetchHealthData() async {
  final now = DateTime.now();
  final yesterday = now.subtract(Duration(days: 1));
  
  List<HealthDataPoint> healthData = await Health().getHealthDataFromTypes(
    yesterday,
    now,
    [
      HealthDataType.STEPS,
      HealthDataType.HEART_RATE,
      HealthDataType.SLEEP_IN_BED,
    ],
  );
  
  for (var data in healthData) {
    print('${data.type}: ${data.value} ${data.unit}');
    // 백엔드 API로 전송
    await syncToBackend(data);
  }
}
```

### 8.2 Android Health Connect

**패키지:** `health` (pub.dev) - 동일 패키지로 통합 지원

**권한 요청:**
```dart
// iOS와 동일한 코드 사용 가능
await requestHealthPermission();
```

**주의사항:**
- Android 14 (API 34) 이상 필요
- Google Play Services 업데이트 필요

---

## 9. 보안 설계

### 9.1 데이터 암호화

| 항목 | 암호화 방식 | 비고 |
|------|-------------|------|
| **전송 중 데이터** | TLS 1.3 | HTTPS/WSS |
| **저장 데이터 (DB)** | AES-256 | 건강 정보, 대화 내역 |
| **앱 로컬 저장소** | flutter_secure_storage | iOS: Keychain, Android: EncryptedSharedPreferences |

### 9.2 JWT 토큰 전략

**Access Token:**
- 유효 기간: 1시간
- Payload: user_id, email, subscription_tier

**Refresh Token:**
- 유효 기간: 30일
- Payload: user_id
- 저장 위치: DB (hashed), 클라이언트 (Secure Storage)

### 9.3 API Rate Limiting

| 엔드포인트 | 제한 | 설명 |
|-----------|------|------|
| `/api/v1/auth/login/social` | 5 req/min | 무차별 로그인 시도 방지 |
| `/api/v1/conversations/start` | 10 req/hour | 음성 상담 남용 방지 |
| `/api/v1/wearables/sync` | 60 req/hour | 데이터 동기화 |

**구현:** Redis + FastAPI Middleware

---

## 10. 인프라 및 배포

### 10.1 개발 환경 (Local)

**Docker Compose:**
```yaml
version: '3.8'

services:
  postgres:
    image: postgres:15
    environment:
      POSTGRES_USER: healthai
      POSTGRES_PASSWORD: password
      POSTGRES_DB: healthai_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
  
  backend:
    build: ./backend
    ports:
      - "8001-8006:8001-8006"
    environment:
      DATABASE_URL: postgresql://healthai:password@postgres:5432/healthai_db
      REDIS_URL: redis://redis:6379
      OPENAI_API_KEY: ${OPENAI_API_KEY}
    depends_on:
      - postgres
      - redis

volumes:
  postgres_data:
```

### 10.2 프로덕션 환경 (AWS)

**인프라:**
- **컴퓨팅:** AWS ECS (Fargate)
- **데이터베이스:** AWS RDS (PostgreSQL)
- **캐시:** AWS ElastiCache (Redis)
- **로드 밸런서:** AWS ALB
- **CDN:** AWS CloudFront
- **스토리지:** AWS S3 (오디오 파일)

**예상 비용 (월간, MAU 10,000명 기준):**
- AWS ECS: $150
- AWS RDS (db.t3.medium): $70
- AWS ElastiCache: $30
- AWS ALB: $20
- AWS S3 + CloudFront: $50
- **합계: $320**

### 10.3 CI/CD 파이프라인

**도구:** GitHub Actions

```yaml
name: Deploy Backend

on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Build Docker Image
        run: |
          docker build -t healthai-backend:latest ./backend
      
      - name: Push to ECR
        run: |
          aws ecr get-login-password | docker login --username AWS --password-stdin $ECR_REGISTRY
          docker tag healthai-backend:latest $ECR_REGISTRY/healthai-backend:latest
          docker push $ECR_REGISTRY/healthai-backend:latest
      
      - name: Deploy to ECS
        run: |
          aws ecs update-service --cluster healthai-cluster --service healthai-backend --force-new-deployment
```

---

## 11. 모니터링 및 로깅

### 11.1 모니터링

**도구:** Prometheus + Grafana

**주요 지표:**
- API 응답 시간 (p50, p95, p99)
- 에러율
- 음성 상담 세션 수
- 동시 접속자 수
- DB 쿼리 성능

### 11.2 로깅

**도구:** ELK Stack (Elasticsearch, Logstash, Kibana)

**로그 레벨:**
- ERROR: API 에러, 예외 발생
- WARN: Rate limit 초과, 긴 응답 시간
- INFO: API 요청/응답, 세션 시작/종료
- DEBUG: 상세 디버깅 정보

### 11.3 에러 추적

**도구:** Sentry

**통합:**
```python
# backend/main.py
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn="https://your-sentry-dsn@sentry.io/project-id",
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1
)
```

```dart
// Flutter app
import 'package:sentry_flutter/sentry_flutter.dart';

await SentryFlutter.init(
  (options) {
    options.dsn = 'https://your-sentry-dsn@sentry.io/project-id';
    options.tracesSampleRate = 0.1;
  },
  appRunner: () => runApp(MyApp()),
);
```

---

## 12. 개발 환경 설정

### 12.1 로컬 개발 환경 구축

#### 백엔드

```bash
# 1. Python 가상 환경 생성
cd backend
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate

# 2. 의존성 설치
pip install -r requirements.txt

# 3. 환경 변수 설정
cp .env.example .env
# .env 파일 편집 (OPENAI_API_KEY, DATABASE_URL 등)

# 4. DB 마이그레이션
alembic upgrade head

# 5. 개발 서버 실행
uvicorn main:app --reload --port 8001
```

#### 프론트엔드 (Flutter)

```bash
# 1. Flutter 설치 확인
flutter doctor

# 2. 의존성 설치
cd mobile
flutter pub get

# 3. 환경 변수 설정
cp .env.example .env
# API_URL=http://localhost:8001

# 4. iOS 시뮬레이터 실행
flutter run -d ios

# 5. Android 에뮬레이터 실행
flutter run -d android
```

### 12.2 필수 환경 변수

```bash
# .env (Backend)
DATABASE_URL=postgresql://healthai:password@localhost:5432/healthai_db
REDIS_URL=redis://localhost:6379
OPENAI_API_KEY=sk-...
CLAUDE_API_KEY=sk-ant-...
JWT_SECRET=your-secret-key
SENTRY_DSN=https://...@sentry.io/...
```

```bash
# .env (Flutter)
API_URL=http://localhost:8001
SENTRY_DSN=https://...@sentry.io/...
REVENUECAT_API_KEY=your-revenuecat-key
```

---

## 13. 부록

### 13.1 API 엔드포인트 요약

| Method | Endpoint | 설명 |
|--------|----------|------|
| POST | `/api/v1/auth/login/social` | 소셜 로그인 |
| POST | `/api/v1/auth/refresh` | 토큰 갱신 |
| GET | `/api/v1/families` | 가족 프로필 목록 |
| POST | `/api/v1/families` | 가족 프로필 추가 |
| POST | `/api/v1/conversations/start` | 음성 상담 시작 |
| GET | `/api/v1/conversations/{id}` | 상담 세션 조회 |
| GET | `/api/v1/characters` | AI 캐릭터 목록 |
| GET | `/api/v1/characters/{id}/introduction` | 캐릭터 자기소개 ⭐ NEW |
| POST | `/api/v1/wearables/sync` | 웨어러블 데이터 동기화 |
| POST | `/api/v1/subscriptions/webhook` | RevenueCat 웹훅 |
| GET | `/api/v1/routines/items` | 루틴 항목 목록 ⭐ NEW |
| POST | `/api/v1/routines/check` | 루틴 체크 생성/업데이트 ⭐ NEW |
| GET | `/api/v1/routines/check/today` | 오늘의 루틴 조회 ⭐ NEW |
| GET | `/api/v1/routines/stats/weekly` | 주간 루틴 통계 ⭐ NEW |
| POST | `/api/v1/routines/notifications` | 루틴 알림 설정 ⭐ NEW |
| GET | `/api/v1/routines/notifications` | 루틴 알림 조회 ⭐ NEW |

### 13.2 관련 문서

- **PRD v1.1** - 제품 기획서
- **AI캐릭터_시스템프롬프트_가이드_v1.1** - 6개 캐릭터 프롬프트
- **개발_체크리스트_v1.1** - 8단계 개발 계획

### 13.3 개발 로드맵

| Phase | 기간 | 주요 마일스톤 |
|-------|------|---------------|
| **Phase 1 (MVP)** | 2025-12-04 ~ 2026-01-28 (8주) | 음성 AI 상담, 가족 프로필, 웨어러블 연동 |
| **베타 테스트** | 2026-01-29 ~ 2026-02-11 (2주) | 100명 테스터 피드백 |
| **정식 출시** | 2026-02-12 | iOS/Android App Store |
| **Phase 2** | 2026-02-12 ~ 2026-03-25 (6주) | 건강기능식품 추천, AI 코칭 |
| **Phase 3** | 2026-03-26 ~ 2026-05-06 (6주) | 캐릭터 확장, 커뮤니티 |

---

**문서 끝**  
**다음 문서:** 개발_체크리스트_v1.1 (8단계 개발 계획)
