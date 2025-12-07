# Phase 2-5: 고급 기능 개요 가이드

## 📋 개요

이 섹션은 Claude Code 개발 프롬프트 v1.3의 **Phase 2-5: 고급 기능** 부분입니다.

**참조 문서:**
- 개발_체크리스트_v1.3.md: Phase 2-5 (Lines 488-570)
- PRD v1.3: 섹션 4.6-4.9 (고급 기능)

**중요:** Phase 2-5는 MVP(Phase 1) 이후 단계별로 구현할 고급 기능입니다. 아래 개요를 참조하여 필요 시 상세 구현을 진행하세요.

---

## Phase 2: 영양제 추천 시스템 (Day 62-70)

### 목표
사용자의 건강 데이터와 InBody 측정 결과를 기반으로 맞춤형 영양제를 추천합니다.

### 주요 기능

#### 1. InBody 데이터 분석 (Day 62-64)
```python
# core_api/models/inbody.py
class InBodyMeasurement(Base):
    """InBody 측정 데이터"""
    __tablename__ = "inbody_measurements"
    
    id = Column(String(36), primary_key=True)
    family_profile_id = Column(String(36), ForeignKey("family_profiles.id"))
    
    # 기본 측정값
    weight = Column(Float)  # 체중
    muscle_mass = Column(Float)  # 골격근량
    body_fat_mass = Column(Float)  # 체지방량
    body_fat_percentage = Column(Float)  # 체지방률
    bmi = Column(Float)  # BMI
    
    # 부위별 측정
    right_arm_muscle = Column(Float)
    left_arm_muscle = Column(Float)
    trunk_muscle = Column(Float)
    right_leg_muscle = Column(Float)
    left_leg_muscle = Column(Float)
    
    # 체성분 분석
    protein = Column(Float)  # 단백질
    minerals = Column(Float)  # 무기질
    body_water = Column(Float)  # 체수분
    
    # 평가
    visceral_fat_level = Column(Integer)  # 내장지방 레벨
    basal_metabolic_rate = Column(Integer)  # 기초대사량
    
    measured_at = Column(DateTime)
    created_at = Column(DateTime)
```

#### 2. 영양제 데이터베이스 (Day 65-67)
```python
# core_api/models/supplement.py
class Supplement(Base):
    """영양제 정보"""
    __tablename__ = "supplements"
    
    id = Column(String(36), primary_key=True)
    
    # 기본 정보
    name_ko = Column(String(200))  # 비타민D, 오메가3 등
    name_en = Column(String(200))
    category = Column(String(50))  # "vitamin", "mineral", "omega", etc.
    
    # 효능
    benefits = Column(JSON)  # ["면역력 강화", "뼈 건강"]
    recommended_for = Column(JSON)  # ["근육량 부족", "체지방 과다"]
    
    # 복용 정보
    daily_dosage = Column(String(100))  # "1일 1회, 1정"
    best_time = Column(String(50))  # "아침 식후"
    
    # 가격 정보
    average_price = Column(Integer)
    
    # 이미지
    image_url = Column(String(500))
```

#### 3. AI 추천 알고리즘 (Day 68-70)
```python
# core_api/services/supplement_recommendation_service.py
class SupplementRecommendationService:
    """영양제 추천 서비스"""
    
    @staticmethod
    def get_recommendations(
        db: Session,
        family_profile: FamilyProfile,
        inbody_data: Optional[InBodyMeasurement] = None
    ) -> List[Supplement]:
        """맞춤형 영양제 추천"""
        
        recommendations = []
        
        # 1. 나이/성별 기반 기본 추천
        if family_profile.age >= 50:
            recommendations.append("칼슘+비타민D")
        
        # 2. InBody 데이터 기반 추천
        if inbody_data:
            if inbody_data.muscle_mass < 기준값:
                recommendations.append("단백질 보충제")
            
            if inbody_data.body_fat_percentage > 기준값:
                recommendations.append("오메가3")
            
            if inbody_data.visceral_fat_level >= 10:
                recommendations.append("식이섬유")
        
        # 3. 만성질환 기반 추천
        if "고혈압" in family_profile.chronic_conditions:
            recommendations.append("마그네슘")
        
        if "당뇨" in family_profile.chronic_conditions:
            recommendations.append("크롬")
        
        # 4. 우선순위 정렬
        return sorted_recommendations
```

### API 엔드포인트
```
POST   /api/v1/inbody
GET    /api/v1/inbody/profiles/{id}/latest
GET    /api/v1/supplements
GET    /api/v1/supplements/recommendations/profiles/{id}
```

### Flutter UI
- InBody 데이터 입력 화면
- 3D 신체 시각화
- 영양제 추천 목록
- 상세 정보 및 구매 링크

---

## Phase 3: AI 건강 코칭 (Day 71-84)

### 목표
RAG(Retrieval-Augmented Generation) 기반 맞춤형 건강 조언을 제공합니다.

### 주요 기능

#### 1. Chroma DB 벡터 저장소 (Day 71-74)
```python
# core_api/services/chroma_service.py
from chromadb import Client, Settings
from chromadb.config import Settings

class ChromaService:
    """Chroma DB 벡터 저장소"""
    
    def __init__(self):
        self.client = Client(Settings(
            chroma_db_impl="duckdb+parquet",
            persist_directory="/data/chroma"
        ))
        
        self.collection = self.client.get_or_create_collection(
            name="health_knowledge",
            metadata={"hnsw:space": "cosine"}
        )
    
    def add_documents(self, documents: List[str], metadatas: List[dict]):
        """건강 지식 문서 추가"""
        self.collection.add(
            documents=documents,
            metadatas=metadatas,
            ids=[str(uuid.uuid4()) for _ in documents]
        )
    
    def search(self, query: str, n_results: int = 5) -> List[dict]:
        """유사 문서 검색"""
        results = self.collection.query(
            query_texts=[query],
            n_results=n_results
        )
        return results
```

#### 2. 건강 지식 베이스 구축 (Day 75-78)
- 국민건강보험공단 건강검진 가이드
- 질병관리청 만성질환 관리 지침
- 대한의학회 진료 가이드라인
- 식품의약품안전처 영양 정보

```python
# scripts/ingest_health_knowledge.py
def ingest_health_documents():
    """건강 지식 문서 색인"""
    
    documents = []
    metadatas = []
    
    # PDF 파싱
    for pdf_path in pdf_files:
        text = extract_text_from_pdf(pdf_path)
        chunks = split_text_into_chunks(text, chunk_size=500)
        
        for chunk in chunks:
            documents.append(chunk)
            metadatas.append({
                "source": pdf_path,
                "category": "guideline"
            })
    
    chroma_service.add_documents(documents, metadatas)
```

#### 3. RAG 기반 건강 조언 (Day 79-84)
```python
# core_api/services/health_coaching_service.py
class HealthCoachingService:
    """AI 건강 코칭"""
    
    @staticmethod
    async def get_advice(
        user_query: str,
        family_profile: FamilyProfile,
        health_data: List[HealthData]
    ) -> str:
        """맞춤형 건강 조언"""
        
        # 1. 유사 문서 검색
        relevant_docs = chroma_service.search(user_query, n_results=3)
        
        # 2. 컨텍스트 구성
        context = f"""
        사용자 정보:
        - 나이: {family_profile.age}세
        - 성별: {family_profile.gender}
        - 만성질환: {family_profile.chronic_conditions}
        
        최근 건강 데이터:
        - 혈압: {health_data.blood_pressure}
        - 혈당: {health_data.blood_sugar}
        
        관련 의학 지식:
        {relevant_docs}
        """
        
        # 3. OpenAI API 호출
        response = await openai.ChatCompletion.create(
            model="gpt-4",
            messages=[
                {"role": "system", "content": "당신은 전문 건강 코치입니다."},
                {"role": "user", "content": f"{context}\n\n질문: {user_query}"}
            ]
        )
        
        return response.choices[0].message.content
```

### API 엔드포인트
```
POST   /api/v1/coaching/ask
GET    /api/v1/coaching/recommendations/profiles/{id}
GET    /api/v1/coaching/daily-tips
```

---

## Phase 4: 커뮤니티 기능 (Day 85-98)

### 목표
사용자 간 경험 공유 및 소통 플랫폼을 구축합니다.

### 주요 기능

#### 1. 게시판 (Day 85-90)
```python
# core_api/models/community.py
class Post(Base):
    """커뮤니티 게시글"""
    __tablename__ = "posts"
    
    id = Column(String(36), primary_key=True)
    user_id = Column(String(36), ForeignKey("users.id"))
    
    category = Column(String(50))  # "건강팁", "식단", "운동", "질문"
    title = Column(String(200))
    content = Column(Text)
    
    # 통계
    view_count = Column(Integer, default=0)
    like_count = Column(Integer, default=0)
    comment_count = Column(Integer, default=0)
    
    # 이미지
    images = Column(JSON)  # ["url1", "url2"]
    
    created_at = Column(DateTime)
    updated_at = Column(DateTime)

class Comment(Base):
    """댓글"""
    __tablename__ = "comments"
    
    id = Column(String(36), primary_key=True)
    post_id = Column(String(36), ForeignKey("posts.id"))
    user_id = Column(String(36), ForeignKey("users.id"))
    
    content = Column(Text)
    like_count = Column(Integer, default=0)
    
    created_at = Column(DateTime)
```

#### 2. 챌린지 (Day 91-95)
```python
class Challenge(Base):
    """건강 챌린지"""
    __tablename__ = "challenges"
    
    id = Column(String(36), primary_key=True)
    
    title = Column(String(200))  # "30일 만보 걷기"
    description = Column(Text)
    category = Column(String(50))  # "운동", "식단", "수면"
    
    # 목표
    target_value = Column(Float)  # 10000 (만보)
    target_unit = Column(String(20))  # "steps"
    
    # 기간
    start_date = Column(DateTime)
    end_date = Column(DateTime)
    
    # 참여
    participant_count = Column(Integer, default=0)
    completion_count = Column(Integer, default=0)

class ChallengeParticipation(Base):
    """챌린지 참여"""
    __tablename__ = "challenge_participations"
    
    id = Column(String(36), primary_key=True)
    challenge_id = Column(String(36), ForeignKey("challenges.id"))
    user_id = Column(String(36), ForeignKey("users.id"))
    
    progress = Column(Float, default=0.0)  # 0.0 - 1.0
    is_completed = Column(Boolean, default=False)
    
    joined_at = Column(DateTime)
    completed_at = Column(DateTime, nullable=True)
```

#### 3. 랭킹 시스템 (Day 96-98)
- 일일 걸음수 랭킹
- 챌린지 완료 랭킹
- 주간 활동 랭킹

### API 엔드포인트
```
GET    /api/v1/community/posts
POST   /api/v1/community/posts
GET    /api/v1/community/posts/{id}
POST   /api/v1/community/posts/{id}/comments
GET    /api/v1/community/challenges
POST   /api/v1/community/challenges/{id}/join
GET    /api/v1/community/rankings/steps
```

---

## Phase 5: 다국어 지원 (Day 99-105)

### 목표
영어, 일본어, 중국어 지원으로 글로벌 시장 진출을 준비합니다.

### 주요 기능

#### 1. i18n 구조 (Day 99-101)
```dart
// lib/l10n/app_en.arb (영어)
{
  "home_title": "Voice AI Health Doctor",
  "morning_routine": "Morning Routine",
  "water_drink": "Drink Water",
  "gratitude_journal": "Gratitude Journal"
}

// lib/l10n/app_ja.arb (일본어)
{
  "home_title": "音声AI健康主治医",
  "morning_routine": "朝のルーティン",
  "water_drink": "水を飲む",
  "gratitude_journal": "感謝日記"
}

// lib/l10n/app_zh.arb (중국어)
{
  "home_title": "语音AI健康医生",
  "morning_routine": "晨间例程",
  "water_drink": "喝水",
  "gratitude_journal": "感恩日记"
}
```

#### 2. Backend 다국어 (Day 102-103)
```python
# core_api/models/translation.py
class Translation(Base):
    """다국어 번역"""
    __tablename__ = "translations"
    
    id = Column(String(36), primary_key=True)
    
    key = Column(String(100), unique=True)  # "morning_routine.water"
    ko = Column(Text)  # "물 마시기"
    en = Column(Text)  # "Drink Water"
    ja = Column(Text)  # "水を飲む"
    zh = Column(Text)  # "喝水"
```

#### 3. AI 캐릭터 다국어 (Day 104-105)
```python
# conversation_service/prompts/multilingual.py
CHARACTER_PROMPTS_EN = {
    "park_jihoon": """
    You are Dr. Park Jihoon, an internal medicine specialist with 20 years of experience.
    You specialize in chronic disease management.
    Speak warmly and professionally.
    """,
    # ... other characters
}

CHARACTER_PROMPTS_JA = {
    "park_jihoon": """
    あなたは朴智勲医師です。内科専門医として20年の経験があります。
    慢性疾患管理を専門としています。
    温かく専門的に話してください。
    """,
    # ... other characters
}
```

### 언어 전환
```dart
// Flutter
AppLocalizations.of(context)!.home_title

// 사용자 설정
shared_preferences.setString('language', 'en');  // en, ja, zh, ko
```

---

## 📝 Phase 2-5 완료 체크리스트

### Phase 2: 영양제 추천
- ✅ InBody 측정 데이터 모델
- ✅ 영양제 데이터베이스
- ✅ AI 추천 알고리즘
- ✅ Flutter UI

### Phase 3: AI 건강 코칭
- ✅ Chroma DB 벡터 저장소
- ✅ 건강 지식 베이스 색인
- ✅ RAG 기반 조언 시스템
- ✅ Flutter UI

### Phase 4: 커뮤니티
- ✅ 게시판 (게시글, 댓글, 좋아요)
- ✅ 챌린지 시스템
- ✅ 랭킹 시스템
- ✅ Flutter UI

### Phase 5: 다국어
- ✅ i18n 구조 (한/영/일/중)
- ✅ Backend 번역 테이블
- ✅ AI 캐릭터 다국어 프롬프트
- ✅ Flutter Localization

---

## 🚀 구현 우선순위

1. **Phase 2 (영양제 추천)**: InBody 연동이 핵심 차별화 요소
2. **Phase 3 (AI 코칭)**: RAG 기반 조언으로 전문성 강화
3. **Phase 4 (커뮤니티)**: 사용자 리텐션 향상
4. **Phase 5 (다국어)**: 글로벌 확장

---

## 📚 참고 자료

### 의료 가이드라인
- 국민건강보험공단: https://www.nhis.or.kr
- 질병관리청: https://www.kdca.go.kr
- 대한의학회: https://www.kams.or.kr

### 기술 문서
- Chroma DB: https://docs.trychroma.com
- OpenAI Embeddings: https://platform.openai.com/docs/guides/embeddings
- Flutter Localization: https://docs.flutter.dev/ui/accessibility-and-localization/internationalization

---

**이 문서는 Claude Code 개발 프롬프트 v1.3의 Phase 2-5 부분입니다.**  
**전체 문서: Claude_Code_개발_프롬프트_완전판_v1_3.md**

**중요:** Phase 2-5는 MVP 완성 후 순차적으로 구현할 고급 기능입니다. 각 Phase별로 상세 가이드가 필요하면 별도로 요청하세요.
