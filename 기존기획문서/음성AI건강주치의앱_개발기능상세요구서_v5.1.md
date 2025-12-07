# 음성 AI 건강주치의 앱 - 개발 기능 상세 요구서 v5.1

## 📋 버전 정보
- **버전**: v5.1 (건강기능식품 추천 & 샵 기능 통합)
- **작성일**: 2025년 11월
- **이전 버전**: v5.0 (가족 프로필 및 건강정보 관리)
- **주요 변경사항**: 
  - ✅ AI 상담 중 건강기능식품 추천 시스템
  - ✅ RAG 기반 검증된 제품 데이터베이스
  - ✅ 관리자 제품 관리 시스템
  - ✅ 제휴 쇼핑몰 기능 (2차 개발)

---

## 📑 목차

1. [프로젝트 개요 및 목표](#1-프로젝트-개요-및-목표)
2. [핵심 기능 명세](#2-핵심-기능-명세)
3. [가족 프로필 관리 시스템](#3-가족-프로필-관리-시스템)
4. [건강정보 수집 및 관리](#4-건강정보-수집-및-관리)
5. [🆕 건강기능식품 추천 시스템](#5-건강기능식품-추천-시스템)
6. [🆕 제품 데이터베이스 및 RAG](#6-제품-데이터베이스-및-rag)
7. [🆕 관리자 제품 관리](#7-관리자-제품-관리)
8. [🆕 제휴 샵 기능 (Phase 2)](#8-제휴-샵-기능-phase-2)
9. [광고 시스템](#9-광고-시스템)
10. [결제 & 구독 시스템](#10-결제--구독-시스템)
11. [백엔드 아키텍처](#11-백엔드-아키텍처)
12. [데이터베이스 설계](#12-데이터베이스-설계)
13. [보안 및 컴플라이언스](#13-보안-및-컴플라이언스)
14. [모니터링 및 KPI](#14-모니터링-및-kpi)

---

## 1. 프로젝트 개요 및 목표

### 1.1 프로젝트 비전
**"가족 모두의 건강을 AI로 지키고, 검증된 건강기능식품으로 실천하는 스마트 건강 주치의"**

### 1.2 핵심 차별화 포인트 (v5.1 업데이트)
```
1️⃣ 가족 중심 건강관리
   ✓ 본인 + 가족 구성원별 프로필
   ✓ 각 구성원의 건강정보 개별 관리
   ✓ 상담 시 대상자 선택 가능

2️⃣ 상세한 건강정보 기반 맞춤 상담
   ✓ 성별, 나이, 체형 정보
   ✓ 만성질환 및 병력 고려
   ✓ AI가 개인별 맞춤 조언 제공

3️⃣ 🆕 검증된 건강기능식품 추천
   ✓ RAG 기반 성분 분석 시스템
   ✓ 식약처 인증 제품만 추천
   ✓ 상담 중 자연스러운 제품 추천
   ✓ 원클릭 구매 링크

4️⃣ 무료/유료 차별화된 가족 관리
   ✓ 무료: 본인 + 가족 1명
   ✓ 유료: 무제한 가족 구성원

5️⃣ 음성 중심의 편리한 상담
   ✓ 150+ 웨어러블 연동
   ✓ 실시간 음성 대화
   ✓ 자연스러운 건강 상담
```

### 1.3 목표 지표 (업데이트)
```
📊 비즈니스 목표
- 월간 활성 사용자(MAU): 10만명 (12개월 내)
- 무료→유료 전환율: 8-12%
- 가족 프로필 활용률: 60% 이상
- 월간 수익: $50K → $70K 🆕
  ├─ 광고: $5K
  ├─ 구독: $45K
  └─ 🆕 제품 추천 커미션: $20K

📈 사용자 경험 목표
- 앱 평점: 4.6/5.0 이상
- 가족 건강상담 완료율: 70% 이상
- 🆕 제품 추천 클릭률: 15% 이상
- 🆕 제품 구매 전환율: 3-5%
- 사용자 재방문율: 주 4회 이상
```

---

## 2. 핵심 기능 명세

### 2.1 기능 우선순위 (MoSCoW)

#### Must Have (필수 기능 - Phase 1)
```
✅ 가족 프로필 관리
   - 본인 프로필 (필수)
   - 가족 구성원 추가/수정/삭제
   - 상담 대상 선택

✅ 건강정보 관리
   - 온보딩 시 건강정보 수집
   - 건강정보 카드 형태 저장
   - 정보 수정 및 업데이트

✅ 음성 건강상담
   - 대상자별 맞춤 상담
   - 건강정보 기반 AI 응답
   - 상담 히스토리 저장
   - 🆕 건강기능식품 추천
   - 🆕 제품 구매 링크 제공

✅ 🆕 제품 추천 시스템
   - RAG 기반 제품 매칭
   - 성분별 제품 검색
   - 외부 쇼핑몰 연동 (쿠팡, iHerb 등)

✅ 🆕 관리자 제품 관리
   - 제품 등록/수정/삭제
   - 성분 정보 관리
   - 인증서류 업로드
   - 추천 알고리즘 설정
```

#### Should Have (권장 기능 - Phase 1)
```
✅ 웨어러블 연동
   - 150+ 기기 지원
   - 건강 데이터 자동 동기화

✅ 건강 루틴 관리
   - 개인별 루틴 설정
   - 알림 및 추적

✅ 구독 관리
   - 무료/유료 플랜
   - 가족 구성원 수 제한
```

#### Could Have (선택 기능 - Phase 2)
```
✅ 🆕 통합 쇼핑몰
   - 자체 결제 시스템
   - 제휴 상품 판매
   - 포인트/쿠폰 시스템
   - 정기 배송 관리

✅ 감사 일기
✅ 건강정보 검색
✅ 주간 건강 리포트
```

---

## 5. 🆕 건강기능식품 추천 시스템

### 5.1 개요

사용자가 AI와 건강 상담 중, 특정 증상이나 건강 목표에 대해 이야기할 때 **자연스럽게** 검증된 건강기능식품을 추천합니다.

#### 핵심 원칙
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

### 5.2 추천 트리거 (언제 추천하나?)

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

### 5.3 추천 흐름

```
1️⃣ AI 상담 중 추천 의도 감지
   └─ 사용자 동의 요청
   
2️⃣ RAG 시스템 쿼리
   └─ 증상/성분 → 제품 매칭
   
3️⃣ 개인화 필터링
   └─ 나이, 성별, 만성질환 확인
   └─ 금기 성분 제외
   
4️⃣ 제품 카드 표시
   └─ 제품명, 성분, 효능
   └─ 식약처 인증 마크
   └─ 가격 및 구매 링크
   
5️⃣ 사용자 액션
   └─ 클릭 → 외부 쇼핑몰 (Phase 1)
   └─ 클릭 → 자체 샵 (Phase 2)
```

### 5.4 API 명세

#### 5.4.1 제품 추천 요청
```
POST /api/v1/products/recommend

Request:
{
  "consultation_id": "consult_99999",
  "profile_id": "profile_67890",
  "symptom": "눈 피로",
  "keywords": ["눈 건강", "루테인"],
  "health_context": {
    "age": 68,
    "gender": "female",
    "chronic_conditions": ["hypertension", "diabetes"],
    "medications": ["혈압약", "당뇨약"]
  }
}

Response:
{
  "recommendations": [
    {
      "product_id": "prod_12345",
      "name": "루테인 지아잔틴 플러스",
      "brand": "뉴트리원",
      "category": "눈 건강",
      "key_ingredients": [
        {
          "name": "루테인",
          "amount": "20mg",
          "daily_value": "100%"
        },
        {
          "name": "지아잔틴",
          "amount": "4mg",
          "daily_value": "100%"
        }
      ],
      "certifications": [
        {
          "type": "식약처 기능성 인증",
          "number": "제2023-123호",
          "date": "2023-06-15"
        }
      ],
      "benefits": [
        "눈의 피로 개선",
        "황반 색소 밀도 증가"
      ],
      "price": {
        "original": 45000,
        "discounted": 35000,
        "currency": "KRW"
      },
      "purchase_links": [
        {
          "platform": "쿠팡",
          "url": "https://coupang.com/...",
          "affiliate_code": "AF12345"
        },
        {
          "platform": "iHerb",
          "url": "https://iherb.com/...",
          "affiliate_code": "HEALTH2024"
        }
      ],
      "safety_check": {
        "safe_for_user": true,
        "warnings": [],
        "contraindications": []
      },
      "rating": 4.7,
      "review_count": 1234
    },
    // 최대 3개 추천
  ],
  "disclaimer": "본 제품 추천은 의학적 진단이나 치료를 대체하지 않습니다. 질병이 있거나 약물을 복용 중이라면 의사와 상담하세요."
}
```

#### 5.4.2 제품 상세 조회
```
GET /api/v1/products/{product_id}

Response:
{
  "product_id": "prod_12345",
  "name": "루테인 지아잔틴 플러스",
  "brand": "뉴트리원",
  "description": "미국산 마리골드 추출 루테인 20mg...",
  "detailed_ingredients": [
    {
      "name": "루테인",
      "amount": "20mg",
      "source": "마리골드 꽃 추출물",
      "function": "황반 색소 밀도 증가, 눈 건강 개선"
    }
  ],
  "usage": "1일 1회, 1캡슐을 물과 함께 섭취",
  "cautions": [
    "임산부, 수유부는 섭취 전 의사 상담",
    "알레르기 체질은 성분 확인 후 섭취"
  ],
  "certifications": [...],
  "clinical_studies": [
    {
      "title": "루테인의 눈 건강 효과",
      "journal": "Journal of Nutrition",
      "year": 2022,
      "summary": "루테인 20mg 섭취 시 황반 색소 밀도 15% 증가"
    }
  ],
  "images": [
    "https://cdn.example.com/product1.jpg",
    "https://cdn.example.com/product2.jpg"
  ],
  "videos": [
    {
      "title": "제품 소개 영상",
      "url": "https://youtube.com/..."
    }
  ]
}
```

#### 5.4.3 제품 클릭 추적
```
POST /api/v1/products/{product_id}/click

Request:
{
  "user_id": "user_12345",
  "profile_id": "profile_67890",
  "consultation_id": "consult_99999",
  "platform": "쿠팡"
}

Response:
{
  "tracked": true,
  "redirect_url": "https://coupang.com/...?af=AF12345"
}
```

### 5.5 UI/UX 설계

#### 5.5.1 상담 중 제품 추천 카드

```
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
└─────────────────────────────────────┘
```

#### 5.5.2 제품 상세 화면

```
┌─────────────────────────────────────┐
│  ← 루테인 지아잔틴 플러스            │
├─────────────────────────────────────┤
│  [제품 이미지 갤러리]                │
│  ◀ 1/3 ▶                            │
│                                     │
│  루테인 지아잔틴 플러스              │
│  뉴트리원                            │
│  ⭐ 4.7 (1,234개 리뷰)              │
│                                     │
│  ₩35,000 (22% ↓)                   │
│  정가: ₩45,000                      │
│                                     │
│  ✅ 식약처 기능성 인증               │
│  ✅ 임상 시험 완료                   │
│  ✅ GMP 인증 제조                   │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  📊 주요 성분                        │
│  • 루테인 20mg (100%)               │
│  • 지아잔틴 4mg (100%)              │
│                                     │
│  💊 복용법                           │
│  1일 1회, 1캡슐을 물과 함께          │
│                                     │
│  ⚠️ 주의사항                         │
│  • 임산부 상담 필요                  │
│  • 알레르기 체질 성분 확인           │
│                                     │
│  📚 임상 연구                        │
│  "루테인 20mg 섭취 시 황반 색소     │
│   밀도 15% 증가" (J. Nutrition 2022)│
│                                     │
│  ─────────────────────────────      │
│                                     │
│  💚 김영희(엄마)님께 적합            │
│  ✓ 나이(68세)에 맞는 용량            │
│  ✓ 고혈압, 당뇨와 상호작용 없음      │
│                                     │
│  [쿠팡에서 구매하기]                 │
│  [iHerb에서 구매하기]                │
└─────────────────────────────────────┘
```

### 5.6 개인화 안전성 검사

```python
def check_product_safety(product, profile):
    """
    사용자의 건강 상태에 따라 제품 안전성 검사
    """
    warnings = []
    contraindications = []
    safe = True
    
    # 나이 확인
    if profile.age < 18 and product.min_age >= 18:
        safe = False
        contraindications.append("18세 미만 섭취 불가")
    
    # 임산부/수유부 확인
    if profile.is_pregnant and not product.safe_for_pregnancy:
        safe = False
        contraindications.append("임산부는 의사 상담 필요")
    
    # 만성질환 확인
    for condition in profile.chronic_conditions:
        if condition in product.contraindications:
            safe = False
            contraindications.append(
                f"{condition} 환자는 섭취 주의"
            )
    
    # 약물 상호작용 확인
    for medication in profile.medications:
        if medication in product.drug_interactions:
            warnings.append(
                f"{medication}과 상호작용 가능성"
            )
    
    return {
        "safe_for_user": safe,
        "warnings": warnings,
        "contraindications": contraindications
    }
```

---

## 6. 🆕 제품 데이터베이스 및 RAG

### 6.1 제품 데이터 구조

```
제품 데이터베이스 (PostgreSQL)
├─ 제품 기본 정보
│  └─ 제품명, 브랜드, 카테고리, 가격
├─ 성분 정보
│  └─ 성분명, 함량, 기능
├─ 인증 정보
│  └─ 식약처, GMP, 임상시험
├─ 안전성 정보
│  └─ 금기 사항, 약물 상호작용
└─ 판매 정보
   └─ 구매 링크, 제휴 코드

RAG 벡터 데이터베이스 (Pinecone/Weaviate)
├─ 성분별 임베딩
├─ 증상별 임베딩
├─ 제품 설명 임베딩
└─ 임상 연구 임베딩
```

### 6.2 RAG 시스템 동작

```
사용자 질문: "눈이 피로한데 어떤 영양제가 좋을까요?"

1️⃣ 쿼리 임베딩 생성
   "눈 피로" → [0.12, 0.34, ...]

2️⃣ 벡터 유사도 검색
   유사 증상: ["눈 건조", "시력 저하", "황반변성"]
   관련 성분: ["루테인", "지아잔틴", "오메가3"]

3️⃣ 제품 매칭
   성분 포함 제품 검색
   └─ WHERE ingredients CONTAINS 'lutein'

4️⃣ 개인화 필터링
   나이, 성별, 건강 상태 고려
   └─ 금기 성분 제외

5️⃣ 랭킹 알고리즘
   ├─ 성분 매칭도 (40%)
   ├─ 안전성 점수 (30%)
   ├─ 사용자 리뷰 (20%)
   └─ 가격 경쟁력 (10%)

6️⃣ Top 3 제품 추천
```

### 6.3 제품 데이터 수집 및 검증

```
1️⃣ 수집 소스
   ✅ 식약처 건강기능식품 데이터베이스
   ✅ 제조사 공식 자료
   ✅ 임상 연구 논문 (PubMed)
   ✅ 제휴 쇼핑몰 API

2️⃣ 검증 프로세스
   ✅ 의료진 리뷰 (영양사, 약사)
   ✅ 성분 분석 (유효 성분 확인)
   ✅ 인증서 확인 (식약처, GMP)
   ✅ 안전성 평가 (부작용, 상호작용)

3️⃣ 정기 업데이트
   ✅ 월 1회 제품 정보 동기화
   ✅ 주 1회 가격 정보 업데이트
   ✅ 실시간 재고 확인 (제휴사 API)
```

---

## 7. 🆕 관리자 제품 관리

### 7.1 관리자 대시보드

```
┌─────────────────────────────────────┐
│  관리자 > 제품 관리                  │
├─────────────────────────────────────┤
│                                     │
│  📊 통계                             │
│  ┌───────────────────────────────┐  │
│  │ 총 제품: 1,234개              │  │
│  │ 활성 제품: 1,180개            │  │
│  │ 검수 대기: 54개               │  │
│  │ 오늘 클릭: 2,345회            │  │
│  │ 오늘 구매: 87건               │  │
│  │ 전환율: 3.7%                  │  │
│  └───────────────────────────────┘  │
│                                     │
│  [+ 새 제품 추가]                   │
│                                     │
│  🔍 검색: [                    ] 🔎 │
│  필터: [카테고리 ▼] [인증 ▼]        │
│                                     │
│  제품 목록                           │
│  ┌───────────────────────────────┐  │
│  │ 루테인 지아잔틴 플러스        │  │
│  │ 뉴트리원 | 눈 건강            │  │
│  │ ✅ 승인 | 클릭: 1,234 구매: 45│  │
│  │ [수정] [통계] [비활성화]      │  │
│  └───────────────────────────────┘  │
│                                     │
│  ┌───────────────────────────────┐  │
│  │ 오메가3 트리플 스트렝스       │  │
│  │ 뉴트리라이프 | 심혈관 건강    │  │
│  │ ⏳ 검수 대기 | 등록일: 1일 전 │  │
│  │ [검수하기] [수정] [삭제]      │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

### 7.2 제품 등록 화면

```
┌─────────────────────────────────────┐
│  ← 새 제품 등록                      │
├─────────────────────────────────────┤
│                                     │
│  1️⃣ 기본 정보                       │
│                                     │
│  제품명 *                            │
│  ┌──────────────────────────┐       │
│  │ 루테인 지아잔틴 플러스    │       │
│  └──────────────────────────┘       │
│                                     │
│  브랜드 *                            │
│  ┌──────────────────────────┐       │
│  │ 뉴트리원                  │       │
│  └──────────────────────────┘       │
│                                     │
│  카테고리 *                          │
│  ┌──────────────────────────┐       │
│  │ [눈 건강 ▼]               │       │
│  └──────────────────────────┘       │
│    - 눈 건강                         │
│    - 심혈관 건강                     │
│    - 뼈/관절 건강                    │
│    - 면역 건강                       │
│    - 소화 건강                       │
│    - 기타                            │
│                                     │
│  제품 설명                           │
│  ┌──────────────────────────┐       │
│  │ 미국산 마리골드 추출      │       │
│  │ 루테인 20mg, 지아잔틴...  │       │
│  └──────────────────────────┘       │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  2️⃣ 성분 정보                       │
│                                     │
│  [+ 성분 추가]                       │
│                                     │
│  성분 1                              │
│  ┌──────────────────────────┐       │
│  │ 성분명: 루테인            │       │
│  │ 함량: 20mg                │       │
│  │ 1일 권장량 대비: 100%     │       │
│  │ 원료: 마리골드 꽃 추출물  │       │
│  │ 기능: 황반 색소 밀도 증가 │       │
│  └──────────────────────────┘       │
│  [삭제]                              │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  3️⃣ 인증 정보                       │
│                                     │
│  [+ 인증 추가]                       │
│                                     │
│  인증 1: 식약처 기능성 인증          │
│  ┌──────────────────────────┐       │
│  │ 인증 번호: 제2023-123호   │       │
│  │ 인증 날짜: 2023-06-15     │       │
│  │ 유효 기간: 2026-06-14     │       │
│  │ 인증서 파일: [업로드]     │       │
│  └──────────────────────────┘       │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  4️⃣ 안전성 정보                     │
│                                     │
│  복용법                              │
│  ┌──────────────────────────┐       │
│  │ 1일 1회, 1캡슐을 물과 함께│       │
│  └──────────────────────────┘       │
│                                     │
│  최소 연령                           │
│  ┌──────────────────────────┐       │
│  │ [18] 세 이상              │       │
│  └──────────────────────────┘       │
│                                     │
│  임산부/수유부 안전                  │
│  ⚪ 안전  ⚪ 주의  ⚪ 금기             │
│                                     │
│  금기 사항 (만성질환)                │
│  □ 고혈압  □ 당뇨병  □ 신장질환     │
│  □ 간질환  □ 심혈관 질환             │
│                                     │
│  약물 상호작용                       │
│  ┌──────────────────────────┐       │
│  │ 항응고제 복용 시 주의     │       │
│  └──────────────────────────┘       │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  5️⃣ 가격 및 판매 정보               │
│                                     │
│  정가                                │
│  ┌──────────────────────────┐       │
│  │ ₩ 45,000                  │       │
│  └──────────────────────────┘       │
│                                     │
│  할인가                              │
│  ┌──────────────────────────┐       │
│  │ ₩ 35,000 (22% 할인)       │       │
│  └──────────────────────────┘       │
│                                     │
│  구매 링크                           │
│  [+ 링크 추가]                       │
│                                     │
│  플랫폼: [쿠팡 ▼]                    │
│  URL: [https://coupang.com/...]     │
│  제휴 코드: [AF12345]               │
│  [추가]                              │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  6️⃣ 이미지 및 비디오                │
│                                     │
│  제품 이미지 (최대 5개)              │
│  [업로드] [업로드] [업로드]          │
│                                     │
│  소개 영상 (선택)                    │
│  YouTube URL: [                ]     │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  7️⃣ 추천 알고리즘 설정               │
│                                     │
│  추천 키워드 (증상/건강 목표)        │
│  ┌──────────────────────────┐       │
│  │ 눈 피로, 눈 건조,         │       │
│  │ 시력 저하, 황반변성       │       │
│  └──────────────────────────┘       │
│                                     │
│  추천 우선순위                       │
│  ⚪ 높음  ⚪ 보통  ⚪ 낮음            │
│                                     │
│  ─────────────────────────────      │
│                                     │
│  [임시 저장]      [검수 요청]        │
└─────────────────────────────────────┘
```

### 7.3 제품 검수 프로세스

```
제품 등록 (관리자)
    ↓
자동 검증
    ├─ 필수 정보 누락 확인
    ├─ 성분 데이터 형식 확인
    ├─ 이미지 품질 확인
    └─ 중복 제품 확인
    ↓
의료진 검수 (영양사/약사)
    ├─ 성분 정보 정확성
    ├─ 기능성 주장 적절성
    ├─ 안전성 정보 충분성
    └─ 금기사항 명확성
    ↓
승인 or 반려
    ├─ 승인 → 활성화
    └─ 반려 → 수정 요청
    ↓
RAG 시스템 업데이트
    ├─ 제품 임베딩 생성
    ├─ 벡터 DB 저장
    └─ 검색 인덱스 갱신
```

### 7.4 API 명세

#### 7.4.1 제품 등록
```
POST /api/v1/admin/products

Request:
{
  "name": "루테인 지아잔틴 플러스",
  "brand": "뉴트리원",
  "category": "eye_health",
  "description": "미국산 마리골드 추출...",
  "ingredients": [
    {
      "name": "루테인",
      "amount": "20mg",
      "daily_value_percent": 100,
      "source": "마리골드 꽃 추출물",
      "function": "황반 색소 밀도 증가"
    }
  ],
  "certifications": [
    {
      "type": "kfda_functional",
      "number": "제2023-123호",
      "date": "2023-06-15",
      "expiry_date": "2026-06-14",
      "certificate_url": "https://..."
    }
  ],
  "safety_info": {
    "usage": "1일 1회, 1캡슐을 물과 함께",
    "min_age": 18,
    "safe_for_pregnancy": false,
    "contraindications": [],
    "drug_interactions": ["항응고제"]
  },
  "pricing": {
    "original_price": 45000,
    "discounted_price": 35000,
    "currency": "KRW"
  },
  "purchase_links": [
    {
      "platform": "coupang",
      "url": "https://coupang.com/...",
      "affiliate_code": "AF12345"
    }
  ],
  "images": [
    "https://cdn.example.com/product1.jpg"
  ],
  "recommendation_keywords": [
    "눈 피로", "눈 건조", "시력 저하"
  ],
  "recommendation_priority": "high"
}

Response:
{
  "product_id": "prod_12345",
  "status": "pending_review",
  "created_at": "2025-11-18T10:00:00Z",
  "reviewer_assigned": "dr_kim",
  "estimated_review_time": "24-48 hours"
}
```

#### 7.4.2 제품 목록 조회 (관리자)
```
GET /api/v1/admin/products?status=pending&category=eye_health

Response:
{
  "products": [
    {
      "product_id": "prod_12345",
      "name": "루테인 지아잔틴 플러스",
      "brand": "뉴트리원",
      "category": "eye_health",
      "status": "pending_review",
      "created_at": "2025-11-18T10:00:00Z",
      "clicks": 1234,
      "purchases": 45,
      "conversion_rate": 3.6
    }
  ],
  "total_count": 54,
  "page": 1,
  "per_page": 20
}
```

#### 7.4.3 제품 승인/반려
```
POST /api/v1/admin/products/{product_id}/review

Request:
{
  "action": "approve", // or "reject"
  "reviewer_id": "dr_kim",
  "notes": "모든 검증 완료. 승인합니다.",
  "required_changes": [] // reject 시 수정 사항
}

Response:
{
  "product_id": "prod_12345",
  "status": "active",
  "reviewed_by": "dr_kim",
  "reviewed_at": "2025-11-19T14:30:00Z"
}
```

---

## 8. 🆕 제휴 샵 기능 (Phase 2)

### 8.1 개요

Phase 1에서는 외부 쇼핑몰(쿠팡, iHerb) 제휴로 시작하지만, Phase 2에서는 자체 쇼핑몰 기능을 구축하여 더 나은 사용자 경험과 수익을 창출합니다.

### 8.2 핵심 기능

```
🛒 통합 쇼핑몰
   ✅ 자체 결제 시스템
   ✅ 장바구니 & 위시리스트
   ✅ 포인트 & 쿠폰
   ✅ 정기 배송
   ✅ 주문 추적
   ✅ 반품/환불

💰 수익 구조
   Phase 1 (제휴):
   - 쿠팡: 클릭당 $0.20, 구매 시 3-5% 커미션
   - iHerb: 구매 시 5-10% 커미션
   
   Phase 2 (자체 샵):
   - 제품 마진: 15-30%
   - 정기 배송 할인: 10% (안정적 수익)
   - 포인트 적립: 3% (재구매 유도)
```

### 8.3 쇼핑 플로우

```
제품 추천 (AI 상담)
    ↓
제품 상세 확인
    ↓
🆕 Phase 2: 장바구니 담기
    ├─ 수량 선택
    ├─ 정기 배송 옵션
    └─ 쿠폰 적용
    ↓
🆕 Phase 2: 결제
    ├─ 배송지 입력
    ├─ 결제 수단 선택
    │  ├─ 신용카드
    │  ├─ 계좌이체
    │  ├─ 간편결제 (카카오페이, 네이버페이)
    │  └─ 포인트 사용
    └─ 주문 확인
    ↓
🆕 Phase 2: 주문 추적
    ├─ 주문 확인
    ├─ 상품 준비 중
    ├─ 배송 중
    └─ 배송 완료
    ↓
🆕 Phase 2: 리뷰 작성
    └─ 포인트 적립
```

### 8.4 정기 배송 시스템

```
┌─────────────────────────────────────┐
│  정기 배송 설정                      │
├─────────────────────────────────────┤
│                                     │
│  루테인 지아잔틴 플러스              │
│  1개월분 (30캡슐)                   │
│                                     │
│  배송 주기                           │
│  ⚪ 1개월마다                        │
│  ⚪ 2개월마다                        │
│  ⚪ 3개월마다                        │
│                                     │
│  첫 배송일                           │
│  ┌──────────────────────────┐       │
│  │ 2025-12-01 ▼             │       │
│  └──────────────────────────┘       │
│                                     │
│  할인                                │
│  • 정기 배송 10% 할인                │
│  • 포인트 3% 적립                    │
│                                     │
│  총 금액                             │
│  ₩31,500 (10% 할인)                 │
│  + 포인트 945원 적립                 │
│                                     │
│  ℹ️ 언제든 변경/취소 가능            │
│                                     │
│  [정기 배송 신청하기]                │
└─────────────────────────────────────┘
```

### 8.5 포인트 & 쿠폰 시스템

```
포인트 적립
├─ 제품 구매: 3%
├─ 리뷰 작성: 500원
├─ 정기 배송 첫 구매: 2,000원
└─ 친구 추천: 5,000원 (친구도 3,000원)

포인트 사용
└─ 1포인트 = 1원 (최대 30% 사용)

쿠폰 종류
├─ 신규 가입: 5,000원 (30,000원 이상 구매 시)
├─ 생일 쿠폰: 10,000원
├─ 정기 배송 쿠폰: 15% 할인
└─ 이벤트 쿠폰: 다양
```

### 8.6 데이터베이스 설계 (Phase 2 추가)

```sql
-- 장바구니
CREATE TABLE cart_items (
  cart_item_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  product_id VARCHAR(50) NOT NULL,
  quantity INT DEFAULT 1,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- 주문
CREATE TABLE orders (
  order_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  total_amount DECIMAL(10,2),
  discount_amount DECIMAL(10,2),
  point_used DECIMAL(10,2),
  final_amount DECIMAL(10,2),
  status VARCHAR(20), -- pending, paid, shipped, delivered, cancelled
  shipping_address TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);

-- 주문 상품
CREATE TABLE order_items (
  order_item_id VARCHAR(50) PRIMARY KEY,
  order_id VARCHAR(50) NOT NULL,
  product_id VARCHAR(50) NOT NULL,
  quantity INT,
  unit_price DECIMAL(10,2),
  subtotal DECIMAL(10,2)
);

-- 정기 배송
CREATE TABLE subscriptions (
  subscription_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  product_id VARCHAR(50) NOT NULL,
  quantity INT,
  frequency VARCHAR(20), -- monthly, bi_monthly, quarterly
  next_delivery_date DATE,
  status VARCHAR(20), -- active, paused, cancelled
  created_at TIMESTAMP
);

-- 포인트
CREATE TABLE points (
  point_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  amount DECIMAL(10,2),
  type VARCHAR(20), -- earned, used, expired
  reason VARCHAR(100),
  expiry_date DATE,
  created_at TIMESTAMP
);

-- 쿠폰
CREATE TABLE coupons (
  coupon_id VARCHAR(50) PRIMARY KEY,
  code VARCHAR(20) UNIQUE,
  discount_type VARCHAR(10), -- percentage, fixed
  discount_value DECIMAL(10,2),
  min_purchase_amount DECIMAL(10,2),
  max_discount_amount DECIMAL(10,2),
  valid_from DATE,
  valid_until DATE,
  usage_limit INT,
  used_count INT DEFAULT 0
);

-- 사용자 쿠폰
CREATE TABLE user_coupons (
  user_coupon_id VARCHAR(50) PRIMARY KEY,
  user_id VARCHAR(50) NOT NULL,
  coupon_id VARCHAR(50) NOT NULL,
  status VARCHAR(20), -- available, used, expired
  issued_at TIMESTAMP,
  used_at TIMESTAMP
);
```

---

## 9. 광고 시스템

[v5.0 내용 유지, 제품 추천과 구분하여 광고는 별도 표시]

---

## 10. 결제 & 구독 시스템

### 10.1 구독 플랜 (업데이트)

```
┌──────────────────────────────────────────────────┐
│  🆓 Free Plan                                     │
├──────────────────────────────────────────────────┤
│  가격: $0/월                                      │
│                                                  │
│  기능:                                            │
│  ✅ 본인 프로필 1개                               │
│  ✅ 가족 프로필 1개                               │
│  ✅ 하루 5회 음성 상담                            │
│  ✅ 🆕 제품 추천 (기본)                           │
│  ✅ 건강 루틴 & 감사 일기                         │
│  ✅ 웨어러블 연동                                  │
│  ⚠️  광고 표시 (하루 3-5회)                       │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  💎 Premium Plan                                  │
├──────────────────────────────────────────────────┤
│  가격: $9.99/월 (7일 무료 체험)                   │
│                                                  │
│  기능:                                            │
│  ✅ 본인 프로필 1개                               │
│  ✅ 가족 프로필 4개 (총 5개)                      │
│  ✅ 무제한 음성 상담                              │
│  ✅ 🆕 맞춤형 제품 추천 (AI 분석)                 │
│  ✅ 🆕 제품 구매 시 추가 포인트 적립              │
│  ✅ 광고 없음                                     │
│  ✅ 상세 건강 분석                                │
│  ✅ 주간 건강 리포트                              │
└──────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────┐
│  👑 Platinum Plan                                 │
├──────────────────────────────────────────────────┤
│  가격: $19.99/월 (7일 무료 체험)                  │
│                                                  │
│  기능:                                            │
│  ✅ Premium 모든 기능                             │
│  ✅ 가족 프로필 무제한                            │
│  ✅ 가족 통합 건강 리포트                         │
│  ✅ 🆕 제품 구매 시 VIP 할인 (추가 5%)            │
│  ✅ 🆕 정기 배송 무료 배송                        │
│  ✅ 우선 고객 지원                                │
│  ✅ AI 캐릭터 무제한 변경                         │
│  ✅ VIP 배지                                      │
└──────────────────────────────────────────────────┘
```

---

## 11. 백엔드 아키텍처

### 11.1 마이크로서비스 구성 (업데이트)

```
┌─────────────────────────────────────────────┐
│  1️⃣ User Service                            │
│     - 사용자 인증 & 관리                     │
│     - 프로필 관리                            │
│     - 가족 구성원 관리                       │
├─────────────────────────────────────────────┤
│  2️⃣ Health Info Service                     │
│     - 건강정보 저장 & 조회                   │
│     - BMI 자동 계산                          │
│     - 만성질환 관리                          │
│     - 병력 관리                              │
├─────────────────────────────────────────────┤
│  3️⃣ Consultation Service                    │
│     - 음성 상담 처리                         │
│     - 대상자별 맞춤 상담                     │
│     - AI 컨텍스트 구성                       │
│     - 🆕 제품 추천 트리거                    │
│     - 상담 히스토리 저장                     │
├─────────────────────────────────────────────┤
│  4️⃣ 🆕 Product Service                      │
│     - 제품 정보 관리                         │
│     - RAG 기반 제품 검색                     │
│     - 개인화 필터링                          │
│     - 안전성 검사                            │
│     - 클릭/구매 추적                         │
├─────────────────────────────────────────────┤
│  5️⃣ 🆕 Shop Service (Phase 2)               │
│     - 장바구니 관리                          │
│     - 주문 처리                              │
│     - 정기 배송 관리                         │
│     - 포인트 & 쿠폰                          │
│     - 결제 연동                              │
├─────────────────────────────────────────────┤
│  6️⃣ Wearable Service                        │
│     - 웨어러블 데이터 동기화                 │
│     - 프로필별 데이터 관리                   │
├─────────────────────────────────────────────┤
│  7️⃣ Subscription Service                    │
│     - 구독 관리                              │
│     - 프로필 수 제한 확인                    │
│     - RevenueCat 연동                        │
├─────────────────────────────────────────────┤
│  8️⃣ Ad Service                              │
│     - 광고 노출 & 추적                       │
│     - 무료/유료 차별화                       │
└─────────────────────────────────────────────┘
```

### 11.2 주요 API 엔드포인트 (업데이트)

```
프로필 관리 (기존)
POST   /api/v1/profiles
GET    /api/v1/profiles
GET    /api/v1/profiles/{id}
PUT    /api/v1/profiles/{id}
DELETE /api/v1/profiles/{id}

건강정보 관리 (기존)
POST   /api/v1/profiles/{id}/health-info
GET    /api/v1/profiles/{id}/health-info
PUT    /api/v1/profiles/{id}/health-info

상담 관리 (기존)
POST   /api/v1/consultations/start
POST   /api/v1/consultations/{id}/message
GET    /api/v1/consultations/history

🆕 제품 관리
POST   /api/v1/products/recommend          # 제품 추천
GET    /api/v1/products/{id}                # 제품 상세
POST   /api/v1/products/{id}/click          # 클릭 추적
GET    /api/v1/products/search              # 제품 검색

🆕 관리자 제품 관리
POST   /api/v1/admin/products               # 제품 등록
GET    /api/v1/admin/products               # 제품 목록
PUT    /api/v1/admin/products/{id}          # 제품 수정
DELETE /api/v1/admin/products/{id}          # 제품 삭제
POST   /api/v1/admin/products/{id}/review   # 제품 검수

🆕 쇼핑 (Phase 2)
POST   /api/v1/shop/cart                    # 장바구니 추가
GET    /api/v1/shop/cart                    # 장바구니 조회
POST   /api/v1/shop/orders                  # 주문 생성
GET    /api/v1/shop/orders/{id}             # 주문 조회
POST   /api/v1/shop/subscriptions           # 정기 배송 신청
GET    /api/v1/shop/points                  # 포인트 조회
POST   /api/v1/shop/coupons/apply           # 쿠폰 적용
```

---

## 12. 데이터베이스 설계

### 12.1 전체 ERD (업데이트)

```
┌──────────────┐
│    users     │
└──────┬───────┘
       │ 1
       ├────────────────────────┐
       │ N                      │ N
┌──────▼───────┐       ┌────────▼────────┐
│   profiles   │       │  🆕 products    │
│              │ 1     │                 │
└──────┬───────┘       └────────┬────────┘
       │ 1                      │ N
       │                        │
       │ N                      │
┌──────▼─────────┐    ┌─────────▼──────────────┐
│ health_info    │    │ 🆕 product_ingredients │
│                │    │ 🆕 product_certs       │
└────────┬───────┘    │ 🆕 product_links       │
         │ 1          │ 🆕 product_clicks      │
         │            └────────────────────────┘
         │ N
┌────────▼─────────────────┐
│ chronic_conditions       │
│ medical_history          │
│ consultations            │
└──────────────────────────┘

🆕 Phase 2 추가:
┌──────────────┐
│ cart_items   │
│ orders       │
│ order_items  │
│ subscriptions│
│ points       │
│ coupons      │
│ user_coupons │
└──────────────┘
```

### 12.2 제품 관련 테이블 (신규)

```sql
-- 제품 기본 정보
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
  status VARCHAR(20) DEFAULT 'pending', -- pending, active, inactive
  rating DECIMAL(3,2) DEFAULT 0,
  review_count INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  created_by VARCHAR(50), -- admin user_id
  reviewed_by VARCHAR(50), -- reviewer user_id
  reviewed_at TIMESTAMP,
  
  CONSTRAINT valid_status CHECK (
    status IN ('pending', 'active', 'inactive', 'rejected')
  )
);

-- 제품 성분
CREATE TABLE product_ingredients (
  ingredient_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  name VARCHAR(100) NOT NULL,
  amount VARCHAR(50),
  daily_value_percent INT,
  source TEXT,
  function TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 인증
CREATE TABLE product_certifications (
  cert_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  type VARCHAR(50) NOT NULL, -- kfda_functional, gmp, clinical, etc
  cert_number VARCHAR(100),
  cert_date DATE,
  expiry_date DATE,
  certificate_url TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 구매 링크
CREATE TABLE product_purchase_links (
  link_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  platform VARCHAR(50) NOT NULL, -- coupang, iherb, own_shop
  url TEXT NOT NULL,
  affiliate_code VARCHAR(100),
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 이미지
CREATE TABLE product_images (
  image_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  image_url TEXT NOT NULL,
  image_order INT DEFAULT 0,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 금기 사항
CREATE TABLE product_contraindications (
  contraindication_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  condition_code VARCHAR(50) NOT NULL, -- hypertension, diabetes, etc
  severity VARCHAR(20) DEFAULT 'warning', -- warning, caution, contraindicated
  notes TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 약물 상호작용
CREATE TABLE product_drug_interactions (
  interaction_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  drug_name VARCHAR(100) NOT NULL,
  interaction_type VARCHAR(20), -- major, moderate, minor
  description TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 제품 클릭 추적
CREATE TABLE product_clicks (
  click_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id),
  user_id VARCHAR(50) REFERENCES users(user_id),
  profile_id VARCHAR(50) REFERENCES profiles(profile_id),
  consultation_id VARCHAR(50),
  platform VARCHAR(50), -- coupang, iherb
  clicked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_product_clicks_product (product_id),
  INDEX idx_product_clicks_user (user_id),
  INDEX idx_product_clicks_date (clicked_at)
);

-- 제품 구매 추적 (제휴사로부터 webhook 수신)
CREATE TABLE product_purchases (
  purchase_id VARCHAR(50) PRIMARY KEY,
  click_id VARCHAR(50) REFERENCES product_clicks(click_id),
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id),
  user_id VARCHAR(50) REFERENCES users(user_id),
  platform VARCHAR(50),
  order_amount DECIMAL(10,2),
  commission_amount DECIMAL(10,2),
  commission_rate DECIMAL(5,2),
  purchased_at TIMESTAMP,
  confirmed_at TIMESTAMP,
  
  INDEX idx_product_purchases_product (product_id),
  INDEX idx_product_purchases_user (user_id)
);

-- RAG 추천 키워드
CREATE TABLE product_recommendation_keywords (
  keyword_id VARCHAR(50) PRIMARY KEY,
  product_id VARCHAR(50) NOT NULL REFERENCES products(product_id) ON DELETE CASCADE,
  keyword VARCHAR(100) NOT NULL,
  keyword_type VARCHAR(20), -- symptom, health_goal, ingredient
  priority INT DEFAULT 0, -- 높을수록 우선순위 높음
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  
  INDEX idx_keywords_product (product_id),
  INDEX idx_keywords_keyword (keyword)
);

-- 인덱스
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_products_status ON products(status);
CREATE INDEX idx_products_brand ON products(brand);
CREATE INDEX idx_product_ingredients_name ON product_ingredients(name);
```

---

## 13. 보안 및 컴플라이언스

### 13.1 제품 데이터 보안

```
🔒 데이터 무결성
   - 관리자만 제품 등록/수정
   - 검수 완료 제품만 노출
   - 가격 정보 암호화 (제휴 코드)

🛡️ 사용자 안전
   - 금기 사항 자동 체크
   - 약물 상호작용 경고
   - 임산부/수유부 필터링

📋 컴플라이언스
   - 식약처 가이드라인 준수
   - 건강기능식품법 준수
   - 표시광고법 준수
   - 의료기기법 준수 (해당 시)
```

### 13.2 제품 추천 면책 조항

```
제품 추천 시 항상 표시:

"본 제품 추천은 일반적인 건강 정보를 바탕으로 한 것이며, 
의학적 진단이나 치료를 대체하지 않습니다. 

질병이 있거나 약물을 복용 중이라면 의사 또는 약사와 상담하세요. 

제품 구매 및 사용은 전적으로 사용자의 책임이며, 
당사는 제품의 효과나 안전성에 대해 보증하지 않습니다."
```

---

## 14. 모니터링 및 KPI

### 14.1 비즈니스 KPI (업데이트)

```
📊 사용자 지표
- MAU (월간 활성 사용자): 100K
- DAU/MAU 비율: 40% 이상
- 가족 프로필 생성률: 60%
- 🆕 제품 추천 클릭률(CTR): 15% 이상
- 🆕 제품 구매 전환율(CVR): 3-5%

💰 수익 지표
- 무료→유료 전환율: 8-12%
- ARPU (사용자당 평균 수익): $2.5 → $3.5
- 🆕 제품 커미션 수익: $20K/월
  ├─ 평균 클릭: 30K/월
  ├─ 평균 구매: 900건/월
  └─ 평균 커미션: $22/건
- Churn Rate (이탈율): 5% 이하

🎯 참여 지표
- 건강정보 완성도: 90% 이상
- 상담 완료율: 85% 이상
- 🆕 제품 추천 만족도: 4.2/5.0 이상
- 🆕 제품 재구매율: 30% 이상
```

### 14.2 제품 관련 KPI

```
📊 제품 데이터베이스
- 총 제품 수: 1,500개 (12개월 목표)
- 카테고리별 균형: 각 10% 이상
- 식약처 인증률: 100%
- 제품 정보 완성도: 95% 이상

🔍 추천 시스템
- 추천 정확도: 80% 이상
  (사용자가 클릭/구매한 제품이 실제 필요에 맞음)
- 추천 응답 시간: < 500ms
- RAG 검색 정확도: 85% 이상

🛒 전환 깔때기 (Phase 2)
- 제품 추천 노출: 100%
- 제품 카드 클릭: 15%
- 상세 페이지 조회: 10%
- 장바구니 추가: 5%
- 구매 완료: 3%
```

---

## 15. 개발 일정

### 15.1 Phase 1: 제품 추천 시스템 (4주)

```
Week 1: 제품 데이터베이스
  □ 제품 테이블 설계 (9개)
  □ 제품 API 개발 (4개)
  □ 관리자 제품 등록 UI
  □ 제품 검수 프로세스

Week 2: RAG 시스템
  □ 제품 임베딩 생성
  □ 벡터 DB 구축 (Pinecone/Weaviate)
  □ 유사도 검색 알고리즘
  □ 개인화 필터링

Week 3: 추천 시스템 통합
  □ AI 상담 중 추천 트리거
  □ 제품 카드 UI
  □ 제품 상세 화면
  □ 구매 링크 연동 (쿠팡, iHerb)

Week 4: 테스트 & 최적화
  □ 추천 정확도 테스트
  □ 안전성 검사 테스트
  □ 클릭 추적 구현
  □ 커미션 정산 시스템
```

### 15.2 Phase 2: 자체 샵 기능 (8주)

```
Week 5-6: 쇼핑 기본 기능
  □ 장바구니 API & UI
  □ 주문 시스템
  □ 결제 연동 (PG사)
  □ 주문 추적

Week 7-8: 포인트 & 쿠폰
  □ 포인트 시스템
  □ 쿠폰 시스템
  □ 적립/사용 UI
  □ 정기 배송

Week 9-10: 고급 기능
  □ 위시리스트
  □ 리뷰 시스템
  □ 정기 배송 관리
  □ 반품/환불

Week 11-12: 테스트 & 배포
  □ 통합 테스트
  □ 결제 시나리오 테스트
  □ 베타 테스트 (100명)
  □ Production 배포
```

---

## 16. 부록

### 16.1 제품 카테고리 분류

```
| 카테고리 코드 | 한글명 | 주요 성분 예시 |
|--------------|--------|----------------|
| eye_health | 눈 건강 | 루테인, 지아잔틴, 오메가3 |
| cardiovascular | 심혈관 건강 | 오메가3, 코엔자임Q10 |
| bone_joint | 뼈/관절 건강 | 칼슘, 비타민D, 글루코사민 |
| immune | 면역 건강 | 비타민C, 아연, 프로폴리스 |
| digestive | 소화 건강 | 프로바이오틱스, 소화효소 |
| brain | 두뇌 건강 | DHA, 은행잎추출물 |
| energy | 에너지/피로 | 비타민B군, 마그네슘 |
| beauty | 피부/미용 | 콜라겐, 히알루론산 |
| weight | 체중 관리 | 가르시니아, 공액리놀레산 |
| womens | 여성 건강 | 엽산, 철분, 석류추출물 |
| mens | 남성 건강 | 쏘팔메토, 마카 |
| senior | 노인 건강 | 종합비타민, 칼슘, 오메가3 |
```

### 16.2 성분별 효능 매핑

```
| 성분명 | 주요 효능 | 권장 대상 |
|--------|----------|----------|
| 루테인 | 황반 색소 밀도 증가, 눈 건강 | 화면 작업자, 중장년층 |
| 오메가3 | 혈행 개선, 두뇌 건강 | 심혈관 질환 위험군 |
| 비타민D | 뼈 건강, 면역 증진 | 실내 근무자, 노년층 |
| 프로바이오틱스 | 장 건강, 면역 조절 | 소화 불량, 항생제 복용자 |
| 코엔자임Q10 | 세포 에너지 생성, 항산화 | 피로, 심혈관 건강 |
| 글루코사민 | 연골 건강 | 관절염, 중장년층 |
| 콜라겐 | 피부 탄력, 관절 건강 | 피부 노화, 여성 |
```

### 16.3 FAQ

```
Q1: 제품 추천은 어떻게 작동하나요?
A: AI가 상담 중 사용자의 증상이나 건강 목표를 파악하면, 
   RAG 시스템을 통해 검증된 제품을 추천합니다. 
   사용자의 나이, 성별, 만성질환을 고려하여 안전한 제품만 추천합니다.

Q2: 추천되는 제품은 안전한가요?
A: 네, 모든 제품은:
   - 식약처 기능성 인증 제품
   - 의료진(영양사, 약사) 검수 완료
   - 성분 정보 투명 공개
   - 금기 사항 자동 확인
   
Q3: 제품을 꼭 구매해야 하나요?
A: 아니요, 제품 추천은 선택사항입니다. 
   AI 상담만 받으셔도 충분하며, 제품 구매는 전적으로 사용자의 선택입니다.

Q4: Phase 1과 Phase 2의 차이는?
A: Phase 1: 외부 쇼핑몰(쿠팡, iHerb) 링크 제공
   Phase 2: 자체 쇼핑몰 구축 (장바구니, 결제, 정기 배송 등)

Q5: 커미션은 어떻게 발생하나요?
A: Phase 1: 제휴 쇼핑몰에서 구매 시 3-10% 커미션
   Phase 2: 자체 판매 마진 15-30%

Q6: 제품 가격은 합리적인가요?
A: 제휴 쇼핑몰(쿠팡 등)의 정상 가격과 동일하며,
   자체 샵에서는 정기 배송 할인(10%)과 포인트 적립(3%)을 제공합니다.
```

---

## 📞 문의

- **프로젝트 관리**: pm@health-voice-ai.com
- **기술 문의**: dev@health-voice-ai.com
- **보안 문의**: security@health-voice-ai.com
- **제휴 문의**: partnership@health-voice-ai.com

---

**문서 버전**: v5.1  
**최종 업데이트**: 2025년 11월 18일  
**다음 리뷰**: 2025년 12월
