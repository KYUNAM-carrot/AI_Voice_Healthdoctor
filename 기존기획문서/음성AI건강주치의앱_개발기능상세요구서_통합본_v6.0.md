# 🏥 음성 AI 건강주치의 앱 - 통합 개발 기능 명세서 v6.0

## 📑 목차
1. [프로젝트 개요](#1-프로젝트-개요)
2. [시스템 아키텍처](#2-시스템-아키텍처)
3. [핵심 기능 명세](#3-핵심-기능-명세)
   - 3.1 AI 건강주치의 캐릭터 시스템
   - 3.2 가족 프로필 관리 시스템
   - 3.3 건강정보 수집 및 관리
   - 3.4 건강 루틴 체크 기능
   - 3.5 감사 일기 기능
   - 3.6 RAG 지식베이스 시스템
   - 3.7 건강기능식품 추천 시스템
   - 3.8 웨어러블 데이터 통합
   - 3.9 로그인 및 인증 기능
   - 3.10 의료 서비스 통합 기능
4. [수익 모델 구현](#4-수익-모델-구현)
5. [광고 시스템](#5-광고-시스템)
6. [결제 및 구독 시스템](#6-결제-및-구독-시스템)
7. [기술 스택](#7-기술-스택)
8. [데이터베이스 설계](#8-데이터베이스-설계)
9. [API 명세](#9-api-명세)
10. [보안 및 규정 준수](#10-보안-및-규정-준수)
11. [개발 일정](#11-개발-일정)
12. [예상 비용 분석](#12-예상-비용-분석)
13. [마케팅 및 성장 전략](#13-마케팅-및-성장-전략)
14. [리스크 관리](#14-리스크-관리)
15. [향후 로드맵](#15-향후-로드맵)
16. [결론](#16-결론)

---

## 1. 프로젝트 개요

### 1.1 프로젝트 정보
- **프로젝트명**: 음성 AI 건강주치의 앱
- **타입**: 모바일 앱 (Android/iOS)
- **개발 기간**: 16주 (약 4개월)
- **예상 사용자**: 건강관리에 관심 있는 20-60대 성인 및 가족

### 1.2 프로젝트 비전
**"가족 모두의 건강을 AI로 지키고, 검증된 건강기능식품으로 실천하는 스마트 건강 주치의"**

### 1.3 핵심 가치 제안

```
1️⃣ 다양한 AI 캐릭터
   ✓ 남성 5명, 여성 5명 총 10가지 캐릭터
   ✓ 각 캐릭터별 최적화된 음성과 페르소나
   ✓ 전문분야별 차별화된 상담 스타일

2️⃣ 가족 중심 건강관리
   ✓ 본인 + 가족 구성원별 프로필
   ✓ 각 구성원의 건강정보 개별 관리
   ✓ 상담 시 대상자 선택 가능
   ✓ 무료: 본인 + 가족 1명 / 유료: 무제한

3️⃣ 상세한 건강정보 기반 맞춤 상담
   ✓ 성별, 나이, 체형 정보
   ✓ 만성질환 및 병력 고려
   ✓ 복용 약물 및 알레르기 관리
   ✓ AI가 개인별 맞춤 조언 제공

4️⃣ 검증된 건강기능식품 추천
   ✓ RAG 기반 성분 분석 시스템
   ✓ 식약처 인증 제품만 추천
   ✓ 상담 중 자연스러운 제품 추천
   ✓ 원클릭 구매 링크
   ✓ 안전성 검증 (금기사항, 약물상호작용)

5️⃣ 전문 자료 기반 지식베이스
   ✓ 국민건강보험공단 47개 증상별 자가관리
   ✓ 만성질환 관리 가이드
   ✓ RAG를 통한 의학적 검증 정보

6️⃣ 실시간 건강 데이터 활용
   ✓ 150+ 스마트워치 연동
   ✓ Terra API, Health Connect 통합
   ✓ 객관적 데이터 기반 조언

7️⃣ 무료 기본 기능
   ✓ 건강 루틴 체크 (물마시기, 운동, 명상 등)
   ✓ 감사 일기
   ✓ 기본 음성 상담

8️⃣ 의료 서비스 통합
   ✓ 의사 연계 대시보드
   ✓ 원격상담 연결
   ✓ 응급 분류 시스템
   ✓ 비대면 진료 예약
```

### 1.4 v6.0 주요 통합 업데이트

```
✨ v4.0 기반 핵심 기능
- AI 캐릭터 시스템 (10가지)
- OpenAI Realtime 음성 매칭
- Chroma DB 기반 RAG
- 국민건강보험공단 데이터 통합
- 건강 루틴 & 감사 일기
- 다중 웨어러블 통합
- 의료 서비스 연계

✨ v5.1 신규 추가 기능
- 가족 프로필 관리 시스템 (상세)
- 건강정보 수집 및 카드 형태 관리
- 건강기능식품 추천 시스템
- 제품 데이터베이스 및 RAG
- 관리자 제품 관리 시스템
- 제휴 샵 기능 (Phase 2)
- 제품 커미션 기반 수익 모델
```

### 1.5 목표 지표 (통합)

```
📊 비즈니스 목표
- 월간 활성 사용자(MAU): 10만명 (12개월 내)
- 무료→유료 전환율: 8-12%
- 가족 프로필 활용률: 60% 이상
- 월간 수익: $70K
  ├─ 광고: $5K
  ├─ 구독: $45K
  └─ 제품 추천 커미션: $20K

📈 사용자 경험 목표
- 앱 평점: 4.6/5.0 이상
- 캐릭터 평균 평점: 4.6+
- 가족 건강상담 완료율: 70% 이상
- 제품 추천 클릭률: 15% 이상
- 제품 구매 전환율: 3-5%
- 건강 루틴 완료율: 60%
- 사용자 재방문율: 주 4회 이상
```

---

## 2. 시스템 아키텍처

### 2.1 전체 아키텍처 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                     클라이언트 레이어                          │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ React Native │  │   음성 UI    │  │ Health Connect│     │
│  │     App      │  │  Visualizer  │  │   Integration │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  AI 캐릭터 선택 UI (10가지) + 가족 프로필 관리       │  │
│  │  건강정보 관리 + 제품 추천 UI                        │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                     API 게이트웨이 레이어                      │
│           (Node.js/Express + WebSocket)                     │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                    백엔드 서비스 레이어                        │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Voice Agent  │  │  RAG Engine  │  │   Product    │     │
│  │   Service    │  │   Service    │  │Recommendation│     │
│  │+캐릭터 관리   │  │+Chroma DB    │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Family     │  │ Subscription │  │  Analytics   │     │
│  │   Profile    │  │   Service    │  │   Service    │     │
│  │   Service    │  └──────────────┘  └──────────────┘     │
│  └──────────────┘  ┌──────────────┐  ┌──────────────┐     │
│  │   Health     │  │  Ad Network  │  │   Medical    │     │
│  │   Data Svc   │  │  Integration │  │   Service    │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                     데이터 레이어                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  PostgreSQL  │  │    Chroma    │  │    Redis     │     │
│  │  (사용자/    │  │  (Vector DB) │  │   (Cache)    │     │
│  │  가족/제품)  │  │              │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
                            ↕
┌─────────────────────────────────────────────────────────────┐
│                   외부 서비스 연동                            │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │OpenAI Realtime│ │  Terra API   │  │  Ad Network  │     │
│  │      API      │  │Health Connect│  │  (AdMob 등)  │     │
│  │10가지 음성    │  │              │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Medical    │  │  Affiliate   │  │   Payment    │     │
│  │   Services   │  │   Networks   │  │   Gateway    │     │
│  │              │  │(쿠팡,iHerb) │  │              │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 데이터 플로우

```
사용자 상담 플로우 (제품 추천 포함):

1. 사용자가 가족 구성원 선택
   └→ Family Profile Service
   
2. 음성 상담 시작
   └→ Voice Agent Service
   └→ Health Data Service (웨어러블 데이터 조회)
   
3. AI 응답 생성
   └→ RAG Engine (의료 지식 검색)
   └→ OpenAI Realtime API (음성 생성)
   
4. 제품 추천 트리거 감지
   └→ Product Recommendation Service
   └→ RAG Engine (제품 매칭)
   └→ Safety Check (금기사항 확인)
   
5. 제품 카드 표시
   └→ 사용자 클릭 추적
   └→ Affiliate Network 연결
```

---

## 3. 핵심 기능 명세

### 3.1 AI 건강주치의 캐릭터 시스템

#### 3.1.1 캐릭터 프로필 및 음성 매칭
**기능 ID**: F-CHARACTER-001  
**우선순위**: P0 (최우선)

**캐릭터 라인업 (10명)**:

##### 👨 남성 캐릭터 (5명)

| ID | 이름 | 나이 | 전문분야 | 성격 | OpenAI 음성 | 설명 |
|----|------|------|----------|------|-------------|------|
| M01 | 닥터 강민수 | 45세 | 가정의학과 | 따뜻하고 신뢰감 있는 | `alloy` | 20년 경력의 가정의학과 전문의. 부모님 같은 편안함 |
| M02 | 박준혁 코치 | 32세 | 운동처방 | 활기차고 동기부여하는 | `echo` | 전직 국가대표 트레이너. 에너지 넘치는 스타일 |
| M03 | 이현우 약사 | 38세 | 약학/영양 | 꼼꼼하고 설명 잘하는 | `fable` | 약국 경력 15년. 복잡한 내용을 쉽게 설명 |
| M04 | 김태양 선생 | 28세 | 정신건강 | 친근하고 공감력 높은 | `onyx` | 심리상담사. 젊고 친근한 접근 |
| M05 | 최성진 교수 | 52세 | 내과 | 권위있고 전문적인 | `shimmer` | 대학병원 교수. 깊이있는 의학 지식 |

##### 👩 여성 캐릭터 (5명)

| ID | 이름 | 나이 | 전문분야 | 성격 | OpenAI 음성 | 설명 |
|----|------|------|----------|------|-------------|------|
| F01 | 서지영 원장 | 42세 | 가정의학과 | 다정하고 세심한 | `nova` | 여성 건강 전문. 세심한 케어 |
| F02 | 윤수진 트레이너 | 30세 | 필라테스/요가 | 차분하고 우아한 | `alloy` | 홀리스틱 건강 전문가 |
| F03 | 정미라 영양사 | 36세 | 임상영양 | 명랑하고 실용적인 | `echo` | 병원 영양사 출신. 실생활 적용 |
| F04 | 한예린 선생 | 27세 | 웰니스코칭 | 밝고 에너제틱한 | `fable` | MZ세대 감성. 트렌디한 건강 정보 |
| F05 | 김선희 박사 | 48세 | 한의학 | 지혜롭고 포근한 | `shimmer` | 한의학 박사. 동서의학 통합 접근 |

**데이터 모델**:
```typescript
interface AICharacter {
  id: string;                          // 캐릭터 고유 ID
  name: string;                        // 이름
  gender: 'male' | 'female';          // 성별
  age: number;                         // 나이
  specialty: string[];                 // 전문분야 (복수 가능)
  personality: string;                 // 성격 특성
  description: string;                 // 캐릭터 설명
  
  // 음성 설정
  voice: {
    openaiVoice: 'alloy' | 'echo' | 'fable' | 'onyx' | 'shimmer' | 'nova';
    speed: number;                     // 0.25 - 4.0
    pitch: number;                     // -20 - 20
  };
  
  // 시각 자료
  avatarImage: {
    profile: string;                   // 프로필 이미지 URL
    thumbnail: string;                 // 썸네일 이미지 URL
    fullBody: string;                  // 전신 이미지 URL (옵션)
  };
  
  // 대화 스타일
  conversationStyle: {
    greeting: string[];                // 인사말 템플릿
    tone: 'formal' | 'casual' | 'balanced';
    useEmoji: boolean;                 // 이모지 사용 여부
    responseLength: 'short' | 'medium' | 'long';
  };
  
  // 전문 지식
  knowledgeBase: {
    primaryTopics: string[];           // 주요 주제
    certifications: string[];          // 자격증/경력
    yearsOfExperience: number;         // 경력 연수
  };
  
  // 통계
  stats: {
    totalConversations: number;        // 총 대화 횟수
    averageRating: number;             // 평균 평점 (1-5)
    userFavorites: number;             // 즐겨찾기 수
  };
  
  // 메타데이터
  isActive: boolean;                   // 활성화 여부
  isPremium: boolean;                  // 프리미엄 전용 여부
  createdAt: Date;
  updatedAt: Date;
}
```

#### 3.1.2 캐릭터 선택 UI
**기능 ID**: F-CHARACTER-002  
**우선순위**: P0

**화면 설계**:
```
┌─────────────────────────────────────┐
│  건강주치의를 선택해주세요           │
│  ═══════════════════════════════    │
│                                     │
│  [👨남성] [👩여성] [전체] [⭐즐겨찾기]│
│                                     │
│  ┌────────────┐  ┌────────────┐   │
│  │  [사진]    │  │  [사진]    │   │
│  │            │  │            │   │
│  │ 닥터 강민수 │  │ 박준혁 코치 │   │
│  │ 45세       │  │ 32세       │   │
│  │ 가정의학과  │  │ 운동처방   │   │
│  │ ⭐ 4.8     │  │ ⭐ 4.9     │   │
│  │ 🗣 따뜻함   │  │ 🗣 활기참   │   │
│  └────────────┘  └────────────┘   │
│                                     │
│  [◀ 이전]  [1/3]  [다음 ▶]        │
│                                     │
│  💡 팁: 캐릭터를 터치하면 음성 샘플을 │
│     들을 수 있습니다               │
└─────────────────────────────────────┘
```

---

### 3.2 🆕 가족 프로필 관리 시스템

#### 3.2.1 기능 개요
**기능 ID**: F-FAMILY-001  
**우선순위**: P0 (필수)

**핵심 기능**:
```
✅ 본인 프로필 (필수 1명)
✅ 가족 구성원 추가/수정/삭제
✅ 상담 시 대상자 선택
✅ 구성원별 독립적인 건강 데이터
✅ 무료/유료 등급별 제한
   - 무료: 본인 + 가족 1명 (총 2명)
   - 유료: 무제한
```

#### 3.2.2 데이터 모델

```typescript
interface FamilyProfile {
  profile_id: string;                   // 프로필 고유 ID
  user_id: string;                      // 소유자 user_id
  
  // 기본 정보
  name: string;                         // 이름
  nickname?: string;                    // 별명 (선택)
  relationship: 'self' | 'spouse' | 'parent' | 'child' | 'sibling' | 'other';
  date_of_birth: Date;                  // 생년월일
  age: number;                          // 나이 (자동 계산)
  gender: 'male' | 'female' | 'other';
  
  // 체형 정보
  height: number;                       // 키 (cm)
  weight: number;                       // 몸무게 (kg)
  bmi: number;                          // BMI (자동 계산)
  blood_type?: string;                  // 혈액형 (선택)
  
  // 건강 상태
  chronic_conditions: ChronicCondition[]; // 만성질환 목록
  medications: Medication[];            // 복용 약물
  allergies: Allergy[];                 // 알레르기
  surgeries: Surgery[];                 // 수술 이력
  
  // 생활 습관
  smoking_status: 'non-smoker' | 'ex-smoker' | 'smoker';
  alcohol_consumption: 'none' | 'occasional' | 'moderate' | 'heavy';
  exercise_frequency: 'none' | 'rarely' | 'weekly' | 'daily';
  sleep_hours: number;                  // 평균 수면 시간
  
  // 웨어러블 연동
  wearable_connected: boolean;
  wearable_device?: string;             // 연결된 기기 (예: Apple Watch)
  
  // 메타데이터
  is_primary: boolean;                  // 본인 프로필 여부
  avatar_color: string;                 // 아바타 색상 (UI용)
  created_at: Date;
  updated_at: Date;
  last_consultation_at?: Date;          // 마지막 상담 일시
}

interface ChronicCondition {
  condition_id: string;
  condition_code: string;               // 표준 코드 (예: ICD-10)
  condition_name: string;               // 질환명 (예: "고혈압")
  diagnosed_date?: Date;
  severity?: 'mild' | 'moderate' | 'severe';
  notes?: string;
}

interface Medication {
  medication_id: string;
  medication_name: string;              // 약물명
  dosage: string;                       // 용량
  frequency: string;                    // 복용 빈도 (예: "1일 2회")
  start_date?: Date;
  end_date?: Date;
  notes?: string;
}

interface Allergy {
  allergy_id: string;
  allergen: string;                     // 알레르겐 (예: "페니실린", "땅콩")
  reaction: string;                     // 반응 (예: "두드러기")
  severity: 'mild' | 'moderate' | 'severe' | 'life-threatening';
}

interface Surgery {
  surgery_id: string;
  procedure_name: string;               // 수술명
  surgery_date: Date;
  hospital?: string;
  notes?: string;
}
```

#### 3.2.3 UI/UX 설계

##### 가족 프로필 목록 화면
```
┌─────────────────────────────────────┐
│  🏠 우리 가족                        │
│  ═══════════════════════════════    │
│                                     │
│  [➕ 가족 구성원 추가]  (무료: 1/2) │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 👤 김철수 (본인)               │ │
│  │ 남성 · 45세 · 175cm · 70kg    │ │
│  │ 고혈압, 당뇨                   │ │
│  │ 마지막 상담: 2시간 전          │ │
│  │              [상담하기] [편집] │ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 👤 김영희 (배우자)             │ │
│  │ 여성 · 68세 · 160cm · 58kg    │ │
│  │ 골다공증                       │ │
│  │ 마지막 상담: 어제              │ │
│  │              [상담하기] [편집] │ │
│  └───────────────────────────────┘ │
│                                     │
│  💡 유료 전환 시 무제한 가족 추가   │
│     [프리미엄 가입하기 →]          │
└─────────────────────────────────────┘
```

##### 프로필 등록/수정 화면
```
┌─────────────────────────────────────┐
│  가족 구성원 정보                    │
│  ═══════════════════════════════    │
│                                     │
│  📝 기본 정보                        │
│  이름: [____________]               │
│  관계: [본인 ▼]                     │
│  생년월일: [1980-01-01]             │
│  성별: (⚪남성) (⚪여성)             │
│                                     │
│  📏 체형 정보                        │
│  키: [___] cm                       │
│  몸무게: [___] kg                   │
│  BMI: 24.5 (자동 계산)              │
│  혈액형: [A형 ▼]                    │
│                                     │
│  🏥 건강 상태                        │
│  만성질환:                           │
│  [+ 추가하기]                       │
│  • 고혈압 (2020년 진단) [삭제]      │
│  • 당뇨병 (2022년 진단) [삭제]      │
│                                     │
│  💊 복용 약물:                       │
│  [+ 추가하기]                       │
│  • 혈압약 (1일 1회) [삭제]          │
│  • 당뇨약 (1일 2회) [삭제]          │
│                                     │
│  ⚠️ 알레르기:                        │
│  [+ 추가하기]                       │
│  • 페니실린 (심각) [삭제]           │
│                                     │
│  🏃 생활 습관                        │
│  흡연: (⚪비흡연) (⚪과거흡연) (⚪흡연)│
│  음주: [가끔 ▼]                     │
│  운동: [주 3회 ▼]                   │
│  수면: [___] 시간                   │
│                                     │
│  [저장] [취소]                      │
└─────────────────────────────────────┘
```

#### 3.2.4 API 명세

```typescript
// 가족 프로필 목록 조회
GET /api/v1/family/profiles
Response: {
  profiles: FamilyProfile[];
  subscription: {
    plan: 'free' | 'premium';
    max_profiles: number;  // 무료: 2, 유료: 999
    current_count: number;
  };
}

// 가족 프로필 생성
POST /api/v1/family/profiles
Request: {
  name: string;
  relationship: string;
  date_of_birth: Date;
  gender: string;
  height?: number;
  weight?: number;
  chronic_conditions?: ChronicCondition[];
  medications?: Medication[];
  allergies?: Allergy[];
  // ... 기타 필드
}
Response: {
  profile_id: string;
  message: "프로필이 생성되었습니다.";
}

// 가족 프로필 수정
PUT /api/v1/family/profiles/{profile_id}
Request: { /* 수정할 필드들 */ }
Response: {
  profile_id: string;
  message: "프로필이 업데이트되었습니다.";
}

// 가족 프로필 삭제
DELETE /api/v1/family/profiles/{profile_id}
Response: {
  message: "프로필이 삭제되었습니다.";
}

// 가족 프로필 상세 조회
GET /api/v1/family/profiles/{profile_id}
Response: FamilyProfile
```

---

### 3.3 🆕 건강정보 수집 및 관리

#### 3.3.1 온보딩 플로우

**기능 ID**: F-HEALTH-INFO-001  
**우선순위**: P0

```
단계별 정보 수집:

1단계: 기본 정보
   ├─ 이름
   ├─ 나이
   ├─ 성별
   └─ 생년월일

2단계: 체형 정보
   ├─ 키
   ├─ 몸무게
   └─ BMI (자동 계산)

3단계: 건강 상태
   ├─ 만성질환 선택
   ├─ 복용 약물 입력
   └─ 알레르기 입력

4단계: 생활 습관
   ├─ 흡연 여부
   ├─ 음주 빈도
   ├─ 운동 빈도
   └─ 수면 시간

5단계: 웨어러블 연동 (선택)
   ├─ 스마트워치 연결
   └─ Health Connect 권한
```

#### 3.3.2 건강정보 카드 UI

```
┌─────────────────────────────────────┐
│  📊 김철수님의 건강 정보             │
│  ═══════════════════════════════    │
│                                     │
│  기본 정보                           │
│  ┌─────────────────────────────┐   │
│  │ 나이: 45세                   │   │
│  │ 성별: 남성                   │   │
│  │ 키: 175cm                    │   │
│  │ 몸무게: 70kg                 │   │
│  │ BMI: 22.9 (정상)             │   │
│  └─────────────────────────────┘   │
│                                     │
│  만성질환 (2개)                      │
│  ┌─────────────────────────────┐   │
│  │ • 고혈압 (2020년~)           │   │
│  │ • 제2형 당뇨병 (2022년~)     │   │
│  └─────────────────────────────┘   │
│                                     │
│  복용 약물 (2개)                     │
│  ┌─────────────────────────────┐   │
│  │ • 혈압약 (아침 1회)          │   │
│  │ • 당뇨약 (아침/저녁 2회)     │   │
│  └─────────────────────────────┘   │
│                                     │
│  알레르기 (1개)                      │
│  ┌─────────────────────────────┐   │
│  │ ⚠️ 페니실린 (심각)           │   │
│  └─────────────────────────────┘   │
│                                     │
│  생활 습관                           │
│  ┌─────────────────────────────┐   │
│  │ 🚭 비흡연                    │   │
│  │ 🍺 가끔 음주                 │   │
│  │ 🏃 주 3회 운동                │   │
│  │ 😴 7시간 수면                 │   │
│  └─────────────────────────────┘   │
│                                     │
│  [정보 수정하기]                    │
└─────────────────────────────────────┘
```

#### 3.3.3 건강정보 활용

```
AI 상담 시 건강정보 활용 예시:

사용자: "요즘 눈이 침침하고 피로해요."

AI (내부 컨텍스트):
- 이름: 김철수
- 나이: 68세 (노안 가능성)
- 만성질환: 당뇨병 (당뇨망막병증 위험)
- 약물: 당뇨약 복용 중

AI 응답:
"김철수님, 68세 연령과 당뇨병을 고려하면 눈 건강에 특히 
주의가 필요합니다. 당뇨망막병증 위험이 있으니 안과 정기 
검진을 받으시는 게 좋습니다. 

또한 눈 건강에 도움이 되는 루테인, 지아잔틴 같은 성분이 
들어있는 건강기능식품을 추천드릴 수 있는데, 김철수님의 
건강 상태에 맞는 제품을 찾아볼까요?"

💡 제품 추천 시 안전성 자동 확인:
   ✓ 나이 적합성
   ✓ 만성질환 금기사항
   ✓ 약물 상호작용
```

---

### 3.4 건강 루틴 체크 기능

#### 3.4.1 기능 개요
**기능 ID**: F-ROUTINE-001  
**우선순위**: P1  
**가격**: 무료

**지원 루틴 항목**:
```
아침 루틴 (슬로우모닝):
├─ 💧 물 마시기 (500ml)
├─ 🧘 명상/호흡 (5-10분)
├─ 📝 감사 3가지 적기
├─ 🏃 스트레칭 (5-10분)
└─ 🍽️ 건강한 아침 식사

하루 루틴:
├─ 🚶 걷기 (목표 걸음 수)
├─ 💪 운동 (30분)
├─ 🥗 채소 섭취
├─ 💊 약 복용
└─ 💧 물 마시기 (2L 목표)

저녁 루틴:
├─ 📱 디지털 디톡스 (취침 1시간 전)
├─ 🛁 반신욕/족욕
├─ 📔 감사 일기
└─ 😴 정시 취침
```

#### 3.4.2 데이터 모델

```typescript
interface RoutineTemplate {
  template_id: string;
  name: string;                         // "아침 루틴", "저녁 루틴"
  description: string;
  time_of_day: 'morning' | 'afternoon' | 'evening' | 'anytime';
  items: RoutineItem[];
  is_default: boolean;
}

interface RoutineItem {
  item_id: string;
  icon: string;                         // 이모지
  title: string;                        // "물 마시기"
  description: string;                  // "500ml 이상"
  goal_value?: number;                  // 목표 값 (선택)
  goal_unit?: string;                   // 단위 (ml, 분, 회 등)
  order: number;                        // 표시 순서
}

interface RoutineCompletion {
  completion_id: string;
  user_id: string;
  profile_id: string;                   // 가족 프로필 ID
  template_id: string;
  item_id: string;
  completed_at: Date;
  completion_date: Date;                // 날짜만 (YYYY-MM-DD)
  value?: number;                       // 실제 값 (선택)
  note?: string;                        // 메모 (선택)
}

interface RoutineStreak {
  user_id: string;
  profile_id: string;
  item_id: string;
  current_streak: number;               // 현재 연속 일수
  longest_streak: number;               // 최장 연속 일수
  last_completion_date: Date;
}
```

#### 3.4.3 UI/UX 설계

```
┌─────────────────────────────────────┐
│  🌅 오늘의 루틴                      │
│  2025년 11월 25일 (월)              │
│  ═══════════════════════════════    │
│                                     │
│  아침 루틴                           │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  ┌─────────────────────────────┐   │
│  │ ✅ 💧 물 마시기 (500ml)      │   │
│  │    완료! 🔥 3일 연속          │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ⬜ 🧘 명상/호흡 (10분)       │   │
│  │    [시작하기]                │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ⬜ 📝 감사 3가지 적기         │   │
│  │    [시작하기]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  오늘 진행률: ━━━━━━⚪⚪⚪⚪ 40%      │
│                                     │
│  하루 루틴                           │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│  ┌─────────────────────────────┐   │
│  │ ⬜ 🚶 걷기 (10,000걸음)      │   │
│  │    현재: 3,245걸음 (32%)     │   │
│  └─────────────────────────────┘   │
│  ┌─────────────────────────────┐   │
│  │ ⬜ 💪 운동 (30분)            │   │
│  │    [시작하기]                │   │
│  └─────────────────────────────┘   │
│                                     │
│  [루틴 편집하기]                    │
└─────────────────────────────────────┘
```

#### 3.4.4 API 명세

```typescript
// 루틴 템플릿 목록 조회
GET /api/v1/routines/templates
Response: {
  templates: RoutineTemplate[];
}

// 사용자 루틴 목록 조회 (특정 날짜)
GET /api/v1/routines/completions?date=2025-11-25&profile_id=xxx
Response: {
  date: Date;
  profile_id: string;
  routines: {
    template: RoutineTemplate;
    completions: RoutineCompletion[];
    completion_rate: number;  // 0.0 ~ 1.0
  }[];
  overall_completion_rate: number;
}

// 루틴 항목 완료 기록
POST /api/v1/routines/completions
Request: {
  profile_id: string;
  item_id: string;
  value?: number;
  note?: string;
}
Response: {
  completion_id: string;
  streak: {
    current: number;
    longest: number;
  };
  message: "물 마시기 완료! 🔥 3일 연속";
}

// 루틴 통계 조회
GET /api/v1/routines/stats?profile_id=xxx&period=week
Response: {
  period: 'week' | 'month' | 'year';
  stats: {
    item_id: string;
    item_name: string;
    completion_count: number;
    completion_rate: number;
    current_streak: number;
    longest_streak: number;
  }[];
}
```

---

### 3.5 감사 일기 기능

#### 3.5.1 기능 개요
**기능 ID**: F-GRATITUDE-001  
**우선순위**: P1  
**가격**: 무료

**핵심 기능**:
```
✅ 하루 3가지 감사한 일 기록
✅ 취침 전 작성 권장 (알림)
✅ 월별/연도별 기록 조회
✅ 통계 및 인사이트
✅ 긍정적 마인드셋 형성
```

#### 3.5.2 데이터 모델

```typescript
interface GratitudeEntry {
  entry_id: string;
  user_id: string;
  profile_id: string;                   // 가족 프로필 ID
  entry_date: Date;                     // 날짜 (YYYY-MM-DD)
  gratitude_items: string[];            // 감사한 일 3가지
  mood?: 'very-happy' | 'happy' | 'neutral' | 'sad' | 'very-sad';
  note?: string;                        // 추가 메모
  created_at: Date;
}

interface GratitudeStreak {
  user_id: string;
  profile_id: string;
  current_streak: number;               // 현재 연속 일수
  longest_streak: number;               // 최장 연속 일수
  total_entries: number;                // 총 작성 횟수
  last_entry_date: Date;
}
```

#### 3.5.3 UI/UX 설계

##### 감사 일기 작성 화면
```
┌─────────────────────────────────────┐
│  📔 오늘의 감사 일기                 │
│  2025년 11월 25일 (월)              │
│  ═══════════════════════════════    │
│                                     │
│  오늘 하루 감사한 일 3가지를         │
│  작성해보세요 😊                    │
│                                     │
│  1️⃣                                 │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │ 가족과 함께 저녁 식사를     │   │
│  │ 할 수 있어서 감사합니다     │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  2️⃣                                 │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │ 날씨가 좋아서 산책을        │   │
│  │ 할 수 있었습니다            │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  3️⃣                                 │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │ 건강하게 하루를 마무리할    │   │
│  │ 수 있어서 감사합니다        │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  오늘의 기분은?                      │
│  😄 😊 😐 😔 😢                    │
│                                     │
│  추가 메모 (선택)                    │
│  ┌─────────────────────────────┐   │
│  │                             │   │
│  │ 내일은 더 열심히...         │   │
│  │                             │   │
│  └─────────────────────────────┘   │
│                                     │
│  [저장하기] [나중에]                 │
│                                     │
│  🔥 7일 연속 작성 중!                │
└─────────────────────────────────────┘
```

##### 감사 일기 목록 화면
```
┌─────────────────────────────────────┐
│  📔 감사 일기                        │
│  ═══════════════════════════════    │
│                                     │
│  [2025년 11월 ▼]                    │
│                                     │
│  통계                                │
│  ┌─────────────────────────────┐   │
│  │ 이번 달 작성: 18/25일        │   │
│  │ 현재 연속: 🔥 7일            │   │
│  │ 최장 연속: 🏆 14일           │   │
│  │ 전체 작성: 156회             │   │
│  └─────────────────────────────┘   │
│                                     │
│  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━    │
│                                     │
│  11월 25일 (월) 😊                  │
│  ┌─────────────────────────────┐   │
│  │ 1. 가족과 함께 저녁 식사를  │   │
│  │    할 수 있어서              │   │
│  │ 2. 날씨가 좋아서 산책을      │   │
│  │    할 수 있었습니다          │   │
│  │ 3. 건강하게 하루를 마무리   │   │
│  │                             │   │
│  │                   [수정] [삭제]│   │
│  └─────────────────────────────┘   │
│                                     │
│  11월 24일 (일) 😄                  │
│  ┌─────────────────────────────┐   │
│  │ 1. 푹 쉴 수 있는 일요일      │   │
│  │ 2. 좋아하는 영화를 봤어요   │   │
│  │ 3. 친구와 통화했어요        │   │
│  │                   [수정] [삭제]│   │
│  └─────────────────────────────┘   │
│                                     │
│  [더 보기]                          │
└─────────────────────────────────────┘
```

#### 3.5.4 API 명세

```typescript
// 감사 일기 작성
POST /api/v1/gratitude/entries
Request: {
  profile_id: string;
  entry_date: Date;
  gratitude_items: string[];  // 3개 필수
  mood?: string;
  note?: string;
}
Response: {
  entry_id: string;
  streak: {
    current: number;
    longest: number;
  };
  message: "감사 일기가 저장되었습니다! 🔥 7일 연속";
}

// 감사 일기 목록 조회
GET /api/v1/gratitude/entries?profile_id=xxx&year=2025&month=11
Response: {
  entries: GratitudeEntry[];
  stats: {
    entries_this_month: number;
    current_streak: number;
    longest_streak: number;
    total_entries: number;
  };
}

// 감사 일기 수정
PUT /api/v1/gratitude/entries/{entry_id}
Request: {
  gratitude_items?: string[];
  mood?: string;
  note?: string;
}
Response: {
  entry_id: string;
  message: "감사 일기가 수정되었습니다.";
}

// 감사 일기 삭제
DELETE /api/v1/gratitude/entries/{entry_id}
Response: {
  message: "감사 일기가 삭제되었습니다.";
}

// 감사 일기 통계
GET /api/v1/gratitude/stats?profile_id=xxx&period=year
Response: {
  period: 'month' | 'year' | 'all';
  stats: {
    total_entries: number;
    completion_rate: number;         // 0.0 ~ 1.0
    current_streak: number;
    longest_streak: number;
    mood_distribution: {
      'very-happy': number;
      'happy': number;
      'neutral': number;
      'sad': number;
      'very-sad': number;
    };
    monthly_breakdown: {
      month: string;                  // "2025-11"
      count: number;
    }[];
  };
}
```

---

### 3.6 RAG 지식베이스 시스템

#### 3.6.1 기능 개요
**기능 ID**: F-RAG-001  
**우선순위**: P0 (최우선)

**지식베이스 소스**:
```
✅ 국민건강보험공단 자료
   ├─ 47개 증상별 자가관리 가이드
   ├─ 질환별 건강관리 정보
   └─ 건강검진 결과 해석

✅ 만성질환 관리 가이드
   ├─ 당뇨병 관리
   ├─ 고혈압 관리
   ├─ 고지혈증 관리
   ├─ 골다공증 관리
   └─ 만성폐쇄성폐질환(COPD) 관리

✅ 대한의학회 전문 자료
   ├─ 질병 정보
   ├─ 예방 가이드
   └─ 생활 습관 권장사항

✅ 건강기능식품 정보 (v5.1 추가)
   ├─ 식약처 인증 제품 데이터
   ├─ 성분별 효능 정보
   ├─ 안전성 및 금기사항
   └─ 임상 연구 자료
```

#### 3.6.2 기술 스택

```
벡터 데이터베이스: Chroma DB
- 이유: Python 네이티브, 무료 오픈소스
- 배포: Docker 컨테이너
- 대안: Chroma Cloud (스케일업 시)

임베딩 모델: OpenAI text-embedding-3-small
- 차원: 1536
- 비용: $0.02 / 1M 토큰
- 대안: text-embedding-3-large (더 정확)

검색 알고리즘: 
- 유사도 검색 (Cosine Similarity)
- 하이브리드 검색 (Dense + Sparse)
- Re-ranking (옵션)
```

#### 3.6.3 데이터 파이프라인

```
데이터 수집 → 전처리 → 임베딩 → 벡터 DB 저장

1. 데이터 수집
   ├─ 국민건강보험공단 PDF 다운로드
   ├─ 웹 스크래핑 (허용된 소스)
   └─ 수동 입력 (의료진 검증 자료)

2. 전처리
   ├─ PDF → 텍스트 변환 (pypdf)
   ├─ 청크 분할 (500-1000 토큰)
   ├─ 메타데이터 추가
   │   ├─ 소스
   │   ├─ 작성일
   │   ├─ 질환 카테고리
   │   └─ 신뢰도 점수
   └─ 중복 제거

3. 임베딩 생성
   ├─ OpenAI API 호출
   ├─ 배치 처리 (cost 절감)
   └─ 캐싱

4. Chroma DB 저장
   ├─ Collection 생성
   ├─ Document + Embedding 저장
   └─ 인덱싱
```

#### 3.6.4 검색 플로우

```typescript
// RAG 검색 함수
async function ragSearch(
  query: string,
  context: {
    age?: number;
    gender?: string;
    chronic_conditions?: string[];
  },
  topK: number = 5
): Promise<RAGResult[]> {
  
  // 1. 쿼리 확장 (Query Expansion)
  const expandedQuery = await expandQuery(query, context);
  
  // 2. 임베딩 생성
  const queryEmbedding = await openai.embeddings.create({
    model: "text-embedding-3-small",
    input: expandedQuery
  });
  
  // 3. Chroma DB 검색
  const results = await chromaDB.query({
    queryEmbeddings: [queryEmbedding.data[0].embedding],
    nResults: topK,
    where: {
      // 필터링 (옵션)
      category: context.category
    }
  });
  
  // 4. Re-ranking (신뢰도 점수 기반)
  const rankedResults = rerank(results, context);
  
  // 5. 컨텍스트 생성
  return rankedResults.map(r => ({
    text: r.document,
    source: r.metadata.source,
    relevance_score: r.score,
    metadata: r.metadata
  }));
}
```

#### 3.6.5 Chroma DB 설정

```python
import chromadb
from chromadb.config import Settings

# Chroma 클라이언트 초기화
client = chromadb.Client(Settings(
    chroma_db_impl="duckdb+parquet",
    persist_directory="./chroma_data"
))

# Collection 생성
collection = client.create_collection(
    name="health_knowledge_base",
    metadata={
        "description": "국민건강보험공단 + 만성질환 가이드",
        "embedding_model": "text-embedding-3-small",
        "dimension": 1536
    }
)

# 문서 추가
collection.add(
    documents=[
        "고혈압 환자는 저염식이를 해야 합니다...",
        "당뇨병 환자는 혈당 관리가 중요합니다..."
    ],
    metadatas=[
        {"source": "국민건강보험공단", "category": "고혈압", "date": "2023-05"},
        {"source": "대한당뇨병학회", "category": "당뇨병", "date": "2023-06"}
    ],
    ids=["doc1", "doc2"]
)

# 검색
results = collection.query(
    query_texts=["혈압을 낮추는 방법은?"],
    n_results=5
)
```

---

### 3.7 🆕 건강기능식품 추천 시스템

#### 3.7.1 기능 개요
**기능 ID**: F-PRODUCT-RECOMMEND-001  
**우선순위**: P0 (최우선)

**핵심 원칙**:
```
✅ 신뢰성 우선
   - 식약처 인증 제품만 추천
   - 성분 정보 투명하게 공개
   - 의료진 검토 완료 제품

✅ 자연스러운 추천
   - 강요하지 않음
   - 상담 맥락에 맞게
   - 사용자가 선택적으로 확인

✅ 개인화
   - 나이, 성별, 건강 상태 고려
   - 만성질환 확인 (금기 성분)
   - 복용 중인 약물 고려
```

#### 3.7.2 추천 트리거 (언제 추천하나?)

```
시나리오 1: 증상 호소
사용자: "요즘 눈이 너무 피로해요"
AI: "장시간 화면을 보시는 경우 눈 건강에 좋은 루테인, 지아잔틴 같은 
     성분이 도움이 될 수 있어요. 💡 검증된 눈 건강 제품을 추천해드릴까요?"

시나리오 2: 영양소 언급
사용자: "비타민D가 부족하다고 하는데..."
AI: "비타민D 부족은 흔한 문제예요. 햇빛 노출도 중요하지만, 보충제도 
     도움이 됩니다. 💡 식약처 인증 비타민D 제품을 보여드릴까요?"

시나리오 3: 건강 목표
사용자: "뼈 건강을 위해 뭘 먹어야 할까요?"
AI: "칼슘, 비타민D, 마그네슘이 뼈 건강에 중요합니다. 
     💡 뼈 건강에 도움이 되는 검증된 제품이 있는데 확인해보시겠어요?"
```

#### 3.7.3 추천 흐름

```
1️⃣ AI 상담 중 추천 의도 감지
   └─ 사용자 동의 요청
   
2️⃣ RAG 시스템 쿼리
   └─ 증상/성분 → 제품 매칭
   
3️⃣ 개인화 필터링
   └─ 나이, 성별, 만성질환 확인
   └─ 금기 성분 제외
   └─ 약물 상호작용 체크
   
4️⃣ 제품 카드 표시
   └─ 제품명, 성분, 효능
   └─ 식약처 인증 마크
   └─ 가격 및 구매 링크
   
5️⃣ 사용자 액션
   └─ 클릭 → 외부 쇼핑몰 (Phase 1)
   └─ 클릭 → 자체 샵 (Phase 2)
```

#### 3.7.4 제품 데이터 모델

```typescript
interface Product {
  product_id: string;                   // 제품 고유 ID
  name: string;                         // 제품명
  brand: string;                        // 브랜드
  category: string;                     // 카테고리 (눈 건강, 심혈관 등)
  description: string;                  // 제품 설명
  usage_instructions: string;           // 복용 방법
  
  // 성분 정보
  ingredients: Ingredient[];
  
  // 인증 정보
  certifications: Certification[];
  
  // 가격 정보
  pricing: {
    original_price: number;
    discounted_price?: number;
    currency: string;                   // "KRW"
  };
  
  // 구매 링크
  purchase_links: PurchaseLink[];
  
  // 안전성 정보
  safety: {
    min_age: number;                    // 최소 연령
    max_age?: number;                   // 최대 연령 (선택)
    safe_for_pregnancy: boolean;
    safe_for_nursing: boolean;
    contraindications: Contraindication[]; // 금기 사항
    drug_interactions: DrugInteraction[];  // 약물 상호작용
  };
  
  // 통계
  rating: number;                       // 평균 평점 (1-5)
  review_count: number;                 // 리뷰 수
  
  // 임상 연구 (선택)
  clinical_studies?: ClinicalStudy[];
  
  // 이미지/비디오
  images: string[];
  videos?: Video[];
  
  // 메타데이터
  status: 'pending' | 'active' | 'inactive' | 'rejected';
  created_at: Date;
  updated_at: Date;
  created_by: string;                   // 관리자 ID
  reviewed_by?: string;                 // 검수자 ID
  reviewed_at?: Date;
}

interface Ingredient {
  name: string;                         // 성분명
  amount: string;                       // 함량 ("20mg", "500IU" 등)
  daily_value_percent?: number;         // 일일 권장량 대비 %
  source?: string;                      // 원료 출처
  function: string;                     // 기능성 내용
}

interface Certification {
  type: string;                         // "kfda_functional", "gmp", etc
  cert_number: string;                  // 인증 번호
  cert_date: Date;                      // 인증 일자
  expiry_date?: Date;                   // 만료 일자
  certificate_url?: string;             // 인증서 URL
}

interface PurchaseLink {
  platform: string;                     // "쿠팡", "iHerb", "자체샵"
  url: string;                          // 구매 URL
  affiliate_code?: string;              // 제휴 코드
  is_active: boolean;
}

interface Contraindication {
  condition_code: string;               // 질환 코드 (ICD-10)
  condition_name: string;               // 질환명
  severity: 'warning' | 'caution' | 'contraindicated';
  notes: string;                        // 상세 설명
}

interface DrugInteraction {
  drug_name: string;                    // 약물명
  interaction_type: 'major' | 'moderate' | 'minor';
  description: string;                  // 상호작용 설명
}

interface ClinicalStudy {
  title: string;
  journal: string;
  year: number;
  summary: string;
  url?: string;
}

interface Video {
  title: string;
  url: string;
  thumbnail?: string;
}
```

#### 3.7.5 제품 추천 API

```typescript
// 제품 추천 요청
POST /api/v1/products/recommend

Request: {
  consultation_id: string;
  profile_id: string;
  symptom: string;                      // "눈 피로"
  keywords: string[];                   // ["눈 건강", "루테인"]
  health_context: {
    age: number;
    gender: string;
    chronic_conditions: string[];
    medications: string[];
    allergies: string[];
  };
}

Response: {
  recommendations: Product[];           // 최대 3개
  disclaimer: string;                   // 면책 조항
}

// 제품 상세 조회
GET /api/v1/products/{product_id}
Response: Product

// 제품 클릭 추적
POST /api/v1/products/{product_id}/click

Request: {
  user_id: string;
  profile_id: string;
  consultation_id: string;
  platform: string;                     // "쿠팡", "iHerb"
}

Response: {
  tracked: true;
  redirect_url: string;                 // 제휴 링크
}

// 제품 구매 추적 (webhook)
POST /api/v1/products/purchases/webhook

Request: {
  click_id: string;
  order_id: string;
  order_amount: number;
  commission_amount: number;
  commission_rate: number;
  purchased_at: Date;
}

Response: {
  purchase_id: string;
  message: "구매 추적 완료";
}
```

#### 3.7.6 안전성 검증 로직

```typescript
async function checkProductSafety(
  product: Product,
  profile: FamilyProfile
): Promise<SafetyCheckResult> {
  
  const warnings: string[] = [];
  const contraindications: string[] = [];
  let isSafe = true;
  
  // 1. 나이 확인
  if (profile.age < product.safety.min_age) {
    contraindications.push(
      `이 제품은 ${product.safety.min_age}세 이상부터 복용 가능합니다.`
    );
    isSafe = false;
  }
  
  // 2. 임신/수유 확인
  // (프로필에 임신/수유 정보가 있다면)
  if (profile.is_pregnant && !product.safety.safe_for_pregnancy) {
    contraindications.push(
      "임산부는 복용 전 의사와 상담이 필요합니다."
    );
    isSafe = false;
  }
  
  // 3. 만성질환 확인
  for (const condition of profile.chronic_conditions) {
    const match = product.safety.contraindications.find(
      c => c.condition_code === condition.condition_code
    );
    
    if (match) {
      if (match.severity === 'contraindicated') {
        contraindications.push(
          `${condition.condition_name} 환자는 이 제품을 복용할 수 없습니다.`
        );
        isSafe = false;
      } else if (match.severity === 'warning') {
        warnings.push(
          `${condition.condition_name}이 있으시면 주의가 필요합니다: ${match.notes}`
        );
      }
    }
  }
  
  // 4. 약물 상호작용 확인
  for (const medication of profile.medications) {
    const interaction = product.safety.drug_interactions.find(
      i => i.drug_name === medication.medication_name
    );
    
    if (interaction) {
      if (interaction.interaction_type === 'major') {
        contraindications.push(
          `${medication.medication_name}과 상호작용할 수 있습니다: ${interaction.description}`
        );
        isSafe = false;
      } else if (interaction.interaction_type === 'moderate') {
        warnings.push(
          `${medication.medication_name}과 함께 복용 시 주의: ${interaction.description}`
        );
      }
    }
  }
  
  return {
    safe_for_user: isSafe,
    warnings,
    contraindications
  };
}
```

#### 3.7.7 UI/UX 설계

```
상담 중 제품 추천 카드:

┌─────────────────────────────────────┐
│  🤖 AI: 눈 건강에 도움이 되는       │
│        제품을 추천해드릴게요         │
├─────────────────────────────────────┤
│  💡 추천 제품 (1/3)                 │
│  ┌───────────────────────────────┐  │
│  │  [제품 이미지]                │  │
│  │                               │  │
│  │  루테인 지아잔틴 플러스        │  │
│  │  뉴트리원                      │  │
│  │                               │  │
│  │  ✅ 식약처 기능성 인증         │  │
│  │  • 루테인 20mg                │  │
│  │  • 지아잔틴 4mg               │  │
│  │                               │  │
│  │  💚 엄마의 건강 상태에 적합   │  │
│  │  ⚠️ 특이사항 없음              │  │
│  │                               │  │
│  │  가격: ₩35,000 (22% 할인)     │  │
│  │  ⭐ 4.7 (1,234개 리뷰)        │  │
│  │                               │  │
│  │  [쿠팡에서 보기 →]            │  │
│  │  [iHerb에서 보기 →]           │  │
│  └───────────────────────────────┘  │
│                                     │
│  [다음 제품 →]  [더 알아보기]       │
│                                     │
│  ⚠️ 본 추천은 의학적 진단/치료를    │
│     대체하지 않습니다.              │
└─────────────────────────────────────┘
```

---

### 3.8 웨어러블 데이터 통합

#### 3.8.1 지원 플랫폼

**기능 ID**: F-WEARABLE-001  
**우선순위**: P0

**통합 전략**:
```
Phase 1 (필수):
├─ Terra API (유료)
│   └─ 150+ 웨어러블 지원
│   └─ 월 $49 (100 사용자)
│
└─ Health Connect (무료)
    └─ Android 전용
    └─ Google Fit, Samsung Health 등

Phase 2 (선택):
└─ Apple HealthKit (무료)
    └─ iOS 전용
    └─ Apple Watch, iPhone 데이터
```

#### 3.8.2 수집 데이터

```
기본 건강 데이터:
├─ 심박수 (HR)
├─ 걸음 수
├─ 수면 데이터 (수면 시간, 질)
├─ 활동 칼로리
├─ 혈압 (지원 기기)
└─ 혈당 (지원 기기)

고급 데이터 (프리미엄):
├─ 심박 변이도 (HRV)
├─ 산소 포화도 (SpO2)
├─ 스트레스 레벨
├─ 체온
└─ 심전도 (ECG)
```

#### 3.8.3 Terra API 통합

```typescript
// Terra SDK 초기화
import { Terra } from "terra-api";

const terra = new Terra({
  devId: process.env.TERRA_DEV_ID,
  apiKey: process.env.TERRA_API_KEY
});

// 웨어러블 연결 (사용자 인증)
async function connectWearable(
  userId: string,
  provider: 'fitbit' | 'garmin' | 'apple' | 'samsung' | 'oura' // 등
): Promise<string> {
  
  const widgetSession = await terra.generateWidgetSession({
    referenceId: userId,
    providers: [provider],
    language: "ko",
    authSuccessRedirectUrl: `https://app.example.com/wearable/success`,
    authFailureRedirectUrl: `https://app.example.com/wearable/failure`
  });
  
  return widgetSession.url;  // 사용자에게 인증 URL 제공
}

// 데이터 조회
async function getWearableData(
  userId: string,
  startDate: Date,
  endDate: Date
): Promise<WearableData> {
  
  const data = await terra.getDaily({
    userId,
    startDate,
    endDate
  });
  
  return {
    steps: data.steps,
    calories: data.calories_data,
    heart_rate: data.heart_rate_data,
    sleep: data.sleep_durations_data,
    // ... 기타 데이터
  };
}

// Webhook 수신 (실시간 데이터)
app.post('/api/v1/wearable/webhook', async (req, res) => {
  const { type, user, data } = req.body;
  
  // 데이터베이스 저장
  await saveWearableData(user.user_id, type, data);
  
  // 이상 징후 감지 (예: 급격한 심박수 변화)
  if (type === 'heart_rate' && data.heart_rate > 120) {
    await sendAlert(user.user_id, '심박수가 높게 측정되었습니다.');
  }
  
  res.status(200).send('OK');
});
```

#### 3.8.4 Health Connect 통합 (Android)

```kotlin
// Health Connect 권한 요청
val healthConnectClient = HealthConnectClient.getOrCreate(context)

val permissions = setOf(
    HealthPermission.createReadPermission(HeartRateRecord::class),
    HealthPermission.createReadPermission(StepsRecord::class),
    HealthPermission.createReadPermission(SleepSessionRecord::class)
)

// 권한 확인
val granted = healthConnectClient.permissionController.getGrantedPermissions(permissions)

if (granted != permissions) {
    // 권한 요청
    requestPermissions.launch(permissions)
}

// 데이터 읽기
suspend fun readStepsData(startTime: Instant, endTime: Instant): Long {
    val response = healthConnectClient.readRecords(
        ReadRecordsRequest(
            recordType = StepsRecord::class,
            timeRangeFilter = TimeRangeFilter.between(startTime, endTime)
        )
    )
    
    return response.records.sumOf { it.count }
}
```

---

### 3.9 로그인 및 인증 기능

#### 3.9.1 기능 개요
**기능 ID**: F-AUTH-001  
**우선순위**: P0

**지원 로그인 방식**:
```
Phase 1:
├─ 이메일/비밀번호 로그인
├─ 자동 로그인 (토큰 기반)
└─ 비밀번호 찾기 (이메일 인증)

Phase 2:
├─ Google 소셜 로그인
├─ Apple 소셜 로그인
└─ Kakao 소셜 로그인 (선택)
```

#### 3.9.2 인증 플로우

```
1. 회원가입
   ├─ 이메일 입력
   ├─ 이메일 인증 (6자리 코드)
   ├─ 비밀번호 설정
   ├─ 약관 동의
   └─ 본인 프로필 생성

2. 로그인
   ├─ 이메일/비밀번호 입력
   ├─ JWT 토큰 발급
   │   ├─ Access Token (1시간)
   │   └─ Refresh Token (30일)
   └─ 자동 로그인 설정 (선택)

3. 비밀번호 찾기
   ├─ 이메일 입력
   ├─ 인증 코드 발송
   ├─ 코드 확인
   └─ 새 비밀번호 설정

4. 소셜 로그인 (Phase 2)
   ├─ OAuth 2.0 플로우
   ├─ 프로필 정보 자동 입력
   └─ 계정 연동
```

#### 3.9.3 데이터 모델

```typescript
interface User {
  user_id: string;                      // 사용자 고유 ID
  email: string;                        // 이메일 (unique)
  password_hash: string;                // 해시된 비밀번호
  
  // 프로필 정보
  full_name?: string;                   // 전체 이름
  phone_number?: string;                // 전화번호
  
  // 계정 상태
  email_verified: boolean;              // 이메일 인증 여부
  is_active: boolean;                   // 계정 활성화
  is_premium: boolean;                  // 프리미엄 회원
  
  // 소셜 로그인 연동
  google_id?: string;
  apple_id?: string;
  kakao_id?: string;
  
  // 설정
  language: string;                     // "ko", "en", "ja"
  timezone: string;                     // "Asia/Seoul"
  notification_enabled: boolean;
  
  // 메타데이터
  created_at: Date;
  updated_at: Date;
  last_login_at?: Date;
  login_count: number;
}

interface AuthSession {
  session_id: string;
  user_id: string;
  access_token: string;
  refresh_token: string;
  device_info: {
    device_id: string;
    device_type: 'ios' | 'android' | 'web';
    os_version: string;
    app_version: string;
  };
  ip_address: string;
  created_at: Date;
  expires_at: Date;
  last_active_at: Date;
}

interface EmailVerification {
  verification_id: string;
  email: string;
  code: string;                         // 6자리 숫자
  type: 'signup' | 'password_reset';
  verified: boolean;
  created_at: Date;
  expires_at: Date;                     // 10분 후 만료
}
```

#### 3.9.4 API 명세

```typescript
// 회원가입
POST /api/v1/auth/signup
Request: {
  email: string;
  password: string;                     // 최소 8자, 영문+숫자+특수문자
  full_name: string;
  agreed_to_terms: boolean;
  agreed_to_privacy: boolean;
}
Response: {
  user_id: string;
  message: "회원가입이 완료되었습니다. 이메일 인증을 진행해주세요.";
}

// 이메일 인증 코드 발송
POST /api/v1/auth/send-verification-code
Request: {
  email: string;
  type: 'signup' | 'password_reset';
}
Response: {
  verification_id: string;
  message: "인증 코드가 이메일로 발송되었습니다.";
  expires_in: 600;  // 10분
}

// 이메일 인증 코드 확인
POST /api/v1/auth/verify-email
Request: {
  verification_id: string;
  code: string;                         // 6자리
}
Response: {
  verified: true;
  message: "이메일 인증이 완료되었습니다.";
}

// 로그인
POST /api/v1/auth/login
Request: {
  email: string;
  password: string;
  device_info: {
    device_id: string;
    device_type: string;
    os_version: string;
    app_version: string;
  };
}
Response: {
  user_id: string;
  access_token: string;                 // JWT, 1시간 유효
  refresh_token: string;                // 30일 유효
  user: {
    email: string;
    full_name: string;
    is_premium: boolean;
  };
}

// 토큰 갱신
POST /api/v1/auth/refresh
Request: {
  refresh_token: string;
}
Response: {
  access_token: string;
  refresh_token: string;                // 새로운 refresh token
}

// 로그아웃
POST /api/v1/auth/logout
Headers: {
  Authorization: "Bearer {access_token}";
}
Response: {
  message: "로그아웃되었습니다.";
}

// 비밀번호 재설정
POST /api/v1/auth/reset-password
Request: {
  verification_id: string;
  new_password: string;
}
Response: {
  message: "비밀번호가 재설정되었습니다.";
}

// Google 소셜 로그인 (Phase 2)
POST /api/v1/auth/social/google
Request: {
  id_token: string;                     // Google ID Token
  device_info: { /* ... */ };
}
Response: {
  user_id: string;
  access_token: string;
  refresh_token: string;
  is_new_user: boolean;                 // 신규 사용자 여부
}
```

---

### 3.10 의료 서비스 통합 기능

#### 3.10.1 기능 개요
**기능 ID**: F-MEDICAL-SERVICES-001  
**우선순위**: P2 (향후 확장)

**제공 서비스**:
```
✅ 의사 연계 대시보드
   - 환자 건강 데이터 공유
   - 이상 징후 자동 알림
   - 상담 히스토리 제공

✅ 원격상담 연결
   - 의료진과 실시간 화상/음성 상담
   - 사전 문진표 자동 작성
   - 상담 기록 저장

✅ 응급 분류 시스템
   - AI 기반 긴급도 평가
   - 응급/준응급/일반 분류
   - 적정 진료과 추천

✅ 비대면 진료 예약
   - 가까운 의료기관 검색
   - 예약 시스템 연동
   - 진료 알림
```

#### 3.10.2 의사 연계 대시보드

```
의료진용 대시보드:

┌─────────────────────────────────────┐
│  👨‍⚕️ 의료진 대시보드                 │
│  ═══════════════════════════════    │
│                                     │
│  내 환자 (15명)                      │
│  ┌───────────────────────────────┐ │
│  │ 🔴 김철수 (45세, 남)           │ │
│  │    고혈압, 당뇨                │ │
│  │    ⚠️ 혈압 이상 감지 (3시간 전)│ │
│  │    수축기 160mmHg              │ │
│  │                   [확인] [연락]│ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🟡 이영희 (68세, 여)           │ │
│  │    골다공증                    │ │
│  │    💊 복약 미이행 (어제)       │ │
│  │                   [확인] [연락]│ │
│  └───────────────────────────────┘ │
│                                     │
│  ┌───────────────────────────────┐ │
│  │ 🟢 박민준 (52세, 남)           │ │
│  │    정상 범위                   │ │
│  │    마지막 상담: 5일 전         │ │
│  │                   [데이터 보기]│ │
│  └───────────────────────────────┘ │
│                                     │
│  [환자 검색] [통계 보기]             │
└─────────────────────────────────────┘
```

#### 3.10.3 API 명세

```typescript
// 의사-환자 연결 요청
POST /api/v1/medical/connect-doctor
Request: {
  user_id: string;
  doctor_id: string;
  consent: boolean;                     // 데이터 공유 동의
}
Response: {
  connection_id: string;
  message: "의사와 연결되었습니다.";
}

// 환자 건강 데이터 조회 (의사용)
GET /api/v1/medical/patient-data/{user_id}?from=2025-11-01&to=2025-11-25
Headers: {
  Authorization: "Bearer {doctor_access_token}";
}
Response: {
  patient: {
    user_id: string;
    name: string;
    age: number;
    gender: string;
    chronic_conditions: string[];
  };
  health_data: {
    wearable_data: WearableData[];
    consultations: Consultation[];
    medications: Medication[];
  };
  alerts: {
    alert_id: string;
    type: string;                       // "high_bp", "missed_medication"
    severity: string;                   // "low", "medium", "high"
    message: string;
    timestamp: Date;
  }[];
}

// 이상 징후 알림 (시스템 → 의사)
POST /api/v1/medical/alerts/send
Request: {
  doctor_id: string;
  patient_id: string;
  alert_type: string;
  severity: string;
  data: {
    metric: string;                     // "blood_pressure"
    value: number;
    threshold: number;
  };
}
Response: {
  alert_id: string;
  message: "알림이 전송되었습니다.";
}

// 원격상담 예약
POST /api/v1/medical/consultations/book
Request: {
  user_id: string;
  doctor_id: string;
  consultation_type: 'video' | 'voice' | 'chat';
  preferred_time: Date;
  symptoms: string;
  notes?: string;
}
Response: {
  consultation_id: string;
  scheduled_time: Date;
  meeting_link?: string;                // 화상 상담용
  message: "상담이 예약되었습니다.";
}
```

---

## 4. 수익 모델 구현

### 4.1 수익원 구조

```
총 월 수익 목표: $70K (DAU 10,000명 기준)

1️⃣ 구독 수익: $45K (64%)
   ├─ 베이직 플랜: $9.99/월
   │   └─ 300명 × $9.99 = $2,997
   ├─ 프리미엄 플랜: $14.99/월
   │   └─ 150명 × $14.99 = $2,248
   └─ 패밀리 플랜: $24.99/월
       └─ 50명 × $24.99 = $1,249
   
2️⃣ 제품 추천 커미션: $20K (29%)
   ├─ 평균 클릭 수: 30,000/월
   ├─ 구매 전환율: 3%
   ├─ 평균 구매액: $60
   ├─ 평균 커미션율: 12%
   └─ 수익: 900건 × $60 × 12% = $6,480
   └─ Phase 2 (자체샵): $20K/월

3️⃣ 광고 수익: $5K (7%)
   ├─ 무료 사용자 대상
   ├─ eCPM: $5
   └─ 월 노출 수: 1M
```

### 4.2 구독 플랜 상세

#### 4.2.1 무료 플랜
**가격**: $0/월

**포함 기능**:
```
✅ 본인 + 가족 1명 프로필
✅ 기본 AI 건강 상담 (월 10회)
✅ 건강 루틴 체크
✅ 감사 일기
✅ 제품 추천 (클릭만 가능)
✅ AI 캐릭터 3명 선택 가능
❌ 웨어러블 연동 제한
❌ 상담 히스토리 30일만 보관
✅ 광고 표시
```

#### 4.2.2 베이직 플랜
**가격**: $9.99/월 (₩12,900)

**포함 기능**:
```
✅ 본인 + 가족 3명 프로필
✅ 무제한 AI 건강 상담
✅ 전체 AI 캐릭터 10명 선택 가능
✅ 웨어러블 연동 (기본 데이터)
✅ 상담 히스토리 무제한
✅ 제품 구매 시 3% 포인트 적립
✅ 주간 건강 리포트
❌ 광고 제거
❌ 의사 연계 기능 제한
```

#### 4.2.3 프리미엄 플랜
**가격**: $14.99/월 (₩19,900)

**포함 기능**:
```
✅ 무제한 가족 프로필
✅ 무제한 AI 건강 상담
✅ 전체 AI 캐릭터 + 음성 커스터마이징
✅ 웨어러블 연동 (고급 데이터: HRV, SpO2)
✅ 상담 히스토리 무제한
✅ 제품 구매 시 5% 포인트 적립
✅ 주간 + 월간 건강 리포트
✅ 광고 완전 제거
✅ 의사 연계 기능
✅ 우선 고객 지원
✅ 맞춤형 건강 목표 설정
✅ AI 건강 위험도 예측
```

#### 4.2.4 패밀리 플랜
**가격**: $24.99/월 (₩32,900)

**포함 기능**:
```
✅ 프리미엄 플랜 모든 기능
✅ 최대 6명 가족 공유
✅ 각 구성원별 독립 계정
✅ 가족 건강 대시보드
✅ 제품 구매 시 7% 포인트 적립
✅ 정기 배송 10% 추가 할인
```

### 4.3 제품 추천 커미션 모델

#### 4.3.1 Phase 1: 제휴 쇼핑몰

```
제휴 플랫폼별 커미션율:

┌──────────────┬──────────┬──────────┐
│ 플랫폼       │ 커미션율 │ 결제 주기│
├──────────────┼──────────┼──────────┤
│ 쿠팡 파트너스│ 3-5%     │ 월 1회   │
│ iHerb        │ 10%      │ 월 1회   │
│ 11번가       │ 3-7%     │ 월 1회   │
│ G마켓        │ 2-5%     │ 월 1회   │
└──────────────┴──────────┴──────────┘

수익 계산 예시:
- 월 클릭 수: 30,000
- 구매 전환율: 3% = 900건
- 평균 구매액: $60
- 평균 커미션: 12%
- 월 커미션 수익: 900 × $60 × 12% = $6,480
```

#### 4.3.2 Phase 2: 자체 쇼핑몰

```
자체 쇼핑몰 마진율: 15-30%

예상 수익 (자체 샵 오픈 후):
- 월 구매 건수: 1,500건
- 평균 구매액: $80
- 평균 마진율: 20%
- 월 수익: 1,500 × $80 × 20% = $24,000

추가 수익원:
- 정기 배송 구독: +10% 수익
- 프리미엄 제품 판매: +15% 수익
- B2B 기업 웰니스 패키지: +$5K/월
```

---

## 5. 광고 시스템

### 5.1 광고 통합 전략

**타겟**: 무료 사용자만  
**광고 플랫폼**: Google AdMob + Meta Audience Network

**광고 유형**:
```
1️⃣ 배너 광고
   - 위치: 화면 하단
   - 크기: 320x50 (스마트 배너)
   - 빈도: 항상 표시
   - eCPM: $3-5

2️⃣ 네이티브 광고
   - 위치: 콘텐츠 피드 사이
   - 형식: 앱 디자인과 자연스럽게 통합
   - 빈도: 5개 콘텐츠당 1개
   - eCPM: $8-12

3️⃣ 보상형 광고
   - 트리거: 프리미엄 기능 접근 시
   - 보상: 1회 프리미엄 상담 권한
   - 빈도: 하루 3회 제한
   - eCPM: $15-25

4️⃣ 전면 광고
   - 위치: 앱 전환 시 (세션 종료 시)
   - 빈도: 하루 2회 제한
   - eCPM: $10-15
```

### 5.2 수익 예측

```
DAU 10,000명 기준:
- 무료 사용자: 80% = 8,000명
- 일 노출 수: 8,000명 × 10회 = 80,000
- 월 노출 수: 80,000 × 30 = 2,400,000

┌────────────────┬─────────┬──────────┬─────────┐
│ 광고 유형      │ 노출 비율│ eCPM     │ 월 수익 │
├────────────────┼─────────┼──────────┼─────────┤
│ 배너           │ 40%     │ $4       │ $3,840  │
│ 네이티브       │ 30%     │ $10      │ $7,200  │
│ 보상형         │ 20%     │ $20      │ $9,600  │
│ 전면           │ 10%     │ $12      │ $2,880  │
├────────────────┴─────────┴──────────┼─────────┤
│ 총 월 광고 수익                      │ $23,520 │
└──────────────────────────────────────┴─────────┘

※ 실제 수익은 지역, 시즌, 광고 품질에 따라 ±30% 변동
```

### 5.3 광고 구현

```typescript
// AdMob 초기화 (React Native)
import MobileAds from '@react-native-google-mobile-ads/admob';

await MobileAds().initialize();

// 배너 광고
import { BannerAd, BannerAdSize, TestIds } from '@react-native-google-mobile-ads/admob';

const adUnitId = __DEV__ 
  ? TestIds.BANNER 
  : 'ca-app-pub-xxxxx/yyyyy';

<BannerAd
  unitId={adUnitId}
  size={BannerAdSize.ANCHORED_ADAPTIVE_BANNER}
  requestOptions={{
    requestNonPersonalizedAdsOnly: false,
  }}
/>

// 보상형 광고
import { RewardedAd, RewardedAdEventType } from '@react-native-google-mobile-ads/admob';

const rewarded = RewardedAd.createForAdRequest(rewardedAdUnitId);

rewarded.addAdEventListener(RewardedAdEventType.EARNED_REWARD, reward => {
  // 보상 지급
  grantPremiumAccess(userId, '1_consultation');
});

await rewarded.load();
await rewarded.show();
```

---

## 6. 결제 및 구독 시스템

### 6.1 결제 플랫폼

```
iOS: Apple In-App Purchase (필수)
Android: Google Play Billing (필수)
웹: Stripe (선택)
```

### 6.2 구독 관리

```typescript
// React Native IAP 라이브러리 사용
import * as RNIap from 'react-native-iap';

// 제품 ID
const productIds = [
  'com.healthvoiceai.basic.monthly',
  'com.healthvoiceai.premium.monthly',
  'com.healthvoiceai.family.monthly'
];

// 구독 상품 조회
const products = await RNIap.getSubscriptions(productIds);

// 구매 요청
const purchase = await RNIap.requestSubscription({
  sku: 'com.healthvoiceai.premium.monthly',
  andDangerouslyFinishTransactionAutomaticallyIOS: false
});

// 구매 영수증 검증 (백엔드)
POST /api/v1/subscriptions/verify
Request: {
  user_id: string;
  platform: 'ios' | 'android';
  receipt: string;                      // 영수증 데이터
}
Response: {
  verified: true;
  subscription: {
    plan: 'premium';
    start_date: Date;
    expiry_date: Date;
    auto_renew: boolean;
  };
}

// 구독 취소/환불 처리
// iOS: App Store Connect에서 관리
// Android: Google Play Console에서 관리
// Webhook으로 백엔드에 알림
```

### 6.3 자체 샵 결제 (Phase 2)

```
결제 대행사: KG이니시스 / 토스페이먼츠

지원 결제 수단:
├─ 신용카드 (VISA, MasterCard, 국내카드)
├─ 계좌이체
├─ 가상계좌
├─ 카카오페이
├─ 네이버페이
└─ 토스

결제 플로우:
1. 장바구니 → 주문서 작성
2. 결제 수단 선택
3. PG사 결제 창 호출
4. 결제 승인
5. 주문 완료
6. 배송 준비
```

---

## 7. 기술 스택

### 7.1 프론트엔드

```
모바일 앱:
├─ React Native 0.73+
├─ TypeScript 5.0+
├─ React Navigation 6+
├─ React Query (서버 상태 관리)
├─ Zustand (클라이언트 상태 관리)
├─ Styled Components (스타일링)
├─ React Native Voice (음성 입력)
└─ React Native IAP (구독)

웹 관리자 페이지:
├─ Next.js 14+
├─ TypeScript
├─ Tailwind CSS
└─ shadcn/ui
```

### 7.2 백엔드

```
API 서버:
├─ Node.js 20+ / Express.js 4+
├─ TypeScript
├─ Prisma (ORM)
├─ Bull (작업 큐)
└─ Socket.io (WebSocket)

Python 서비스 (AI/ML):
├─ Python 3.11+
├─ FastAPI
├─ LangChain
├─ Chroma DB (벡터 DB)
└─ pandas, numpy (데이터 처리)
```

### 7.3 데이터베이스

```
주 데이터베이스:
├─ PostgreSQL 15+ (사용자, 가족 프로필, 제품 등)
└─ 배포: AWS RDS 또는 Supabase

벡터 데이터베이스:
├─ Chroma DB (의료 지식, 제품 정보)
└─ 배포: Docker 컨테이너

캐시/세션:
├─ Redis 7+
└─ 배포: AWS ElastiCache 또는 Upstash
```

### 7.4 외부 서비스

```
AI/ML:
├─ OpenAI API (GPT-4, Realtime Voice, Embeddings)
└─ 대안: Anthropic Claude, Google Gemini

웨어러블 연동:
├─ Terra API (유료)
├─ Google Health Connect SDK
└─ Apple HealthKit SDK

결제:
├─ Apple In-App Purchase
├─ Google Play Billing
└─ KG이니시스 / 토스페이먼츠 (자체 샵)

알림:
├─ Firebase Cloud Messaging
└─ OneSignal (대안)

이메일:
├─ SendGrid
└─ AWS SES (대안)

파일 저장:
├─ AWS S3
└─ Cloudflare R2 (대안)

CDN:
├─ Cloudflare CDN
└─ AWS CloudFront (대안)
```

### 7.5 DevOps

```
인프라:
├─ AWS EC2 / ECS (컨테이너)
├─ Docker + Docker Compose
└─ Kubernetes (스케일업 시)

CI/CD:
├─ GitHub Actions
├─ CodePipeline
└─ Fastlane (모바일 배포)

모니터링:
├─ Sentry (에러 트래킹)
├─ DataDog (APM)
├─ CloudWatch (인프라)
└─ Mixpanel / Amplitude (사용자 분석)

테스트:
├─ Jest (단위 테스트)
├─ Cypress (E2E 테스트)
└─ Detox (모바일 E2E)
```

---

## 8. 데이터베이스 설계

### 8.1 ERD 다이어그램

```
┌──────────────┐
│    users     │
│──────────────│
│ user_id (PK) │───┐
│ email        │   │
│ password_hash│   │
│ ...          │   │
└──────────────┘   │
                   │
                   │ 1:N
                   │
┌──────────────────▼───┐
│     profiles         │
│──────────────────────│
│ profile_id (PK)      │───┐
│ user_id (FK)         │   │
│ name                 │   │
│ relationship         │   │
│ age, gender          │   │
│ chronic_conditions   │   │
│ ...                  │   │
└──────────────────────┘   │
                           │ 1:N
                           │
┌──────────────────────────▼───┐
│     consultations            │
│──────────────────────────────│
│ consultation_id (PK)         │
│ profile_id (FK)              │
│ character_id (FK)            │
│ transcript                   │
│ ...                          │
└──────────────────────────────┘

┌──────────────┐
│  characters  │
│──────────────│
│ character_id │
│ name         │
│ voice        │
│ ...          │
└──────────────┘

┌──────────────────────┐
│      products        │
│──────────────────────│
│ product_id (PK)      │───┐
│ name, brand          │   │
│ category             │   │
│ ...                  │   │
└──────────────────────┘   │
                           │ 1:N
                           │
┌────────────────────────▼────┐
│   product_ingredients       │
│─────────────────────────────│
│ ingredient_id (PK)          │
│ product_id (FK)             │
│ name, amount                │
│ ...                         │
└─────────────────────────────┘

┌──────────────────────┐
│   subscriptions      │
│──────────────────────│
│ subscription_id (PK) │
│ user_id (FK)         │
│ plan                 │
│ status               │
│ start_date           │
│ expiry_date          │
│ ...                  │
└──────────────────────┘
```

### 8.2 주요 테이블 (통합)

```sql
-- 사용자 테이블
CREATE TABLE users (
  user_id VARCHAR(50) PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255),
  
  full_name VARCHAR(100),
  phone_number VARCHAR(20),
  
  email_verified BOOLEAN DEFAULT FALSE,
  is_active BOOLEAN DEFAULT TRUE,
  is_premium BOOLEAN DEFAULT FALSE,
  
  google_id VARCHAR(255),
  apple_id VARCHAR(255),
  
  language VARCHAR(5) DEFAULT 'ko',
  timezone VARCHAR(50) DEFAULT 'Asia/Seoul',
  notification_enabled BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login_at TIMESTAMP,
  login_count INT DEFAULT 0
);

-- 가족 프로필 테이블
CREATE TABLE profiles (
  profile_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
  
  name VARCHAR(100) NOT NULL,
  nickname VARCHAR(100),
  relationship VARCHAR(20) NOT NULL,
  date_of_birth DATE NOT NULL,
  age INT NOT NULL,
  gender VARCHAR(10) NOT NULL,
  
  height DECIMAL(5,2),
  weight DECIMAL(5,2),
  bmi DECIMAL(4,2),
  blood_type VARCHAR(5),
  
  smoking_status VARCHAR(20),
  alcohol_consumption VARCHAR(20),
  exercise_frequency VARCHAR(20),
  sleep_hours DECIMAL(3,1),
  
  wearable_connected BOOLEAN DEFAULT FALSE,
  wearable_device VARCHAR(100),
  
  is_primary BOOLEAN DEFAULT FALSE,
  avatar_color VARCHAR(7),
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_consultation_at TIMESTAMP,
  
  INDEX idx_profiles_user (user_id),
  INDEX idx_profiles_relationship (relationship)
);

-- 만성질환 테이블
CREATE TABLE chronic_conditions (
  condition_id VARCHAR(50) PRIMARY KEY,
  profile_id VARCHAR(50) NOT NULL REFERENCES profiles(profile_id) ON DELETE CASCADE,
  
  condition_code VARCHAR(20) NOT NULL,
  condition_name VARCHAR(100) NOT NULL,
  diagnosed_date DATE,
  severity VARCHAR(20),
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_conditions_profile (profile_id),
  INDEX idx_conditions_code (condition_code)
);

-- 복용 약물 테이블
CREATE TABLE medications (
  medication_id VARCHAR(50) PRIMARY KEY,
  profile_id VARCHAR(50) NOT NULL REFERENCES profiles(profile_id) ON DELETE CASCADE,
  
  medication_name VARCHAR(200) NOT NULL,
  dosage VARCHAR(100),
  frequency VARCHAR(100),
  start_date DATE,
  end_date DATE,
  notes TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_medications_profile (profile_id)
);

-- 알레르기 테이블
CREATE TABLE allergies (
  allergy_id VARCHAR(50) PRIMARY KEY,
  profile_id VARCHAR(50) NOT NULL REFERENCES profiles(profile_id) ON DELETE CASCADE,
  
  allergen VARCHAR(100) NOT NULL,
  reaction VARCHAR(200),
  severity VARCHAR(20) NOT NULL,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_allergies_profile (profile_id)
);

-- AI 캐릭터 테이블
CREATE TABLE characters (
  character_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  gender VARCHAR(10) NOT NULL,
  age INT NOT NULL,
  specialty TEXT[],
  personality VARCHAR(100),
  description TEXT,
  
  voice_openai VARCHAR(20) NOT NULL,
  voice_speed DECIMAL(3,2) DEFAULT 1.0,
  voice_pitch INT DEFAULT 0,
  
  avatar_profile_url TEXT,
  avatar_thumbnail_url TEXT,
  avatar_fullbody_url TEXT,
  
  conversation_tone VARCHAR(20) DEFAULT 'balanced',
  use_emoji BOOLEAN DEFAULT TRUE,
  response_length VARCHAR(20) DEFAULT 'medium',
  
  total_conversations INT DEFAULT 0,
  average_rating DECIMAL(3,2) DEFAULT 0,
  user_favorites INT DEFAULT 0,
  
  is_active BOOLEAN DEFAULT TRUE,
  is_premium BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 상담 기록 테이블
CREATE TABLE consultations (
  consultation_id VARCHAR(50) PRIMARY KEY,
  profile_id VARCHAR(50) NOT NULL REFERENCES profiles(profile_id),
  character_id VARCHAR(50) REFERENCES characters(character_id),
  
  conversation_type VARCHAR(20) DEFAULT 'voice',
  transcript TEXT,
  audio_url TEXT,
  duration_seconds INT,
  
  wearable_data_snapshot JSONB,
  recommended_products JSONB,
  
  user_rating INT,
  user_feedback TEXT,
  
  started_at TIMESTAMP NOT NULL,
  ended_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_consultations_profile (profile_id),
  INDEX idx_consultations_character (character_id),
  INDEX idx_consultations_date (started_at)
);

-- 제품 테이블
CREATE TABLE products (
  product_id VARCHAR(50) PRIMARY KEY,
  name VARCHAR(200) NOT NULL,
  brand VARCHAR(100) NOT NULL,
  category VARCHAR(50) NOT NULL,
  description TEXT,
  usage_instructions TEXT,
  
  min_age INT DEFAULT 18,
  safe_for_pregnancy BOOLEAN DEFAULT FALSE,
  safe_for_nursing BOOLEAN DEFAULT FALSE,
  
  original_price DECIMAL(10,2),
  discounted_price DECIMAL(10,2),
  currency VARCHAR(3) DEFAULT 'KRW',
  
  status VARCHAR(20) DEFAULT 'pending',
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INT DEFAULT 0,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(50),
  reviewed_by VARCHAR(50),
  reviewed_at TIMESTAMP,
  
  INDEX idx_products_category (category),
  INDEX idx_products_status (status),
  INDEX idx_products_brand (brand),
  
  CONSTRAINT valid_status CHECK (
    status IN ('pending', 'active', 'inactive', 'rejected')
  )
);

-- 제품 성분 테이블
CREATE TABLE product_ingredients (
  ingredient_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  
  name VARCHAR(100) NOT NULL,
  amount VARCHAR(50),
  daily_value_percent INT,
  source TEXT,
  function TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_ingredients_product (product_id),
  INDEX idx_ingredients_name (name)
);

-- 제품 인증 테이블
CREATE TABLE product_certifications (
  cert_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  
  type VARCHAR(50) NOT NULL,
  cert_number VARCHAR(100),
  cert_date DATE,
  expiry_date DATE,
  certificate_url TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 구매 링크 테이블
CREATE TABLE product_purchase_links (
  link_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  
  platform VARCHAR(50) NOT NULL,
  url TEXT NOT NULL,
  affiliate_code VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 클릭 추적 테이블
CREATE TABLE product_clicks (
  click_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id),
  user_id VARCHAR(50) REFERENCES users(user_id),
  profile_id VARCHAR(50) REFERENCES profiles(profile_id),
  consultation_id VARCHAR(50),
  platform VARCHAR(50),
  
  clicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_clicks_product (product_id),
  INDEX idx_clicks_user (user_id),
  INDEX idx_clicks_date (clicked_at)
);

-- 구독 테이블
CREATE TABLE subscriptions (
  subscription_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL REFERENCES users(user_id),
  
  plan VARCHAR(20) NOT NULL,
  status VARCHAR(20) NOT NULL,
  
  platform VARCHAR(20) NOT NULL,
  platform_subscription_id VARCHAR(255),
  receipt TEXT,
  
  start_date TIMESTAMP NOT NULL,
  expiry_date TIMESTAMP NOT NULL,
  auto_renew BOOLEAN DEFAULT TRUE,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  cancelled_at TIMESTAMP,
  
  INDEX idx_subscriptions_user (user_id),
  INDEX idx_subscriptions_status (status),
  INDEX idx_subscriptions_expiry (expiry_date)
);

-- 루틴 완료 기록 테이블
CREATE TABLE routine_completions (
  completion_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL REFERENCES users(user_id),
  profile_id VARCHAR(50) REFERENCES profiles(profile_id),
  
  template_id VARCHAR(50) NOT NULL,
  item_id VARCHAR(50) NOT NULL,
  
  completed_at TIMESTAMP NOT NULL,
  completion_date DATE NOT NULL,
  value DECIMAL(10,2),
  note TEXT,
  
  INDEX idx_completions_user_date (user_id, completion_date),
  INDEX idx_completions_profile (profile_id)
);

-- 감사 일기 테이블
CREATE TABLE gratitude_entries (
  entry_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL REFERENCES users(user_id),
  profile_id VARCHAR(50) REFERENCES profiles(profile_id),
  
  entry_date DATE NOT NULL,
  gratitude_items TEXT[] NOT NULL,
  mood VARCHAR(20),
  note TEXT,
  
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_entries_user_date (user_id, entry_date),
  UNIQUE (user_id, profile_id, entry_date)
);

-- 웨어러블 데이터 테이블
CREATE TABLE wearable_data (
  data_id VARCHAR(50) PRIMARY KEY,
  profile_id VARCHAR(50) NOT NULL REFERENCES profiles(profile_id),
  
  data_type VARCHAR(50) NOT NULL,
  value DECIMAL(10,2) NOT NULL,
  unit VARCHAR(20),
  
  source VARCHAR(50),
  recorded_at TIMESTAMP NOT NULL,
  synced_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  metadata JSONB,
  
  INDEX idx_wearable_profile_type (profile_id, data_type),
  INDEX idx_wearable_recorded (recorded_at)
);
```

---

## 9. API 명세

### 9.1 API 버전 관리

```
Base URL: https://api.healthvoiceai.com
API Version: v1
Format: REST API (JSON)
Authentication: JWT Bearer Token
```

### 9.2 인증 API

자세한 내용은 섹션 3.9 참조

```
POST   /api/v1/auth/signup
POST   /api/v1/auth/login
POST   /api/v1/auth/refresh
POST   /api/v1/auth/logout
POST   /api/v1/auth/send-verification-code
POST   /api/v1/auth/verify-email
POST   /api/v1/auth/reset-password
POST   /api/v1/auth/social/google
POST   /api/v1/auth/social/apple
```

### 9.3 가족 프로필 API

자세한 내용은 섹션 3.2 참조

```
GET    /api/v1/family/profiles
POST   /api/v1/family/profiles
GET    /api/v1/family/profiles/{profile_id}
PUT    /api/v1/family/profiles/{profile_id}
DELETE /api/v1/family/profiles/{profile_id}
```

### 9.4 AI 캐릭터 API

```
GET    /api/v1/characters
GET    /api/v1/characters/{character_id}
POST   /api/v1/characters/{character_id}/favorite
POST   /api/v1/characters/{character_id}/play-sample
```

### 9.5 음성 상담 API

```
POST   /api/v1/consultations/start
POST   /api/v1/consultations/{consultation_id}/end
GET    /api/v1/consultations/history
POST   /api/v1/consultations/{consultation_id}/rate
WebSocket: wss://api.healthvoiceai.com/ws/consultation
```

### 9.6 제품 추천 API

자세한 내용은 섹션 3.7 참조

```
POST   /api/v1/products/recommend
GET    /api/v1/products/{product_id}
POST   /api/v1/products/{product_id}/click
GET    /api/v1/products/categories
GET    /api/v1/products/search?q={query}
```

### 9.7 건강 루틴 API

자세한 내용은 섹션 3.4 참조

```
GET    /api/v1/routines/templates
GET    /api/v1/routines/completions?date={date}&profile_id={id}
POST   /api/v1/routines/completions
GET    /api/v1/routines/stats?profile_id={id}&period={week|month}
```

### 9.8 감사 일기 API

자세한 내용은 섹션 3.5 참조

```
POST   /api/v1/gratitude/entries
GET    /api/v1/gratitude/entries?profile_id={id}&year={year}&month={month}
PUT    /api/v1/gratitude/entries/{entry_id}
DELETE /api/v1/gratitude/entries/{entry_id}
GET    /api/v1/gratitude/stats?profile_id={id}&period={period}
```

### 9.9 웨어러블 연동 API

```
GET    /api/v1/wearable/connect-url?provider={fitbit|garmin|etc}
POST   /api/v1/wearable/disconnect
GET    /api/v1/wearable/data?profile_id={id}&from={date}&to={date}
POST   /api/v1/wearable/sync
Webhook: /api/v1/wearable/webhook (Terra API)
```

### 9.10 구독 API

```
GET    /api/v1/subscriptions/current
POST   /api/v1/subscriptions/verify
POST   /api/v1/subscriptions/cancel
GET    /api/v1/subscriptions/plans
Webhook: /api/v1/subscriptions/webhook/ios
Webhook: /api/v1/subscriptions/webhook/android
```

### 9.11 관리자 API

```
POST   /api/v1/admin/products/create
PUT    /api/v1/admin/products/{product_id}
DELETE /api/v1/admin/products/{product_id}
POST   /api/v1/admin/products/{product_id}/review
GET    /api/v1/admin/analytics/dashboard
GET    /api/v1/admin/users?page={page}&limit={limit}
```

---

## 10. 보안 및 규정 준수

### 10.1 데이터 보안

```
암호화:
├─ 전송 중: TLS 1.3 (HTTPS)
├─ 저장: AES-256 암호화
│   ├─ 비밀번호: bcrypt (salt rounds: 12)
│   ├─ 민감 정보: 필드 레벨 암호화
│   └─ 백업: 암호화된 스냅샷
└─ 키 관리: AWS KMS / Secrets Manager

접근 제어:
├─ 인증: JWT (Access + Refresh Token)
├─ 인가: Role-Based Access Control (RBAC)
├─ API 요청 제한: Rate Limiting
│   ├─ 인증된 사용자: 1000 req/hour
│   └─ 비인증 사용자: 100 req/hour
└─ IP 화이트리스트 (관리자 API)
```

### 10.2 개인정보보호법 준수

```
한국 개인정보보호법:
✅ 개인정보 수집 시 명시적 동의
✅ 수집 목적 명확히 고지
✅ 최소한의 정보만 수집
✅ 개인정보 열람/수정/삭제 권한 제공
✅ 개인정보 보유 기간 명시
✅ 개인정보 유출 시 신고 (24시간 내)
✅ 개인정보 처리방침 공개

GDPR (글로벌 확장 시):
✅ 데이터 주체의 권리 보장
✅ 데이터 이동권
✅ 잊혀질 권리
✅ 개인정보 처리방침 (Privacy Policy)
```

### 10.3 의료 규정 준수

```
의료기기법:
✅ 의료 진단/치료를 대체하지 않음 (명시)
✅ 건강 정보 제공은 "참고용"임을 고지
✅ AI 건강 조언은 의료 행위가 아님
✅ 의료기기 신고 불필요 (정보 제공 목적)

건강기능식품법:
✅ 식약처 인증 제품만 추천
✅ 과대광고 금지
✅ 질병 치료 효과 표기 금지
✅ "건강에 도움을 줄 수 있음" 표현 사용

표시광고법:
✅ 허위/과장 광고 금지
✅ 증거 자료 기반 표현
✅ 면책 조항 명시
```

### 10.4 제품 추천 안전성

```
안전성 검증 프로세스:
1. 사용자 건강 정보 확인
2. 나이, 성별 필터링
3. 만성질환 금기사항 확인
4. 약물 상호작용 체크
5. 임신/수유 여부 확인
6. 경고 메시지 표시
7. 의사 상담 권장

면책 조항:
"본 제품 추천은 일반적인 건강 정보를 바탕으로 한 것이며, 
의학적 진단이나 치료를 대체하지 않습니다. 
질병이 있거나 약물을 복용 중이라면 의사 또는 약사와 상담하세요. 
제품 구매 및 사용은 전적으로 사용자의 책임이며, 
당사는 제품의 효과나 안전성에 대해 보증하지 않습니다."
```

---

## 11. 개발 일정

### 11.1 Phase 1: MVP 개발 (16주)

```
Week 1-2: 프로젝트 설정 및 기초 작업
□ 개발 환경 설정
□ 프로젝트 구조 생성
□ 데이터베이스 스키마 설계
□ CI/CD 파이프라인 구축
□ 디자인 시스템 구축

Week 3-4: 인증 및 사용자 관리
□ 회원가입/로그인 API
□ 이메일 인증
□ 비밀번호 찾기
□ JWT 토큰 관리
□ 사용자 프로필 UI

Week 5-6: 가족 프로필 및 건강정보
□ 가족 프로필 CRUD API
□ 건강정보 수집 온보딩
□ 만성질환/약물/알레르기 관리
□ 프로필 UI/UX 구현
□ 프로필 전환 기능

Week 7-8: AI 캐릭터 시스템
□ 캐릭터 데이터베이스 구축
□ 캐릭터 선택 UI
□ OpenAI Realtime API 통합
□ 음성 샘플 재생
□ 캐릭터별 대화 스타일 설정

Week 9-10: RAG 지식베이스
□ 의료 데이터 수집 및 전처리
□ Chroma DB 설정 및 임베딩 생성
□ RAG 검색 엔진 구현
□ 제품 데이터 임베딩
□ 지식베이스 API

Week 11-12: 제품 추천 시스템
□ 제품 데이터베이스 구축
□ 제품 추천 알고리즘
□ 안전성 검증 로직
□ 제품 카드 UI
□ 제휴 쇼핑몰 연동 (쿠팡, iHerb)
□ 클릭 추적 시스템

Week 13-14: 건강 루틴 & 감사 일기
□ 루틴 템플릿 및 API
□ 루틴 완료 기록 및 통계
□ 감사 일기 CRUD
□ 루틴/일기 UI
□ 알림 설정

Week 15-16: 테스트 및 배포
□ 단위 테스트 작성
□ 통합 테스트
□ UAT (사용자 수용 테스트)
□ 성능 최적화
□ App Store / Play Store 배포
```

### 11.2 Phase 2: 고도화 (8주)

```
Week 17-18: 웨어러블 통합
□ Terra API 연동
□ Health Connect SDK 통합
□ Apple HealthKit 통합
□ 웨어러블 데이터 동기화
□ 데이터 시각화

Week 19-20: 자체 쇼핑몰
□ 장바구니 시스템
□ 주문 시스템
□ PG 결제 연동
□ 포인트/쿠폰 시스템
□ 정기 배송

Week 21-22: 의료 서비스 통합
□ 의사 연계 API
□ 원격상담 기능
□ 응급 분류 시스템
□ 비대면 진료 예약
□ 의료진 대시보드

Week 23-24: SNS 로그인 & 다국어
□ Google/Apple 소셜 로그인
□ i18n 다국어 지원 (영어, 일본어)
□ 언어별 콘텐츠 관리
□ 프로덕션 배포 및 모니터링
```

---

## 12. 예상 비용 분석

### 12.1 초기 개발 비용

```
항목                    | 비용 (만원) | 설명
------------------------|-------------|------------------
인력 비용               | 7,400       | • 개발자 3명 × 4개월
                        |             | • 디자이너 1명 × 2개월
                        |             | • PM 1명 × 4개월
                        |             | • QA 0.5명 × 2개월
의료 자문               | 1,500       | • 의사 1명 × 4개월
                        |             | • 약사/영양사 0.5명
AI 캐릭터 제작          | 800         | • 캐릭터 디자인 10개
                        |             | • 프로필 이미지 제작
                        |             | • 음성 샘플 제작
의료 지식베이스         | 600         | • 국민건강보험공단 데이터
                        |             | • 만성질환 가이드 획득
                        |             | • 데이터 정제 및 검증
제품 데이터베이스       | 500         | • 제품 정보 수집
                        |             | • 성분 데이터 입력
                        |             | • 인증서류 검증
웨어러블 통합           | 400         | • Terra API 설정
                        |             | • Health Connect 개발
                        |             | • Apple HealthKit 개발
외부 서비스 설정        | 400         | • OpenAI API 크레딧
                        |             | • 클라우드 초기 설정
디자인 에셋            | 300         | • 앱 아이콘
                        |             | • UI 컴포넌트
법률/컨설팅            | 700         | • 개인정보보호 검토
                        |             | • 의료 규정 자문
총 초기 비용           | 12,600      | (약 $95K)
```

### 12.2 월간 운영 비용 (DAU 10,000 기준)

```
항목                    | 월 비용 (만원) | 설명
------------------------|----------------|------------------
OpenAI Realtime API     | 900           | • 평균 대화 2분
                        |               | • 월 150,000회 대화
                        |               | • 10가지 음성 활용
OpenAI Embeddings       | 100           | • 제품 임베딩
                        |               | • 지식베이스 임베딩
Chroma DB               | 80            | • Self-hosted (Docker)
                        |               | • 또는 Chroma Cloud
Terra API               | 150           | • $49 (100 users)
                        |               | • 추가 사용자당 $0.5
Health Data Storage     | 150           | • PostgreSQL + S3
(PostgreSQL + S3)       |               | • 웨어러블 데이터 저장
클라우드 인프라         | 500           | • EC2/ECS: 300만원
                        |               | • RDS: 150만원
                        |               | • Load Balancer: 50만원
CDN (에셋 전송)         | 80            | • CloudFront
                        |               | • 캐릭터 이미지
                        |               | • 제품 이미지
모니터링/분석           | 100           | • Sentry
                        |               | • DataDog
                        |               | • Mixpanel
이메일/알림 서비스      | 80            | • SendGrid
                        |               | • Firebase FCM
                        |               | • 푸시 알림
결제 수수료             | 200           | • App Store: 30%
                        |               | • Play Store: 30%
                        |               | • PG 수수료: 3-4%
총 월간 비용            | 2,340         | (약 $18K)

※ 사용자 증가에 따라 비용 증가
```

### 12.3 손익분기점 분석

```
시나리오 1: DAU 10,000명, 전환율 8%

월간 매출:
┌─────────────────────┬──────┬──────┬─────────┐
│ 수익원              │ 단가 │ 건수 │ 월 매출 │
├─────────────────────┼──────┼──────┼─────────┤
│ 베이직 구독         │$9.99 │ 400  │ $3,996  │
│ 프리미엄 구독       │$14.99│ 200  │ $2,998  │
│ 패밀리 구독         │$24.99│  80  │ $1,999  │
│ 제품 커미션         │  -   │  -   │ $6,480  │
│ 광고 수익           │  -   │  -   │ $5,000  │
├─────────────────────┴──────┴──────┼─────────┤
│ 총 월간 매출                       │ $20,473 │
│ (약 2,661만원, $1=₩1,300)          │         │
└────────────────────────────────────┴─────────┘

월간 비용: 2,340만원 ($18K)
손익: +321만원 ($2.5K)

시나리오 2: 손익분기점 (월 비용 2,340만원)

필요 조건:
- DAU: 약 9,000명
- 구독 전환율: 7%
- 또는 DAU: 7,000명 + 전환율: 10%

개선 전략:
1. 제품 커미션 수익 증대 (자체 샵 오픈)
2. 프리미엄 전환율 향상 (고급 기능 강화)
3. B2B 기업 웰니스 서비스
4. 의료 기관 파트너십
```

---

## 13. 마케팅 및 성장 전략

### 13.1 론칭 전략

```
사전 마케팅 (론칭 -2개월):
├─ 랜딩 페이지 제작
├─ 사전 가입 이벤트
│   └─ 얼리버드 할인 (50% OFF)
├─ 인플루언서 협업
│   └─ 건강/웰니스 유튜버 5명
└─ 소셜 미디어 캠페인
    └─ Instagram, Facebook

베타 테스트 (론칭 -1개월):
├─ 베타 테스터 모집 (500-1,000명)
├─ 피드백 수집 및 개선
├─ 추천 이벤트
│   └─ 친구 추천 시 1개월 무료
└─ 리뷰 작성 이벤트

그랜드 오픈:
├─ 프레스 릴리스
├─ App Store 피처링 신청
├─ 론칭 이벤트
│   └─ 첫 3개월 30% 할인
└─ 무료 체험 1개월
```

### 13.2 성장 전략

```
콘텐츠 마케팅:
├─ 블로그 (건강 정보)
├─ YouTube (건강 팁, 제품 리뷰)
├─ 네이버 블로그
└─ 카카오스토리

바이럴 마케팅:
├─ 추천 프로그램
│   └─ 추천인/피추천인 모두 1개월 무료
├─ 소셜 공유 이벤트
│   └─ SNS 공유 시 포인트 적립
└─ 해시태그 챌린지
    └─ #건강주치의챌린지

파트너십:
├─ 헬스케어 브랜드 제휴
├─ 피트니스 센터 제휴
├─ 보험사 제휴
└─ 병원/의원 제휴

PR:
├─ 언론 보도 자료 배포
├─ 건강 관련 컨퍼런스 참가
├─ 의료진 인터뷰
└─ 사용자 성공 스토리
```

### 13.3 리텐션 전략

```
푸시 알림:
├─ 건강 루틴 리마인더
├─ 감사 일기 알림
├─ 개인화된 건강 팁
└─ 제품 추천 (절제적으로)

이메일 마케팅:
├─ 주간 건강 뉴스레터
├─ 맞춤형 건강 조언
├─ 신제품 안내
└─ 이벤트/프로모션

게이미피케이션:
├─ 루틴 연속 달성 배지
├─ 레벨 시스템
├─ 리더보드
└─ 챌린지 이벤트

커뮤니티:
├─ 사용자 포럼
├─ 건강 챌린지
├─ 성공 스토리 공유
└─ 전문가 Q&A
```

---

## 14. 리스크 관리

### 14.1 기술적 리스크

```
리스크 1: OpenAI API 장애
대응 방안:
- 대체 LLM 준비 (Claude, Gemini)
- API 응답 캐싱
- Fallback 메시지 시스템
- SLA 모니터링

리스크 2: 데이터베이스 과부하
대응 방안:
- Read Replica 구성
- 캐싱 레이어 (Redis)
- 쿼리 최적화
- 수평 확장 계획

리스크 3: 웨어러블 데이터 동기화 실패
대응 방안:
- 재시도 메커니즘
- 로컬 캐싱
- 사용자에게 명확한 에러 메시지
- Terra API 외 Health Connect 백업
```

### 14.2 법적 리스크

```
리스크 1: 의료기기법 위반
대응 방안:
- 명확한 면책 조항
- "정보 제공 목적"임을 강조
- 의료 진단/치료 주장 금지
- 법률 자문 정기 검토

리스크 2: 개인정보 유출
대응 방안:
- 강력한 암호화
- 정기 보안 감사
- 침해 대응 계획
- 보험 가입

리스크 3: 제품 추천 관련 소송
대응 방안:
- 상세한 면책 조항
- 의료진 검수 프로세스
- 안전성 검증 시스템
- 제조물 책임 보험
```

### 14.3 비즈니스 리스크

```
리스크 1: 낮은 전환율
대응 방안:
- A/B 테스트
- 무료 체험 확대
- 프리미엄 기능 강화
- 사용자 피드백 적극 반영

리스크 2: 높은 이탈율
대응 방안:
- 리텐션 전략 강화
- 사용자 설문조사
- 이탈 시점 분석
- Win-back 캠페인

리스크 3: 경쟁 앱 출현
대응 방안:
- 차별화된 가치 제공
- 빠른 기능 개선
- 사용자 커뮤니티 강화
- 의료진 네트워크 확대
```

---

## 15. 향후 로드맵

### 15.1 버전별 계획 (통합)

#### v6.0 (현재 - 통합본)
```
✅ 음성 대화 기본 기능
✅ 10가지 AI 캐릭터 시스템
✅ OpenAI Realtime 음성 모델 매칭
✅ Chroma DB 기반 RAG
✅ 국민건강보험공단 47개 증상 데이터
✅ 만성질환 관리 가이드
✅ 가족 프로필 관리 시스템
✅ 건강정보 수집 및 관리
✅ 건강 루틴 체크 (무료)
✅ 감사 일기 (무료)
✅ 건강기능식품 추천 시스템
✅ 제품 데이터베이스 및 RAG
✅ 관리자 제품 관리
✅ 제휴 쇼핑몰 연동 (쿠팡, iHerb)
✅ 다중 웨어러블 통합 (Terra API, Health Connect)
✅ 강화된 로그인 (자동로그인, 비밀번호 찾기)
✅ 제품 추천
✅ 구독 모델
```

#### v6.5 (3개월)
```
🔲 다국어 지원 (영어, 일본어)
🔲 SNS 로그인 (Google, Apple)
🔲 자체 쇼핑몰 (Phase 2)
   - 장바구니/주문/결제
   - 포인트/쿠폰 시스템
   - 정기 배송 관리
🔲 AI 기반 건강 위험도 예측
🔲 개인화 코칭 (웨어러블 데이터 기반)
🔲 캐릭터 커스터마이징 (프리미엄)
🔲 가족 건강 대시보드
🔲 건강 목표 설정 및 추적
```

#### v7.0 (6개월)
```
🔲 의사 연계 대시보드
🔲 건강검진 데이터 자동 분석
🔲 국민건강보험공단 데이터 연동
🔲 만성질환별 전문 관리
   - 당뇨: CGM 연동, AI 혈당 예측
   - 고혈압: 가정혈압 추적
   - 심혈관: ECG 모니터링
🔲 의사 원격상담 연결 (실시간)
🔲 사전문진 자동 작성
🔲 맞춤형 건강보험 추천
🔲 게이미피케이션 (배지, 챌린지)
🔲 커뮤니티 기능
🔲 전문가 Q&A
```

#### v7.5 (9개월)
```
🔲 대화형 AI 증상 분석
🔲 긴급도 분류 (응급/준응급/일반)
🔲 적정 진료과 추천
🔲 비대면/대면 진료 예약
🔲 복약 알림 및 부작용 모니터링
🔲 생활습관 개선 "정밀 넛지"
🔲 식단 사진 분석
🔲 운동 루틴 추천
```

#### v8.0 (12개월)
```
🔲 3D 아바타 캐릭터 (AR/VR)
🔲 다중 캐릭터 대화 (그룹 상담)
🔲 유전자 검사 연동
🔲 기업 웰니스 B2B
🔲 만성질환 관리 프로그램 (기업용)
🔲 AI 의료 어시스턴트 고도화
```

#### v9.0 (18개월)
```
🔲 글로벌 확장
🔲 보험사 직접 연동
🔲 병원 EHR 통합
🔲 예측 건강 관리 (머신러닝)
🔲 정밀 의료 (Precision Medicine)
```

---

## 16. 결론

### 16.1 통합 버전 v6.0 핵심 경쟁력

본 명세서는 **음성 AI 건강주치의 앱 v6.0 통합본**의 완전한 개발 가이드를 제공합니다.

```
1️⃣ 다양한 AI 캐릭터
   - 남녀 10명의 전문 건강주치의
   - OpenAI Realtime 10가지 음성 모델
   - 개성있는 대화 스타일

2️⃣ 가족 중심 건강관리
   - 본인 + 가족 구성원별 프로필
   - 각 구성원의 건강정보 개별 관리
   - 무료/유료 차별화

3️⃣ 신뢰할 수 있는 지식베이스
   - 국민건강보험공단 47개 증상
   - 만성질환 관리 가이드
   - Chroma DB 기반 RAG

4️⃣ 검증된 건강기능식품 추천
   - RAG 기반 매칭
   - 식약처 인증 제품
   - 안전성 검증 시스템
   - 제휴/자체 쇼핑몰

5️⃣ 무료 기본 기능
   - 건강 루틴 체크
   - 감사 일기
   - 진입장벽 제거

6️⃣ 다중 웨어러블 통합
   - Terra API (150+ 기기)
   - Health Connect
   - 객관적 데이터 기반 조언

7️⃣ 강화된 인증 및 편의성
   - 자동로그인
   - SNS 로그인 (Phase 2)
   - 비밀번호 찾기

8️⃣ 의료 서비스 통합 (Phase 2)
   - 의사 연계
   - 원격상담
   - 진료과 추천

9️⃣ 확장 가능한 아키텍처
   - 마이크로서비스 지향
   - 클라우드 네이티브
   - 성장 대비 인프라

🔟 균형잡힌 수익 모델
   - 구독 (64%)
   - 제품 커미션 (29%)
   - 광고 (7%)
```

### 16.2 주요 혁신 (통합)

```
✨ 사용자 경험:
- 다양한 전문가 캐릭터
- 가족 단위 건강 관리
- 개인별 맞춤 상담
- 검증된 제품 추천
- 무료 기본 기능

✨ 기술적 우수성:
- Chroma DB 벡터 검색
- 다중 웨어러블 통합
- 제품 안전성 검증
- RAG 기반 지식베이스
- 실시간 음성 대화

✨ 비즈니스 가치:
- 캐릭터 기반 차별화
- 제품 커미션 수익
- 가족 플랜 확대
- B2B 확장 가능성
- 의료 파트너십

✨ 의료 신뢰성:
- 공식 의료 데이터
- 식약처 인증 제품
- 의사 검증 프로토콜
- 규정 준수
```

### 16.3 다음 단계

**즉시 (1-2주)**:
1. 의료 전문가 자문단 구성
2. 국민건강보험공단 데이터 협의
3. 제품 제휴사 발굴 (쿠팡, iHerb 등)

**단기 (1개월)**:
1. 개발팀 구성 및 킥오프
2. 캐릭터 디자인 작업 시작
3. 제품 데이터베이스 구축
4. 프로토타입 개발 (4주)
   - 2개 캐릭터로 PoC
   - 가족 프로필 기본 기능
   - 제품 추천 시범 운영

**중기 (3개월)**:
1. MVP 완성 및 베타 테스트
2. 투자 유치 준비 (필요시)
3. 의료 기관/제품 제휴 계약

### 16.4 예상 성과

**3개월 후 (v6.0 출시)**:
- 🎯 DAU 1,500명
- 🎯 캐릭터 평균 평점 4.6+
- 🎯 구독 전환율 4%
- 🎯 가족 프로필 생성율 50%
- 🎯 제품 추천 클릭률 10%

**6개월 후 (v6.5 출시)**:
- 🎯 DAU 8,000명
- 🎯 구독 전환율 6%
- 🎯 제품 구매 전환율 3%
- 🎯 자체 샵 론칭
- 🎯 B2B 기업 웰니스 고객 3개

**12개월 후 (v7.0 출시)**:
- 🎯 DAU 25,000명
- 🎯 구독 전환율 8%
- 🎯 월 수익 $70K+
- 🎯 의료 기관 파트너 50개+
- 🎯 언론 보도 및 랜드마크 달성

### 16.5 마지막 메시지

본 통합 명세서(v6.0)는 **v4.0의 전체 시스템 아키텍처**와 **v5.1의 가족 프로필 및 제품 추천 시스템**을 완벽히 통합하여, 빠진 내용 없이 완전한 개발 가이드를 제공합니다.

이 프로젝트는 단순한 건강 앱을 넘어, **가족 모두의 건강을 AI로 지키고 검증된 제품으로 실천하는 스마트 건강 주치의 플랫폼**입니다.

우리의 비전은:
- 누구나 쉽게 접근할 수 있는 건강 관리
- 신뢰할 수 있는 의료 정보
- 가족 단위의 맞춤형 케어
- 검증된 제품을 통한 실천

**함께 더 건강한 미래를 만들어갑시다.** 💚

---

**문의 및 협업**:
- 프로젝트 관리: pm@healthvoiceai.com
- 기술 문의: dev@healthvoiceai.com
- 보안 문의: security@healthvoiceai.com
- 제휴 문의: partnership@healthvoiceai.com

---

**문서 버전**: v6.0 (통합본)  
**최종 업데이트**: 2025년 11월 25일  
**다음 리뷰**: 2025년 12월

**주요 통합 내용**:
- ✅ v4.0의 전체 시스템 아키텍처 포함
- ✅ v5.1의 가족 프로필 관리 시스템 통합
- ✅ v5.1의 건강정보 수집 및 관리 통합
- ✅ v5.1의 건강기능식품 추천 시스템 통합
- ✅ v5.1의 제품 데이터베이스 및 RAG 통합
- ✅ v5.1의 관리자 제품 관리 통합
- ✅ v5.1의 제휴 샵 기능 (Phase 2) 통합
- ✅ 수익 모델에 제품 커미션 추가
- ✅ 개발 일정 업데이트 (16주 → Phase 2 8주)
- ✅ 비용 분석 재계산
- ✅ 로드맵 통합 및 확대
