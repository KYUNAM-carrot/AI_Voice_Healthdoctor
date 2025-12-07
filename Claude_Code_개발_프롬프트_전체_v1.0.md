# 🎯 음성 AI 건강주치의 앱 - Claude Code 개발 가이드 (전체)

**버전:** 1.0  
**작성일:** 2025년 12월 5일  
**대상:** Claude Code를 사용하는 개발자  
**참조 문서:** PRD v1.2, TRD v1.2, AI캐릭터 가이드 v1.1, 개발 체크리스트 v1.2

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
다음 4개 문서를 먼저 읽고 완전히 이해해줘:

1. /mnt/user-data/outputs/음성AI건강주치의앱_PRD_v1.2.md
2. /mnt/user-data/outputs/음성AI건강주치의앱_TRD_v1.2.md
3. /mnt/user-data/outputs/AI캐릭터_시스템프롬프트_가이드_v1.1.md
4. /mnt/user-data/outputs/개발_체크리스트_v1.2.md

## 프로젝트 개요
- **목표:** 40-60대를 위한 가족 중심 음성 AI 건강 관리 앱
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
4. 준비 완료 선언: "Day 1부터 시작할 준비가 됐습니다!"
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

### 10. README.md

```markdown
# 음성 AI 건강주치의 앱 - Backend

40-60대를 위한 가족 중심 음성 AI 건강 관리 플랫폼의 백엔드 서비스입니다.

## 프로젝트 구조

- **Core API Service**: 인증, 사용자, 가족, 루틴, 구독 관리
- **Conversation Service**: OpenAI Realtime API 기반 음성 상담

## 기술 스택

- Python 3.11
- FastAPI
- PostgreSQL 15
- Redis 7
- OpenAI Realtime API
- Chroma DB

## 로컬 실행

### 사전 요구사항
- Docker & Docker Compose
- Python 3.11+

### 1. 환경 변수 설정
```bash
cp .env.example .env
# .env 파일 수정 (OPENAI_API_KEY 등)
```

### 2. Docker Compose 실행
```bash
docker-compose up -d
```

### 3. 데이터베이스 마이그레이션
```bash
docker-compose exec core_api alembic upgrade head
```

### 4. 초기 데이터 삽입
```bash
docker-compose exec core_api python scripts/seed_data.py
```

### 5. API 확인
- Core API: http://localhost:8000/docs
- Conversation API: http://localhost:8004/docs

## 테스트

```bash
docker-compose exec core_api pytest
```

## 참조 문서

- PRD v1.2
- TRD v1.2
- AI 캐릭터 프롬프트 가이드 v1.1
- 개발 체크리스트 v1.2

## 라이센스

Proprietary
```

## 완료 기준
- [ ] 모든 폴더 및 파일이 생성됨
- [ ] requirements.txt가 완성됨
- [ ] docker-compose.yml이 작동함
- [ ] README.md가 명확함
- [ ] .gitignore가 설정됨

## 테스트
```bash
cd /home/claude/healthai-backend
docker-compose up -d
docker-compose ps  # 3개 컨테이너 (postgres, redis, core_api) 실행 확인
curl http://localhost:8000/docs  # Swagger UI 확인
docker-compose logs core_api  # 로그 확인
docker-compose down
```

## 완료 보고
완료되면 다음을 보고해줘:
1. "Day 1-2 완료"
2. 생성된 파일 목록 (트리 구조)
3. docker-compose 실행 결과
4. 다음 단계 준비사항 (Day 3-4로 진행 가능 여부)
```

---

#### Day 3-4: 데이터베이스 설계

```markdown
# Day 3-4: 데이터베이스 설계 및 모델 생성

## 목표
TRD v1.2의 데이터베이스 스키마를 SQLAlchemy 모델로 구현합니다.

## 참조
- 개발_체크리스트_v1.2.md: Day 3-4
- TRD v1.2: 섹션 4 (전체 데이터베이스 설계)
- TRD v1.2: 섹션 4.2 (테이블 정의)

## 요구사항

### 1. core_api/database.py 작성

```python
from sqlalchemy import create_engine
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from core_api.config import settings

engine = create_engine(
    settings.DATABASE_URL,
    pool_pre_ping=True,
    pool_size=10,
    max_overflow=20
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)

Base = declarative_base()

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
```

### 2. SQLAlchemy 모델 생성

#### core_api/models/user.py
TRD 4.2.1 `users` 테이블을 정확히 구현:

```python
import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Enum, Date
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from core_api.database import Base
import enum

class SocialProvider(str, enum.Enum):
    KAKAO = "kakao"
    GOOGLE = "google"
    APPLE = "apple"

class Gender(str, enum.Enum):
    MALE = "male"
    FEMALE = "female"
    OTHER = "other"

class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    social_provider = Column(Enum(SocialProvider), nullable=False)
    social_id = Column(String(255), nullable=False, unique=True)
    email = Column(String(255), unique=True)
    name = Column(String(100), nullable=False)
    profile_image_url = Column(String(500))
    phone_number = Column(String(20))
    birth_date = Column(Date)
    gender = Column(Enum(Gender))
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime)
    
    # Relationships
    family_profiles = relationship("FamilyProfile", back_populates="user", cascade="all, delete-orphan")
    subscriptions = relationship("Subscription", back_populates="user", cascade="all, delete-orphan")
    conversations = relationship("Conversation", back_populates="user", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<User {self.name} ({self.email})>"
```

#### core_api/models/family.py
TRD 4.2.2 `family_profiles` 테이블:

```python
import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Enum, Date, ForeignKey, Text
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from core_api.database import Base
import enum

class Relationship(str, enum.Enum):
    SELF = "self"
    PARENT = "parent"
    SPOUSE = "spouse"
    CHILD = "child"
    SIBLING = "sibling"
    OTHER = "other"

class FamilyProfile(Base):
    __tablename__ = "family_profiles"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    name = Column(String(100), nullable=False)
    relationship = Column(Enum(Relationship), nullable=False)
    birth_date = Column(Date)
    gender = Column(Enum(Gender))
    profile_image_url = Column(String(500))
    
    # 건강 정보 (JSONB)
    # 형식: {"height": 175, "weight": 70, "blood_pressure": "120/80", ...}
    health_info = Column(JSONB)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    deleted_at = Column(DateTime)
    
    # Relationships
    user = relationship("User", back_populates="family_profiles")
    conversations = relationship("Conversation", back_populates="family_profile", cascade="all, delete-orphan")
    health_data = relationship("HealthData", back_populates="family_profile", cascade="all, delete-orphan")
    routine_check_records = relationship("RoutineCheckRecord", back_populates="family_profile", cascade="all, delete-orphan")
    routine_notification = relationship("RoutineNotification", back_populates="family_profile", uselist=False, cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<FamilyProfile {self.name} ({self.relationship})>"
```

#### core_api/models/conversation.py
TRD 4.2.3, 4.2.4 테이블:

```python
import uuid
from datetime import datetime
from sqlalchemy import Column, String, DateTime, Enum, ForeignKey, Integer, Text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from core_api.database import Base
import enum

class ConversationStatus(str, enum.Enum):
    ACTIVE = "active"
    COMPLETED = "completed"
    INTERRUPTED = "interrupted"

class MessageRole(str, enum.Enum):
    USER = "user"
    ASSISTANT = "assistant"

class Conversation(Base):
    __tablename__ = "conversations"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    family_profile_id = Column(UUID(as_uuid=True), ForeignKey("family_profiles.id", ondelete="SET NULL"))
    
    character_id = Column(String(50), nullable=False)
    session_id = Column(String(100), unique=True, nullable=False)
    status = Column(Enum(ConversationStatus), default=ConversationStatus.ACTIVE)
    
    started_at = Column(DateTime, default=datetime.utcnow)
    ended_at = Column(DateTime)
    duration_seconds = Column(Integer)
    
    audio_url = Column(Text)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="conversations")
    family_profile = relationship("FamilyProfile", back_populates="conversations")
    messages = relationship("ConversationMessage", back_populates="conversation", cascade="all, delete-orphan")
    
    def __repr__(self):
        return f"<Conversation {self.session_id} ({self.status})>"

class ConversationMessage(Base):
    __tablename__ = "conversation_messages"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    conversation_id = Column(UUID(as_uuid=True), ForeignKey("conversations.id", ondelete="CASCADE"), nullable=False)
    
    role = Column(Enum(MessageRole), nullable=False)
    content = Column(Text, nullable=False)
    audio_url = Column(Text)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    # Relationships
    conversation = relationship("Conversation", back_populates="messages")
    
    def __repr__(self):
        return f"<ConversationMessage {self.role}: {self.content[:50]}...>"
```

#### core_api/models/routine.py
TRD 4.2.12, 4.2.13, 4.2.14 테이블:

```python
import uuid
from datetime import datetime, time
from sqlalchemy import Column, String, Integer, Boolean, DateTime, Date, Time, ForeignKey, Text, UniqueConstraint
from sqlalchemy.dialects.postgresql import UUID, JSONB
from sqlalchemy.orm import relationship
from core_api.database import Base

class MorningRoutine(Base):
    __tablename__ = "morning_routines"
    
    id = Column(Integer, primary_key=True, autoincrement=True)
    name = Column(String(100), nullable=False)
    icon_emoji = Column(String(10), nullable=False)
    display_order = Column(Integer, nullable=False)
    is_active = Column(Boolean, default=True)
    
    def __repr__(self):
        return f"<MorningRoutine {self.name}>"

class RoutineCheckRecord(Base):
    __tablename__ = "routine_check_records"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    family_profile_id = Column(UUID(as_uuid=True), ForeignKey("family_profiles.id", ondelete="CASCADE"), nullable=False)
    
    check_date = Column(Date, nullable=False)
    
    # 루틴 체크 데이터 (JSONB)
    # 형식: [{"routine_id": 1, "checked": true, "checked_at": "2026-02-12T08:30:00Z"}, ...]
    routine_checks = Column(JSONB, nullable=False, default=list)
    
    # 컨디션
    mood = Column(Integer)  # 1-5
    energy_level = Column(Integer)  # 1-5
    
    # 목표 및 일정
    goal_of_day = Column(Text)
    
    # 일정 (JSONB)
    # 형식: [{"time": "10:00", "description": "팀 회의"}, ...]
    schedules = Column(JSONB, default=list)
    
    # 감사 일기 (JSONB)
    # 형식: ["햇살 좋은 날씨", "가족의 건강", "맛있는 아침식사"]
    gratitude_items = Column(JSONB, default=list)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    family_profile = relationship("FamilyProfile", back_populates="routine_check_records")
    
    __table_args__ = (
        UniqueConstraint('family_profile_id', 'check_date', name='uq_family_profile_check_date'),
    )
    
    def __repr__(self):
        return f"<RoutineCheckRecord {self.check_date}>"

class RoutineNotification(Base):
    __tablename__ = "routine_notifications"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    family_profile_id = Column(UUID(as_uuid=True), ForeignKey("family_profiles.id", ondelete="CASCADE"), nullable=False, unique=True)
    
    is_enabled = Column(Boolean, default=True)
    notification_time = Column(Time, default=time(8, 0))  # 08:00:00
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    family_profile = relationship("FamilyProfile", back_populates="routine_notification")
    
    def __repr__(self):
        return f"<RoutineNotification {self.notification_time}>"
```

#### core_api/models/subscription.py
TRD 4.2.6 테이블:

```python
import uuid
from datetime import datetime
from decimal import Decimal
from sqlalchemy import Column, String, DateTime, Enum, ForeignKey, DECIMAL
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from core_api.database import Base
import enum

class PlanType(str, enum.Enum):
    FREE = "free"
    BASIC = "basic"
    PREMIUM = "premium"
    FAMILY = "family"

class SubscriptionStatus(str, enum.Enum):
    ACTIVE = "active"
    CANCELLED = "cancelled"
    EXPIRED = "expired"
    TRIAL = "trial"

class BillingCycle(str, enum.Enum):
    MONTHLY = "monthly"
    YEARLY = "yearly"

class Subscription(Base):
    __tablename__ = "subscriptions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    plan_type = Column(Enum(PlanType), nullable=False, default=PlanType.FREE)
    status = Column(Enum(SubscriptionStatus), nullable=False, default=SubscriptionStatus.ACTIVE)
    
    price = Column(DECIMAL(10, 2), default=Decimal('0.00'))
    currency = Column(String(3), default="KRW")
    billing_cycle = Column(Enum(BillingCycle))
    
    started_at = Column(DateTime, default=datetime.utcnow)
    expires_at = Column(DateTime)
    cancelled_at = Column(DateTime)
    
    payment_method = Column(String(50))
    external_subscription_id = Column(String(255))  # RevenueCat ID
    
    created_at = Column(DateTime, default=datetime.utcnow)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow)
    
    # Relationships
    user = relationship("User", back_populates="subscriptions")
    
    def __repr__(self):
        return f"<Subscription {self.plan_type} ({self.status})>"
```

#### core_api/models/__init__.py

```python
from core_api.models.user import User, SocialProvider, Gender
from core_api.models.family import FamilyProfile, Relationship
from core_api.models.conversation import Conversation, ConversationMessage, ConversationStatus, MessageRole
from core_api.models.routine import MorningRoutine, RoutineCheckRecord, RoutineNotification
from core_api.models.subscription import Subscription, PlanType, SubscriptionStatus, BillingCycle

__all__ = [
    "User",
    "SocialProvider",
    "Gender",
    "FamilyProfile",
    "Relationship",
    "Conversation",
    "ConversationMessage",
    "ConversationStatus",
    "MessageRole",
    "MorningRoutine",
    "RoutineCheckRecord",
    "RoutineNotification",
    "Subscription",
    "PlanType",
    "SubscriptionStatus",
    "BillingCycle",
]
```

### 3. Alembic 설정

#### alembic/env.py

```python
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context
import os
import sys

# 프로젝트 루트를 sys.path에 추가
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from core_api.database import Base
from core_api.models import *  # 모든 모델 import

# Alembic Config 객체
config = context.config

# 환경 변수에서 DATABASE_URL 가져오기
database_url = os.getenv("DATABASE_URL", "postgresql://healthai:password@localhost:5432/healthai_db")
config.set_main_option("sqlalchemy.url", database_url)

# Logging 설정
if config.config_file_name is not None:
    fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline() -> None:
    url = config.get_main_option("sqlalchemy.url")
    context.configure(
        url=url,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online() -> None:
    connectable = engine_from_config(
        config.get_section(config.config_ini_section, {}),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
```

### 4. 초기 데이터 삽입 스크립트

#### scripts/seed_data.py

```python
#!/usr/bin/env python3
"""
초기 데이터 삽입 스크립트
- 8개 아침 루틴 항목 삽입
"""
import sys
import os

# 프로젝트 루트를 sys.path에 추가
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))

from core_api.database import SessionLocal, engine
from core_api.models import MorningRoutine, Base

def seed_morning_routines():
    """TRD 4.3.12의 8개 루틴 항목 삽입"""
    db = SessionLocal()
    
    try:
        # 기존 데이터 확인
        existing_count = db.query(MorningRoutine).count()
        if existing_count > 0:
            print(f"⚠️  아침 루틴 데이터가 이미 존재합니다 ({existing_count}개)")
            return
        
        routines = [
            {"name": "이불 정리", "icon_emoji": "🛏️", "display_order": 1},
            {"name": "공복에 물 마시기", "icon_emoji": "💧", "display_order": 2},
            {"name": "명상, 독서", "icon_emoji": "🧘", "display_order": 3},
            {"name": "한 동작 운동", "icon_emoji": "🏃", "display_order": 4},
            {"name": "차 마시기", "icon_emoji": "☕", "display_order": 5},
            {"name": "영양제 먹기", "icon_emoji": "💊", "display_order": 6},
            {"name": "모닝 러닝", "icon_emoji": "🏃‍♂️", "display_order": 7},
            {"name": "오늘 할 일 정리", "icon_emoji": "📝", "display_order": 8},
        ]
        
        for routine_data in routines:
            routine = MorningRoutine(**routine_data)
            db.add(routine)
        
        db.commit()
        print(f"✅ 아침 루틴 {len(routines)}개 항목 삽입 완료!")
        
        # 확인
        all_routines = db.query(MorningRoutine).order_by(MorningRoutine.display_order).all()
        for r in all_routines:
            print(f"   {r.id}. {r.icon_emoji} {r.name}")
    
    except Exception as e:
        print(f"❌ 오류 발생: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    print("🌱 초기 데이터 삽입 시작...")
    seed_morning_routines()
    print("✨ 완료!")
```

## 완료 기준
- [ ] 모든 모델이 TRD 스펙과 100% 일치
- [ ] 외래키 관계가 ERD와 일치
- [ ] Enum 타입이 정확히 정의됨
- [ ] Alembic 마이그레이션 생성 성공
- [ ] 초기 데이터 삽입 성공

## 테스트

```bash
# Docker Compose 실행
docker-compose up -d

# Alembic 마이그레이션 생성
docker-compose exec core_api alembic revision --autogenerate -m "Initial schema"

# 마이그레이션 적용
docker-compose exec core_api alembic upgrade head

# 초기 데이터 삽입
docker-compose exec core_api python scripts/seed_data.py

# PostgreSQL 접속 확인
docker-compose exec postgres psql -U healthai -d healthai_db

# SQL 명령어로 확인
\dt  # 테이블 목록
\d users  # users 테이블 스키마
\d family_profiles  # family_profiles 테이블 스키마
SELECT * FROM morning_routines;  # 루틴 데이터 확인

# 빠져나오기
\q
```

## 완료 보고
완료되면 다음을 보고해줘:
1. "Day 3-4 완료"
2. 생성된 테이블 목록 (9개 테이블)
3. morning_routines 데이터 확인 결과 (8개 항목)
4. ERD 관계 요약
5. 다음 단계 준비사항 (Day 5-8로 진행 가능 여부)
```

---

#### Day 5-8: 인증 시스템

```markdown
# Day 5-8: JWT 기반 소셜 로그인 인증 시스템

## 목표
카카오, 구글, 애플 소셜 로그인과 JWT 토큰 관리를 구현합니다.

## 참조
- 개발_체크리스트_v1.2.md: Day 5-8
- TRD v1.2: 섹션 5.1 (Auth Service API)
- TRD v1.2: 섹션 9.1 (인증 및 인가)

## 요구사항

### 1. core_api/config.py 설정

```python
from pydantic_settings import BaseSettings
from functools import lru_cache

class Settings(BaseSettings):
    # App
    APP_NAME: str = "HealthAI API"
    APP_VERSION: str = "1.0.0"
    ENVIRONMENT: str = "development"
    LOG_LEVEL: str = "info"
    
    # Database
    DATABASE_URL: str
    
    # Redis
    REDIS_URL: str
    
    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 14
    
    # OAuth - Kakao
    KAKAO_CLIENT_ID: str = ""
    KAKAO_CLIENT_SECRET: str = ""
    KAKAO_REDIRECT_URI: str = ""
    
    # OAuth - Google
    GOOGLE_CLIENT_ID: str = ""
    GOOGLE_CLIENT_SECRET: str = ""
    GOOGLE_REDIRECT_URI: str = ""
    
    # OAuth - Apple
    APPLE_CLIENT_ID: str = ""
    APPLE_TEAM_ID: str = ""
    APPLE_KEY_ID: str = ""
    APPLE_PRIVATE_KEY_PATH: str = ""
    
    # OpenAI
    OPENAI_API_KEY: str = ""
    
    class Config:
        env_file = ".env"
        case_sensitive = True

@lru_cache()
def get_settings() -> Settings:
    return Settings()

settings = get_settings()
```

### 2. core_api/schemas/auth.py

```python
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import datetime
from core_api.models.user import SocialProvider, Gender

class SocialLoginRequest(BaseModel):
    provider: SocialProvider
    access_token: str  # 소셜 로그인에서 받은 토큰
    
class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    expires_in: int  # seconds
    user_id: str
    is_new_user: bool  # 신규 가입 여부
    
class RefreshTokenRequest(BaseModel):
    refresh_token: str
    
class UserInfoResponse(BaseModel):
    id: str
    email: Optional[EmailStr]
    name: str
    profile_image_url: Optional[str]
    social_provider: SocialProvider
    created_at: datetime
    
    class Config:
        from_attributes = True
```

### 3. core_api/services/auth_service.py

```python
from datetime import datetime, timedelta
from typing import Optional, Dict, Any
from jose import JWTError, jwt
from sqlalchemy.orm import Session
import httpx

from core_api.config import settings
from core_api.models.user import User, SocialProvider
from core_api.schemas.auth import TokenResponse, UserInfoResponse

class AuthService:
    
    def __init__(self, db: Session):
        self.db = db
    
    def create_access_token(self, data: dict) -> str:
        """Access Token 생성 (30분)"""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
        to_encode.update({"exp": expire, "type": "access"})
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    
    def create_refresh_token(self, data: dict) -> str:
        """Refresh Token 생성 (14일)"""
        to_encode = data.copy()
        expire = datetime.utcnow() + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
        to_encode.update({"exp": expire, "type": "refresh"})
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)
    
    def verify_token(self, token: str, token_type: str = "access") -> Optional[Dict[str, Any]]:
        """토큰 검증"""
        try:
            payload = jwt.decode(token, settings.JWT_SECRET_KEY, algorithms=[settings.JWT_ALGORITHM])
            if payload.get("type") != token_type:
                return None
            return payload
        except JWTError:
            return None
    
    async def verify_kakao_token(self, access_token: str) -> Optional[Dict[str, Any]]:
        """카카오 토큰 검증 및 사용자 정보 가져오기"""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    "https://kapi.kakao.com/v2/user/me",
                    headers={"Authorization": f"Bearer {access_token}"}
                )
                
                if response.status_code != 200:
                    return None
                
                data = response.json()
                kakao_account = data.get("kakao_account", {})
                profile = kakao_account.get("profile", {})
                
                return {
                    "social_id": str(data.get("id")),
                    "email": kakao_account.get("email"),
                    "name": profile.get("nickname", "사용자"),
                    "profile_image_url": profile.get("profile_image_url"),
                }
            except Exception as e:
                print(f"Kakao token verification error: {e}")
                return None
    
    async def verify_google_token(self, access_token: str) -> Optional[Dict[str, Any]]:
        """구글 토큰 검증 및 사용자 정보 가져오기"""
        async with httpx.AsyncClient() as client:
            try:
                response = await client.get(
                    "https://www.googleapis.com/oauth2/v2/userinfo",
                    headers={"Authorization": f"Bearer {access_token}"}
                )
                
                if response.status_code != 200:
                    return None
                
                data = response.json()
                return {
                    "social_id": data.get("id"),
                    "email": data.get("email"),
                    "name": data.get("name", "사용자"),
                    "profile_image_url": data.get("picture"),
                }
            except Exception as e:
                print(f"Google token verification error: {e}")
                return None
    
    async def verify_apple_token(self, id_token: str) -> Optional[Dict[str, Any]]:
        """애플 ID 토큰 검증 및 사용자 정보 가져오기"""
        # Apple Sign In은 ID Token을 직접 파싱
        # 실제 구현에서는 Apple의 public key로 서명 검증 필요
        try:
            # 간단한 구현 (실제로는 서명 검증 필수)
            payload = jwt.decode(id_token, options={"verify_signature": False})
            
            return {
                "social_id": payload.get("sub"),
                "email": payload.get("email"),
                "name": "Apple 사용자",  # Apple은 이름을 제공하지 않을 수 있음
                "profile_image_url": None,
            }
        except Exception as e:
            print(f"Apple token verification error: {e}")
            return None
    
    async def social_login(self, provider: SocialProvider, access_token: str) -> TokenResponse:
        """소셜 로그인 처리"""
        
        # 1. 소셜 플랫폼에서 사용자 정보 가져오기
        if provider == SocialProvider.KAKAO:
            user_info = await self.verify_kakao_token(access_token)
        elif provider == SocialProvider.GOOGLE:
            user_info = await self.verify_google_token(access_token)
        elif provider == SocialProvider.APPLE:
            user_info = await self.verify_apple_token(access_token)
        else:
            raise ValueError(f"Unsupported provider: {provider}")
        
        if not user_info:
            raise ValueError("Invalid access token")
        
        # 2. 기존 사용자 확인 또는 신규 생성
        user = self.db.query(User).filter(
            User.social_provider == provider,
            User.social_id == user_info["social_id"]
        ).first()
        
        is_new_user = False
        
        if not user:
            # 신규 사용자 생성
            user = User(
                social_provider=provider,
                social_id=user_info["social_id"],
                email=user_info.get("email"),
                name=user_info["name"],
                profile_image_url=user_info.get("profile_image_url")
            )
            self.db.add(user)
            self.db.commit()
            self.db.refresh(user)
            is_new_user = True
        else:
            # 기존 사용자 정보 업데이트 (프로필 이미지 등)
            user.profile_image_url = user_info.get("profile_image_url")
            user.updated_at = datetime.utcnow()
            self.db.commit()
        
        # 3. JWT 토큰 생성
        token_data = {"sub": str(user.id), "email": user.email}
        access_token_jwt = self.create_access_token(token_data)
        refresh_token_jwt = self.create_refresh_token(token_data)
        
        return TokenResponse(
            access_token=access_token_jwt,
            refresh_token=refresh_token_jwt,
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user_id=str(user.id),
            is_new_user=is_new_user
        )
    
    def refresh_access_token(self, refresh_token: str) -> TokenResponse:
        """Refresh Token으로 Access Token 갱신"""
        payload = self.verify_token(refresh_token, token_type="refresh")
        if not payload:
            raise ValueError("Invalid refresh token")
        
        user_id = payload.get("sub")
        user = self.db.query(User).filter(User.id == user_id).first()
        
        if not user:
            raise ValueError("User not found")
        
        # 새로운 Access Token 생성
        token_data = {"sub": str(user.id), "email": user.email}
        access_token = self.create_access_token(token_data)
        
        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,  # Refresh Token은 재사용
            expires_in=settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60,
            user_id=str(user.id),
            is_new_user=False
        )
```

### 4. core_api/dependencies.py

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from sqlalchemy.orm import Session
from core_api.database import get_db
from core_api.services.auth_service import AuthService
from core_api.models.user import User

security = HTTPBearer()

def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(security),
    db: Session = Depends(get_db)
) -> User:
    """현재 로그인한 사용자 반환"""
    token = credentials.credentials
    
    auth_service = AuthService(db)
    payload = auth_service.verify_token(token, token_type="access")
    
    if not payload:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
            headers={"WWW-Authenticate": "Bearer"},
        )
    
    user_id = payload.get("sub")
    user = db.query(User).filter(User.id == user_id).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="User not found"
        )
    
    return user
```

### 5. core_api/routers/auth.py

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core_api.database import get_db
from core_api.schemas.auth import SocialLoginRequest, TokenResponse, RefreshTokenRequest, UserInfoResponse
from core_api.services.auth_service import AuthService
from core_api.dependencies import get_current_user
from core_api.models.user import User

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])

@router.post("/login/social", response_model=TokenResponse, status_code=status.HTTP_200_OK)
async def social_login(
    request: SocialLoginRequest,
    db: Session = Depends(get_db)
):
    """
    소셜 로그인 (카카오, 구글, 애플)
    
    - **provider**: 소셜 로그인 제공자 (kakao, google, apple)
    - **access_token**: 소셜 플랫폼에서 받은 access token
    
    반환:
    - JWT access_token (30분)
    - JWT refresh_token (14일)
    - is_new_user: 신규 가입 여부
    """
    auth_service = AuthService(db)
    
    try:
        token_response = await auth_service.social_login(
            provider=request.provider,
            access_token=request.access_token
        )
        return token_response
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )

@router.post("/refresh", response_model=TokenResponse)
def refresh_token(
    request: RefreshTokenRequest,
    db: Session = Depends(get_db)
):
    """
    Refresh Token으로 Access Token 갱신
    
    - **refresh_token**: JWT refresh token
    
    반환:
    - 새로운 access_token
    - 기존 refresh_token (재사용)
    """
    auth_service = AuthService(db)
    
    try:
        token_response = auth_service.refresh_access_token(request.refresh_token)
        return token_response
    except ValueError as e:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=str(e)
        )

@router.post("/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout(current_user: User = Depends(get_current_user)):
    """
    로그아웃
    
    실제로는 클라이언트에서 토큰을 삭제하면 됨.
    서버 측에서는 토큰 블랙리스트를 관리할 수도 있음 (향후 구현).
    """
    # 향후: Redis에 토큰 블랙리스트 추가
    return

@router.get("/me", response_model=UserInfoResponse)
def get_current_user_info(current_user: User = Depends(get_current_user)):
    """
    현재 로그인한 사용자 정보 조회
    """
    return current_user
```

### 6. core_api/main.py 업데이트

```python
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from core_api.routers import auth
from core_api.config import settings

app = FastAPI(
    title=settings.APP_NAME,
    version=settings.APP_VERSION,
    description="음성 AI 건강주치의 앱 - Core API"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # 프로덕션에서는 제한 필요
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Routers
app.include_router(auth.router)

@app.get("/health")
def health_check():
    return {"status": "healthy", "service": "core-api"}

@app.get("/")
def root():
    return {
        "message": "Welcome to HealthAI API",
        "version": settings.APP_VERSION,
        "docs": "/docs"
    }
```

### 7. tests/test_auth.py

```python
import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, AsyncMock
from core_api.main import app
from core_api.models.user import SocialProvider

client = TestClient(app)

@pytest.mark.asyncio
async def test_social_login_kakao_success():
    """카카오 소셜 로그인 성공 테스트"""
    
    mock_user_info = {
        "social_id": "123456789",
        "email": "test@kakao.com",
        "name": "테스터",
        "profile_image_url": "https://example.com/profile.jpg"
    }
    
    with patch("core_api.services.auth_service.AuthService.verify_kakao_token", new_callable=AsyncMock) as mock_verify:
        mock_verify.return_value = mock_user_info
        
        response = client.post(
            "/api/v1/auth/login/social",
            json={
                "provider": "kakao",
                "access_token": "fake_kakao_token"
            }
        )
        
        assert response.status_code == 200
        data = response.json()
        
        assert "access_token" in data
        assert "refresh_token" in data
        assert data["token_type"] == "bearer"
        assert data["is_new_user"] is True

@pytest.mark.asyncio
async def test_social_login_invalid_token():
    """잘못된 토큰으로 소셜 로그인 실패 테스트"""
    
    with patch("core_api.services.auth_service.AuthService.verify_kakao_token", new_callable=AsyncMock) as mock_verify:
        mock_verify.return_value = None
        
        response = client.post(
            "/api/v1/auth/login/social",
            json={
                "provider": "kakao",
                "access_token": "invalid_token"
            }
        )
        
        assert response.status_code == 401

def test_refresh_token_success():
    """Refresh Token으로 Access Token 갱신 성공"""
    
    # 먼저 로그인하여 토큰 받기 (mock 필요)
    # 그 다음 refresh 테스트
    # 실제 테스트에서는 fixture 사용
    
    pass

def test_get_current_user_with_valid_token():
    """유효한 토큰으로 사용자 정보 조회"""
    
    # 먼저 로그인하여 토큰 받기
    # 그 토큰으로 /me 호출
    
    pass
```

## 완료 기준
- [ ] 카카오, 구글, 애플 소셜 로그인 구현 완료
- [ ] JWT 토큰 생성/검증 로직 작동
- [ ] Refresh Token으로 Access Token 갱신 작동
- [ ] 토큰 만료 시 401 에러 반환
- [ ] 단위 테스트 작성 완료

## 테스트

```bash
# 테스트 실행
docker-compose exec core_api pytest tests/test_auth.py -v

# 수동 테스트 (Swagger UI)
# http://localhost:8000/docs 접속
# POST /api/v1/auth/login/social 테스트

# 카카오 토큰으로 테스트 (실제 카카오 Developer Console에서 토큰 받아야 함)
curl -X POST "http://localhost:8000/api/v1/auth/login/social" \
  -H "Content-Type: application/json" \
  -d '{
    "provider": "kakao",
    "access_token": "실제_카카오_토큰"
  }'
```

## 완료 보고
완료되면 다음을 보고해줘:
1. "Day 5-8 완료"
2. 구현된 API 엔드포인트 목록 (3개)
3. 테스트 결과
4. 다음 단계 준비사항 (Day 9-12로 진행 가능 여부)
```

---

### 🔹 Week 2: 사용자 & 가족 관리 (Day 9-16)

#### Day 9-12: 사용자 프로필 API

```markdown
# Day 9-12: 사용자 프로필 관리 API

## 목표
사용자 프로필 조회/수정 및 건강 정보 관리 API를 구현합니다.

## 참조
- 개발_체크리스트_v1.2.md: Day 9-12
- TRD v1.2: 섹션 5.2 (User Service API)
- TRD v1.2: 섹션 4.2.5 (health_data 테이블)

## 요구사항

### 1. core_api/schemas/user.py

```python
from pydantic import BaseModel, EmailStr
from typing import Optional
from datetime import date, datetime
from core_api.models.user import Gender

class UserProfileResponse(BaseModel):
    id: str
    email: Optional[EmailStr]
    name: str
    profile_image_url: Optional[str]
    phone_number: Optional[str]
    birth_date: Optional[date]
    gender: Optional[Gender]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class UpdateUserProfileRequest(BaseModel):
    name: Optional[str] = None
    phone_number: Optional[str] = None
    birth_date: Optional[date] = None
    gender: Optional[Gender] = None

class HealthInfoRequest(BaseModel):
    height: Optional[float] = None  # cm
    weight: Optional[float] = None  # kg
    blood_pressure_systolic: Optional[int] = None  # 수축기
    blood_pressure_diastolic: Optional[int] = None  # 이완기
    blood_sugar: Optional[float] = None  # mg/dL
    chronic_diseases: Optional[list[str]] = None  # ["고혈압", "당뇨"]
    medications: Optional[list[str]] = None  # ["메트포르민", "아스피린"]
    allergies: Optional[list[str]] = None  # ["페니실린", "땅콩"]

class HealthInfoResponse(BaseModel):
    height: Optional[float]
    weight: Optional[float]
    bmi: Optional[float]  # 계산 값
    blood_pressure: Optional[str]  # "120/80"
    blood_sugar: Optional[float]
    chronic_diseases: list[str]
    medications: list[str]
    allergies: list[str]
```

### 2. core_api/services/user_service.py

```python
from sqlalchemy.orm import Session
from typing import Optional
from core_api.models.user import User
from core_api.models.family import FamilyProfile, Relationship
from core_api.schemas.user import (
    UpdateUserProfileRequest,
    HealthInfoRequest,
    HealthInfoResponse
)
from datetime import datetime

class UserService:
    
    def __init__(self, db: Session):
        self.db = db
    
    def get_user_profile(self, user_id: str) -> User:
        """사용자 프로필 조회"""
        user = self.db.query(User).filter(User.id == user_id).first()
        if not user:
            raise ValueError("User not found")
        return user
    
    def update_user_profile(self, user_id: str, data: UpdateUserProfileRequest) -> User:
        """사용자 프로필 수정"""
        user = self.get_user_profile(user_id)
        
        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(user, key, value)
        
        user.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(user)
        
        return user
    
    def get_or_create_self_profile(self, user: User) -> FamilyProfile:
        """사용자의 본인(self) 프로필 가져오기 또는 생성"""
        self_profile = self.db.query(FamilyProfile).filter(
            FamilyProfile.user_id == user.id,
            FamilyProfile.relationship == Relationship.SELF
        ).first()
        
        if not self_profile:
            # 본인 프로필 자동 생성
            self_profile = FamilyProfile(
                user_id=user.id,
                name=user.name,
                relationship=Relationship.SELF,
                birth_date=user.birth_date,
                gender=user.gender,
                profile_image_url=user.profile_image_url,
                health_info={}
            )
            self.db.add(self_profile)
            self.db.commit()
            self.db.refresh(self_profile)
        
        return self_profile
    
    def update_health_info(self, user_id: str, data: HealthInfoRequest) -> HealthInfoResponse:
        """건강 정보 등록/수정"""
        user = self.get_user_profile(user_id)
        self_profile = self.get_or_create_self_profile(user)
        
        # 기존 health_info에 병합
        health_info = self_profile.health_info or {}
        
        if data.height is not None:
            health_info["height"] = data.height
        if data.weight is not None:
            health_info["weight"] = data.weight
        if data.blood_pressure_systolic is not None and data.blood_pressure_diastolic is not None:
            health_info["blood_pressure"] = f"{data.blood_pressure_systolic}/{data.blood_pressure_diastolic}"
        if data.blood_sugar is not None:
            health_info["blood_sugar"] = data.blood_sugar
        if data.chronic_diseases is not None:
            health_info["chronic_diseases"] = data.chronic_diseases
        if data.medications is not None:
            health_info["medications"] = data.medications
        if data.allergies is not None:
            health_info["allergies"] = data.allergies
        
        self_profile.health_info = health_info
        self_profile.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(self_profile)
        
        return self._build_health_info_response(health_info)
    
    def get_health_info(self, user_id: str) -> HealthInfoResponse:
        """건강 정보 조회"""
        user = self.get_user_profile(user_id)
        self_profile = self.get_or_create_self_profile(user)
        
        health_info = self_profile.health_info or {}
        return self._build_health_info_response(health_info)
    
    def _build_health_info_response(self, health_info: dict) -> HealthInfoResponse:
        """health_info dict를 Response 모델로 변환"""
        height = health_info.get("height")
        weight = health_info.get("weight")
        
        # BMI 계산
        bmi = None
        if height and weight:
            height_m = height / 100
            bmi = round(weight / (height_m ** 2), 1)
        
        return HealthInfoResponse(
            height=height,
            weight=weight,
            bmi=bmi,
            blood_pressure=health_info.get("blood_pressure"),
            blood_sugar=health_info.get("blood_sugar"),
            chronic_diseases=health_info.get("chronic_diseases", []),
            medications=health_info.get("medications", []),
            allergies=health_info.get("allergies", [])
        )
```

### 3. core_api/routers/users.py

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core_api.database import get_db
from core_api.dependencies import get_current_user
from core_api.models.user import User
from core_api.schemas.user import (
    UserProfileResponse,
    UpdateUserProfileRequest,
    HealthInfoRequest,
    HealthInfoResponse
)
from core_api.services.user_service import UserService

router = APIRouter(prefix="/api/v1/users", tags=["Users"])

@router.get("/me", response_model=UserProfileResponse)
def get_my_profile(
    current_user: User = Depends(get_current_user)
):
    """
    내 프로필 조회
    
    인증된 사용자 본인의 프로필 정보를 반환합니다.
    """
    return current_user

@router.put("/me", response_model=UserProfileResponse)
def update_my_profile(
    data: UpdateUserProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    내 프로필 수정
    
    - **name**: 이름 (선택)
    - **phone_number**: 전화번호 (선택)
    - **birth_date**: 생년월일 (선택, YYYY-MM-DD)
    - **gender**: 성별 (선택, male/female/other)
    """
    user_service = UserService(db)
    
    try:
        updated_user = user_service.update_user_profile(str(current_user.id), data)
        return updated_user
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

@router.post("/health-info", response_model=HealthInfoResponse)
def register_health_info(
    data: HealthInfoRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    건강 정보 등록/수정
    
    - **height**: 신장 (cm)
    - **weight**: 체중 (kg)
    - **blood_pressure_systolic**: 수축기 혈압
    - **blood_pressure_diastolic**: 이완기 혈압
    - **blood_sugar**: 혈당 (mg/dL)
    - **chronic_diseases**: 만성질환 목록
    - **medications**: 복용약물 목록
    - **allergies**: 알레르기 목록
    
    반환: BMI 자동 계산 포함
    """
    user_service = UserService(db)
    
    try:
        health_info = user_service.update_health_info(str(current_user.id), data)
        return health_info
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))

@router.get("/health-info", response_model=HealthInfoResponse)
def get_my_health_info(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    건강 정보 조회
    
    본인의 건강 정보를 조회합니다.
    """
    user_service = UserService(db)
    
    try:
        health_info = user_service.get_health_info(str(current_user.id))
        return health_info
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail=str(e))
```

### 4. core_api/main.py 업데이트

```python
from core_api.routers import auth, users

# ...

app.include_router(auth.router)
app.include_router(users.router)  # 추가
```

### 5. tests/test_users.py

```python
import pytest
from fastapi.testclient import TestClient
from core_api.main import app

client = TestClient(app)

def test_get_my_profile_without_auth():
    """인증 없이 프로필 조회 시 401 에러"""
    response = client.get("/api/v1/users/me")
    assert response.status_code == 401

def test_get_my_profile_with_auth(auth_token):
    """인증 후 프로필 조회 성공"""
    response = client.get(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "id" in data
    assert "email" in data

def test_update_profile(auth_token):
    """프로필 수정"""
    response = client.put(
        "/api/v1/users/me",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "name": "홍길동",
            "phone_number": "010-1234-5678",
            "birth_date": "1980-01-01",
            "gender": "male"
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "홍길동"

def test_register_health_info(auth_token):
    """건강 정보 등록"""
    response = client.post(
        "/api/v1/users/health-info",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "height": 175.0,
            "weight": 70.0,
            "blood_pressure_systolic": 120,
            "blood_pressure_diastolic": 80,
            "chronic_diseases": ["없음"],
            "medications": [],
            "allergies": []
        }
    )
    assert response.status_code == 200
    data = response.json()
    assert data["height"] == 175.0
    assert data["bmi"] == 22.9  # 자동 계산

def test_get_health_info(auth_token):
    """건강 정보 조회"""
    response = client.get(
        "/api/v1/users/health-info",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200
```

## 완료 기준
- [ ] 사용자 프로필 조회/수정 API 작동
- [ ] 건강 정보 등록/조회 API 작동
- [ ] BMI 자동 계산 로직 작동
- [ ] JWT 인증 미들웨어 적용
- [ ] 단위 테스트 통과

## 테스트

```bash
# 테스트 실행
docker-compose exec core_api pytest tests/test_users.py -v

# Swagger UI 테스트
# http://localhost:8000/docs
# 1. POST /api/v1/auth/login/social로 토큰 받기
# 2. Authorize 버튼으로 토큰 설정
# 3. GET /api/v1/users/me 테스트
# 4. PUT /api/v1/users/me 테스트
# 5. POST /api/v1/users/health-info 테스트
```

## 완료 보고
완료되면 다음을 보고해줘:
1. "Day 9-12 완료"
2. 구현된 API 엔드포인트 목록 (4개)
3. 테스트 결과
4. 다음 단계 준비사항 (Day 13-16로 진행 가능 여부)
```

---

#### Day 13-16: 가족 프로필 관리

```markdown
# Day 13-16: 가족 프로필 관리 API

## 목표
가족 프로필 CRUD와 구독 플랜별 제한 로직을 구현합니다.

## 참조
- 개발_체크리스트_v1.2.md: Day 13-16
- TRD v1.2: 섹션 5.3 (Family Service API)
- PRD v1.2: 섹션 4.2 (가족 프로필 관리)
- PRD v1.2: 섹션 6.1 (구독 플랜별 제한)

## 요구사항

### 1. core_api/schemas/family.py

```python
from pydantic import BaseModel
from typing import Optional, Dict, Any
from datetime import date, datetime
from core_api.models.family import Relationship
from core_api.models.user import Gender

class CreateFamilyProfileRequest(BaseModel):
    name: str
    relationship: Relationship
    birth_date: Optional[date] = None
    gender: Optional[Gender] = None
    profile_image_url: Optional[str] = None
    health_info: Optional[Dict[str, Any]] = None

class UpdateFamilyProfileRequest(BaseModel):
    name: Optional[str] = None
    birth_date: Optional[date] = None
    gender: Optional[Gender] = None
    profile_image_url: Optional[str] = None
    health_info: Optional[Dict[str, Any]] = None

class FamilyProfileResponse(BaseModel):
    id: str
    name: str
    relationship: Relationship
    birth_date: Optional[date]
    gender: Optional[Gender]
    profile_image_url: Optional[str]
    health_info: Optional[Dict[str, Any]]
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class FamilyProfileListResponse(BaseModel):
    total: int
    limit: int  # 구독 플랜에 따른 제한
    profiles: list[FamilyProfileResponse]
```

### 2. core_api/services/family_service.py

```python
from sqlalchemy.orm import Session
from typing import List
from fastapi import HTTPException, status

from core_api.models.user import User
from core_api.models.family import FamilyProfile, Relationship
from core_api.models.subscription import Subscription, PlanType
from core_api.schemas.family import (
    CreateFamilyProfileRequest,
    UpdateFamilyProfileRequest,
    FamilyProfileResponse
)
from datetime import datetime

class FamilyService:
    
    def __init__(self, db: Session):
        self.db = db
    
    def _get_subscription_limit(self, user: User) -> int:
        """사용자의 구독 플랜에 따른 가족 프로필 제한 수"""
        subscription = self.db.query(Subscription).filter(
            Subscription.user_id == user.id,
            Subscription.status == "active"
        ).first()
        
        if not subscription or subscription.plan_type == PlanType.FREE:
            # Free: 본인 + 1명 = 총 2명
            return 2
        else:
            # Basic, Premium, Family: 무제한 (실질적으로 100명)
            return 100
    
    def get_family_profiles(self, user: User) -> List[FamilyProfile]:
        """사용자의 가족 프로필 목록 조회"""
        profiles = self.db.query(FamilyProfile).filter(
            FamilyProfile.user_id == user.id,
            FamilyProfile.deleted_at.is_(None)
        ).order_by(
            # self를 먼저, 나머지는 생성일 순
            FamilyProfile.relationship == Relationship.SELF.desc(),
            FamilyProfile.created_at
        ).all()
        
        return profiles
    
    def get_family_profile(self, user: User, family_id: str) -> FamilyProfile:
        """특정 가족 프로필 조회"""
        profile = self.db.query(FamilyProfile).filter(
            FamilyProfile.id == family_id,
            FamilyProfile.user_id == user.id,
            FamilyProfile.deleted_at.is_(None)
        ).first()
        
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="Family profile not found"
            )
        
        return profile
    
    def create_family_profile(self, user: User, data: CreateFamilyProfileRequest) -> FamilyProfile:
        """가족 프로필 생성"""
        
        # 1. 구독 플랜 제한 확인
        existing_profiles = self.get_family_profiles(user)
        limit = self._get_subscription_limit(user)
        
        if len(existing_profiles) >= limit:
            raise HTTPException(
                status_code=status.HTTP_402_PAYMENT_REQUIRED,
                detail=f"Family profile limit reached. Upgrade to add more members. Current limit: {limit}"
            )
        
        # 2. self 프로필은 하나만 가능
        if data.relationship == Relationship.SELF:
            self_exists = any(p.relationship == Relationship.SELF for p in existing_profiles)
            if self_exists:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="Self profile already exists"
                )
        
        # 3. 프로필 생성
        profile = FamilyProfile(
            user_id=user.id,
            name=data.name,
            relationship=data.relationship,
            birth_date=data.birth_date,
            gender=data.gender,
            profile_image_url=data.profile_image_url,
            health_info=data.health_info or {}
        )
        
        self.db.add(profile)
        self.db.commit()
        self.db.refresh(profile)
        
        return profile
    
    def update_family_profile(
        self,
        user: User,
        family_id: str,
        data: UpdateFamilyProfileRequest
    ) -> FamilyProfile:
        """가족 프로필 수정"""
        profile = self.get_family_profile(user, family_id)
        
        update_data = data.model_dump(exclude_unset=True)
        for key, value in update_data.items():
            setattr(profile, key, value)
        
        profile.updated_at = datetime.utcnow()
        self.db.commit()
        self.db.refresh(profile)
        
        return profile
    
    def delete_family_profile(self, user: User, family_id: str) -> None:
        """가족 프로필 삭제 (소프트 삭제)"""
        profile = self.get_family_profile(user, family_id)
        
        # self 프로필은 삭제 불가
        if profile.relationship == Relationship.SELF:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Cannot delete self profile"
            )
        
        profile.deleted_at = datetime.utcnow()
        self.db.commit()
```

### 3. core_api/routers/families.py

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from core_api.database import get_db
from core_api.dependencies import get_current_user
from core_api.models.user import User
from core_api.schemas.family import (
    CreateFamilyProfileRequest,
    UpdateFamilyProfileRequest,
    FamilyProfileResponse,
    FamilyProfileListResponse
)
from core_api.services.family_service import FamilyService

router = APIRouter(prefix="/api/v1/families", tags=["Family"])

@router.post("", response_model=FamilyProfileResponse, status_code=status.HTTP_201_CREATED)
def create_family_profile(
    data: CreateFamilyProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    가족 프로필 생성
    
    구독 플랜에 따라 제한:
    - **Free**: 본인 + 1명 (총 2명)
    - **Basic/Premium/Family**: 무제한
    
    - **name**: 이름 (필수)
    - **relationship**: 관계 (필수, self/parent/spouse/child/sibling/other)
    - **birth_date**: 생년월일 (선택)
    - **gender**: 성별 (선택)
    - **profile_image_url**: 프로필 이미지 URL (선택)
    - **health_info**: 건강 정보 (선택, JSON)
    """
    family_service = FamilyService(db)
    
    try:
        profile = family_service.create_family_profile(current_user, data)
        return profile
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(e)
        )

@router.get("", response_model=FamilyProfileListResponse)
def get_family_profiles(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    가족 프로필 목록 조회
    
    본인(self) 프로필을 포함한 모든 가족 프로필을 반환합니다.
    """
    family_service = FamilyService(db)
    
    profiles = family_service.get_family_profiles(current_user)
    limit = family_service._get_subscription_limit(current_user)
    
    return FamilyProfileListResponse(
        total=len(profiles),
        limit=limit,
        profiles=profiles
    )

@router.get("/{family_id}", response_model=FamilyProfileResponse)
def get_family_profile(
    family_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    특정 가족 프로필 조회
    
    - **family_id**: 가족 프로필 ID
    """
    family_service = FamilyService(db)
    
    try:
        profile = family_service.get_family_profile(current_user, family_id)
        return profile
    except HTTPException:
        raise

@router.put("/{family_id}", response_model=FamilyProfileResponse)
def update_family_profile(
    family_id: str,
    data: UpdateFamilyProfileRequest,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    가족 프로필 수정
    
    - **family_id**: 가족 프로필 ID
    - **name**: 이름 (선택)
    - **birth_date**: 생년월일 (선택)
    - **gender**: 성별 (선택)
    - **profile_image_url**: 프로필 이미지 URL (선택)
    - **health_info**: 건강 정보 (선택, JSON)
    """
    family_service = FamilyService(db)
    
    try:
        profile = family_service.update_family_profile(current_user, family_id, data)
        return profile
    except HTTPException:
        raise

@router.delete("/{family_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_family_profile(
    family_id: str,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    가족 프로필 삭제 (소프트 삭제)
    
    - **family_id**: 가족 프로필 ID
    
    주의: self 프로필은 삭제할 수 없습니다.
    """
    family_service = FamilyService(db)
    
    try:
        family_service.delete_family_profile(current_user, family_id)
        return
    except HTTPException:
        raise
```

### 4. core_api/main.py 업데이트

```python
from core_api.routers import auth, users, families

# ...

app.include_router(auth.router)
app.include_router(users.router)
app.include_router(families.router)  # 추가
```

### 5. tests/test_families.py

```python
import pytest
from fastapi.testclient import TestClient
from core_api.main import app

client = TestClient(app)

def test_create_family_profile(auth_token):
    """가족 프로필 생성"""
    response = client.post(
        "/api/v1/families",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={
            "name": "홍어머니",
            "relationship": "parent",
            "birth_date": "1955-03-15",
            "gender": "female"
        }
    )
    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "홍어머니"
    assert data["relationship"] == "parent"

def test_create_family_profile_exceed_limit(auth_token_free):
    """Free 플랜 제한 초과 (3번째 프로필 생성 시 402)"""
    
    # 1번째 프로필 (본인은 자동 생성됨)
    # 2번째 프로필 생성
    client.post("/api/v1/families", headers={"Authorization": f"Bearer {auth_token_free}"}, json={"name": "가족1", "relationship": "parent"})
    
    # 3번째 프로필 생성 시 제한
    response = client.post(
        "/api/v1/families",
        headers={"Authorization": f"Bearer {auth_token_free}"},
        json={"name": "가족2", "relationship": "spouse"}
    )
    assert response.status_code == 402
    assert "limit reached" in response.json()["detail"].lower()

def test_get_family_profiles(auth_token):
    """가족 프로필 목록 조회"""
    response = client.get(
        "/api/v1/families",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200
    data = response.json()
    assert "total" in data
    assert "limit" in data
    assert "profiles" in data

def test_get_family_profile(auth_token, family_id):
    """특정 가족 프로필 조회"""
    response = client.get(
        f"/api/v1/families/{family_id}",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 200

def test_update_family_profile(auth_token, family_id):
    """가족 프로필 수정"""
    response = client.put(
        f"/api/v1/families/{family_id}",
        headers={"Authorization": f"Bearer {auth_token}"},
        json={"name": "홍어머니 (수정)"}
    )
    assert response.status_code == 200
    data = response.json()
    assert data["name"] == "홍어머니 (수정)"

def test_delete_family_profile(auth_token, family_id):
    """가족 프로필 삭제"""
    response = client.delete(
        f"/api/v1/families/{family_id}",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 204

def test_delete_self_profile_fail(auth_token, self_profile_id):
    """self 프로필 삭제 시도 (실패)"""
    response = client.delete(
        f"/api/v1/families/{self_profile_id}",
        headers={"Authorization": f"Bearer {auth_token}"}
    )
    assert response.status_code == 400
```

## 완료 기준
- [ ] 가족 프로필 CRUD API 작동
- [ ] 구독 플랜별 제한 로직 작동 (Free: 2명, 유료: 무제한)
- [ ] self 프로필은 삭제 불가
- [ ] 소프트 삭제 작동
- [ ] 단위 테스트 통과

## 테스트

```bash
# 테스트 실행
docker-compose exec core_api pytest tests/test_families.py -v

# Swagger UI 테스트
# http://localhost:8000/docs
# 1. 인증 후 POST /api/v1/families로 프로필 생성
# 2. GET /api/v1/families로 목록 조회
# 3. GET /api/v1/families/{family_id}로 특정 프로필 조회
# 4. PUT /api/v1/families/{family_id}로 수정
# 5. DELETE /api/v1/families/{family_id}로 삭제
```

## 완료 보고
완료되면 다음을 보고해줘:
1. "Day 13-16 완료"
2. 구현된 API 엔드포인트 목록 (5개)
3. 구독 플랜별 제한 로직 테스트 결과
4. 다음 단계 준비사항 (Day 17-25로 진행 가능 여부)
```

---

이렇게 계속 작성하면 너무 길어지므로, **나머지 Day들의 프롬프트를 요약된 형태로 작성**하겠습니다.

---

### 🔹 Week 3-4: 음성 상담 시스템 (Day 17-25)

```markdown
# Day 17-25: OpenAI Realtime API 음성 상담 시스템

[전체 내용은 앞서 작성한 Day 17-25 프롬프트 참조]

## 핵심 요구사항
1. conversation_service/main.py: WebSocket 엔드포인트
2. conversation_service/realtime.py: OpenAI Realtime API 클라이언트
3. conversation_service/characters.py: 10개 AI 캐릭터 프롬프트 로드
4. conversation_service/rag.py: Chroma DB RAG 시스템
5. Redis 세션 관리
6. TRD 섹션 6, 7 참조
7. AI캐릭터 가이드 전체 참조

## 완료 기준
- [ ] WebSocket 양방향 통신
- [ ] OpenAI Realtime API 연결
- [ ] 10개 캐릭터 각각 테스트
- [ ] RAG 시스템 작동
- [ ] conversation_messages 테이블에 저장
```

---

### 🔹 Week 4-5: 웨어러블 & 건강 데이터 (Day 26-34)

```markdown
# Day 26-29: 웨어러블 데이터 수집 (Apple HealthKit / Android Health Connect)

## 목표
Apple HealthKit과 Android Health Connect 연동 API 구현

## 참조
- TRD v1.2: 섹션 8 (웨어러블 연동)
- TRD v1.2: 섹션 5.5 (Wearable Service API)

## 핵심 요구사항
1. core_api/models/health_data.py 생성 (TRD 4.2.5 참조)
2. core_api/routers/wearables.py
   - POST /api/v1/wearables/sync (클라이언트에서 데이터 전송)
   - GET /api/v1/wearables/data (데이터 조회)
3. core_api/services/wearable_service.py
   - 데이터 검증 및 저장
   - 일별/주별/월별 통계 계산

## 데이터 타입 (TRD 8.2 참조)
- 걸음 수, 수면, 심박수, 혈압, 체중, 운동, 칼로리

---

# Day 30-34: 건강 코칭 알고리즘

## 목표
웨어러블 데이터 기반 AI 건강 코칭 로직

## 참조
- TRD v1.2: 섹션 7.4 (건강 코칭 알고리즘)

## 핵심 요구사항
1. core_api/services/coaching_service.py
   - analyze_health_trends(): 주간 건강 트렌드 분석
   - generate_coaching_message(): Claude API로 코칭 메시지 생성
2. 하루 1회 자동 분석 스케줄러 (향후 구현)
```

---

### 🔹 Week 6-7: 구독 & UI (Day 35-52)

```markdown
# Day 35-42: 구독 관리

## Backend (Day 35-38)
- core_api/routers/subscriptions.py
- RevenueCat Webhook 처리
- TRD 섹션 5.6 참조

## Frontend (Day 39-42)
- Flutter 구독 화면
- in_app_purchase, purchases_flutter 패키지
- Apple IAP, Google Play Billing

---

# Day 43-52: Flutter UI 개발

## Day 43-46: 기본 UI
- 스플래시, 온보딩, 로그인 화면
- Riverpod 상태 관리 설정

## Day 47-48: 홈 & 프로필
- 홈 화면 (오늘의 건강, 최근 상담)
- 프로필 설정 화면

## Day 49-52: 음성 상담 UI
- 캐릭터 선택 화면
- 음성 상담 화면 (WebSocket 연결)
- 오디오 녹음/재생
```

---

### 🔹 Week 8: 배포 준비 (Day 53-56)

```markdown
# Day 53-54: 통합 테스트

- 전체 API 엔드포인트 테스트
- 음성 상담 E2E 테스트
- 부하 테스트 (locust 또는 k6)

---

# Day 55-56: Fly.io 배포

## 참조
- TRD v1.2: 섹션 10 (인프라 및 배포)
- 개발_체크리스트_v1.2.md: Day 55-56

## 요구사항
1. Fly.io 계정 생성 및 CLI 설치
2. fly.core.toml, fly.conversation.toml 작성 (TRD 10.2 참조)
3. Fly.io Postgres 생성
4. Upstash Redis 연동
5. Fly.io Secrets 설정
6. GitHub Actions CI/CD 파이프라인
7. 테스트 배포 및 smoke test

## 배포 프로세스
```bash
# Fly.io 앱 생성
fly launch --config fly.core.toml --no-deploy
fly launch --config fly.conversation.toml --no-deploy

# Postgres 생성
fly postgres create --name healthai-db --region hkg

# Secrets 설정
fly secrets set OPENAI_API_KEY=sk-xxx DATABASE_URL=postgres://...

# 배포
fly deploy --config fly.core.toml
fly deploy --config fly.conversation.toml

# 마이그레이션
fly ssh console --app healthai-core-api
> alembic upgrade head
```

## 완료 기준
- [ ] Fly.io 배포 성공
- [ ] Core API 접속 가능
- [ ] Conversation Service WebSocket 작동
- [ ] GitHub Actions 자동 배포 작동
```

---

## 3. Phase 1.5: 아침 루틴 기능 (1주)

```markdown
# Phase 1.5: 아침 루틴 체크 기능 (Day 57-61)

## 목표
타이탄의 아침일기 앱 UI를 참고하여 아침 루틴 체크 기능 구현

## 참조
- PRD v1.2: F-ROUTINE-001 (대폭 보강된 섹션)
- TRD v1.2: 섹션 4.2.12~14 (루틴 테이블)
- TRD v1.2: 섹션 5.7 (Routine Service API)

## Backend (Day 57-59)
### Day 57-58: 데이터베이스 (이미 Day 3-4에서 완료됨)
- morning_routines, routine_check_records, routine_notifications 테이블

### Day 58-59: Routine API
- core_api/routers/routines.py (6개 엔드포인트)
  - GET /api/v1/routines/items
  - POST /api/v1/routines/check
  - GET /api/v1/routines/check/today
  - GET /api/v1/routines/stats/weekly
  - POST /api/v1/routines/notifications
  - GET /api/v1/routines/notifications

### Day 59-60: 알림 스케줄러
- FCM (Firebase Cloud Messaging) 통합
- 매일 설정 시간에 푸시 알림

## Frontend (Day 57-60)
### Day 57-58: 루틴 체크 화면 UI
- 타이탄 앱 참고
- 8개 체크박스 (이불 정리, 물 마시기, ...)
- 진행률 표시 (6/8 완료)
- 기분/에너지 선택 (5단계)
- 애니메이션 (체크 시)

### Day 58-59: 입력 필드
- 목표 1가지 (TextField, 최대 100자)
- 일정 3가지 (ListView, 각 최대 50자)
- 감사 일기 3가지 (선택, 각 최대 50자)
- 저장 버튼
- API 연동

### Day 59-60: 루틴 통계 화면
- 주간 달성률 차트 (fl_chart 패키지)
- 연속 달성일
- 가장 많이 완료한 루틴 TOP 3

### Day 60: 알림 설정
- 설정 화면 추가
- TimePicker (알림 시간 선택)
- ON/OFF 스위치
- FCM 토큰 등록

## 테스트 (Day 61)
- 통합 테스트: 루틴 체크 → 저장 → 통계
- 알림 수신 테스트 (iOS/Android)

## 완료 기준
- [ ] 8개 루틴 항목 체크 가능
- [ ] 오늘의 컨디션 입력 가능
- [ ] 목표/일정/감사 일기 입력 가능
- [ ] 주간 통계 화면 작동
- [ ] 알림 설정 및 수신 작동
```

---

## 4. Phase 2: 베타 테스트 (2주)

```markdown
# Phase 2: 베타 테스트 (2주, 2026-01-22 ~ 2026-02-04)

## 목표
100명 베타 테스터로 실제 사용 테스트 및 피드백 수집

## Week 1: 베타 배포 및 초기 테스트

### 준비사항
- [ ] 베타 테스터 100명 모집 (TestFlight, Google Play Internal Testing)
- [ ] Fly.io 프로덕션 환경 확인
- [ ] Sentry 오류 추적 활성화
- [ ] Firebase Analytics 설정
- [ ] 사용자 가이드 문서 작성

### 테스트 시나리오
1. **회원가입 및 로그인**
   - 카카오/구글/애플 소셜 로그인
   - 프로필 설정

2. **가족 프로필 관리**
   - 가족 프로필 추가 (Free 플랜 제한 확인)
   - 건강 정보 입력

3. **음성 상담**
   - 10개 캐릭터 각각 테스트
   - 음성 인식 정확도 확인
   - 응답 속도 확인 (목표: <500ms)

4. **아침 루틴 체크**
   - 루틴 체크 및 저장
   - 알림 수신 확인
   - 주간 통계 확인

5. **구독 관리**
   - 구독 플랜 변경 (Free → Premium)
   - 가족 프로필 제한 해제 확인

### 수집할 데이터
- 세션 길이, 음성 상담 횟수
- 에러 발생 빈도 (Sentry)
- 사용자 이탈 시점
- 평균 응답 시간
- 사용자 피드백 (설문 조사)

## Week 2: 버그 수정 및 최적화

### 주요 작업
- [ ] 버그 수정 (Sentry 기준 Critical/High)
- [ ] UI/UX 개선 (사용자 피드백 기준)
- [ ] 성능 최적화 (응답 속도, 메모리 사용량)
- [ ] 접근성 개선 (WCAG 2.1 AA 준수)
- [ ] 문서 업데이트

### 최종 점검
- [ ] 모든 Critical 버그 해결
- [ ] 평균 음성 응답 속도 <500ms
- [ ] 앱 크래시율 <1%
- [ ] NPS 점수 수집 (목표: >50)

## 완료 기준
- [ ] 100명 베타 테스트 완료
- [ ] 주요 버그 모두 수정
- [ ] 사용자 만족도 >85%
- [ ] 정식 출시 준비 완료
```

---

## 5. Phase 3: 정식 출시

```markdown
# Phase 3: 정식 출시 (2026-02-12)

## 출시 전 체크리스트

### Backend (Fly.io)
- [ ] Fly.io 프로덕션 환경 최종 확인
- [ ] PostgreSQL 백업 설정 (자동 스냅샷)
- [ ] Upstash Redis 안정성 확인
- [ ] Cloudflare R2 버킷 설정
- [ ] 커스텀 도메인 설정 (예: api.healthai.com)
- [ ] TLS/SSL 인증서 확인
- [ ] 최소 인스턴스 수 설정 (auto_stop_machines: false)
- [ ] API Rate Limiting 활성화
- [ ] Fly.io Metrics 대시보드 설정
- [ ] Sentry 오류 추적 최종 확인
- [ ] Slack 알림 연동

### Frontend
- [ ] App Store 제출 (iOS)
- [ ] Google Play 제출 (Android)
- [ ] 앱 스토어 스크린샷 (5-10장)
- [ ] 앱 설명 작성 (한국어, 영어)
- [ ] 개인정보 처리방침 웹페이지
- [ ] 이용약관 웹페이지
- [ ] 고객지원 이메일 설정

### 마케팅
- [ ] 랜딩 페이지 오픈
- [ ] 블로그 포스트 작성
- [ ] SNS 계정 생성 (인스타그램, 페이스북)
- [ ] 프레스킷 준비
- [ ] 출시 보도자료 배포

## 출시 당일 모니터링
- 실시간 에러 모니터링 (Sentry)
- 서버 상태 모니터링 (Fly.io Metrics)
- 사용자 유입 추적 (Firebase Analytics)
- 앱 스토어 리뷰 모니터링

## 출시 후 1주일
- 버그 긴급 패치
- 사용자 피드백 수집 및 대응
- 첫 주 통계 분석
  - 다운로드 수
  - DAU/MAU
  - 구독 전환율
  - 평균 세션 시간
```

---

## 6. Phase 4: 고도화 (6주)

```markdown
# Phase 4: 고도화 (2026-02-13 ~ 2026-03-26)

## Week 1-2: 건강 리포트 자동 생성

### 목표
주간/월간 건강 리포트를 AI가 자동 생성

### 요구사항
- core_api/services/report_service.py
- Claude API로 리포트 생성
- 웨어러블 데이터 + 상담 이력 분석
- PDF 또는 이미지로 생성
- 이메일 또는 앱 푸시로 전송

---

## Week 3-4: 건강 목표 설정 및 추적

### 목표
사용자가 건강 목표를 설정하고 진행률 추적

### 예시
- "한 달 동안 5kg 감량"
- "매일 만보 걷기"
- "혈당 120 이하 유지"

### 요구사항
- core_api/models/health_goal.py
- core_api/routers/goals.py
- Flutter UI: 목표 설정 화면, 진행률 차트

---

## Week 5-6: 가족 공유 기능 (선택적)

### 목표
가족 구성원끼리 건강 데이터 선택적 공유

### 요구사항
- 공유 설정 (어떤 데이터를 누구에게)
- 푸시 알림 (가족의 건강 이상 시)
- 가족 대시보드
```

---

## 7. Phase 5: 확장 (6주)

```markdown
# Phase 5: 확장 (2026-03-27 ~ 2026-05-07)

## Week 1-2: 캐릭터 확장 (6명 → 20명)

### 새로운 캐릭터
- 치과 전문의
- 안과 전문의
- 정형외과 전문의
- 재활의학과 전문의
- 한의사
- 등등 10개 추가

### 요구사항
- AI캐릭터 프롬프트 작성 (10개)
- conversation_service 업데이트

---

## Week 3-4: 커뮤니티 기능

### 목표
사용자 간 건강 정보 공유 커뮤니티

### 요구사항
- 게시판 (질문, 팁, 성공 사례)
- 댓글, 좋아요
- 커뮤니티 가이드라인 AI 검수

---

## Week 5-6: 다국어 지원

### 목표
글로벌 확장을 위한 영어, 일본어 지원

### 요구사항
- 앱 UI 다국어화 (Flutter intl)
- AI 캐릭터 영어/일본어 프롬프트
- 번역 API 연동 (DeepL 또는 Google Translate)
```

---

## 8. 부록: 유용한 프롬프트 템플릿

### 🔧 문제 해결 프롬프트

```markdown
# 문제 발생 시

문제가 발생했어. 다음을 확인해줘:

1. 에러 메시지 전체를 보여줘
2. 어떤 파일에서 발생했는지 확인해줘
3. TRD v1.2의 관련 섹션을 다시 읽고 스펙과 일치하는지 확인해줘
4. 3가지 해결 방법을 제안해줘 (우선순위 순)
5. 가장 좋은 방법을 선택하고 구현해줘
```

---

### 📊 진행 상황 확인 프롬프트

```markdown
# Day X-Y 완료 확인

Day X-Y 작업이 완료됐어?

다음을 확인해줘:
1. 개발_체크리스트_v1.2.md의 Day X-Y 모든 항목 완료 여부
2. 단위 테스트 통과 여부
3. 로컬에서 실행 테스트 결과
4. API 문서 (Swagger UI) 업데이트 여부

## 완료 보고서 작성
- ✅ 완료된 작업 목록
- 📁 생성된 파일 목록
- 🧪 테스트 결과 요약
- ⚠️ 발견된 이슈 (있다면)
- ✨ 다음 단계 준비사항
```

---

### 🧪 테스트 프롬프트

```markdown
# 통합 테스트 실행

다음 시나리오를 전부 테스트해줘:

1. **사용자 플로우**
   - 소셜 로그인 (카카오)
   - 프로필 수정
   - 건강 정보 등록

2. **가족 관리 플로우**
   - 가족 프로필 생성 (부모님)
   - 가족 프로필 조회
   - 건강 정보 등록

3. **음성 상담 플로우**
   - 캐릭터 선택 (김영훈)
   - WebSocket 연결
   - 음성 메시지 전송
   - 응답 수신

4. **루틴 플로우**
   - 오늘의 루틴 체크
   - 저장
   - 통계 조회

각 테스트마다 결과를 보고해줘:
- ✅ 성공
- ❌ 실패 (에러 메시지 포함)
```

---

### 🚀 배포 프롬프트

```markdown
# Fly.io 배포

다음 순서로 Fly.io 배포를 진행해줘:

1. **사전 점검**
   - 모든 테스트 통과 확인
   - .env 파일 확인
   - fly.core.toml, fly.conversation.toml 확인

2. **배포 실행**
   ```bash
   fly deploy --config fly.core.toml
   fly deploy --config fly.conversation.toml
   ```

3. **배포 후 확인**
   - fly status --app healthai-core-api
   - fly logs --app healthai-core-api
   - curl https://healthai-core-api.fly.dev/health

4. **마이그레이션**
   ```bash
   fly ssh console --app healthai-core-api
   alembic upgrade head
   ```

5. **Smoke Test**
   - /health 엔드포인트
   - POST /api/v1/auth/login/social (테스트 토큰)
   - GET /api/v1/users/me

각 단계마다 결과를 보고해줘.
```

---

### 📝 코드 리뷰 프롬프트

```markdown
# 코드 리뷰 요청

방금 작성한 코드를 리뷰해줘:

## 체크리스트
1. **TRD 스펙 준수**
   - TRD v1.2와 100% 일치하는지 확인

2. **코드 품질**
   - PEP 8 (Python) 준수
   - 타입 힌트 사용
   - Docstring 작성

3. **보안**
   - SQL Injection 방지 (ORM 사용)
   - JWT 토큰 검증
   - 민감 정보 노출 방지

4. **성능**
   - N+1 쿼리 문제
   - 불필요한 DB 호출
   - 캐싱 가능 여부

5. **테스트**
   - 단위 테스트 커버리지
   - Edge case 처리

개선이 필요한 부분이 있다면 구체적으로 제안해줘.
```

---

### 🎯 다음 단계 준비 프롬프트

```markdown
# 다음 단계 준비

Day X-Y가 완료됐으니 Day Z로 넘어갈 준비를 하자.

1. **현재 상태 정리**
   - 완료된 기능 목록
   - API 엔드포인트 목록
   - 테스트 커버리지

2. **다음 단계 확인**
   - 개발_체크리스트_v1.2.md의 Day Z 읽기
   - 필요한 파일 목록
   - 참조해야 할 TRD 섹션

3. **준비 사항**
   - 새로운 패키지 설치 필요 여부
   - DB 스키마 변경 필요 여부
   - 외부 API 연동 필요 여부

4. **시작 선언**
   - "Day Z 시작 준비 완료!"
```

---

## 🎉 마무리

이 프롬프트 가이드를 사용하여 Claude Code와 함께 **음성 AI 건강주치의 앱**을 단계별로 개발하세요!

### 핵심 원칙
1. **문서 우선**: 항상 PRD, TRD, 체크리스트 참조
2. **한 번에 한 Day**: 욕심내지 말고 순서대로
3. **테스트 필수**: 코드 작성 후 반드시 테스트
4. **피드백 루프**: 완료 → 확인 → 다음 단계

### 예상 타임라인
- **Phase 1 (MVP)**: 8주 (56일)
- **Phase 1.5 (루틴)**: 1주 (5일)
- **Phase 2 (베타)**: 2주
- **Phase 3 (출시)**: 2026-02-12
- **Phase 4 (고도화)**: 6주
- **Phase 5 (확장)**: 6주

### 성공 지표
- ✅ MVP 완성: 2026-01-20
- ✅ 베타 테스트: 100명
- ✅ 정식 출시: 2026-02-12
- ✅ 6개월 후 MAU: 10,000명

---

**행운을 빕니다! 🚀**
