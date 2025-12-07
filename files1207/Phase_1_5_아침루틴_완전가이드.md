# Phase 1.5: 아침 루틴 기능 완전 가이드 (Day 57-61)

## 📋 개요

이 섹션은 Claude Code 개발 프롬프트 v1.3의 **Phase 1.5: 아침 루틴 기능** 부분입니다.

**참조 문서:**
- 개발_체크리스트_v1.3.md: Phase 1.5 (Lines 446-487)
- PRD v1.3: 섹션 4.5 (아침 루틴 기능)
- UI_UX_가이드_v1.2.md: 섹션 4.5 (아침 루틴 화면)

**주요 기능:**
- 8가지 아침 체크리스트 (물 마시기, 창문 열기, 스트레칭, 아침 식사, 약 복용, 양치질, 샤워, 감사 일기)
- 감사 일기 작성
- 푸시 알림 (7:00 AM 기본)
- 연속 일수 추적
- 주간 통계

---

## Day 57-58: 아침 루틴 데이터 모델

### 목표
아침 루틴 체크리스트 및 감사 일기 데이터 모델을 구현합니다.

### Claude Code 프롬프트

```markdown
# Day 57-58: 아침 루틴 데이터 모델

## 목표
아침 루틴 체크리스트, 감사 일기, 알림 설정 모델을 구현합니다.

## 1. core_api/models/morning_routine.py 작성

```python
from sqlalchemy import Column, String, DateTime, ForeignKey, Boolean, Integer, Text, Time
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import JSON
from datetime import datetime, time
import uuid
from core_api.database import Base

class MorningRoutineCheckItem(Base):
    """아침 루틴 체크 아이템 (8가지 고정)"""
    __tablename__ = "morning_routine_check_items"
    
    # Primary Key
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Item Info
    item_key = Column(String(50), unique=True, nullable=False)  # "water", "window", etc.
    name_ko = Column(String(100), nullable=False)  # "물 마시기"
    name_en = Column(String(100), nullable=False)  # "Drink Water"
    icon = Column(String(50), nullable=False)  # "water_drop"
    description = Column(Text, nullable=True)
    order = Column(Integer, nullable=False)  # 표시 순서
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    def __repr__(self):
        return f"<MorningRoutineCheckItem(id={self.id}, name={self.name_ko})>"

class MorningRoutineCheck(Base):
    """사용자의 일일 아침 루틴 체크 기록"""
    __tablename__ = "morning_routine_checks"
    
    # Primary Key
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Foreign Keys
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    
    # Date
    check_date = Column(DateTime, nullable=False)  # 체크한 날짜 (YYYY-MM-DD)
    
    # 8 Items (Boolean)
    water = Column(Boolean, default=False)      # 물 마시기
    window = Column(Boolean, default=False)     # 창문 열기
    stretch = Column(Boolean, default=False)    # 스트레칭
    breakfast = Column(Boolean, default=False)  # 아침 식사
    medication = Column(Boolean, default=False) # 약 복용
    teeth = Column(Boolean, default=False)      # 양치질
    shower = Column(Boolean, default=False)     # 샤워
    gratitude = Column(Boolean, default=False)  # 감사 일기
    
    # Completion
    completed_count = Column(Integer, default=0)  # 완료한 항목 수 (0-8)
    is_all_completed = Column(Boolean, default=False)  # 전체 완료 여부
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="morning_routine_checks")
    gratitude_journal = relationship("GratitudeJournal", back_populates="morning_check", uselist=False)
    
    def __repr__(self):
        return f"<MorningRoutineCheck(id={self.id}, date={self.check_date}, completed={self.completed_count}/8)>"

class GratitudeJournal(Base):
    """감사 일기"""
    __tablename__ = "gratitude_journals"
    
    # Primary Key
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Foreign Keys
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    morning_check_id = Column(String(36), ForeignKey("morning_routine_checks.id", ondelete="CASCADE"), nullable=True)
    
    # Content
    content = Column(Text, nullable=False)  # 감사 일기 내용 (500자 제한)
    entry_date = Column(DateTime, nullable=False)  # 작성 날짜
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="gratitude_journals")
    morning_check = relationship("MorningRoutineCheck", back_populates="gratitude_journal")
    
    def __repr__(self):
        return f"<GratitudeJournal(id={self.id}, date={self.entry_date})>"

class MorningRoutineNotification(Base):
    """아침 루틴 알림 설정"""
    __tablename__ = "morning_routine_notifications"
    
    # Primary Key
    id = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    
    # Foreign Key
    user_id = Column(String(36), ForeignKey("users.id", ondelete="CASCADE"), nullable=False, unique=True)
    
    # Settings
    enabled = Column(Boolean, default=True)
    notification_time = Column(Time, default=time(7, 0))  # 기본 07:00 AM
    days_of_week = Column(JSON, default=lambda: [1, 2, 3, 4, 5, 6, 7])  # 1=월요일, 7=일요일
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="morning_routine_notification")
    
    def __repr__(self):
        return f"<MorningRoutineNotification(id={self.id}, enabled={self.enabled}, time={self.notification_time})>"
```

## 2. 마이그레이션 생성 및 실행

```bash
# 마이그레이션 생성
docker-compose exec core_api alembic revision --autogenerate -m "Add morning routine tables"

# 마이그레이션 적용
docker-compose exec core_api alembic upgrade head
```

## 3. 아침 루틴 체크 아이템 Seed Data

```bash
# scripts/seed_morning_routine_items.py
```

```python
from sqlalchemy.orm import Session
from core_api.database import get_db, engine
from core_api.models.morning_routine import MorningRoutineCheckItem

def seed_morning_routine_items():
    """8가지 아침 루틴 체크 아이템 시드 데이터"""
    items = [
        {
            "item_key": "water",
            "name_ko": "물 마시기",
            "name_en": "Drink Water",
            "icon": "water_drop",
            "description": "따뜻한 물 한 잔으로 하루를 시작하세요",
            "order": 1
        },
        {
            "item_key": "window",
            "name_ko": "창문 열기",
            "name_en": "Open Window",
            "icon": "window",
            "description": "신선한 공기를 마시며 환기하세요",
            "order": 2
        },
        {
            "item_key": "stretch",
            "name_ko": "스트레칭",
            "name_en": "Stretching",
            "icon": "self_improvement",
            "description": "가볍게 몸을 풀어주세요",
            "order": 3
        },
        {
            "item_key": "breakfast",
            "name_ko": "아침 식사",
            "name_en": "Breakfast",
            "icon": "restaurant",
            "description": "영양가 있는 아침 식사를 챙기세요",
            "order": 4
        },
        {
            "item_key": "medication",
            "name_ko": "약 복용",
            "name_en": "Take Medication",
            "icon": "medication",
            "description": "정해진 약을 빠짐없이 복용하세요",
            "order": 5
        },
        {
            "item_key": "teeth",
            "name_ko": "양치질",
            "name_en": "Brush Teeth",
            "icon": "clean_hands",
            "description": "깨끗하게 양치질하세요",
            "order": 6
        },
        {
            "item_key": "shower",
            "name_ko": "샤워",
            "name_en": "Shower",
            "icon": "shower",
            "description": "상쾌한 샤워로 하루를 준비하세요",
            "order": 7
        },
        {
            "item_key": "gratitude",
            "name_ko": "감사 일기",
            "name_en": "Gratitude Journal",
            "icon": "edit_note",
            "description": "오늘 감사한 일을 적어보세요",
            "order": 8
        }
    ]
    
    db = next(get_db())
    
    for item_data in items:
        existing = db.query(MorningRoutineCheckItem).filter(
            MorningRoutineCheckItem.item_key == item_data["item_key"]
        ).first()
        
        if not existing:
            item = MorningRoutineCheckItem(**item_data)
            db.add(item)
    
    db.commit()
    print("✅ 아침 루틴 체크 아이템 시드 완료 (8개)")

if __name__ == "__main__":
    seed_morning_routine_items()
```

```bash
# 실행
docker-compose exec core_api python scripts/seed_morning_routine_items.py
```

## 완료 기준
- [ ] core_api/models/morning_routine.py 작성
  - [ ] MorningRoutineCheckItem (8가지 고정)
  - [ ] MorningRoutineCheck (일일 체크 기록)
  - [ ] GratitudeJournal (감사 일기)
  - [ ] MorningRoutineNotification (알림 설정)
- [ ] 마이그레이션 생성 및 실행
- [ ] 시드 데이터 실행 (8개 아이템)
- [ ] 테이블 확인

## 테스트
```bash
# 테이블 확인
docker-compose exec core_api psql $DATABASE_URL -c "SELECT * FROM morning_routine_check_items ORDER BY \"order\";"

# 시드 데이터 확인
docker-compose exec core_api psql $DATABASE_URL -c "SELECT item_key, name_ko, icon FROM morning_routine_check_items;"
```

## 보고서 작성
Day 57-58 완료 후 다음을 보고해줘:
1. 작성된 파일 목록
2. 테이블 구조
3. 시드 데이터 확인
4. 다음 단계 준비 상태

완료했으면 "Day 57-58 완료 보고서"를 작성해줘.
```

---

## Day 59-61: 아침 루틴 API & Flutter UI

### 목표
아침 루틴 체크 API 및 Flutter 화면을 구현합니다.

### Claude Code 프롬프트

```markdown
# Day 59-61: 아침 루틴 API & Flutter UI

## 목표
아침 루틴 체크 API, 감사 일기 API, Flutter 화면을 구현합니다.

## 1. core_api/schemas/morning_routine.py 작성

```python
from pydantic import BaseModel, Field, validator
from typing import Optional
from datetime import datetime, time

class MorningRoutineCheckCreate(BaseModel):
    """아침 루틴 체크 생성"""
    check_date: datetime = Field(default_factory=datetime.now)
    water: bool = False
    window: bool = False
    stretch: bool = False
    breakfast: bool = False
    medication: bool = False
    teeth: bool = False
    shower: bool = False
    gratitude: bool = False

class MorningRoutineCheckUpdate(BaseModel):
    """아침 루틴 체크 업데이트"""
    water: Optional[bool] = None
    window: Optional[bool] = None
    stretch: Optional[bool] = None
    breakfast: Optional[bool] = None
    medication: Optional[bool] = None
    teeth: Optional[bool] = None
    shower: Optional[bool] = None
    gratitude: Optional[bool] = None

class MorningRoutineCheckResponse(BaseModel):
    id: str
    user_id: str
    check_date: datetime
    water: bool
    window: bool
    stretch: bool
    breakfast: bool
    medication: bool
    teeth: bool
    shower: bool
    gratitude: bool
    completed_count: int
    is_all_completed: bool
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class GratitudeJournalCreate(BaseModel):
    """감사 일기 작성"""
    content: str = Field(..., min_length=1, max_length=500)
    entry_date: datetime = Field(default_factory=datetime.now)

class GratitudeJournalResponse(BaseModel):
    id: str
    user_id: str
    content: str
    entry_date: datetime
    created_at: datetime
    updated_at: datetime
    
    class Config:
        from_attributes = True

class MorningRoutineStats(BaseModel):
    """아침 루틴 통계"""
    total_days: int
    consecutive_days: int
    completion_rate: float  # 0.0 - 1.0
    most_completed_item: str
    least_completed_item: str

class NotificationSettingsUpdate(BaseModel):
    """알림 설정 업데이트"""
    enabled: Optional[bool] = None
    notification_time: Optional[time] = None
    days_of_week: Optional[list[int]] = None
    
    @validator('days_of_week')
    def validate_days(cls, v):
        if v is not None:
            if not all(1 <= day <= 7 for day in v):
                raise ValueError('Days must be between 1-7')
        return v
```

## 2. core_api/services/morning_routine_service.py 작성

```python
from sqlalchemy.orm import Session
from core_api.models.morning_routine import (
    MorningRoutineCheck,
    GratitudeJournal,
    MorningRoutineNotification
)
from core_api.models.user import User
from core_api.schemas.morning_routine import (
    MorningRoutineCheckCreate,
    MorningRoutineCheckUpdate,
    GratitudeJournalCreate,
    MorningRoutineStats
)
from typing import Optional
from datetime import datetime, timedelta
from fastapi import HTTPException, status

class MorningRoutineService:
    """아침 루틴 서비스"""
    
    @staticmethod
    def get_today_check(db: Session, user: User) -> Optional[MorningRoutineCheck]:
        """오늘의 아침 루틴 체크 조회"""
        today = datetime.now().date()
        
        check = db.query(MorningRoutineCheck).filter(
            MorningRoutineCheck.user_id == user.id,
            MorningRoutineCheck.check_date >= datetime.combine(today, datetime.min.time()),
            MorningRoutineCheck.check_date < datetime.combine(today + timedelta(days=1), datetime.min.time())
        ).first()
        
        return check
    
    @staticmethod
    def create_or_update_check(
        db: Session,
        user: User,
        data: MorningRoutineCheckUpdate
    ) -> MorningRoutineCheck:
        """아침 루틴 체크 생성 또는 업데이트"""
        check = MorningRoutineService.get_today_check(db, user)
        
        if not check:
            # 새로 생성
            check = MorningRoutineCheck(
                user_id=user.id,
                check_date=datetime.now()
            )
            db.add(check)
        
        # 업데이트
        update_dict = data.dict(exclude_unset=True)
        for key, value in update_dict.items():
            setattr(check, key, value)
        
        # 완료 개수 계산
        check.completed_count = sum([
            check.water, check.window, check.stretch, check.breakfast,
            check.medication, check.teeth, check.shower, check.gratitude
        ])
        check.is_all_completed = (check.completed_count == 8)
        
        db.commit()
        db.refresh(check)
        
        return check
    
    @staticmethod
    def create_gratitude_journal(
        db: Session,
        user: User,
        data: GratitudeJournalCreate
    ) -> GratitudeJournal:
        """감사 일기 작성"""
        # 오늘의 체크 조회
        check = MorningRoutineService.get_today_check(db, user)
        
        journal = GratitudeJournal(
            user_id=user.id,
            morning_check_id=check.id if check else None,
            content=data.content,
            entry_date=data.entry_date
        )
        
        db.add(journal)
        
        # 체크에 gratitude 항목 업데이트
        if check:
            check.gratitude = True
            check.completed_count = sum([
                check.water, check.window, check.stretch, check.breakfast,
                check.medication, check.teeth, check.shower, check.gratitude
            ])
            check.is_all_completed = (check.completed_count == 8)
        
        db.commit()
        db.refresh(journal)
        
        return journal
    
    @staticmethod
    def get_stats(db: Session, user: User, days: int = 30) -> MorningRoutineStats:
        """아침 루틴 통계"""
        start_date = datetime.now() - timedelta(days=days)
        
        checks = db.query(MorningRoutineCheck).filter(
            MorningRoutineCheck.user_id == user.id,
            MorningRoutineCheck.check_date >= start_date
        ).order_by(MorningRoutineCheck.check_date.desc()).all()
        
        if not checks:
            return MorningRoutineStats(
                total_days=0,
                consecutive_days=0,
                completion_rate=0.0,
                most_completed_item="",
                least_completed_item=""
            )
        
        # 연속 일수 계산
        consecutive_days = 0
        today = datetime.now().date()
        
        for i, check in enumerate(checks):
            check_date = check.check_date.date()
            expected_date = today - timedelta(days=i)
            
            if check_date == expected_date and check.is_all_completed:
                consecutive_days += 1
            else:
                break
        
        # 완료율 계산
        total_checks = len(checks)
        completed_checks = sum(1 for c in checks if c.is_all_completed)
        completion_rate = completed_checks / total_checks if total_checks > 0 else 0.0
        
        # 가장 많이/적게 완료한 항목
        item_counts = {
            "water": sum(c.water for c in checks),
            "window": sum(c.window for c in checks),
            "stretch": sum(c.stretch for c in checks),
            "breakfast": sum(c.breakfast for c in checks),
            "medication": sum(c.medication for c in checks),
            "teeth": sum(c.teeth for c in checks),
            "shower": sum(c.shower for c in checks),
            "gratitude": sum(c.gratitude for c in checks),
        }
        
        most_completed = max(item_counts, key=item_counts.get)
        least_completed = min(item_counts, key=item_counts.get)
        
        return MorningRoutineStats(
            total_days=total_checks,
            consecutive_days=consecutive_days,
            completion_rate=completion_rate,
            most_completed_item=most_completed,
            least_completed_item=least_completed
        )
```

## 3. core_api/routers/morning_routine.py 작성

```python
from fastapi import APIRouter, Depends, HTTPException, status, Query
from sqlalchemy.orm import Session
from core_api.database import get_db
from core_api.schemas.morning_routine import (
    MorningRoutineCheckResponse,
    MorningRoutineCheckUpdate,
    GratitudeJournalCreate,
    GratitudeJournalResponse,
    MorningRoutineStats
)
from core_api.services.morning_routine_service import MorningRoutineService
from core_api.dependencies import get_current_active_user
from core_api.models.user import User
from typing import List

router = APIRouter(prefix="/api/v1/morning-routine", tags=["Morning Routine"])

@router.get("/today", response_model=MorningRoutineCheckResponse)
async def get_today_check(
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """오늘의 아침 루틴 체크 조회"""
    check = MorningRoutineService.get_today_check(db, current_user)
    
    if not check:
        # 없으면 빈 체크 생성
        check = MorningRoutineService.create_or_update_check(
            db, current_user, MorningRoutineCheckUpdate()
        )
    
    return MorningRoutineCheckResponse.from_orm(check)

@router.patch("/today", response_model=MorningRoutineCheckResponse)
async def update_today_check(
    data: MorningRoutineCheckUpdate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """오늘의 아침 루틴 체크 업데이트"""
    check = MorningRoutineService.create_or_update_check(db, current_user, data)
    return MorningRoutineCheckResponse.from_orm(check)

@router.post("/gratitude", response_model=GratitudeJournalResponse, status_code=status.HTTP_201_CREATED)
async def create_gratitude_journal(
    data: GratitudeJournalCreate,
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """감사 일기 작성"""
    journal = MorningRoutineService.create_gratitude_journal(db, current_user, data)
    return GratitudeJournalResponse.from_orm(journal)

@router.get("/stats", response_model=MorningRoutineStats)
async def get_stats(
    days: int = Query(30, ge=7, le=365),
    current_user: User = Depends(get_current_active_user),
    db: Session = Depends(get_db)
):
    """아침 루틴 통계"""
    stats = MorningRoutineService.get_stats(db, current_user, days)
    return stats
```

## 4. core_api/main.py 라우터 등록

```python
from core_api.routers import morning_routine  # 추가

app.include_router(morning_routine.router)  # 추가
```

## 5. Flutter 아침 루틴 화면 (간략)

```dart
// lib/features/morning_routine/screens/morning_routine_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MorningRoutineScreen extends ConsumerWidget {
  const MorningRoutineScreen({super.key});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('아침 루틴'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 연속 일수 카드
          _buildStreakCard(),
          const SizedBox(height: 20),
          
          // 8가지 체크리스트
          _buildChecklistSection(),
          const SizedBox(height: 20),
          
          // 감사 일기
          _buildGratitudeJournalSection(),
        ],
      ),
    );
  }
  
  Widget _buildStreakCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text('연속 완료', style: TextStyle(fontSize: 14)),
            const SizedBox(height: 8),
            Text('7일 🔥', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
  
  Widget _buildChecklistSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 체크리스트', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            // 8가지 체크박스
            _buildCheckItem('물 마시기', Icons.water_drop, false),
            _buildCheckItem('창문 열기', Icons.window, false),
            // ... 나머지 항목
          ],
        ),
      ),
    );
  }
  
  Widget _buildCheckItem(String title, IconData icon, bool checked) {
    return CheckboxListTile(
      title: Row(
        children: [
          Icon(icon, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      value: checked,
      onChanged: (value) {
        // TODO: 체크 업데이트
      },
    );
  }
  
  Widget _buildGratitudeJournalSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('오늘의 감사 일기', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              maxLines: 4,
              maxLength: 500,
              decoration: InputDecoration(
                hintText: '오늘 감사한 일을 적어보세요...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: 감사 일기 저장
              },
              child: const Text('저장'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## 완료 기준
- [ ] core_api/schemas/morning_routine.py 작성
- [ ] core_api/services/morning_routine_service.py 작성
- [ ] core_api/routers/morning_routine.py 작성
  - [ ] GET /api/v1/morning-routine/today (오늘 체크 조회)
  - [ ] PATCH /api/v1/morning-routine/today (체크 업데이트)
  - [ ] POST /api/v1/morning-routine/gratitude (감사 일기 작성)
  - [ ] GET /api/v1/morning-routine/stats (통계)
- [ ] Flutter 화면 구현
- [ ] 푸시 알림 설정 (기본 7:00 AM)
- [ ] 테스트

## 테스트
```bash
# 오늘의 체크 조회
curl -X GET http://localhost:8000/api/v1/morning-routine/today \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"

# 체크 업데이트
curl -X PATCH http://localhost:8000/api/v1/morning-routine/today \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "water": true,
    "window": true,
    "stretch": true
  }'

# 감사 일기 작성
curl -X POST http://localhost:8000/api/v1/morning-routine/gratitude \
  -H "Authorization: Bearer YOUR_JWT_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "content": "오늘도 건강하게 일어났습니다. 감사합니다."
  }'

# 통계 조회
curl -X GET "http://localhost:8000/api/v1/morning-routine/stats?days=30" \
  -H "Authorization: Bearer YOUR_JWT_TOKEN"
```

## 보고서 작성
Day 59-61 완료 후 다음을 보고해줘:
1. 작성된 파일 목록
2. API 엔드포인트 목록
3. Flutter 화면 스크린샷
4. 테스트 결과
5. Phase 1.5 완료 상태

완료했으면 "Day 59-61 완료 보고서"를 작성해줘.
```

---

## 📝 Phase 1.5 완료 체크리스트

Phase 1.5를 모두 완료하면 다음을 확인하세요:

### Backend
- ✅ 아침 루틴 데이터 모델 (4개 테이블)
- ✅ 8가지 체크 아이템 시드 데이터
- ✅ 아침 루틴 체크 API
- ✅ 감사 일기 API
- ✅ 통계 API
- ✅ 알림 설정 API

### Flutter
- ✅ 아침 루틴 화면
- ✅ 체크리스트 UI
- ✅ 감사 일기 작성 UI
- ✅ 연속 일수 표시
- ✅ 푸시 알림 (7:00 AM)

### API 엔드포인트 (추가 4개)
```
GET    /api/v1/morning-routine/today
PATCH  /api/v1/morning-routine/today
POST   /api/v1/morning-routine/gratitude
GET    /api/v1/morning-routine/stats
```

### 다음 단계
Phase 2-5로 이동: 고급 기능 (영양제 추천, AI 코칭, 커뮤니티, 다국어)

---

**이 문서는 Claude Code 개발 프롬프트 v1.3의 Phase 1.5 부분입니다.**  
**전체 문서: Claude_Code_개발_프롬프트_완전판_v1_3.md**
