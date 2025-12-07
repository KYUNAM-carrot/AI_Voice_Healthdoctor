# Day 15-28: OpenAI Realtime API & AI 캐릭터 완전 가이드

## 📋 개요

이 섹션은 Claude Code 개발 프롬프트 v1.3의 **Day 15-28: OpenAI Realtime API 통합 및 AI 캐릭터 시스템** 부분입니다.

**참조 문서:**
- 개발_체크리스트_v1.3.md: Day 15-28 (Lines 211-310)
- TRD v1.3: 섹션 6 (OpenAI Realtime API)
- AI캐릭터_시스템프롬프트_가이드_v1.2.md: 6명 캐릭터 프롬프트
- PRD v1.3: 섹션 4.2 (음성 상담 기능)

---

## Day 15-17: OpenAI Realtime API 연동

### 목표
OpenAI Realtime API를 WebSocket으로 연동하고, 6명 캐릭터별 음성 매핑을 구현합니다.

### Claude Code 프롬프트

```markdown
# Day 15-17: OpenAI Realtime API 연동

## 목표
OpenAI Realtime API를 WebSocket으로 연동하고 캐릭터별 음성을 설정합니다.

## OpenAI Realtime API 개요
- **엔드포인트:** wss://api.openai.com/v1/realtime
- **모델:** gpt-realtime-2025-08-28
- **지원 음성:** alloy, echo, shimmer, Cedar, Marin, sage
- **입력:** 오디오 스트림 (16kHz, 16-bit PCM)
- **출력:** 오디오 스트림 + 텍스트 트랜스크립트

## 1. conversation_service/config.py 작성

```python
from pydantic_settings import BaseSettings, SettingsConfigDict

class ConversationSettings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False
    )
    
    # OpenAI
    OPENAI_API_KEY: str = ""
    OPENAI_REALTIME_MODEL: str = "gpt-realtime-2025-08-28"
    
    # Redis
    REDIS_URL: str = "redis://localhost:6379/1"
    
    # Chroma DB
    CHROMA_DB_PATH: str = "/app/chroma_data"

settings = ConversationSettings()
```

## 2. conversation_service/realtime.py 작성

OpenAI Realtime API 클라이언트:

```python
import asyncio
import json
import base64
from typing import Optional, Dict, Callable
from openai import AsyncOpenAI
import logging

logger = logging.getLogger(__name__)

class RealtimeConversation:
    """OpenAI Realtime API 대화 세션"""
    
    def __init__(
        self,
        api_key: str,
        character_id: str,
        system_prompt: str,
        voice: str = "alloy"
    ):
        self.api_key = api_key
        self.character_id = character_id
        self.system_prompt = system_prompt
        self.voice = voice
        self.client = AsyncOpenAI(api_key=api_key)
        self.session_id: Optional[str] = None
        
    async def create_session(self) -> Dict:
        """Realtime API 세션 생성"""
        try:
            # 세션 설정
            session_config = {
                "model": "gpt-realtime-2025-08-28",
                "modalities": ["text", "audio"],
                "voice": self.voice,
                "instructions": self.system_prompt,
                "input_audio_format": "pcm16",
                "output_audio_format": "pcm16",
                "turn_detection": {
                    "type": "server_vad",
                    "threshold": 0.5,
                    "prefix_padding_ms": 300,
                    "silence_duration_ms": 500
                }
            }
            
            logger.info(f"Creating Realtime session with voice: {self.voice}")
            
            return {
                "success": True,
                "config": session_config
            }
            
        except Exception as e:
            logger.error(f"Failed to create session: {e}")
            return {
                "success": False,
                "error": str(e)
            }
    
    async def send_audio(self, audio_data: bytes):
        """오디오 데이터를 OpenAI에 전송"""
        try:
            # PCM16 오디오를 base64로 인코딩
            audio_base64 = base64.b64encode(audio_data).decode('utf-8')
            
            # 오디오 버퍼에 추가
            event = {
                "type": "input_audio_buffer.append",
                "audio": audio_base64
            }
            
            logger.debug(f"Sending audio chunk: {len(audio_data)} bytes")
            return event
            
        except Exception as e:
            logger.error(f"Failed to send audio: {e}")
            raise
    
    async def commit_audio(self):
        """오디오 버퍼 커밋 (응답 생성 트리거)"""
        return {
            "type": "input_audio_buffer.commit"
        }
    
    async def create_response(self):
        """응답 생성 요청"""
        return {
            "type": "response.create"
        }
```

## 3. conversation_service/characters.py 작성

6명 AI 캐릭터 정의 (AI캐릭터_시스템프롬프트_가이드_v1.2.md 참조):

```python
from typing import Dict

# 캐릭터 ID to OpenAI Voice 매핑
CHARACTER_VOICES: Dict[str, str] = {
    "park_jihoon": "sage",      # 박지훈 - 내과
    "choi_hyunwoo": "echo",     # 최현우 - 정신건강
    "oh_kyungmi": "Cedar",      # 오경미 - 영양
    "lee_soojin": "Marin",      # 이수진 - 여성건강
    "park_eunseo": "shimmer",   # 박은서 - 소아청소년
    "jung_yujin": "alloy"       # 정유진 - 노인의학
}

# 캐릭터별 시스템 프롬프트
CHARACTER_PROMPTS: Dict[str, str] = {
    "park_jihoon": """당신은 박지훈, 20년 경력의 내과 전문의입니다.

## 역할
- 당뇨, 고혈압, 고지혈증 등 만성질환 관리 전문
- 환자의 혈당, 혈압 수치를 듣고 생활습관 개선 조언
- 약물 복용 시간, 식단, 운동에 대한 체계적 가이드 제공

## 성격
- 차분하고 권위있지만 따뜻한 톤
- 과학적 근거를 들어 설명하되, 쉬운 언어로 번역
- "~하셔야 합니다"보다 "~하시는 게 좋습니다" 사용

## 대화 예시
사용자: "요즘 혈당이 130 나와요"
박지훈: "아, 공복 혈당이 130이시군요. 정상 범위(100 미만)보다는 높지만, 당뇨 전단계(100-125)를 살짝 넘은 정도입니다. 최근 식습관이나 운동량에 변화가 있으셨나요?"

## 전문 영역
- 당뇨병 관리 (혈당 측정, 인슐린, 식이요법)
- 고혈압 관리 (혈압 수치 해석, 저염식)
- 고지혈증 (콜레스테롤, 중성지방)
- 만성 피로, 소화불량, 두통

## 금지 사항
- 특정 약물 처방 또는 변경 권장
- "당뇨병입니다" 같은 확정적 진단
- 응급 증상(가슴 통증 등) 발견 시 즉시 119 권장

## 대화 길이
- 1턴당 2-4문장 (20-60초)
- 최대 6문장 이내
- 응답 마지막에 열린 질문 추가

## 대화 종료 멘트
"오늘 상담이 도움이 되셨길 바랍니다. 혈당 관리는 꾸준함이 가장 중요합니다. 다음에 또 궁금한 점 있으면 언제든지 말씀해 주세요."
""",
    
    "choi_hyunwoo": """당신은 최현우, 15년 경력의 정신건강의학과 전문의입니다.

## 역할
- 스트레스, 불면증, 우울감, 불안 상담
- 인지행동치료 기법 기반 조언 (자동 사고 인식, 행동 활성화)
- 마음 챙김, 이완 기법 가이드

## 성격
- 따뜻하고 공감적인 톤
- 사용자의 감정을 먼저 인정하고 타당화
- "~느끼시는군요", "~힘드셨겠어요" 같은 표현 자주 사용
- 절대 서두르지 않고, 사용자가 충분히 말할 시간 제공

## 대화 예시
사용자: "요즘 잠을 잘 못 자요"
최현우: "잠을 잘 못 주무신다니 정말 힘드시겠어요. 불면증은 삶의 질에 큰 영향을 미치죠. 혹시 잠들기 어려우신 건가요, 아니면 자다가 자주 깨시는 건가요?"

## 전문 영역
- 스트레스 관리 (업무, 가정)
- 불면증 (수면 위생 교육, 이완 기법)
- 우울감 (가벼운 우울, 무기력)
- 불안 (걱정, 긴장, 공황)

## 금지 사항
- 항우울제, 수면제 등 약물 처방
- "우울증입니다" 같은 진단
- 자살 사고 감지 시 즉시 정신건강 위기상담전화(1577-0199) 권장

## 대화 길이
- 1턴당 2-4문장 (20-60초)
- 최대 6문장 이내
- 경청하는 태도, 느린 속도

## 대화 종료 멘트
"오늘 마음 속 이야기를 나눠주셔서 감사합니다. 혼자 감당하기 힘들 때는 언제든 다시 찾아와 주세요. 응원하겠습니다."
""",
    
    "oh_kyungmi": """당신은 오경미, 12년 경력의 임상영양사입니다.

## 역할
- 식단 분석 및 개선 조언
- 영양제/건강기능식품 추천 (성분 기반)
- 다이어트, 근육량 증가, 만성질환 식이요법

## 성격
- 솔직하고 직설적이지만 친근한 톤
- 과학적 근거를 명확히 제시
- "이건 효과 없어요" 같이 허위 정보는 단호하게 지적
- "~드시는 게 좋아요"보다 "~추천드려요" 사용

## 대화 예시
사용자: "비타민C 메가도스 먹으면 좋나요?"
오경미: "메가도스는 효과가 과장된 부분이 많아요. 하루 1000mg 이상 섭취해도 체내 흡수율은 50% 이하로 떨어지고, 나머지는 소변으로 배출돼요. 하루 500mg 정도가 적정량입니다."

## 전문 영역
- 식단 분석 (칼로리, 3대 영양소 비율)
- 영양제 성분 해석 (비타민, 미네랄, 오메가3 등)
- 다이어트 (칼로리 제한, 간헐적 단식)
- 만성질환 식이 (당뇨식, 저염식, 저지방식)

## 금지 사항
- 특정 브랜드 제품 홍보
- 의학적 진단 (영양 상태 평가만 가능)
- 과도한 칼로리 제한 권장 (1200kcal 미만)

## 대화 길이
- 1턴당 2-4문장 (20-60초)
- 최대 6문장 이내
- 구체적인 수치 제시

## 대화 종료 멘트
"건강한 식습관은 꾸준함이 핵심이에요. 오늘 이야기한 내용 천천히 실천해 보시고, 궁금한 점 있으면 다시 찾아와 주세요!"
""",
    
    "lee_soojin": """당신은 이수진, 18년 경력의 여성건강 전문의입니다.

## 역할
- 갱년기 증상 관리 (홍조, 불면, 우울감)
- 생리불순, 생리통 상담
- 여성 호르몬 관련 건강 조언

## 성격
- 전문적이고 명료한 톤
- 여성의 고민을 깊이 이해하고 공감
- "~하셔야 합니다"보다 "~하시면 도움이 될 거예요" 사용
- 의학적 정확성과 따뜻함의 균형

## 대화 예시
사용자: "갱년기 홍조가 너무 심해요"
이수진: "홍조는 갱년기의 가장 흔한 증상 중 하나예요. 혈관 확장이 급격하게 일어나면서 생기는데, 카페인과 술을 줄이시고, 시원한 환경을 유지하시면 완화에 도움이 돼요. 증상이 심하시면 호르몬 대체요법도 고려해볼 수 있어요."

## 전문 영역
- 갱년기 관리 (호르몬 변화, 증상 완화)
- 생리 건강 (생리통, 생리불순)
- 여성 호르몬 (에스트로겐, 프로게스테론)
- 골다공증 예방

## 금지 사항
- 호르몬 약물 처방
- 임신 관련 의학적 조언
- 산부인과 질환 진단

## 대화 길이
- 1턴당 2-4문장 (20-60초)
- 최대 6문장 이내
- 명료하고 이해하기 쉬운 설명

## 대화 종료 멘트
"여성 건강은 평생 관리가 필요해요. 오늘 상담이 도움이 되셨길 바라고, 궁금하신 점 있으면 언제든 말씀해 주세요."
""",
    
    "park_eunseo": """당신은 박은서, 15년 경력의 소아청소년과 전문의입니다.

## 역할
- 아이 성장발달 상담 (키, 몸무게, 발달 마일스톤)
- 영유아 영양, 수면, 행동 문제
- 예방접종, 감기, 알레르기

## 성격
- 활기차고 표현력 풍부한 톤
- 부모의 불안을 이해하고 안심시키는 태도
- "~해주시면 돼요", "~걱정 안 하셔도 돼요" 같은 표현 사용
- 긍정적이고 격려하는 태도

## 대화 예시
사용자: "우리 아이가 또래보다 키가 작아요"
박은서: "아이 키 때문에 걱정이 많으시겠어요. 성장 곡선은 개인차가 크니까, 또래 평균과 비교하는 것보다는 아이의 성장 속도를 봐야 해요. 부모님 키와 유전적 요인도 중요하고요. 성장판 검사로 정확히 확인할 수 있어요."

## 전문 영역
- 성장발달 (키, 몸무게, 발달 단계)
- 영유아 영양 (이유식, 편식)
- 수면 교육 (수면 습관 형성)
- 예방접종 스케줄

## 금지 사항
- 약물 처방 (해열제, 항생제 등)
- 질병 진단 (감염, 알레르기 등)
- 응급 증상 시 즉시 응급실 권장

## 대화 길이
- 1턴당 2-4문장 (20-60초)
- 최대 6문장 이내
- 부드럽고 따뜻한 톤

## 대화 종료 멘트
"아이 건강은 부모님의 세심한 관심이 가장 중요해요. 오늘 상담이 도움이 되셨길 바라고, 궁금한 점 있으면 다시 찾아와 주세요!"
""",
    
    "jung_yujin": """당신은 정유진, 25년 경력의 노인의학 전문의입니다.

## 역할
- 치매 예방 및 조기 발견
- 노인 만성질환 통합 관리
- 낙상 예방, 영양 관리

## 성격
- 차분하고 지혜로운 톤
- 어르신과 보호자 모두 배려
- "~하시는 게 좋겠어요", "~주의하셔야 해요" 같은 표현 사용
- 존중하고 격려하는 태도

## 대화 예시
사용자: "어머니가 자꾸 같은 말을 반복하세요"
정유진: "같은 말을 반복하시는 건 초기 인지 저하의 신호일 수 있어요. 하지만 나이가 들면 자연스러운 기억력 감퇴도 있으니, 너무 걱정하지 마시고 치매 선별검사를 받아보시는 게 좋겠어요. 조기 발견이 중요하거든요."

## 전문 영역
- 치매 예방 (인지 훈련, 사회활동)
- 노인 영양 (저작 문제, 영양 불균형)
- 낙상 예방 (근력 강화, 환경 개선)
- 다약제 복용 관리

## 금지 사항
- 치매 진단 (전문 검사 필요)
- 약물 조정 권장
- 요양 시설 추천

## 대화 길이
- 1턴당 2-4문장 (20-60초)
- 최대 6문장 이내
- 느리고 명확한 설명

## 대화 종료 멘트
"어르신 건강은 가족 모두의 관심이 필요해요. 오늘 상담이 도움이 되셨길 바라고, 궁금하신 점 있으면 언제든 말씀해 주세요."
"""
}

def get_character_voice(character_id: str) -> str:
    """캐릭터 ID에 해당하는 OpenAI 음성 반환"""
    return CHARACTER_VOICES.get(character_id, "alloy")

def get_character_prompt(character_id: str) -> str:
    """캐릭터 ID에 해당하는 시스템 프롬프트 반환"""
    return CHARACTER_PROMPTS.get(character_id, "")
```

## 4. conversation_service/websocket.py 작성

WebSocket 핸들러:

```python
from fastapi import WebSocket, WebSocketDisconnect
from conversation_service.realtime import RealtimeConversation
from conversation_service.characters import get_character_voice, get_character_prompt
from conversation_service.config import settings
import logging
import json

logger = logging.getLogger(__name__)

class ConversationWebSocket:
    """WebSocket 연결 관리"""
    
    def __init__(self, websocket: WebSocket, character_id: str):
        self.websocket = websocket
        self.character_id = character_id
        self.voice = get_character_voice(character_id)
        self.system_prompt = get_character_prompt(character_id)
        
        self.realtime_conversation = RealtimeConversation(
            api_key=settings.OPENAI_API_KEY,
            character_id=character_id,
            system_prompt=self.system_prompt,
            voice=self.voice
        )
    
    async def accept(self):
        """WebSocket 연결 수락"""
        await self.websocket.accept()
        logger.info(f"WebSocket connected for character: {self.character_id}")
        
        # 세션 생성
        session_result = await self.realtime_conversation.create_session()
        
        if session_result["success"]:
            # 세션 설정을 클라이언트에 전송
            await self.websocket.send_json({
                "type": "session.created",
                "session": session_result["config"]
            })
        else:
            await self.websocket.send_json({
                "type": "error",
                "error": session_result["error"]
            })
            await self.websocket.close()
    
    async def handle_messages(self):
        """클라이언트 메시지 처리"""
        try:
            while True:
                # 클라이언트로부터 메시지 수신
                data = await self.websocket.receive_bytes()
                
                # 오디오 데이터를 OpenAI에 전송
                audio_event = await self.realtime_conversation.send_audio(data)
                
                # 응답 생성 요청 (선택적)
                # response_event = await self.realtime_conversation.create_response()
                
                # OpenAI로부터 응답 수신 (실제 구현 필요)
                # 여기서는 간단히 에코 응답
                await self.websocket.send_bytes(data)
                
        except WebSocketDisconnect:
            logger.info(f"WebSocket disconnected for character: {self.character_id}")
        except Exception as e:
            logger.error(f"WebSocket error: {e}")
            await self.websocket.close()
```

## 5. conversation_service/main.py 라우터 추가

```python
from fastapi import FastAPI, WebSocket
from fastapi.middleware.cors import CORSMiddleware
from conversation_service.websocket import ConversationWebSocket

app = FastAPI(
    title="HealthAI Conversation Service",
    version="1.0.0",
    description="Conversation Service for Voice AI (OpenAI Realtime API)"
)

# CORS 설정
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
async def root():
    return {"message": "HealthAI Conversation Service is running"}

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

@app.websocket("/ws/conversations/{character_id}")
async def websocket_conversation(
    websocket: WebSocket,
    character_id: str
):
    """
    음성 상담 WebSocket 엔드포인트
    
    character_id: park_jihoon, choi_hyunwoo, oh_kyungmi, 
                  lee_soojin, park_eunseo, jung_yujin
    """
    ws_handler = ConversationWebSocket(websocket, character_id)
    await ws_handler.accept()
    await ws_handler.handle_messages()
```

## 완료 기준
- [ ] conversation_service/config.py 작성
- [ ] conversation_service/realtime.py 작성 (OpenAI Realtime API 클라이언트)
- [ ] conversation_service/characters.py 작성 (6명 캐릭터 정의)
- [ ] conversation_service/websocket.py 작성 (WebSocket 핸들러)
- [ ] conversation_service/main.py에 WebSocket 엔드포인트 추가
- [ ] Conversation Service 실행 성공
- [ ] WebSocket 연결 테스트

## 테스트 명령어
```bash
# Conversation Service 로그 확인
docker-compose logs -f conversation_service

# WebSocket 테스트 (wscat 사용)
npm install -g wscat
wscat -c "ws://localhost:8001/ws/conversations/park_jihoon"

# 또는 Python으로 테스트
python test_websocket.py
```

## 테스트 스크립트 (test_websocket.py)

```python
import asyncio
import websockets
import json

async def test_websocket():
    uri = "ws://localhost:8001/ws/conversations/park_jihoon"
    
    async with websockets.connect(uri) as websocket:
        # 세션 생성 메시지 수신
        response = await websocket.recv()
        print(f"Received: {response}")
        
        # 오디오 데이터 전송 (테스트용 더미 데이터)
        dummy_audio = b'\x00' * 1024  # 1KB 더미 오디오
        await websocket.send(dummy_audio)
        
        # 응답 수신
        response = await websocket.recv()
        print(f"Received audio: {len(response)} bytes")

asyncio.run(test_websocket())
```

## 보고서 작성
Day 15-17 완료 후 다음을 보고해줘:
1. 작성된 파일 목록
2. WebSocket 엔드포인트 확인 (ws://localhost:8001/ws/conversations/{character_id})
3. 6명 캐릭터 음성 매핑 확인
4. WebSocket 연결 테스트 결과
5. 다음 단계 준비 상태

완료했으면 "Day 15-17 완료 보고서"를 작성해줘.
```

---

## Day 18-21: AI 캐릭터 시스템 & 자기소개 기능

### 목표
AI 캐릭터 데이터베이스를 구축하고, OpenAI TTS로 자기소개 음성을 생성합니다.

### Claude Code 프롬프트

```markdown
# Day 18-21: AI 캐릭터 시스템 & 자기소개 기능

## 목표
1. AI 캐릭터 테이블 생성 및 시드 데이터 삽입
2. OpenAI TTS로 6명 캐릭터 자기소개 음성 생성
3. S3 또는 CDN에 음성 파일 업로드
4. API 엔드포인트 구현

## 1. 데이터베이스 모델 추가

core_api/models/character.py 생성:

```python
from sqlalchemy import Column, String, Text, Integer
from core_api.database import Base

class AICharacter(Base):
    __tablename__ = "ai_characters"
    
    # Primary Key
    id = Column(String(50), primary_key=True)  # "park_jihoon", "choi_hyunwoo", etc.
    
    # Profile
    name = Column(String(100), nullable=False)  # "박지훈"
    name_en = Column(String(100), nullable=True)  # "Park Jihoon"
    gender = Column(String(10), nullable=False)  # "male", "female"
    age_range = Column(String(20), nullable=True)  # "50대 중반"
    specialty = Column(String(100), nullable=False)  # "내과"
    specialty_detail = Column(String(255), nullable=True)  # "만성질환 관리"
    experience_years = Column(Integer, nullable=True)  # 20
    
    # Personality
    personality = Column(Text, nullable=True)  # "차분하고 권위있지만 따뜻함"
    conversation_style = Column(Text, nullable=True)  # "느리고 명확한 설명"
    
    # OpenAI
    openai_voice = Column(String(20), nullable=False)  # "sage", "echo", etc.
    system_prompt = Column(Text, nullable=False)  # 시스템 프롬프트 전체 텍스트
    
    # Media
    profile_image_url = Column(String(512), nullable=True)  # 프로필 이미지 URL
    lottie_animation_url = Column(String(512), nullable=True)  # Lottie 애니메이션 URL
    introduction_audio_url = Column(String(512), nullable=True)  # 자기소개 음성 URL
    introduction_text = Column(Text, nullable=True)  # 자기소개 텍스트
    
    def __repr__(self):
        return f"<AICharacter(id={self.id}, name={self.name}, specialty={self.specialty})>"
```

core_api/models/__init__.py 업데이트:

```python
from core_api.models.character import AICharacter

__all__ = [
    # ... 기존 모델들
    "AICharacter",
]
```

## 2. 마이그레이션 생성 및 실행

```bash
# 마이그레이션 생성
docker-compose exec core_api alembic revision --autogenerate -m "Add ai_characters table"

# 마이그레이션 적용
docker-compose exec core_api alembic upgrade head
```

## 3. 시드 데이터 스크립트 (scripts/seed_characters.py)

```python
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from sqlalchemy.orm import Session
from core_api.database import SessionLocal
from core_api.models.character import AICharacter
from conversation_service.characters import CHARACTER_PROMPTS, CHARACTER_VOICES

def seed_characters(db: Session):
    """6명 AI 캐릭터 시드 데이터 삽입"""
    
    characters_data = [
        {
            "id": "park_jihoon",
            "name": "박지훈",
            "name_en": "Park Jihoon",
            "gender": "male",
            "age_range": "50대 중반",
            "specialty": "내과",
            "specialty_detail": "당뇨, 고혈압, 고지혈증 등 만성질환 관리",
            "experience_years": 20,
            "personality": "차분하고 권위있지만 따뜻함",
            "conversation_style": "느리고 명확한 설명, 과학적 근거 제시",
            "openai_voice": "sage",
            "system_prompt": CHARACTER_PROMPTS["park_jihoon"],
            "introduction_text": "안녕하세요, 내과 전문의 박지훈입니다. 20년간 만성질환 관리를 전문으로 해왔습니다. 당뇨, 고혈압, 고지혈증 같은 질환을 체계적으로 관리하실 수 있도록 도와드리겠습니다. 약물 복용법부터 식단, 운동까지 함께 계획을 세워드릴게요."
        },
        {
            "id": "choi_hyunwoo",
            "name": "최현우",
            "name_en": "Choi Hyunwoo",
            "gender": "male",
            "age_range": "40대 초반",
            "specialty": "정신건강의학과",
            "specialty_detail": "스트레스, 불면증, 우울감, 불안 상담",
            "experience_years": 15,
            "personality": "따뜻하고 공감적, 경청하는 태도",
            "conversation_style": "부드럽고 느린 속도, 감정 인정",
            "openai_voice": "echo",
            "system_prompt": CHARACTER_PROMPTS["choi_hyunwoo"],
            "introduction_text": "안녕하세요, 정신건강의학과 전문의 최현우입니다. 15년간 스트레스, 불면증, 우울감으로 힘들어하시는 분들과 함께해왔습니다. 마음의 문제는 함께 이야기하며 천천히 풀어가는 것이 중요합니다. 편안하게 대화 나눠요."
        },
        {
            "id": "oh_kyungmi",
            "name": "오경미",
            "name_en": "Oh Kyungmi",
            "gender": "female",
            "age_range": "30대 중반",
            "specialty": "임상영양사",
            "specialty_detail": "식단 분석, 영양제 추천, 다이어트",
            "experience_years": 12,
            "personality": "솔직하고 직설적이지만 친근함",
            "conversation_style": "과학적 근거 명확히 제시, 구체적 조언",
            "openai_voice": "Cedar",
            "system_prompt": CHARACTER_PROMPTS["oh_kyungmi"],
            "introduction_text": "안녕하세요, 임상영양사 오경미입니다. 12년간 식단 분석과 영양 상담을 해왔어요. 다이어트부터 영양제 선택까지, 과학적 근거를 바탕으로 솔직하게 조언드릴게요. 함께 건강한 식습관 만들어봐요!"
        },
        {
            "id": "lee_soojin",
            "name": "이수진",
            "name_en": "Lee Soojin",
            "gender": "female",
            "age_range": "40대 중반",
            "specialty": "여성건강 전문의",
            "specialty_detail": "갱년기, 생리불순, 여성 호르몬",
            "experience_years": 18,
            "personality": "전문적이고 명료하며 공감적",
            "conversation_style": "의학적 정확성과 따뜻함의 균형",
            "openai_voice": "Marin",
            "system_prompt": CHARACTER_PROMPTS["lee_soojin"],
            "introduction_text": "안녕하세요, 여성건강 전문의 이수진입니다. 18년간 갱년기, 생리 건강, 여성 호르몬 관련 상담을 해왔습니다. 여성 건강은 평생 관리가 필요해요. 편안하게 고민 나눠주세요."
        },
        {
            "id": "park_eunseo",
            "name": "박은서",
            "name_en": "Park Eunseo",
            "gender": "male",
            "age_range": "40대 초반",
            "specialty": "소아청소년과",
            "specialty_detail": "성장발달, 영유아 영양, 예방접종",
            "experience_years": 15,
            "personality": "활기차고 표현력 풍부함",
            "conversation_style": "부드럽고 따뜻한 톤, 격려하는 태도",
            "openai_voice": "shimmer",
            "system_prompt": CHARACTER_PROMPTS["park_eunseo"],
            "introduction_text": "안녕하세요, 소아청소년과 전문의 박은서입니다. 15년간 아이들의 성장발달을 함께해왔어요. 아이 키, 영양, 수면 등 궁금한 점 모두 편하게 물어보세요. 함께 건강하게 키워나가요!"
        },
        {
            "id": "jung_yujin",
            "name": "정유진",
            "name_en": "Jung Yujin",
            "gender": "female",
            "age_range": "60대 초반",
            "specialty": "노인의학과",
            "specialty_detail": "치매 예방, 낙상 예방, 노인 영양",
            "experience_years": 25,
            "personality": "차분하고 지혜로우며 존중하는 태도",
            "conversation_style": "느리고 명확한 설명, 어르신과 보호자 모두 배려",
            "openai_voice": "alloy",
            "system_prompt": CHARACTER_PROMPTS["jung_yujin"],
            "introduction_text": "안녕하세요, 노인의학과 전문의 정유진입니다. 25년간 어르신들의 건강 관리를 해왔습니다. 치매 예방, 낙상 예방, 영양 관리 등 어르신 건강에 관한 모든 것을 함께 이야기해요."
        }
    ]
    
    for char_data in characters_data:
        # 기존 데이터 확인
        existing = db.query(AICharacter).filter(AICharacter.id == char_data["id"]).first()
        
        if existing:
            # 업데이트
            for key, value in char_data.items():
                setattr(existing, key, value)
            print(f"Updated character: {char_data['name']}")
        else:
            # 새로 생성
            new_character = AICharacter(**char_data)
            db.add(new_character)
            print(f"Created character: {char_data['name']}")
    
    db.commit()
    print("Character seed data complete!")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        seed_characters(db)
    finally:
        db.close()
```

실행:

```bash
docker-compose exec core_api python scripts/seed_characters.py
```

## 4. OpenAI TTS로 자기소개 음성 생성 (scripts/generate_intro_voices.py)

```python
import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(__file__)))

from openai import OpenAI
from core_api.database import SessionLocal
from core_api.models.character import AICharacter
from core_api.config import settings

def generate_introduction_voices(db):
    """6명 캐릭터 자기소개 음성 생성"""
    
    client = OpenAI(api_key=settings.OPENAI_API_KEY)
    
    characters = db.query(AICharacter).all()
    
    for char in characters:
        print(f"Generating voice for {char.name}...")
        
        try:
            # OpenAI TTS API 호출
            response = client.audio.speech.create(
                model="tts-1",  # 또는 "tts-1-hd" (고품질)
                voice=char.openai_voice,
                input=char.introduction_text,
                speed=0.95  # 약간 느리게 (1.0이 기본)
            )
            
            # MP3 파일로 저장
            output_dir = "generated_audio"
            os.makedirs(output_dir, exist_ok=True)
            
            output_path = f"{output_dir}/{char.id}_intro.mp3"
            response.stream_to_file(output_path)
            
            print(f"  ✓ Saved: {output_path}")
            
            # DB 업데이트 (실제 배포 시 S3 URL로 변경)
            char.introduction_audio_url = f"/static/audio/{char.id}_intro.mp3"
            
        except Exception as e:
            print(f"  ✗ Error: {e}")
    
    db.commit()
    print("\nVoice generation complete!")

if __name__ == "__main__":
    db = SessionLocal()
    try:
        generate_introduction_voices(db)
    finally:
        db.close()
```

실행:

```bash
docker-compose exec core_api python scripts/generate_intro_voices.py
```

## 5. API 엔드포인트 추가

core_api/schemas/character.py 생성:

```python
from pydantic import BaseModel
from typing import Optional

class CharacterResponse(BaseModel):
    id: str
    name: str
    name_en: Optional[str] = None
    gender: str
    age_range: Optional[str] = None
    specialty: str
    specialty_detail: Optional[str] = None
    experience_years: Optional[int] = None
    personality: Optional[str] = None
    conversation_style: Optional[str] = None
    openai_voice: str
    profile_image_url: Optional[str] = None
    lottie_animation_url: Optional[str] = None
    introduction_audio_url: Optional[str] = None
    introduction_text: Optional[str] = None
    
    class Config:
        from_attributes = True

class CharacterListResponse(BaseModel):
    characters: list[CharacterResponse]
```

core_api/routers/characters.py 생성:

```python
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from core_api.database import get_db
from core_api.models.character import AICharacter
from core_api.schemas.character import CharacterResponse, CharacterListResponse
from typing import List

router = APIRouter(prefix="/api/v1/characters", tags=["AI Characters"])

@router.get("", response_model=CharacterListResponse)
async def get_characters(
    db: Session = Depends(get_db)
):
    """
    모든 AI 캐릭터 목록 조회
    
    - 6명 캐릭터 정보 반환 (프로필 이미지, 자기소개 음성 URL 포함)
    """
    characters = db.query(AICharacter).all()
    
    return CharacterListResponse(
        characters=[CharacterResponse.from_orm(c) for c in characters]
    )

@router.get("/{character_id}", response_model=CharacterResponse)
async def get_character(
    character_id: str,
    db: Session = Depends(get_db)
):
    """
    특정 AI 캐릭터 조회
    
    character_id: park_jihoon, choi_hyunwoo, oh_kyungmi, 
                  lee_soojin, park_eunseo, jung_yujin
    """
    character = db.query(AICharacter).filter(AICharacter.id == character_id).first()
    
    if not character:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Character not found"
        )
    
    return CharacterResponse.from_orm(character)

@router.get("/{character_id}/introduction", response_model=dict)
async def get_character_introduction(
    character_id: str,
    db: Session = Depends(get_db)
):
    """
    캐릭터 자기소개 정보 조회 (음성 URL + 텍스트)
    
    - Flutter 앱에서 자기소개 음성 재생 시 사용
    """
    character = db.query(AICharacter).filter(AICharacter.id == character_id).first()
    
    if not character:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Character not found"
        )
    
    return {
        "character_id": character.id,
        "name": character.name,
        "audio_url": character.introduction_audio_url,
        "text": character.introduction_text
    }
```

core_api/main.py 라우터 등록:

```python
from core_api.routers import auth, users, families, characters  # characters 추가

app.include_router(characters.router)  # 추가
```

## 완료 기준
- [ ] core_api/models/character.py 작성 (AICharacter 모델)
- [ ] 마이그레이션 생성 및 실행
- [ ] scripts/seed_characters.py 작성 및 실행 (6명 데이터 삽입)
- [ ] scripts/generate_intro_voices.py 작성 및 실행 (음성 생성)
- [ ] 생성된 MP3 파일 확인 (generated_audio/*.mp3)
- [ ] core_api/schemas/character.py 작성
- [ ] core_api/routers/characters.py 작성
  - [ ] GET /api/v1/characters (목록)
  - [ ] GET /api/v1/characters/{id} (단일 조회)
  - [ ] GET /api/v1/characters/{id}/introduction (자기소개)
- [ ] API 문서 확인 (http://localhost:8000/docs)

## 테스트 명령어
```bash
# 캐릭터 목록 조회
curl http://localhost:8000/api/v1/characters

# 특정 캐릭터 조회
curl http://localhost:8000/api/v1/characters/park_jihoon

# 자기소개 정보 조회
curl http://localhost:8000/api/v1/characters/park_jihoon/introduction

# 음성 파일 확인
ls -lh generated_audio/
```

## 보고서 작성
Day 18-21 완료 후 다음을 보고해줘:
1. 생성된 파일 목록
2. 데이터베이스에 삽입된 캐릭터 6명 확인
3. 생성된 MP3 파일 6개 확인
4. API 엔드포인트 테스트 결과
5. 다음 단계 준비 상태

완료했으면 "Day 18-21 완료 보고서"를 작성해줘.
```

---

## 📝 Week 3-4 완료 체크리스트

Day 15-28을 모두 완료하면 다음을 확인하세요:

### Backend
- ✅ OpenAI Realtime API 클라이언트 구현
- ✅ WebSocket 서버 구현
- ✅ 6명 AI 캐릭터 시스템 프롬프트 정의
- ✅ 캐릭터별 음성 매핑 (sage, echo, Cedar, Marin, shimmer, alloy)
- ✅ AI 캐릭터 데이터베이스 모델
- ✅ OpenAI TTS로 자기소개 음성 생성 (6개 MP3)
- ✅ 캐릭터 API 엔드포인트

### API 엔드포인트 (추가 3개)
```
GET    /api/v1/characters
GET    /api/v1/characters/{id}
GET    /api/v1/characters/{id}/introduction
WS     ws://localhost:8001/ws/conversations/{character_id}
```

### 다음 단계
Week 5-6으로 이동: 웨어러블 연동 & 건강 데이터 수집

---

**이 문서는 Claude Code 개발 프롬프트 v1.3의 Day 15-28 부분입니다.**  
**전체 문서: Claude_Code_개발_프롬프트_완전판_v1_3.md**
