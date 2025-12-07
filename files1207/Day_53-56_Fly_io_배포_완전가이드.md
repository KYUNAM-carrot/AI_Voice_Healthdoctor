# Day 53-56: Fly.io 배포 완전 가이드

## 📋 개요

이 섹션은 Claude Code 개발 프롬프트 v1.3의 **Day 53-56: Fly.io 배포 및 인프라 설정** 부분입니다.

**참조 문서:**
- 개발_체크리스트_v1.3.md: Day 53-56 (Lines 417-445)
- TRD v1.3: 섹션 2 (아키텍처), 섹션 3.1 (Fly.io 홍콩 리전)
- PRD v1.3: 섹션 2.2 (비용 최적화 $20/월)

---

## Day 53-54: Fly.io 인프라 설정

### 목표
Fly.io에 Core API 및 Conversation Service를 배포합니다.

### Claude Code 프롬프트

```markdown
# Day 53-54: Fly.io 인프라 설정

## 목표
Fly.io Hong Kong 리전에 2개 서비스를 배포하고 PostgreSQL, Redis를 설정합니다.

## 사전 준비

### 1. Fly.io CLI 설치

```bash
# macOS
brew install flyctl

# Linux
curl -L https://fly.io/install.sh | sh

# Windows
powershell -Command "iwr https://fly.io/install.ps1 -useb | iex"

# 로그인
flyctl auth login

# 확인
flyctl version
```

### 2. 프로젝트 구조 확인

```
voice-ai-health-doctor/
├── core_api/           # Core API 서비스
│   ├── Dockerfile
│   ├── fly.toml
│   └── ...
├── conversation_service/  # Conversation Service
│   ├── Dockerfile
│   ├── fly.toml
│   └── ...
└── docker-compose.yml
```

## 1. Core API Dockerfile 작성

```dockerfile
# core_api/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 8000

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8000/health')"

# 실행
CMD ["uvicorn", "core_api.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## 2. Core API fly.toml 작성

```toml
# core_api/fly.toml
app = "voice-ai-core-api"
primary_region = "hkg"  # Hong Kong

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "8000"
  ENVIRONMENT = "production"

[http_service]
  internal_port = 8000
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1
  processes = ["app"]

  [http_service.concurrency]
    type = "requests"
    hard_limit = 250
    soft_limit = 200

[[services]]
  internal_port = 8000
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

  [[services.tcp_checks]]
    interval = "15s"
    timeout = "2s"
    grace_period = "5s"

  [[services.http_checks]]
    interval = "30s"
    timeout = "5s"
    grace_period = "10s"
    method = "get"
    path = "/health"
    protocol = "http"

[mounts]
  source = "core_api_data"
  destination = "/data"

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 512
```

## 3. Conversation Service Dockerfile 작성

```dockerfile
# conversation_service/Dockerfile
FROM python:3.11-slim

WORKDIR /app

# 시스템 패키지 설치
RUN apt-get update && apt-get install -y \
    && rm -rf /var/lib/apt/lists/*

# Python 의존성 설치
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# 애플리케이션 코드 복사
COPY . .

# 포트 노출
EXPOSE 8001

# 헬스체크
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD python -c "import requests; requests.get('http://localhost:8001/health')"

# 실행
CMD ["uvicorn", "conversation_service.main:app", "--host", "0.0.0.0", "--port", "8001"]
```

## 4. Conversation Service fly.toml 작성

```toml
# conversation_service/fly.toml
app = "voice-ai-conversation"
primary_region = "hkg"  # Hong Kong

[build]
  dockerfile = "Dockerfile"

[env]
  PORT = "8001"
  ENVIRONMENT = "production"

[http_service]
  internal_port = 8001
  force_https = true
  auto_stop_machines = true
  auto_start_machines = true
  min_machines_running = 1
  processes = ["app"]

  [http_service.concurrency]
    type = "connections"
    hard_limit = 100
    soft_limit = 80

[[services]]
  internal_port = 8001
  protocol = "tcp"

  [[services.ports]]
    handlers = ["http"]
    port = 80

  [[services.ports]]
    handlers = ["tls", "http"]
    port = 443

  [[services.tcp_checks]]
    interval = "15s"
    timeout = "2s"
    grace_period = "5s"

  [[services.http_checks]]
    interval = "30s"
    timeout = "5s"
    grace_period = "10s"
    method = "get"
    path = "/health"
    protocol = "http"

[[vm]]
  cpu_kind = "shared"
  cpus = 1
  memory_mb = 512
```

## 5. PostgreSQL 설정

```bash
# PostgreSQL 앱 생성 (홍콩 리전)
flyctl postgres create \
  --name voice-ai-db \
  --region hkg \
  --vm-size shared-cpu-1x \
  --volume-size 10

# Core API와 연결
flyctl postgres attach voice-ai-db -a voice-ai-core-api

# 연결 정보 확인
flyctl postgres connect -a voice-ai-db
```

## 6. Redis 설정

```bash
# Upstash Redis 사용 (Fly.io 통합)
flyctl redis create \
  --name voice-ai-redis \
  --region hkg \
  --plan free

# 또는 외부 Upstash Redis
# 1. https://upstash.com 가입
# 2. 홍콩 리전 Redis 생성
# 3. 연결 URL 복사

# 환경 변수 설정
flyctl secrets set REDIS_URL="redis://..." -a voice-ai-core-api
flyctl secrets set REDIS_URL="redis://..." -a voice-ai-conversation
```

## 7. 환경 변수 설정

```bash
# Core API 환경 변수
flyctl secrets set \
  DATABASE_URL="postgresql://..." \
  SECRET_KEY="your-secret-key" \
  OPENAI_API_KEY="sk-..." \
  KAKAO_CLIENT_ID="..." \
  GOOGLE_CLIENT_ID="..." \
  APPLE_CLIENT_ID="..." \
  CLOUDFLARE_ACCOUNT_ID="..." \
  CLOUDFLARE_ACCESS_KEY="..." \
  CLOUDFLARE_SECRET_KEY="..." \
  -a voice-ai-core-api

# Conversation Service 환경 변수
flyctl secrets set \
  OPENAI_API_KEY="sk-..." \
  REDIS_URL="redis://..." \
  CORE_API_URL="https://voice-ai-core-api.fly.dev" \
  -a voice-ai-conversation
```

## 8. 배포

```bash
# Core API 배포
cd core_api
flyctl deploy

# Conversation Service 배포
cd ../conversation_service
flyctl deploy

# 배포 상태 확인
flyctl status -a voice-ai-core-api
flyctl status -a voice-ai-conversation

# 로그 확인
flyctl logs -a voice-ai-core-api
flyctl logs -a voice-ai-conversation
```

## 9. 마이그레이션 실행

```bash
# Core API 마이그레이션
flyctl ssh console -a voice-ai-core-api
> alembic upgrade head
> exit

# 확인
flyctl ssh console -a voice-ai-core-api
> psql $DATABASE_URL -c "SELECT tablename FROM pg_tables WHERE schemaname='public';"
```

## 완료 기준
- [ ] Fly.io CLI 설치
- [ ] Core API Dockerfile 작성
- [ ] Core API fly.toml 작성
- [ ] Conversation Service Dockerfile 작성
- [ ] Conversation Service fly.toml 작성
- [ ] PostgreSQL 생성 및 연결
- [ ] Redis 생성 및 연결
- [ ] 환경 변수 설정
- [ ] 배포 성공
- [ ] 마이그레이션 실행
- [ ] Health Check 통과

## 테스트
```bash
# Health Check
curl https://voice-ai-core-api.fly.dev/health
curl https://voice-ai-conversation.fly.dev/health

# API 테스트
curl https://voice-ai-core-api.fly.dev/api/v1/characters

# WebSocket 테스트 (wscat 사용)
wscat -c wss://voice-ai-conversation.fly.dev/ws/conversations/park_jihoon
```

## 비용 확인
```bash
# 사용량 확인
flyctl dashboard

# 예상 비용: $20/월
- Core API: $5/월 (512MB RAM, shared CPU)
- Conversation Service: $5/월 (512MB RAM, shared CPU)
- PostgreSQL: $0/월 (10GB, Hobby plan)
- Redis: $5/월 (Upstash 250MB)
- 트래픽: $5/월 (예상)
```

## 보고서 작성
Day 53-54 완료 후 다음을 보고해줘:
1. 배포된 앱 URL
2. PostgreSQL 연결 정보
3. Redis 연결 정보
4. Health Check 결과
5. 비용 확인
6. 다음 단계 준비 상태

완료했으면 "Day 53-54 완료 보고서"를 작성해줘.
```

---

## Day 55-56: CI/CD & 모니터링

### 목표
GitHub Actions를 통한 자동 배포 및 모니터링을 설정합니다.

### Claude Code 프롬프트

```markdown
# Day 55-56: CI/CD & 모니터링

## 목표
GitHub Actions로 자동 배포를 구성하고 모니터링을 설정합니다.

## 1. .github/workflows/deploy-core-api.yml 작성

```yaml
name: Deploy Core API

on:
  push:
    branches:
      - main
    paths:
      - 'core_api/**'
      - '.github/workflows/deploy-core-api.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd core_api
          pip install -r requirements.txt
      
      - name: Run tests
        run: |
          cd core_api
          pytest tests/ -v
      
      - name: Setup Fly.io
        uses: superfly/flyctl-actions/setup-flyctl@master
      
      - name: Deploy to Fly.io
        run: |
          cd core_api
          flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
      
      - name: Health Check
        run: |
          sleep 30
          curl -f https://voice-ai-core-api.fly.dev/health || exit 1
      
      - name: Notify Slack (Success)
        if: success()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
          payload: |
            {
              "text": "✅ Core API 배포 성공",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Core API 배포 완료*\n배포 시간: $(date)"
                  }
                }
              ]
            }
      
      - name: Notify Slack (Failure)
        if: failure()
        uses: slackapi/slack-github-action@v1
        with:
          webhook-url: ${{ secrets.SLACK_WEBHOOK_URL }}
          payload: |
            {
              "text": "❌ Core API 배포 실패",
              "blocks": [
                {
                  "type": "section",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Core API 배포 실패*\n로그 확인 필요"
                  }
                }
              ]
            }
```

## 2. .github/workflows/deploy-conversation.yml 작성

```yaml
name: Deploy Conversation Service

on:
  push:
    branches:
      - main
    paths:
      - 'conversation_service/**'
      - '.github/workflows/deploy-conversation.yml'

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
      - uses: actions/checkout@v3
      
      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      
      - name: Install dependencies
        run: |
          cd conversation_service
          pip install -r requirements.txt
      
      - name: Run tests
        run: |
          cd conversation_service
          pytest tests/ -v
      
      - name: Setup Fly.io
        uses: superfly/flyctl-actions/setup-flyctl@master
      
      - name: Deploy to Fly.io
        run: |
          cd conversation_service
          flyctl deploy --remote-only
        env:
          FLY_API_TOKEN: ${{ secrets.FLY_API_TOKEN }}
      
      - name: Health Check
        run: |
          sleep 30
          curl -f https://voice-ai-conversation.fly.dev/health || exit 1
```

## 3. GitHub Secrets 설정

```bash
# GitHub Repository → Settings → Secrets → Actions

# 추가할 Secrets:
FLY_API_TOKEN=your-fly-api-token
SLACK_WEBHOOK_URL=your-slack-webhook-url

# Fly.io API Token 생성
flyctl auth token
```

## 4. core_api/main.py에 Health Check 추가

```python
@app.get("/health")
async def health_check():
    """Health Check 엔드포인트"""
    try:
        # Database 연결 확인
        db = next(get_db())
        db.execute(text("SELECT 1"))
        
        # Redis 연결 확인
        redis_client.ping()
        
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "database": "connected",
            "redis": "connected",
            "version": "1.0.0"
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "error": str(e)
            }
        )
```

## 5. conversation_service/main.py에 Health Check 추가

```python
@app.get("/health")
async def health_check():
    """Health Check 엔드포인트"""
    try:
        # Redis 연결 확인
        redis_client.ping()
        
        return {
            "status": "healthy",
            "timestamp": datetime.utcnow().isoformat(),
            "redis": "connected",
            "version": "1.0.0"
        }
    except Exception as e:
        return JSONResponse(
            status_code=503,
            content={
                "status": "unhealthy",
                "error": str(e)
            }
        )
```

## 6. 모니터링 설정 (Sentry)

```bash
# Sentry 설치
pip install sentry-sdk[fastapi]
```

```python
# core_api/main.py
import sentry_sdk
from sentry_sdk.integrations.fastapi import FastApiIntegration

sentry_sdk.init(
    dsn=os.getenv("SENTRY_DSN"),
    integrations=[FastApiIntegration()],
    traces_sample_rate=0.1,
    environment=os.getenv("ENVIRONMENT", "production")
)
```

## 7. 로깅 설정

```python
# core_api/core/logging.py
import logging
import sys

def setup_logging():
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.StreamHandler(sys.stdout)
        ]
    )
    
    # Uvicorn 로그 레벨 설정
    logging.getLogger("uvicorn").setLevel(logging.INFO)
    logging.getLogger("uvicorn.access").setLevel(logging.INFO)

# core_api/main.py
from core.logging import setup_logging

setup_logging()
```

## 8. 배포 테스트

```bash
# 변경사항 커밋 및 푸시
git add .
git commit -m "feat: Add CI/CD and monitoring"
git push origin main

# GitHub Actions 확인
# https://github.com/your-repo/actions

# 배포 상태 확인
flyctl status -a voice-ai-core-api
flyctl status -a voice-ai-conversation

# 로그 실시간 확인
flyctl logs -a voice-ai-core-api
```

## 9. 롤백 전략

```bash
# 이전 버전으로 롤백
flyctl releases -a voice-ai-core-api
flyctl releases rollback <version> -a voice-ai-core-api

# 특정 이미지로 배포
flyctl deploy --image registry.fly.io/voice-ai-core-api:v1.0.0
```

## 완료 기준
- [ ] .github/workflows/deploy-core-api.yml 작성
- [ ] .github/workflows/deploy-conversation.yml 작성
- [ ] GitHub Secrets 설정
- [ ] Health Check 엔드포인트 구현
- [ ] Sentry 모니터링 설정
- [ ] 로깅 설정
- [ ] CI/CD 파이프라인 테스트
- [ ] 배포 자동화 확인
- [ ] 롤백 테스트

## 테스트
```bash
# CI/CD 테스트
1. 코드 변경 (예: README 수정)
2. Git commit & push
3. GitHub Actions 확인
4. 배포 완료 확인
5. Health Check 확인

# 모니터링 확인
1. Sentry 대시보드 접속
2. 에러 발생 시 알림 확인
3. 로그 확인

# 롤백 테스트
1. 이전 버전으로 롤백
2. Health Check 확인
3. 기능 동작 확인
```

## 보고서 작성
Day 55-56 완료 후 다음을 보고해줘:
1. CI/CD 파이프라인 구성
2. 배포 성공 여부
3. Health Check 결과
4. Sentry 설정 완료
5. 롤백 테스트 결과
6. 전체 시스템 상태

완료했으면 "Day 55-56 완료 보고서"를 작성해줘.
```

---

## 📝 Week 9 완료 체크리스트

Day 53-56을 모두 완료하면 다음을 확인하세요:

### Fly.io 배포
- ✅ Core API 배포 (홍콩 리전)
- ✅ Conversation Service 배포 (홍콩 리전)
- ✅ PostgreSQL 설정
- ✅ Redis 설정
- ✅ 환경 변수 설정
- ✅ Health Check 구현

### CI/CD
- ✅ GitHub Actions 파이프라인
- ✅ 자동 배포
- ✅ 자동 테스트
- ✅ Slack 알림

### 모니터링
- ✅ Sentry 에러 추적
- ✅ 로깅 시스템
- ✅ Health Check 모니터링

### 비용
- ✅ 월 $20 이하 확인

### 다음 단계
Phase 1.5로 이동: 아침 루틴 기능 (Day 57-61)

---

## 🚀 배포 URL

```
Core API: https://voice-ai-core-api.fly.dev
Conversation Service: https://voice-ai-conversation.fly.dev

API 문서: https://voice-ai-core-api.fly.dev/docs
WebSocket: wss://voice-ai-conversation.fly.dev/ws/conversations/{character_id}
```

---

**이 문서는 Claude Code 개발 프롬프트 v1.3의 Day 53-56 부분입니다.**  
**전체 문서: Claude_Code_개발_프롬프트_완전판_v1_3.md**
