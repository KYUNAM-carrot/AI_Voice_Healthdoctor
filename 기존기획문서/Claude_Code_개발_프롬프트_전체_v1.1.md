# 🎯 음성 AI 건강주치의 앱 - Claude Code 개발 가이드 (전체)

**버전:** 1.1  
**작성일:** 2025년 12월 5일  
**대상:** Claude Code를 사용하는 개발자  
**참조 문서:** 
- PRD v1.2
- TRD v1.2
- AI캐릭터 가이드 v1.1
- 개발 체크리스트 v1.2
- **UI/UX 디자인 가이드 v1.1** (신규)


---

## 📚 목차

1. [시작 전 필수 작업](#1-시작-전-필수-작업)
2. [Phase 1: MVP 개발 (8주, 56일)](#2-phase-1-mvp-개발-8주-56일)
   - Week 1: 인프라 설정 및 인증 (Day 1-8)
   - Week 2: 사용자 & 가족 관리 (Day 9-16)
   - Week 3-4: 음성 상담 시스템 (Day 17-25)
   - Week 4-5: 웨어러블 & 건강 데이터 (Day 26-34)
   - Week 6-7: 구독 & UI (Day 35-52) 
   - Week 8: 배포 준비 (Day 53-56)
3. [Phase 1.5: 아침 루틴 기능 (1주)](#3-phase-15-아침-루틴-기능-1주)
4. [Phase 2: 베타 테스트 (2주)](#4-phase-2-베타-테스트-2주)
5. [Phase 3: 정식 출시](#5-phase-3-정식-출시)
6. [Phase 4: 고도화 (6주)](#6-phase-4-고도화-6주)
7. [Phase 5: 확장 (6주)](#7-phase-5-확장-6주)
8. [부록: 유용한 프롬프트 템플릿](#8-부록-유용한-프롬프트-템플릿)

---

## 1. 시작 전 필수 작업

### 🎬 프로젝트 초기화 프롬프트

```markdown
# 프로젝트 시작 - 문서 로딩

안녕! 음성 AI 건강주치의 앱을 개발할 거야.

## 필수 문서 읽기
다음 5개 문서를 먼저 읽고 완전히 이해해줘:

1. /mnt/user-data/outputs/음성AI건강주치의앱_PRD_v1.2.md
2. /mnt/user-data/outputs/음성AI건강주치의앱_TRD_v1.2.md
3. /mnt/user-data/outputs/AI캐릭터_시스템프롬프트_가이드_v1.1.md
4. /mnt/user-data/outputs/개발_체크리스트_v1.2.md
5. /mnt/user-data/outputs/음성AI건강주치의앱_UI_UX_디자인_가이드_v1.1.md 

## 프로젝트 개요
- **목표:** 20-50대를 위한 가족 중심 음성 AI 건강 관리 앱
- **아키텍처:** 통합 마이크로서비스 (Core API + Conversation Service)
- **배포:** Fly.io (홍콩 리전)
- **기간:** 8주 MVP + 1주 루틴 + 2주 베타 테스트
- **출시:** 2026년 2월 12일

## 기술 스택
- Backend: Python 3.11, FastAPI, SQLAlchemy
- Database: PostgreSQL 15, Redis 7, Chroma DB
- AI: OpenAI Realtime API (gpt-realtime-2025-08-28)
- Frontend: Flutter 3.24+
- Deployment: Fly.io (홍콩), Cloudflare R2

## 디자인 원칙 (UI/UX v1.1)
1. **정보 밀도:** 한 화면에 더 많은 정보 (v1.0 대비 2배)
2. **전문성:** 클린한 디자인, 명확한 데이터 시각화
3. **효율성:** 빠른 작업 완료, 최소 탭
4. **모던함:** 2025년 최신 디자인 트렌드
5. **접근성:** WCAG 2.1 AA 준수 (터치 44px, 대비 4.5:1)

## 개발 원칙
1. TRD 스펙을 100% 정확히 따를 것
2. 각 Day별 체크리스트를 순서대로 완료할 것
3. 테스트 우선 개발 (TDD)
4. 코드 작성 후 반드시 로컬 테스트
5. 각 Day 완료 시 보고서 작성

문서를 모두 읽었으면 다음을 답변해줘:
1. "문서 이해 완료"
2. 프로젝트의 핵심 목표 3가지 요약
3. 통합 마이크로서비스 구조 (2개 서비스) 설명
4. UI/UX 디자인 철학 (정보 밀도, 전문성, 효율성, 모던함)
5. 준비 완료 선언: "Day 1부터 시작할 준비가 됐습니다!"
```

---

## 2. Phase 1: MVP 개발 (8주, 56일)

### 🔹 Week 1: 인프라 설정 및 인증 (Day 1-8)

#### Day 1-2: 프로젝트 초기 설정

```markdown
# Day 1-2: 프로젝트 초기 설정

## 목표
백엔드 프로젝트 구조를 생성하고 로컬 개발 환경을 구축합니다.

## 참조
- 개발_체크리스트_v1.2.md: Day 1-2
- TRD v1.2: 섹션 2.3 (Core API 내부 구조)
- TRD v1.2: 섹션 10.1 (개발 환경)

## 작업 위치
/home/claude/healthai-backend

## 요구사항

### 1. 프로젝트 구조 생성
다음 구조를 정확히 생성해줘:

```
healthai-backend/
├── core_api/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── database.py
│   ├── dependencies.py
│   ├── routers/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── users.py
│   │   ├── families.py
│   │   ├── routines.py
│   │   ├── subscriptions.py
│   │   ├── characters.py
│   │   └── wearables.py
│   ├── models/
│   │   ├── __init__.py
│   │   ├── user.py
│   │   ├── family.py
│   │   ├── conversation.py
│   │   ├── routine.py
│   │   └── subscription.py
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── auth.py
│   │   ├── user.py
│   │   ├── family.py
│   │   ├── routine.py
│   │   └── subscription.py
│   └── services/
│       ├── __init__.py
│       ├── auth_service.py
│       ├── user_service.py
│       ├── family_service.py
│       ├── routine_service.py
│       └── wearable_service.py
├── conversation_service/
│   ├── __init__.py
│   ├── main.py
│   ├── config.py
│   ├── realtime.py
│   ├── websocket.py
│   ├── rag.py
│   └── characters.py
├── alembic/
│   ├── env.py
│   ├── script.py.mako
│   └── versions/
├── tests/
│   ├── __init__.py
│   ├── conftest.py
│   ├── test_auth.py
│   ├── test_users.py
│   ├── test_families.py
│   └── test_routines.py
├── scripts/
│   ├── __init__.py
│   └── seed_data.py
├── requirements.txt
├── Dockerfile.core
├── Dockerfile.conversation
├── docker-compose.yml
├── fly.core.toml
├── fly.conversation.toml
├── alembic.ini
├── .env.example
├── .gitignore
├── pytest.ini
└── README.md
```

### 2. requirements.txt 작성
TRD v1.2 섹션 3.2의 백엔드 스택 참조:

```
# FastAPI & Server
fastapi==0.115.0
uvicorn[standard]==0.30.0
python-multipart==0.0.9

# Database
sqlalchemy==2.0.31
alembic==1.14.0
psycopg2-binary==2.9.9

# Redis & Caching
redis==5.0.7

# Data Validation
pydantic==2.9.0
pydantic-settings==2.4.0

# Authentication & Security
python-jose[cryptography]==3.3.0
passlib[bcrypt]==1.7.4
cryptography==42.0.8

# HTTP Client
aiohttp==3.10.0
httpx==0.27.0

# OpenAI & AI
openai==1.54.0
chromadb==0.5.3
tiktoken==0.7.0

# Testing
pytest==8.3.0
pytest-asyncio==0.24.0
pytest-cov==5.0.0

# Utilities
python-dotenv==1.0.1
```

### 3. docker-compose.yml
TRD v1.2 섹션 10.1 참조:

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
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U healthai"]
      interval: 5s
      timeout: 5s
      retries: 5
  
  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"
    healthcheck:
      test: ["CMD", "redis-cli", "ping"]
      interval: 5s
      timeout: 3s
      retries: 5
  
  core_api:
    build:
      context: .
      dockerfile: Dockerfile.core
    ports:
      - "8000:8000"
    environment:
      DATABASE_URL: postgresql://healthai:password@postgres:5432/healthai_db
      REDIS_URL: redis://redis:6379
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      ENVIRONMENT: development
      LOG_LEVEL: debug
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./core_api:/app/core_api
      - ./alembic:/app/alembic
      - ./scripts:/app/scripts
    command: uvicorn core_api.main:app --host 0.0.0.0 --port 8000 --reload
  
  conversation:
    build:
      context: .
      dockerfile: Dockerfile.conversation
    ports:
      - "8004:8004"
    environment:
      DATABASE_URL: postgresql://healthai:password@postgres:5432/healthai_db
      REDIS_URL: redis://redis:6379
      OPENAI_API_KEY: ${OPENAI_API_KEY}
      ENVIRONMENT: development
      LOG_LEVEL: debug
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    volumes:
      - ./conversation_service:/app/conversation_service
    command: uvicorn conversation_service.main:app --host 0.0.0.0 --port 8004 --reload

volumes:
  postgres_data:
```

### 4. Dockerfile.core

```dockerfile
FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    gcc \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Python 패키지 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 앱 코드 복사
COPY core_api/ ./core_api/
COPY alembic/ ./alembic/
COPY alembic.ini .
COPY scripts/ ./scripts/

EXPOSE 8000

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')"

CMD ["uvicorn", "core_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 5. Dockerfile.conversation

```dockerfile
FROM python:3.11-slim

WORKDIR /app

RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY conversation_service/ ./conversation_service/

EXPOSE 8004

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8004/health')"

CMD ["uvicorn", "conversation_service.main:app", "--host", "0.0.0.0", "--port", "8004"]
```

### 6. .env.example

```bash
# Database
DATABASE_URL=postgresql://healthai:password@postgres:5432/healthai_db

# Redis
REDIS_URL=redis://redis:6379

# JWT
JWT_SECRET_KEY=your-secret-key-change-this-in-production
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=30
REFRESH_TOKEN_EXPIRE_DAYS=14

# OpenAI
OPENAI_API_KEY=sk-your-key-here

# OAuth (추후 설정)
KAKAO_CLIENT_ID=
KAKAO_CLIENT_SECRET=
KAKAO_REDIRECT_URI=http://localhost:8000/api/v1/auth/callback/kakao

GOOGLE_CLIENT_ID=
GOOGLE_CLIENT_SECRET=
GOOGLE_REDIRECT_URI=http://localhost:8000/api/v1/auth/callback/google

APPLE_CLIENT_ID=
APPLE_TEAM_ID=
APPLE_KEY_ID=
APPLE_PRIVATE_KEY_PATH=

# Environment
ENVIRONMENT=development
LOG_LEVEL=info

# Chroma DB (추후 설정)
CHROMA_HOST=localhost
CHROMA_PORT=8001
```

### 7. .gitignore

```
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv/

# IDEs
.vscode/
.idea/
*.swp
*.swo

# Environment
.env
.env.local

# Database
*.db
*.sqlite

# Testing
.coverage
htmlcov/
.pytest_cache/

# Docker
*.log

# OS
.DS_Store
Thumbs.db

# Alembic
alembic/versions/*_test.py
```

### 8. pytest.ini

```ini
[pytest]
testpaths = tests
python_files = test_*.py
python_functions = test_*
asyncio_mode = auto
```

### 9. alembic.ini

```ini
[alembic]
script_location = alembic
prepend_sys_path = .
version_path_separator = os

sqlalchemy.url = postgresql://healthai:password@localhost:5432/healthai_db

[loggers]
keys = root,sqlalchemy,alembic

[handlers]
keys = console

[formatters]
keys = generic

[logger_root]
level = WARN
handlers = console
qualname =

[logger_sqlalchemy]
level = WARN
handlers =
qualname = sqlalchemy.engine

[logger_alembic]
level = INFO
handlers =
qualname = alembic

[handler_console]
class = StreamHandler
args = (sys.stderr,)
level = NOTSET
formatter = generic

[formatter_generic]
format = %(levelname)-5.5s [%(name)s] %(message)s
datefmt = %H:%M:%S
```

## 완료 확인
다음을 확인하고 보고해줘:
- [ ] 모든 파일과 폴더 생성 완료
- [ ] docker-compose up 실행 성공
- [ ] PostgreSQL 연결 확인 (psql 접속)
- [ ] Redis 연결 확인 (redis-cli ping)
- [ ] Core API 헬스체크 (http://localhost:8000/health)
- [ ] Conversation Service 헬스체크 (http://localhost:8004/health)
```

---

#### Day 3-4: 데이터베이스 스키마 설계

```markdown
# Day 3-4: 데이터베이스 스키마 설계

## 목표
TRD v1.2 섹션 5의 데이터베이스 스키마를 SQLAlchemy 모델로 구현합니다.

## 참조
- TRD v1.2: 섹션 5 (데이터베이스 스키마)
- 개발_체크리스트_v1.2.md: Day 3-4

## 요구사항

### 1. core_api/models/user.py

TRD v1.2 섹션 5.1 참조:

```python
from sqlalchemy import Column, String, DateTime, Boolean, Text, Integer
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from core_api.database import Base

class User(Base):
    __tablename__ = "users"
    
    # TRD 5.1: 기본 필드
    user_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String(255), unique=True, nullable=True, index=True)
    phone_number = Column(String(20), unique=True, nullable=True, index=True)
    
    # 프로필
    name = Column(String(100), nullable=False)
    birth_date = Column(DateTime, nullable=True)
    gender = Column(String(10), nullable=True)  # male, female, other
    profile_image_url = Column(Text, nullable=True)
    
    # OAuth
    oauth_provider = Column(String(20), nullable=True)  # kakao, google, apple
    oauth_provider_id = Column(String(255), unique=True, nullable=True, index=True)
    
    # 건강 정보
    height_cm = Column(Integer, nullable=True)
    weight_kg = Column(Integer, nullable=True)
    blood_type = Column(String(5), nullable=True)
    chronic_conditions = Column(JSONB, nullable=True)  # ["diabetes", "hypertension"]
    medications = Column(JSONB, nullable=True)         # ["metformin 500mg"]
    allergies = Column(JSONB, nullable=True)           # ["pollen", "penicillin"]
    
    # 구독
    subscription_tier = Column(String(20), default="free")  # free, premium
    subscription_status = Column(String(20), default="active")  # active, expired, cancelled
    subscription_end_date = Column(DateTime, nullable=True)
    
    # FCM (푸시 알림)
    fcm_token = Column(Text, nullable=True)
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    last_login_at = Column(DateTime, nullable=True)
    
    # 관계
    family_profiles = relationship("FamilyProfile", back_populates="owner", cascade="all, delete-orphan")
    conversations = relationship("Conversation", back_populates="user", cascade="all, delete-orphan")
    routine_checks = relationship("RoutineCheck", back_populates="user", cascade="all, delete-orphan")
    
    # 인덱스는 migration에서 추가
    __table_args__ = (
        {'comment': 'User accounts and profiles'}
    )
```

### 2. core_api/models/family.py

TRD v1.2 섹션 5.2 참조:

```python
from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from core_api.database import Base

class FamilyProfile(Base):
    __tablename__ = "family_profiles"
    
    # TRD 5.2
    profile_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    
    # 기본 정보
    name = Column(String(100), nullable=False)
    relationship_type = Column(String(20), nullable=False)  # father, mother, spouse, child, etc.
    birth_date = Column(DateTime, nullable=True)
    gender = Column(String(10), nullable=True)
    profile_image_url = Column(Text, nullable=True)
    
    # 건강 정보
    height_cm = Column(Integer, nullable=True)
    weight_kg = Column(Integer, nullable=True)
    blood_type = Column(String(5), nullable=True)
    chronic_conditions = Column(JSONB, nullable=True)
    medications = Column(JSONB, nullable=True)
    allergies = Column(JSONB, nullable=True)
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # 관계
    owner = relationship("User", back_populates="family_profiles")
    conversations = relationship("Conversation", back_populates="family_profile")
    
    __table_args__ = (
        {'comment': 'Family member profiles'}
    )
```

### 3. core_api/models/conversation.py

TRD v1.2 섹션 5.3 참조:

```python
from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from core_api.database import Base

class Conversation(Base):
    __tablename__ = "conversations"
    
    # TRD 5.3
    conversation_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    family_profile_id = Column(UUID(as_uuid=True), ForeignKey("family_profiles.profile_id", ondelete="SET NULL"), nullable=True, index=True)
    character_id = Column(String(50), nullable=False, index=True)  # "dr_kim_younghoon"
    
    # 대화 내용
    messages = Column(JSONB, nullable=False)  # [{"role": "user", "content": "...", "timestamp": "..."}]
    summary = Column(Text, nullable=True)  # AI 요약
    
    # 통계
    duration_seconds = Column(Integer, nullable=True)
    user_message_count = Column(Integer, default=0)
    ai_message_count = Column(Integer, default=0)
    
    # 타임스탬프
    started_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    ended_at = Column(DateTime, nullable=True)
    
    # 관계
    user = relationship("User", back_populates="conversations")
    family_profile = relationship("FamilyProfile", back_populates="conversations")
    
    __table_args__ = (
        {'comment': 'Voice consultation conversations'}
    )
```

### 4. core_api/models/routine.py

TRD v1.2 섹션 5.4 참조:

```python
from sqlalchemy import Column, String, DateTime, Integer, ForeignKey, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from datetime import datetime, date
import uuid
from core_api.database import Base

class RoutineCheck(Base):
    __tablename__ = "routine_checks"
    
    # TRD 5.4
    check_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    check_date = Column(DateTime, nullable=False, index=True)  # 체크한 날짜 (YYYY-MM-DD)
    
    # 8개 루틴 체크 (Boolean)
    bedding_organized = Column(Boolean, default=False)
    water_intake = Column(Boolean, default=False)
    meditation = Column(Boolean, default=False)
    stretching = Column(Boolean, default=False)
    gratitude_journal = Column(Boolean, default=False)
    morning_walk = Column(Boolean, default=False)
    vitamins = Column(Boolean, default=False)
    planning = Column(Boolean, default=False)
    
    # 컨디션 (1-5)
    mood_score = Column(Integer, nullable=True)      # 기분 (1=매우나쁨 ~ 5=매우좋음)
    energy_score = Column(Integer, nullable=True)    # 에너지 (1=매우낮음 ~ 5=매우높음)
    
    # 자유 입력
    goal_today = Column(Text, nullable=True)          # 오늘의 목표 (최대 100자)
    schedule_items = Column(JSONB, nullable=True)     # 오늘의 일정 3가지 ["회의", "운동", "저녁식사"]
    gratitude_items = Column(JSONB, nullable=True)    # 감사한 일 3가지 ["건강", "가족", "날씨"]
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # 관계
    user = relationship("User", back_populates="routine_checks")
    
    __table_args__ = (
        {'comment': 'Daily routine check records'}
    )
```

### 5. core_api/models/subscription.py

TRD v1.2 섹션 5.5 참조:

```python
from sqlalchemy import Column, String, DateTime, Numeric, ForeignKey, Text, Boolean
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from datetime import datetime
import uuid
from core_api.database import Base

class SubscriptionHistory(Base):
    __tablename__ = "subscription_history"
    
    # TRD 5.5
    history_id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.user_id", ondelete="CASCADE"), nullable=False, index=True)
    
    # 구독 정보
    tier = Column(String(20), nullable=False)  # free, premium
    status = Column(String(20), nullable=False)  # active, expired, cancelled
    
    # RevenueCat
    revenuecat_customer_id = Column(String(255), nullable=True)
    revenuecat_entitlement_id = Column(String(255), nullable=True)
    
    # 가격 정보
    price_krw = Column(Numeric(10, 2), nullable=True)
    currency = Column(String(3), default="KRW")
    
    # 기간
    started_at = Column(DateTime, nullable=False, index=True)
    expires_at = Column(DateTime, nullable=True, index=True)
    cancelled_at = Column(DateTime, nullable=True)
    
    # 메타데이터
    purchase_platform = Column(String(20), nullable=True)  # ios, android
    
    # 타임스탬프
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    __table_args__ = (
        {'comment': 'Subscription purchase history'}
    )
```

### 6. core_api/database.py

```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from core_api.config import settings

# Database URL
SQLALCHEMY_DATABASE_URL = settings.DATABASE_URL

# Engine
engine = create_engine(
    SQLALCHEMY_DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20,
    echo=settings.ENVIRONMENT == "development"
)

# Session
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

# Base
Base = declarative_base()

# Dependency
def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### 7. Alembic 마이그레이션 생성

```bash
# 마이그레이션 초기화 (이미 완료됨)
alembic init alembic

# 첫 마이그레이션 생성
alembic revision --autogenerate -m "Initial schema with users, families, conversations, routines, subscriptions"

# 마이그레이션 적용
alembic upgrade head
```

## 완료 확인
- [ ] 모든 모델 파일 생성 완료
- [ ] core_api/models/__init__.py에 모든 모델 import
- [ ] Alembic 마이그레이션 생성 및 적용
- [ ] PostgreSQL에 테이블 생성 확인 (psql \dt)
- [ ] 각 테이블의 인덱스 확인 (psql \d tablename)
```

---

#### Day 5-8: 소셜 로그인 구현 (카카오, 구글, 애플)

```markdown
# Day 5-8: 소셜 로그인 구현

## 목표
카카오, 구글, 애플 소셜 로그인을 구현합니다.

## 참조
- TRD v1.2: 섹션 6.1 (인증 API)
- 개발_체크리스트_v1.2.md: Day 5-8

## 요구사항

### 1. core_api/routers/auth.py

TRD v1.2 섹션 6.1 참조:

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from core_api.database import get_db
from core_api.schemas.auth import (
    SocialLoginRequest,
    TokenResponse,
    RefreshTokenRequest
)
from core_api.services.auth_service import AuthService
from core_api.dependencies import get_current_user
from core_api.models.user import User

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

@router.post("/login/social", response_model=TokenResponse)
async def social_login(
    request: SocialLoginRequest,
    db: Session = Depends(get_db)
):
    """
    F-AUTH-001: 소셜 로그인
    
    - provider: kakao, google, apple
    - token: OAuth provider의 액세스 토큰
    """
    auth_service = AuthService(db)
    
    try:
        result = await auth_service.social_login(
            provider=request.provider,
            token=request.token
        )
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(e)
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Login failed"
        )

@router.post("/refresh", response_model=TokenResponse)
async def refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    F-AUTH-002: 토큰 갱신
    """
    auth_service = AuthService(db)
    
    try:
        result = await auth_service.refresh_token(request.refresh_token)
        return result
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )

@router.post("/logout")
async def logout(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    F-AUTH-003: 로그아웃
    """
    # FCM 토큰 제거
    current_user.fcm_token = None
    db.commit()
    
    return {"message": "Logged out successfully"}

@router.delete("/withdraw")
async def withdraw(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    F-AUTH-004: 회원 탈퇴
    """
    # User 삭제 (cascade로 모든 관련 데이터 삭제)
    db.delete(current_user)
    db.commit()
    
    return {"message": "Account deleted successfully"}
```

### 2. core_api/services/auth_service.py

```python
import httpx
from jose import JWTError, jwt
from datetime import datetime, timedelta
from sqlalchemy.orm import Session
from core_api.models.user import User
from core_api.config import settings

class AuthService:
    def __init__(self, db: Session):
        self.db = db
    
    async def social_login(self, provider: str, token: str):
        """소셜 로그인 처리"""
        
        # 1. Provider별 사용자 정보 가져오기
        if provider == "kakao":
            user_info = await self._get_kakao_user_info(token)
        elif provider == "google":
            user_info = await self._get_google_user_info(token)
        elif provider == "apple":
            user_info = await self._get_apple_user_info(token)
        else:
            raise ValueError("Unsupported provider")
        
        # 2. 기존 사용자 찾기 또는 생성
        user = self.db.query(User).filter(
            User.oauth_provider == provider,
            User.oauth_provider_id == user_info["id"]
        ).first()
        
        if not user:
            # 신규 사용자 생성
            user = User(
                email=user_info.get("email"),
                name=user_info.get("name", "사용자"),
                oauth_provider=provider,
                oauth_provider_id=user_info["id"],
                profile_image_url=user_info.get("picture")
            )
            self.db.add(user)
            self.db.commit()
            self.db.refresh(user)
        
        # 3. last_login_at 업데이트
        user.last_login_at = datetime.utcnow()
        self.db.commit()
        
        # 4. JWT 토큰 생성
        access_token = self._create_access_token(user.user_id)
        refresh_token = self._create_refresh_token(user.user_id)
        
        return {
            "access_token": access_token,
            "refresh_token": refresh_token,
            "token_type": "bearer",
            "user": {
                "user_id": str(user.user_id),
                "name": user.name,
                "email": user.email,
                "profile_image_url": user.profile_image_url
            }
        }
    
    async def _get_kakao_user_info(self, access_token: str):
        """카카오 사용자 정보 가져오기"""
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://kapi.kakao.com/v2/user/me",
                headers={"Authorization": f"Bearer {access_token}"}
            )
            
            if response.status_code != 200:
                raise ValueError("Invalid Kakao token")
            
            data = response.json()
            kakao_account = data.get("kakao_account", {})
            
            return {
                "id": str(data["id"]),
                "email": kakao_account.get("email"),
                "name": kakao_account.get("profile", {}).get("nickname"),
                "picture": kakao_account.get("profile", {}).get("thumbnail_image_url")
            }
    
    async def _get_google_user_info(self, access_token: str):
        """구글 사용자 정보 가져오기"""
        async with httpx.AsyncClient() as client:
            response = await client.get(
                "https://www.googleapis.com/oauth2/v2/userinfo",
                headers={"Authorization": f"Bearer {access_token}"}
            )
            
            if response.status_code != 200:
                raise ValueError("Invalid Google token")
            
            data = response.json()
            
            return {
                "id": data["id"],
                "email": data.get("email"),
                "name": data.get("name"),
                "picture": data.get("picture")
            }
    
    async def _get_apple_user_info(self, id_token: str):
        """애플 사용자 정보 가져오기 (ID Token 검증)"""
        try:
            # Apple ID Token 검증
            payload = jwt.decode(
                id_token,
                settings.APPLE_PUBLIC_KEY,  # 애플 공개키로 검증
                algorithms=["RS256"],
                audience=settings.APPLE_CLIENT_ID
            )
            
            return {
                "id": payload["sub"],  # Apple unique user ID
                "email": payload.get("email"),
                "name": None  # Apple은 이름을 제공하지 않음
            }
        except JWTError:
            raise ValueError("Invalid Apple token")
    
    def _create_access_token(self, user_id):
        """Access Token 생성 (30분)"""
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode = {
            "sub": str(user_id),
            "exp": expire,
            "type": "access"
        }
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    
    def _create_refresh_token(self, user_id):
        """Refresh Token 생성 (14일)"""
        expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        to_encode = {
            "sub": str(user_id),
            "exp": expire,
            "type": "refresh"
        }
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    
    async def refresh_token(self, refresh_token: str):
        """Refresh Token으로 새 Access Token 발급"""
        try:
            payload = jwt.decode(
                refresh_token,
                settings.JWT_SECRET_KEY,
                algorithms=[settings.JWT_ALGORITHM]
            )
            
            if payload.get("type") != "refresh":
                raise ValueError("Invalid token type")
            
            user_id = payload.get("sub")
            
            # 새 Access Token 생성
            access_token = self._create_access_token(user_id)
            
            return {
                "access_token": access_token,
                "refresh_token": refresh_token,  # Refresh token은 그대로 유지
                "token_type": "bearer"
            }
        except JWTError:
            raise ValueError("Invalid refresh token")
```

### 3. core_api/dependencies.py

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from jose import JWTError, jwt
from sqlalchemy.orm import Session
from core_api.database import get_db
from core_api.models.user import User
from core_api.config import settings

security = HTTPBearer()

async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """현재 로그인한 사용자 가져오기"""
    
    token = credentials.credentials
    
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM]
        )
        
        if payload.get("type") != "access":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token type"
            )
        
        user_id = payload.get("sub")
        
        if user_id is None:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Could not validate credentials"
            )
        
    except JWTError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Could not validate credentials"
        )
    
    # 사용자 조회
    user = db.query(User).filter(User.user_id == user_id).first()
    
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    return user
```

### 4. core_api/schemas/auth.py

```python
from pydantic import BaseModel, Field
from typing import Optional

class SocialLoginRequest(BaseModel):
    provider: str = Field(..., description="kakao, google, apple")
    token: str = Field(..., description="OAuth provider's access token or ID token")

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: Optional[dict] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str
```

### 5. core_api/config.py

```python
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    # Database
    DATABASE_URL: str
    
    # Redis
    REDIS_URL: str
    
    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 14
    
    # OAuth
    KAKAO_CLIENT_ID: str = ""
    KAKAO_CLIENT_SECRET: str = ""
    
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""
    
    APPLE_CLIENT_ID: str = ""
    APPLE_PUBLIC_KEY: str = ""  # 애플 공개키
    
    # OpenAI
    OPENAI_API_KEY: str
    
    # Environment
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "info"
    
    class Config:
        env_file = ".env"

settings = Settings()
```

### 6. core_api/main.py

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core_api.routers import auth, users, families, routines, subscriptions

app = FastAPI(
    title="건강주치의 AI - Core API",
    version="1.0.0",
    description="Core API for 음성 AI 건강주치의 앱"
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 제한 필요
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router)
app.include_router(users.router)
app.include_router(families.router)
app.include_router(routines.router)
app.include_router(subscriptions.router)

@app.get("/health")
async def health_check():
    return {"status": "healthy", "service": "core_api"}

@app.get("/")
async def root():
    return {"message": "건강주치의 AI Core API v1.0"}
```

## 완료 확인
- [ ] 소셜 로그인 엔드포인트 구현 (POST /api/v1/auth/login/social)
- [ ] 토큰 갱신 엔드포인트 구현 (POST /api/v1/auth/refresh)
- [ ] 로그아웃 엔드포인트 구현 (POST /api/v1/auth/logout)
- [ ] 회원 탈퇴 엔드포인트 구현 (DELETE /api/v1/auth/withdraw)
- [ ] JWT 토큰 생성 및 검증 로직 구현
- [ ] 카카오/구글/애플 사용자 정보 가져오기 구현
- [ ] Swagger UI 확인 (http://localhost:8000/docs)
- [ ] Postman으로 테스트 (카카오 로그인 → Access Token 받기 → API 호출)
```

---

### 🔹 Week 2: 사용자 & 가족 관리 (Day 9-16)

**Day 9-12, Day 13-16은 기존 문서와 동일하게 유지 (생략)**

---

### 🔹 Week 3-4: 음성 상담 시스템 (Day 17-25)

**Day 17-25는 기존 문서와 동일하게 유지 (생략)**

---

### 🔹 Week 4-5: 웨어러블 & 건강 데이터 (Day 26-34)

**Day 26-34는 기존 문서와 동일하게 유지 (생략)**

---

### 🔹 Week 6-7: 구독 & UI (Day 35-52) ⭐ 대폭 확장

#### Day 35-42: RevenueCat 구독 시스템 (기존 동일)

**Day 35-42는 기존 문서와 동일하게 유지 (생략)**

---

#### Day 43-44: Flutter 프로젝트 초기화 & 테마 설정

```markdown
# Day 43-44: Flutter 프로젝트 초기화 & 테마 설정

## 목표
Flutter 프로젝트를 생성하고 UI/UX 디자인 가이드 v1.1에 따라 테마를 설정합니다.

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 2 (디자인 시스템)
- UI/UX 디자인 가이드 v1.1: 섹션 13.1 (Flutter 테마 설정)

## 요구사항

### 1. Flutter 프로젝트 생성

```bash
flutter create healthai_app
cd healthai_app
```

### 2. pubspec.yaml 패키지 추가

```yaml
name: healthai_app
description: 음성 AI 건강주치의 앱
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  
  # State Management
  flutter_riverpod: ^2.5.1
  
  # Navigation
  go_router: ^14.0.2
  
  # HTTP Client
  dio: ^5.4.3+1
  
  # Local Storage
  shared_preferences: ^2.2.3
  flutter_secure_storage: ^9.2.2
  
  # UI Components
  flutter_svg: ^2.0.10+1
  cached_network_image: ^3.3.1
  lottie: ^3.1.2
  
  # Charts
  fl_chart: ^0.68.0
  
  # WebSocket
  web_socket_channel: ^2.4.5
  
  # Auth
  google_sign_in: ^6.2.1
  sign_in_with_apple: ^6.1.1
  kakao_flutter_sdk: ^1.9.3
  
  # Subscription
  purchases_flutter: ^6.29.4  # RevenueCat
  
  # Push Notification
  firebase_core: ^2.32.0
  firebase_messaging: ^14.9.4
  
  # Utils
  intl: ^0.19.0
  uuid: ^4.4.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
  
  # Fonts (Pretendard)
  fonts:
    - family: Pretendard
      fonts:
        - asset: assets/fonts/Pretendard-Regular.ttf
        - asset: assets/fonts/Pretendard-Medium.ttf
          weight: 500
        - asset: assets/fonts/Pretendard-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Pretendard-Bold.ttf
          weight: 700
  
  # Assets
  assets:
    - assets/images/
    - assets/icons/
    - assets/lottie/
```

### 3. 프로젝트 구조 생성

```
lib/
├── main.dart
├── app.dart
├── config/
│   ├── app_config.dart
│   └── api_config.dart
├── theme/
│   ├── app_theme.dart          ⭐ UI/UX v1.1 테마
│   ├── app_colors.dart         ⭐ v1.1 색상
│   └── app_text_styles.dart    ⭐ v1.1 타이포그래피
├── router/
│   └── app_router.dart
├── providers/
│   ├── auth_provider.dart
│   └── user_provider.dart
├── screens/
│   ├── splash_screen.dart
│   ├── onboarding_screen.dart
│   ├── login_screen.dart
│   ├── home_screen.dart
│   ├── character_selection_screen.dart
│   ├── voice_consultation_screen.dart
│   ├── routine_check_screen.dart
│   ├── family_profile_screen.dart
│   ├── statistics_screen.dart     ⭐ 신규
│   ├── subscription_screen.dart
│   └── settings_screen.dart
├── widgets/
│   ├── buttons/
│   │   ├── primary_button.dart
│   │   ├── secondary_button.dart
│   │   ├── text_button.dart
│   │   └── icon_button.dart      ⭐ 신규
│   ├── cards/
│   │   ├── stat_card.dart        ⭐ 신규 (핵심!)
│   │   ├── compact_card.dart
│   │   └── character_card.dart
│   ├── inputs/
│   │   ├── text_input.dart
│   │   └── search_input.dart     ⭐ 신규
│   ├── chips/
│   │   └── chip.dart             ⭐ 신규
│   └── common/
│       ├── loading_indicator.dart
│       └── error_widget.dart
├── services/
│   ├── api_service.dart
│   ├── auth_service.dart
│   └── websocket_service.dart
└── models/
    ├── user.dart
    ├── family_profile.dart
    ├── conversation.dart
    └── routine.dart
```

### 4. lib/theme/app_colors.dart (UI/UX v1.1)

```dart
import 'package:flutter/material.dart';

/// UI/UX 디자인 가이드 v1.1 - 섹션 2.1 컬러 팔레트
class AppColors {
  // Primary Colors (20-50대 맞춤)
  static const Color primaryBlue = Color(0xFF2563EB);      // v1.0: #4A90E2 → 더 진함
  static const Color secondaryTeal = Color(0xFF14B8A6);    // 신규
  static const Color accentPurple = Color(0xFF8B5CF6);     // 신규
  
  // Neutral Colors (Tailwind Gray)
  static const Color gray50 = Color(0xFFF9FAFB);
  static const Color gray100 = Color(0xFFF3F4F6);
  static const Color gray200 = Color(0xFFE5E7EB);
  static const Color gray400 = Color(0xFF9CA3AF);
  static const Color gray600 = Color(0xFF4B5563);
  static const Color gray900 = Color(0xFF111827);
  
  // Semantic Colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);
  
  // Character Colors (10개)
  static const Map<String, Color> characterColors = {
    'dr_kim_younghoon': Color(0xFF2563EB),      // 가정의학과
    'dr_park_seoyeon': Color(0xFF8B5CF6),       // 정신건강의학과
    'dr_jung_minjoon': Color(0xFF0891B2),       // 내과
    'dr_lee_soojin': Color(0xFFF59E0B),         // 소아청소년과
    'dr_choi_minho': Color(0xFF78716C),         // 정형외과
    'dr_kang_jieun': Color(0xFFEC4899),         // 피부과
    'dr_yoon_taeyoung': Color(0xFFDC2626),      // 심장내과
    'dr_han_soyoung': Color(0xFFBE185D),        // 산부인과
    'dr_oh_kyungmi': Color(0xFF16A34A),         // 영양학
    'dr_lim_jaehyun': Color(0xFFEA580C),        // 운동의학
  };
  
  // Dark Mode
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkPrimary = Color(0xFF3B82F6);
  static const Color darkText = Color(0xFFF1F5F9);
  static const Color darkTextSecondary = Color(0xFF94A3B8);
}
```

### 5. lib/theme/app_text_styles.dart (UI/UX v1.1 - 작은 폰트)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';

/// UI/UX 디자인 가이드 v1.1 - 섹션 2.2 타이포그래피
/// 20-50대 맞춤: 폰트 크기 축소, 정보 밀도 2배
class AppTextStyles {
  // H1 (Display) - v1.0: 32px → v1.1: 28px
  static const TextStyle h1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.gray900,
  );
  
  // H2 (Heading) - v1.0: 24px → v1.1: 20px
  static const TextStyle h2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.gray900,
  );
  
  // H3 (Subheading) - v1.0: 20px → v1.1: 16px
  static const TextStyle h3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.2,
    color: AppColors.gray900,
  );
  
  // Body - v1.0: 16px → v1.1: 14px
  static const TextStyle body = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.gray900,
  );
  
  // Body Small - 신규
  static const TextStyle bodySmall = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.gray600,
  );
  
  // Caption - v1.0: 14px → v1.1: 12px
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.gray600,
  );
  
  // Overline - 신규 (라벨, 태그용)
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.gray600,
    letterSpacing: 0.5,
  );
  
  // Button
  static const TextStyle button = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.0,
  );
}
```

### 6. lib/theme/app_theme.dart (UI/UX v1.1 완전 구현)

```dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

/// UI/UX 디자인 가이드 v1.1 - 섹션 13.1 Flutter 테마 설정
/// 20-50대 맞춤: 컴팩트 컴포넌트, 정보 밀도 최적화
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    
    // 색상 스킴 (v1.1)
    colorScheme: ColorScheme.light(
      primary: AppColors.primaryBlue,
      secondary: AppColors.secondaryTeal,
      tertiary: AppColors.accentPurple,
      surface: Colors.white,
      background: AppColors.gray50,
      error: AppColors.error,
    ),
    
    // 폰트 (Pretendard)
    fontFamily: 'Pretendard',
    
    // 타이포그래피 (v1.1 - 작은 크기)
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1,       // 28px
      headlineMedium: AppTextStyles.h2,     // 20px
      titleLarge: AppTextStyles.h3,         // 16px
      bodyLarge: AppTextStyles.body,        // 14px
      bodySmall: AppTextStyles.bodySmall,   // 13px
      labelSmall: AppTextStyles.caption,    // 12px
    ),
    
    // 버튼 테마 (v1.1 - 높이 48px)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: Colors.white,
        minimumSize: Size(0, 48),  // v1.0: 56px → v1.1: 48px (-8px)
        padding: EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),  // v1.0: 12px → v1.1: 8px (sharp)
        ),
        elevation: 0,
        shadowColor: Colors.black.withOpacity(0.08),
        textStyle: AppTextStyles.button,
      ),
    ),
    
    // 입력 필드 테마 (v1.1 - 높이 44px)
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.gray50,
      contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.gray200, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.gray200, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.gray600),
      hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
    ),
    
    // 카드 테마 (v1.1 - 패딩 12px)
    cardTheme: CardTheme(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.gray100, width: 1),
      ),
      margin: EdgeInsets.symmetric(vertical: 6),  // 카드 간격 12px / 2
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.08),
    ),
    
    // 앱바 테마
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: AppColors.gray900,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: AppTextStyles.h2,
    ),
    
    // 바텀 네비게이션 바
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primaryBlue,
      unselectedItemColor: AppColors.gray400,
      selectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
      unselectedLabelStyle: TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    
    // 체크박스 (v1.1 - 20px, 루틴은 24px)
    checkboxTheme: CheckboxThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      side: BorderSide(color: AppColors.gray400, width: 1.5),
    ),
    
    // 스위치
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return Colors.white;
        }
        return AppColors.gray400;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.primaryBlue;
        }
        return AppColors.gray200;
      }),
    ),
    
    // 구분선
    dividerColor: AppColors.gray200,
    dividerTheme: DividerThemeData(
      color: AppColors.gray200,
      thickness: 0.5,
      space: 16,
    ),
  );
  
  // 다크 모드 (UI/UX v1.1 섹션 8)
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.secondaryTeal,
      tertiary: AppColors.accentPurple,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.error,
    ),
    
    fontFamily: 'Pretendard',
    
    textTheme: TextTheme(
      displayLarge: AppTextStyles.h1.copyWith(color: AppColors.darkText),
      headlineMedium: AppTextStyles.h2.copyWith(color: AppColors.darkText),
      titleLarge: AppTextStyles.h3.copyWith(color: AppColors.darkText),
      bodyLarge: AppTextStyles.body.copyWith(color: AppColors.darkText),
      bodySmall: AppTextStyles.bodySmall.copyWith(color: AppColors.darkTextSecondary),
      labelSmall: AppTextStyles.caption.copyWith(color: AppColors.darkTextSecondary),
    ),
    
    // ... (다크 모드 나머지 설정)
  );
}
```

### 7. lib/main.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  runApp(
    ProviderScope(
      child: MyApp(),
    ),
  );
}
```

### 8. lib/app.dart

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'theme/app_theme.dart';
import 'router/app_router.dart';

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: '건강주치의 AI',
      
      // UI/UX v1.1 테마
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      
      // 라우팅
      routerConfig: ref.watch(appRouterProvider),
      
      // 디버그 배너 제거
      debugShowCheckedModeBanner: false,
    );
  }
}
```

## 완료 확인
- [ ] Flutter 프로젝트 생성 완료
- [ ] pubspec.yaml 패키지 추가
- [ ] Pretendard 폰트 assets/fonts/에 추가
- [ ] app_colors.dart 작성 (v1.1 색상)
- [ ] app_text_styles.dart 작성 (v1.1 타이포그래피)
- [ ] app_theme.dart 작성 (v1.1 테마)
- [ ] main.dart, app.dart 작성
- [ ] flutter run 실행 성공
- [ ] 테마 적용 확인 (버튼, 입력 필드 등)
```

---

#### Day 45-46: 공통 위젯 구현 (Stat Card 포함!)

```markdown
# Day 45-46: 공통 위젯 구현

## 목표
재사용 가능한 공통 위젯을 구현합니다. 특히 **Stat Card**는 v1.1의 핵심 컴포넌트입니다.

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 3 (컴포넌트 라이브러리)
- UI/UX 디자인 가이드 v1.1: 섹션 13.2 (재사용 컴포넌트)

## 요구사항

### 1. lib/widgets/cards/stat_card.dart ⭐ 신규 & 핵심

UI/UX v1.1 섹션 3.3 참조:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// UI/UX v1.1 - Stat Card (통계 카드)
/// 정보 밀도 극대화를 위한 핵심 컴포넌트
/// 
/// 사용처: 걸음 수, 칼로리, 수면 시간, 심박수, 루틴 달성률 등
class StatCard extends StatelessWidget {
  final String title;          // 제목 (11px Overline)
  final String value;          // 큰 숫자 (24px Bold)
  final String? change;        // 변화량 (예: "+12%", "▲ 5%")
  final bool isPositive;       // 변화가 긍정적인지 (녹색/빨강)
  final IconData icon;         // 아이콘 (16x16px)
  final Color? backgroundColor;

  const StatCard({
    Key? key,
    required this.title,
    required this.value,
    this.change,
    this.isPositive = true,
    required this.icon,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray100, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더 (아이콘 + 제목)
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.gray400),
              SizedBox(width: 4),
              Text(
                title,
                style: AppTextStyles.overline.copyWith(
                  color: AppColors.gray600,
                ),
              ),
            ],
          ),
          
          Spacer(),
          
          // 큰 숫자 (핵심 정보)
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.gray900,
            ),
          ),
          
          // 변화량 (선택적)
          if (change != null) ...[
            SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 12,
                  color: isPositive ? AppColors.success : AppColors.error,
                ),
                SizedBox(width: 2),
                Text(
                  change!,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isPositive ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Stat Card 그리드 (2열)
class StatCardGrid extends StatelessWidget {
  final List<StatCard> cards;

  const StatCardGrid({Key? key, required this.cards}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,  // 너비:높이 = 1.4:1
      children: cards,
    );
  }
}
```

### 2. lib/widgets/buttons/primary_button.dart

UI/UX v1.1 섹션 3.1 참조:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Primary Button (v1.1 - 높이 48px)
class PrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double? width;

  const PrimaryButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width ?? double.infinity,
      height: 48,  // v1.0: 56px → v1.1: 48px
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          disabledBackgroundColor: AppColors.gray200,
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: AppTextStyles.button.copyWith(color: Colors.white),
              ),
      ),
    );
  }
}
```

### 3. lib/widgets/buttons/icon_button.dart ⭐ 신규

UI/UX v1.1 섹션 3.1 참조:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Icon Button (v1.1 신규)
/// 크기: 44x44px (최소 터치 영역)
class AppIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? iconColor;
  final double size;

  const AppIconButton({
    Key? key,
    required this.icon,
    this.onPressed,
    this.backgroundColor,
    this.iconColor,
    this.size = 44,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor ?? AppColors.gray50,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.gray900,
          ),
        ),
      ),
    );
  }
}
```

### 4. lib/widgets/chips/chip.dart ⭐ 신규

UI/UX v1.1 섹션 3.5 참조:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Chip (v1.1 신규)
/// 태그, 필터링용
class AppChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback? onTap;

  const AppChip({
    Key? key,
    required this.label,
    this.isSelected = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 28,
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryBlue : AppColors.gray100,
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : AppColors.gray600,
          ),
        ),
      ),
    );
  }
}
```

### 5. lib/widgets/inputs/search_input.dart ⭐ 신규

UI/UX v1.1 섹션 3.2 참조:

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Search Input (v1.1 신규)
/// 높이: 40px
class SearchInput extends StatelessWidget {
  final String hint;
  final ValueChanged<String>? onChanged;
  final TextEditingController? controller;

  const SearchInput({
    Key? key,
    this.hint = '검색...',
    this.onChanged,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: AppColors.gray100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 14, color: AppColors.gray400),
          prefixIcon: Icon(Icons.search, size: 16, color: AppColors.gray400),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
```

### 6. lib/widgets/cards/compact_card.dart

```dart
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';

/// Compact Card (v1.1 - 패딩 12px)
class CompactCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;

  const CompactCard({
    Key? key,
    required this.child,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),  // v1.0: 16px → v1.1: 12px
          child: child,
        ),
      ),
    );
  }
}
```

## 완료 확인
- [ ] StatCard 구현 (가장 중요!)
- [ ] StatCardGrid 구현
- [ ] PrimaryButton 구현
- [ ] AppIconButton 구현 (신규)
- [ ] AppChip 구현 (신규)
- [ ] SearchInput 구현 (신규)
- [ ] CompactCard 구현
- [ ] 모든 위젯 테스트 화면에서 확인
```

---

#### Day 47-48: 홈 화면 구현 (정보 밀도 2배!)

```markdown
# Day 47-48: 홈 화면 구현 (v1.1 - 정보 밀도 2배)

## 목표
UI/UX v1.1의 가장 큰 변화인 **정보 밀도 2배 홈 화면**을 구현합니다.

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 4.2 (홈 화면)
- v1.0 대비: 2개 카드 → 7개 정보 단위 (3.5배 증가)

## v1.0 vs v1.1 비교

### v1.0 홈 화면 (40-60대)
```
┌────────────────────────┐
│ 안녕하세요, 지영님 👋   │  <- H1 (32px)
│                        │
│ [루틴 진행률 카드]      │  <- 큰 카드 (패딩 16px)
│ 6/8 완료 (75%)         │
│                        │
│ [최근 상담 카드]        │  <- 큰 카드
│ 김영훈 - 2시간 전       │
│                        │
│ (스크롤 필요)          │
└────────────────────────┘
```

### v1.1 홈 화면 (20-50대) ⭐ 정보 밀도 2배
```
┌────────────────────────┐
│ 안녕하세요, 지영님 👋   │  <- H2 (20px)
│                        │
│ ┌──────┐ ┌──────┐     │  <- Stat Card 2x2 그리드
│ │루틴  │ │걸음수│     │     (각 100px 높이)
│ │6/8   │ │8,234 │     │
│ │75%▲ │ │+5%▲ │     │
│ └──────┘ └──────┘     │
│ ┌──────┐ ┌──────┐     │
│ │수면  │ │심박수│     │
│ │7.5h  │ │72bpm│     │
│ │양호✅│ │정상  │     │
│ └──────┘ └──────┘     │
│                        │
│ 최근 상담 ────>         │  <- H3 (16px)
│ 👨‍⚕️ 김영훈 · 2h        │  <- 컴팩트 카드 (높이 60px)
│ 👩‍⚕️ 박서연 · 1일전     │
│                        │
│ 건강 목표 ────>         │
│ 🎯 만보 걷기 ███▢▢ 82%│  <- 프로그레스 바
│                        │
│ (스크롤 거의 불필요)    │
└────────────────────────┘
```

## 요구사항

### 1. lib/screens/home_screen.dart (완전 재설계)

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/cards/stat_card.dart';
import '../widgets/cards/compact_card.dart';

class HomeScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.gray50,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),  // v1.0: 20px → v1.1: 16px
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. 인사말 (H2, 컴팩트)
              Text(
                '안녕하세요, 지영님 👋',
                style: AppTextStyles.h2,  // 20px (v1.0: 32px)
              ),
              SizedBox(height: 16),  // v1.0: 24px → v1.1: 16px
              
              // 2. Stat Cards (2x2 그리드) ⭐ 핵심!
              StatCardGrid(
                cards: [
                  StatCard(
                    title: '루틴',
                    value: '6/8',
                    change: '75%',
                    isPositive: true,
                    icon: Icons.check_circle_outline,
                  ),
                  StatCard(
                    title: '걸음 수',
                    value: '8,234',
                    change: '+5%',
                    isPositive: true,
                    icon: Icons.directions_walk,
                  ),
                  StatCard(
                    title: '수면',
                    value: '7.5h',
                    change: '양호',
                    isPositive: true,
                    icon: Icons.bedtime_outlined,
                  ),
                  StatCard(
                    title: '심박수',
                    value: '72',
                    change: '정상',
                    isPositive: true,
                    icon: Icons.favorite_border,
                  ),
                ],
              ),
              
              SizedBox(height: 24),  // 섹션 간격
              
              // 3. 최근 상담
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('최근 상담', style: AppTextStyles.h3),  // 16px
                  TextButton(
                    onPressed: () {},
                    child: Text('더보기', style: TextStyle(fontSize: 14)),
                  ),
                ],
              ),
              SizedBox(height: 8),
              
              // 상담 카드 (컴팩트, 1줄 ellipsis)
              _buildConsultationCard(
                context,
                '👨‍⚕️',
                '김영훈',
                '2시간 전',
                '혈압 관리 방법에 대해 상담했습니다...',
              ),
              SizedBox(height: 8),
              _buildConsultationCard(
                context,
                '👩‍⚕️',
                '박서연',
                '1일 전',
                '수면 패턴 개선에 대해 논의했습니다...',
              ),
              
              SizedBox(height: 24),
              
              // 4. 건강 목표
              Text('건강 목표', style: AppTextStyles.h3),
              SizedBox(height: 12),
              
              _buildGoalCard(
                context,
                '🎯 만보 걷기',
                0.82,
                '8,234 / 10,000',
              ),
              
              _buildGoalCard(
                context,
                '💧 물 2L 마시기',
                0.60,
                '1.2L / 2.0L',
              ),
            ],
          ),
        ),
      ),
      
      // 플로팅 버튼 (음성 상담)
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // 캐릭터 선택 화면으로 이동
        },
        backgroundColor: AppColors.primaryBlue,
        child: Icon(Icons.mic, color: Colors.white, size: 28),
      ),
      
      // 하단 네비게이션 (v1.1 - 텍스트 11px)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,  // v1.0: 12px → v1.1: 11px
        unselectedFontSize: 11,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: '가족'),
          BottomNavigationBarItem(icon: Icon(Icons.mic), label: '상담'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: '통계'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'MY'),
        ],
      ),
    );
  }
  
  /// 최근 상담 카드 (컴팩트 - 1줄 ellipsis)
  Widget _buildConsultationCard(
    BuildContext context,
    String emoji,
    String doctorName,
    String time,
    String preview,
  ) {
    return CompactCard(
      onTap: () {},
      child: Row(
        children: [
          Text(emoji, style: TextStyle(fontSize: 32)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(doctorName, style: AppTextStyles.h3),
                    Text(' · ', style: TextStyle(color: AppColors.gray400)),
                    Text(time, style: AppTextStyles.caption),
                  ],
                ),
                SizedBox(height: 4),
                Text(
                  preview,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, size: 20, color: AppColors.gray400),
        ],
      ),
    );
  }
  
  /// 건강 목표 카드
  Widget _buildGoalCard(
    BuildContext context,
    String title,
    double progress,
    String subtitle,
  ) {
    return CompactCard(
      onTap: () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: AppTextStyles.body),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,  // v1.0: 8px → v1.1: 6px (얇게)
              backgroundColor: AppColors.gray200,
              valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
            ),
          ),
          SizedBox(height: 4),
          Text(subtitle, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}
```

## 정보 밀도 비교

| 항목 | v1.0 | v1.1 | 변화 |
|------|------|------|------|
| 화면 제목 폰트 | 32px | 20px | -12px |
| 카드 패딩 | 16px | 12px | -4px |
| 섹션 간격 | 32px | 24px | -8px |
| 주요 정보 단위 | 2개 | **7개** | +250% ⭐ |
| Stat Card | ❌ | ✅ (4개) | 신규 |
| 스크롤 | 필요 | 최소화 | 개선 |
| 첫 화면 정보량 | 낮음 | **높음** | 2배↑ |

## 완료 확인
- [ ] 홈 화면 UI 구현 (v1.1)
- [ ] Stat Card 4개 표시 (2x2 그리드)
- [ ] 최근 상담 2개 표시 (컴팩트)
- [ ] 건강 목표 2개 표시
- [ ] 하단 네비게이션 5개 탭
- [ ] 플로팅 버튼 (음성 상담)
- [ ] 실제 기기에서 테스트 (정보 밀도 확인)
- [ ] v1.0과 비교 (정보량 2배 증가 확인)
```

---

#### Day 49-50: 캐릭터 선택 & 음성 상담 화면

```markdown
# Day 49-50: 캐릭터 선택 & 음성 상담 화면

## 목표
10개 AI 캐릭터 선택 화면과 음성 상담 화면을 구현합니다 (v1.1 컴팩트 버전).

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 4.3, 4.4
- AI캐릭터 가이드 v1.1: 10개 캐릭터 정보

## 요구사항

### 1. lib/screens/character_selection_screen.dart (v1.1 컴팩트)

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/inputs/search_input.dart';

class CharacterSelectionScreen extends StatefulWidget {
  @override
  _CharacterSelectionScreenState createState() => _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  String searchQuery = '';
  
  // 10개 캐릭터 (AI캐릭터 가이드 v1.1 참조)
  final List<Map<String, dynamic>> characters = [
    {
      'id': 'dr_kim_younghoon',
      'name': '김영훈',
      'specialty': '가정의학과',
      'emoji': '👨‍⚕️',
      'color': AppColors.characterColors['dr_kim_younghoon'],
      'rating': 4.9,
    },
    {
      'id': 'dr_park_seoyeon',
      'name': '박서연',
      'specialty': '정신건강의학과',
      'emoji': '👩‍⚕️',
      'color': AppColors.characterColors['dr_park_seoyeon'],
      'rating': 4.8,
    },
    // ... (나머지 8개)
  ];

  @override
  Widget build(BuildContext context) {
    final filteredCharacters = characters.where((char) {
      return char['name'].contains(searchQuery) || 
             char['specialty'].contains(searchQuery);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('AI 주치의 선택'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 검색 입력 (v1.1 신규 - 40px)
            Padding(
              padding: EdgeInsets.all(16),
              child: SearchInput(
                hint: '이름 또는 전문과 검색...',
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
            ),
            
            // 캐릭터 그리드 (2열, v1.1 컴팩트)
            Expanded(
              child: GridView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,  // v1.0: 16px → v1.1: 12px
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.78,  // 140x180px
                ),
                itemCount: filteredCharacters.length,
                itemBuilder: (context, index) {
                  final character = filteredCharacters[index];
                  return _buildCharacterCard(character);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  /// 캐릭터 카드 (v1.1 - 140x180px)
  Widget _buildCharacterCard(Map<String, dynamic> character) {
    return InkWell(
      onTap: () {
        // 음성 상담 화면으로 이동
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VoiceConsultationScreen(
              characterId: character['id'],
              characterName: character['name'],
              characterEmoji: character['emoji'],
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.gray100, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 3,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지 (80x80px)
            Text(character['emoji'], style: TextStyle(fontSize: 64)),
            SizedBox(height: 12),
            
            // 이름 (H3, 16px)
            Text(
              character['name'],
              style: AppTextStyles.h3,
            ),
            SizedBox(height: 4),
            
            // 전문과 (Caption, 12px)
            Text(
              character['specialty'],
              style: AppTextStyles.caption,
            ),
            SizedBox(height: 4),
            
            // 평점 (Caption, 신규)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 12, color: Colors.amber),
                SizedBox(width: 2),
                Text(
                  character['rating'].toString(),
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. lib/screens/voice_consultation_screen.dart (v1.1 컴팩트)

```dart
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class VoiceConsultationScreen extends StatefulWidget {
  final String characterId;
  final String characterName;
  final String characterEmoji;

  const VoiceConsultationScreen({
    Key? key,
    required this.characterId,
    required this.characterName,
    required this.characterEmoji,
  }) : super(key: key);

  @override
  _VoiceConsultationScreenState createState() => _VoiceConsultationScreenState();
}

class _VoiceConsultationScreenState extends State<VoiceConsultationScreen> {
  bool isRecording = false;
  List<Map<String, String>> messages = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.characterName} 상담'),
        actions: [
          IconButton(
            icon: Icon(Icons.more_vert),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. 캐릭터 프로필 (v1.1 - 80x80px, 컴팩트)
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Text(widget.characterEmoji, style: TextStyle(fontSize: 64)),  // v1.0: 80px → v1.1: 64px
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget.characterName, style: AppTextStyles.h2),
                    Text('온라인', style: AppTextStyles.caption.copyWith(color: AppColors.success)),
                  ],
                ),
              ],
            ),
          ),
          
          Divider(height: 0.5),
          
          // 2. 대화 영역
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';
                
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),  // v1.0: 12px → v1.1: 8px (컴팩트)
                  child: Row(
                    mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                        padding: EdgeInsets.all(12),  // v1.0: 16px → v1.1: 12px
                        decoration: BoxDecoration(
                          color: isUser ? AppColors.primaryBlue : AppColors.gray100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          message['content']!,
                          style: AppTextStyles.body.copyWith(  // v1.1: 14px
                            color: isUser ? Colors.white : AppColors.gray900,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          
          // 3. 음성 파형 (Lottie, v1.1 - 높이 60px, 컴팩트)
          if (isRecording)
            Container(
              height: 60,  // v1.0: 80px → v1.1: 60px
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Lottie.asset(
                'assets/lottie/voice_wave.json',
                fit: BoxFit.contain,
              ),
            ),
          
          // 4. 녹음 버튼 (v1.1 - 64x64px)
          Container(
            padding: EdgeInsets.all(20),
            color: Colors.white,
            child: GestureDetector(
              onTapDown: (_) {
                setState(() {
                  isRecording = true;
                });
                // 녹음 시작
              },
              onTapUp: (_) {
                setState(() {
                  isRecording = false;
                });
                // 녹음 종료
              },
              child: Container(
                width: 64,  // v1.0: 80px → v1.1: 64px
                height: 64,
                decoration: BoxDecoration(
                  color: isRecording ? AppColors.error : AppColors.primaryBlue,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: (isRecording ? AppColors.error : AppColors.primaryBlue).withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
```

## 완료 확인
- [ ] 캐릭터 선택 화면 구현 (2열 그리드, 140x180px)
- [ ] 검색 기능 구현 (SearchInput 사용)
- [ ] 음성 상담 화면 구현
- [ ] 녹음 버튼 애니메이션
- [ ] 말풍선 UI (v1.1 컴팩트)
- [ ] 실제 기기에서 테스트
```

---

#### Day 51: 아침 루틴 체크 화면 (컴팩트)

```markdown
# Day 51: 아침 루틴 체크 화면 (v1.1 컴팩트)

## 목표
F-ROUTINE-001 기능을 구현합니다 (v1.1 컴팩트 버전).

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 4.5
- PRD v1.2: F-ROUTINE-001

## v1.0 vs v1.1 비교

| 항목 | v1.0 | v1.1 | 변화 |
|------|------|------|------|
| 체크박스 | 32px | 24px | -8px |
| 항목 높이 | 56px | 40px | -16px |
| 간격 | 12px | 4px | -8px (더 좁게) |
| 입력 필드 | 56px | 44px | -12px |
| 프로그레스 바 | 8px | 6px | -2px (얇게) |

## 요구사항

### lib/screens/routine_check_screen.dart (v1.1 완전 재설계)

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/buttons/primary_button.dart';

class RoutineCheckScreen extends StatefulWidget {
  @override
  _RoutineCheckScreenState createState() => _RoutineCheckScreenState();
}

class _RoutineCheckScreenState extends State<RoutineCheckScreen> {
  // 8개 루틴 체크 상태
  Map<String, bool> routines = {
    '이불 정리': false,
    '물 한 컵 마시기': false,
    '5분 명상': false,
    '스트레칭': false,
    '감사 일기': false,
    '아침 산책': false,
    '비타민 복용': false,
    '오늘 계획 세우기': false,
  };
  
  // 컨디션
  int? moodScore;
  int? energyScore;
  
  // 입력
  TextEditingController goalController = TextEditingController();
  List<TextEditingController> scheduleControllers = List.generate(3, (_) => TextEditingController());
  List<TextEditingController> gratitudeControllers = List.generate(3, (_) => TextEditingController());

  @override
  Widget build(BuildContext context) {
    final completedCount = routines.values.where((v) => v).length;
    final progress = completedCount / routines.length;

    return Scaffold(
      appBar: AppBar(
        title: Text('아침 루틴 체크'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 진행률 (v1.1 - 얇은 프로그레스 바)
            Text('오늘의 루틴', style: AppTextStyles.h2),
            SizedBox(height: 8),
            
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 6,  // v1.0: 8px → v1.1: 6px
                      backgroundColor: AppColors.gray200,
                      valueColor: AlwaysStoppedAnimation(AppColors.primaryBlue),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  '$completedCount/8 완료',
                  style: AppTextStyles.bodySmall,
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // 2. 8개 체크박스 (v1.1 - 24px, 간격 4px)
            ...routines.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4),  // v1.0: 12px → v1.1: 4px (좁게)
                child: Container(
                  height: 40,  // v1.0: 56px → v1.1: 40px
                  decoration: BoxDecoration(
                    color: entry.value ? AppColors.primaryBlue.withOpacity(0.05) : Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: entry.value ? AppColors.primaryBlue : AppColors.gray200,
                      width: 1,
                    ),
                  ),
                  child: CheckboxListTile(
                    value: entry.value,
                    onChanged: (value) {
                      setState(() {
                        routines[entry.key] = value ?? false;
                      });
                    },
                    title: Text(
                      entry.key,
                      style: AppTextStyles.body.copyWith(  // 14px
                        decoration: entry.value ? TextDecoration.lineThrough : null,
                      ),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                    dense: true,  // 컴팩트
                  ),
                ),
              );
            }).toList(),
            
            SizedBox(height: 24),
            
            // 3. 컨디션 선택 (기분/에너지)
            Text('오늘의 컨디션', style: AppTextStyles.h3),
            SizedBox(height: 12),
            
            _buildConditionSelector(
              '기분',
              ['😞', '😕', '😐', '😊', '😄'],
              moodScore,
              (score) => setState(() => moodScore = score),
            ),
            SizedBox(height: 12),
            _buildConditionSelector(
              '에너지',
              ['🪫', '🔋', '🔋🔋', '🔋🔋🔋', '⚡'],
              energyScore,
              (score) => setState(() => energyScore = score),
            ),
            
            SizedBox(height: 24),
            
            // 4. 목표 (v1.1 - 높이 44px)
            Text('오늘의 목표', style: AppTextStyles.h3),
            SizedBox(height: 8),
            TextField(
              controller: goalController,
              decoration: InputDecoration(
                hintText: '오늘 꼭 이루고 싶은 한 가지',
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              maxLength: 100,
              style: AppTextStyles.body,  // 14px
            ),
            
            SizedBox(height: 24),
            
            // 5. 일정 3가지
            Text('오늘의 일정', style: AppTextStyles.h3),
            SizedBox(height: 8),
            ...List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: scheduleControllers[index],
                  decoration: InputDecoration(
                    hintText: '일정 ${index + 1}',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  maxLength: 50,
                  style: AppTextStyles.body,
                ),
              );
            }),
            
            SizedBox(height: 24),
            
            // 6. 감사 일기 3가지 (선택)
            Text('감사한 일 (선택)', style: AppTextStyles.h3),
            SizedBox(height: 8),
            ...List.generate(3, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: TextField(
                  controller: gratitudeControllers[index],
                  decoration: InputDecoration(
                    hintText: '감사한 일 ${index + 1}',
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                  maxLength: 50,
                  style: AppTextStyles.body,
                ),
              );
            }),
            
            SizedBox(height: 32),
            
            // 7. 저장 버튼
            PrimaryButton(
              text: '저장하기',
              onPressed: () {
                // API 호출
              },
            ),
          ],
        ),
      ),
    );
  }
  
  /// 컨디션 선택기 (5단계 이모지)
  Widget _buildConditionSelector(
    String label,
    List<String> emojis,
    int? selectedScore,
    Function(int) onSelect,
  ) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(label, style: AppTextStyles.body),
        ),
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final score = index + 1;
              final isSelected = selectedScore == score;
              
              return InkWell(
                onTap: () => onSelect(score),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryBlue.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryBlue : AppColors.gray200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    emojis[index],
                    style: TextStyle(fontSize: 24),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
```

## 완료 확인
- [ ] 8개 루틴 체크박스 구현 (v1.1 - 24px, 40px 높이)
- [ ] 진행률 프로그레스 바 (6px)
- [ ] 컨디션 선택 (기분/에너지 5단계)
- [ ] 목표 입력 (최대 100자)
- [ ] 일정 3가지 입력 (각 50자)
- [ ] 감사 일기 3가지 입력 (선택, 각 50자)
- [ ] 저장 버튼
- [ ] 스크롤 최소화 확인 (v1.1 컴팩트)
```

---

#### Day 52: 가족 프로필 & 구독 화면

```markdown
# Day 52: 가족 프로필 & 구독 화면 (v1.1)

## 목표
가족 프로필 관리 및 구독 플랜 화면을 구현합니다 (v1.1 컴팩트 버전).

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 4.6, 4.7
- PRD v1.2: F-USER-005, F-SUBS-001

## 요구사항

### 1. lib/screens/family_profile_screen.dart (v1.1 - 건강 점수 추가)

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/cards/compact_card.dart';

class FamilyProfileScreen extends StatelessWidget {
  final List<Map<String, dynamic>> familyMembers = [
    {
      'name': '아버지',
      'relationship': '부',
      'emoji': '👨',
      'health_score': 85,  // v1.1 신규
      'recent_consultations': 3,
    },
    {
      'name': '어머니',
      'relationship': '모',
      'emoji': '👩',
      'health_score': 78,
      'recent_consultations': 5,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('가족 프로필'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // 가족 추가 화면
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 가족 건강 요약 (v1.1 신규)
            Text('가족 건강 요약', style: AppTextStyles.h2),
            SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _buildSummaryCard('평균 건강 점수', '78', Colors.blue),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('최근 상담', '5건', Colors.green),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: _buildSummaryCard('주의 필요', '1명', Colors.orange),
                ),
              ],
            ),
            
            SizedBox(height: 24),
            
            // 가족 멤버 리스트
            Text('가족 멤버 (${familyMembers.length}/10)', style: AppTextStyles.h3),
            SizedBox(height: 12),
            
            ...familyMembers.map((member) {
              return Padding(
                padding: EdgeInsets.only(bottom: 8),  // v1.0: 12px → v1.1: 8px
                child: _buildFamilyCard(context, member),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
  
  /// 요약 카드 (v1.1 신규 - 3열)
  Widget _buildSummaryCard(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.caption,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
  
  /// 가족 카드 (v1.1 - 80px, 건강 점수 추가)
  Widget _buildFamilyCard(BuildContext context, Map<String, dynamic> member) {
    return CompactCard(
      onTap: () {
        // 가족 상세 화면
      },
      child: Row(
        children: [
          // 프로필 (v1.1 - 64px)
          Container(
            width: 64,  // v1.0: 80px → v1.1: 64px
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.gray100,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(member['emoji'], style: TextStyle(fontSize: 40)),
          ),
          SizedBox(width: 12),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(member['name'], style: AppTextStyles.h3),
                    SizedBox(width: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        member['relationship'],
                        style: TextStyle(fontSize: 10, color: AppColors.gray600),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 4),
                
                // 건강 점수 (v1.1 신규)
                Row(
                  children: [
                    Text('건강 점수: ', style: AppTextStyles.bodySmall),
                    Text(
                      '${member['health_score']}점',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: _getHealthScoreColor(member['health_score']),
                      ),
                    ),
                  ],
                ),
                
                Text(
                  '최근 상담 ${member['recent_consultations']}건',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          
          Icon(Icons.chevron_right, color: AppColors.gray400),
        ],
      ),
    );
  }
  
  Color _getHealthScoreColor(int score) {
    if (score >= 80) return AppColors.success;
    if (score >= 60) return AppColors.warning;
    return AppColors.error;
  }
}
```

### 2. lib/screens/subscription_screen.dart (v1.1 컴팩트)

```dart
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/buttons/primary_button.dart';

class SubscriptionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('구독 플랜'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // 현재 플랜
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primaryBlue),
              ),
              child: Row(
                children: [
                  Icon(Icons.star, color: AppColors.primaryBlue),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('현재 플랜', style: AppTextStyles.caption),
                        Text('Free 플랜', style: AppTextStyles.h3),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: Text('변경'),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 24),
            
            // Free 플랜
            _buildPlanCard(
              context,
              title: 'Free',
              price: '₩0',
              period: '무료',
              features: [
                '가족 프로필 1개',
                '무제한 음성 상담',
                '웨어러블 데이터 연동',
                '기본 건강 코칭',
              ],
              isCurrent: true,
            ),
            
            SizedBox(height: 12),
            
            // Premium 플랜 (v1.1 - 높이 200px, 컴팩트)
            _buildPlanCard(
              context,
              title: 'Premium',
              price: '₩9,900',
              period: '월 (33% 할인)',  // v1.1: 할인 강조
              originalPrice: '₩14,900',
              features: [
                '무제한 가족 프로필',
                '고급 건강 분석',
                '맞춤형 건강 리포트',
                '우선 응답',
              ],
              isRecommended: true,
            ),
          ],
        ),
      ),
    );
  }
  
  /// 플랜 카드 (v1.1 - 컴팩트, 200px)
  Widget _buildPlanCard(
    BuildContext context, {
    required String title,
    required String price,
    required String period,
    String? originalPrice,
    required List<String> features,
    bool isCurrent = false,
    bool isRecommended = false,
  }) {
    return Container(
      height: 200,  // v1.0: 280px → v1.1: 200px (-80px)
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRecommended ? AppColors.accentPurple : AppColors.gray200,
          width: isRecommended ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.h2),
                  if (originalPrice != null) ...[
                    Row(
                      children: [
                        Text(
                          originalPrice,
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.gray400,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        SizedBox(width: 4),
                        Text(
                          price,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.error,  // 할인가 빨강
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(price, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                  Text(period, style: AppTextStyles.caption),
                ],
              ),
              if (isRecommended)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accentPurple,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '추천',
                    style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
            ],
          ),
          
          SizedBox(height: 12),
          
          // 기능 (v1.1 - 간결하게 4개만)
          ...features.take(4).map((feature) {
            return Padding(
              padding: EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Icon(Icons.check_circle, size: 16, color: AppColors.success),
                  SizedBox(width: 8),
                  Text(feature, style: AppTextStyles.bodySmall),
                ],
              ),
            );
          }).toList(),
          
          Spacer(),
          
          // 버튼
          if (isCurrent)
            SizedBox(
              width: double.infinity,
              height: 40,
              child: OutlinedButton(
                onPressed: null,
                child: Text('현재 플랜', style: TextStyle(fontSize: 14)),
              ),
            )
          else
            SizedBox(
              width: double.infinity,
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  // 구독 시작
                },
                child: Text('구독하기', style: TextStyle(fontSize: 14)),
              ),
            ),
        ],
      ),
    );
  }
}
```

## 완료 확인
- [ ] 가족 프로필 화면 구현 (v1.1)
- [ ] 가족 건강 요약 (3열 미니 카드)
- [ ] 건강 점수 표시 (신규)
- [ ] 가족 카드 (80px → 64px)
- [ ] 구독 화면 구현 (v1.1)
- [ ] 플랜 카드 컴팩트 (200px)
- [ ] 할인 강조 (33%)
- [ ] 기능 비교표 간결화
```

---

### 🔹 Week 8: 배포 준비 (Day 53-56)

**Day 53-56은 기존 문서와 동일하게 유지 (생략)**

---

## 3. Phase 1.5: 아침 루틴 기능 (1주)

**Phase 1.5는 기존 문서와 동일하게 유지 (생략)**

---

## 4. Phase 2: 베타 테스트 (2주)

**Phase 2는 기존 문서와 동일하게 유지 (생략)**

---

## 5. Phase 3: 정식 출시

**Phase 3은 기존 문서와 동일하게 유지 (생략)**

---

## 6. Phase 4: 고도화 (6주)

**Phase 4는 기존 문서와 동일하게 유지 (생략)**

---

## 7. Phase 5: 확장 (6주)

**Phase 5는 기존 문서와 동일하게 유지 (생략)**

---

## 8. 부록: 유용한 프롬프트 템플릿

### 🎨 UI 구현 관련 프롬프트

```markdown
# UI 컴포넌트 구현 요청

다음 UI 컴포넌트를 UI/UX 디자인 가이드 v1.1에 따라 구현해줘:

## 컴포넌트 정보
- 컴포넌트 이름: [예: StatCard, AppChip]
- 참조: UI/UX 디자인 가이드 v1.1 섹션 [섹션 번호]

## 요구사항
1. v1.1 스펙 준수:
   - 폰트 크기 (H1 28px, Body 14px)
   - 컴포넌트 크기 (버튼 48px, 입력 44px)
   - 간격 (4px 그리드)
   - 색상 (Primary #2563EB)

2. 접근성:
   - 최소 터치 영역 44px
   - 색상 대비 4.5:1 이상
   - VoiceOver/TalkBack 지원

3. 애니메이션:
   - 빠른 반응 (80-200ms)
   - Curves.easeInOut

## 참조
- app_colors.dart (색상)
- app_text_styles.dart (폰트)
- 섹션 [번호] (구체적 스펙)

구현 후:
1. 코드 리뷰 (TRD 스펙 준수 확인)
2. 테스트 화면 생성
3. 스크린샷
```

---

### 🔧 UI 문제 해결 프롬프트

```markdown
# UI 문제 발생

다음 UI 문제를 해결해줘:

## 문제 설명
[문제 상세 설명]

## 기대 동작
UI/UX 디자인 가이드 v1.1에 따르면:
- [기대되는 동작]

## 현재 동작
- [실제 동작]

## 참조
- UI/UX 디자인 가이드 v1.1: 섹션 [번호]
- 파일: [문제가 발생한 파일]

해결 방법을 제안해줘:
1. 원인 분석
2. 3가지 해결 방법 (우선순위 순)
3. 권장 해결 방법 구현
```

---

### 📊 정보 밀도 확인 프롬프트

```markdown
# 정보 밀도 확인

현재 [화면 이름] 화면의 정보 밀도를 확인해줘:

## v1.1 기준
- 한 화면 최소 3개 이상 정보 섹션
- 카드 패딩 12px 이하
- 불필요한 여백 최소화
- 스크롤 최소화

## 현재 상태
[현재 화면 설명]

## 확인 사항
1. 첫 화면에 표시되는 정보 단위 개수
2. 카드 패딩 및 간격
3. 스크롤 필요 여부
4. v1.0 대비 정보 밀도 증가율

개선 방법을 제안해줘.
```

---

## 🎉 마무리

### UI/UX v1.1 핵심 변경사항 요약

| 항목 | v1.0 (40-60대) | v1.1 (20-50대) | 효과 |
|------|----------------|----------------|------|
| **타겟** | 40-60대 | 20-50대 | 더 넓은 시장 |
| **디자인 철학** | 신뢰 + 따뜻함 | 전문성 + 효율성 | 모던함 |
| **H1 폰트** | 32px | 28px | 정보 밀도↑ |
| **Body 폰트** | 16px | 14px | 정보 밀도↑ |
| **버튼 높이** | 56px | 48px | 컴팩트 |
| **카드 패딩** | 16px | 12px | 정보 밀도↑ |
| **홈 화면 정보** | 2개 | 7개 | **250%↑** |
| **Stat Card** | ❌ | ✅ | 핵심 지표 강조 |
| **칩(Chip)** | ❌ | ✅ | 태그/필터 |
| **통계 화면** | ❌ | ✅ | 데이터 중심 |
| **건강 점수** | ❌ | ✅ | 한눈에 파악 |
| **접근성** | WCAG AA | WCAG AA | 여전히 준수 |

### 성공 지표
- ✅ MVP 완성: 2026-01-20
- ✅ UI/UX v1.1 적용 (정보 밀도 2배)
- ✅ 접근성 WCAG 2.1 AA 준수
- ✅ 베타 테스트: 100명
- ✅ 정식 출시: 2026-02-12
- ✅ 6개월 후 MAU: 10,000명

---

**UI/UX v1.1이 완전히 통합된 개발 가이드 완성! 🚀**

**20-50대를 위한 정보 밀도 2배, 전문성과 효율성이 핵심입니다!**
