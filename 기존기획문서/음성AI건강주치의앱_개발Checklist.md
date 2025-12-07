# 🏥 음성 AI 건강주치의 앱 - 상세 개발 실행 체크리스트

**기반 문서**:
- 개발 기능 상세 요구서 v6.0
- UI/UX 설계 가이드 통합본 v4.0
**총 개발 기간**: 16주 (MVP)
**작성일**: 2025.11.25

---

## 📅 Phase 0: 프로젝트 착수 및 인프라 구축 (Week 1-2)
> **목표**: 안정적인 개발 환경 구성 및 디자인 시스템 코드화

### 0.1 개발 환경 및 협업 설정
- [ ] **Git Repository 설정**
    - [ ] Monorepo 구조 구성 (Frontend/Backend/AI)
    - [ ] Branch 전략 수립 (Git-flow: main, develop, feature/*)
    - [ ] Commit Convention 정의 (Feat, Fix, Chore, Refactor 등)
- [ ] **프로젝트 초기화**
    - [ ] FE: React Native CLI + TypeScript 5.0+ 초기화
    - [ ] BE: Node.js (Express) + TypeScript 설정
    - [ ] AI: Python 3.11+ (FastAPI) 가상환경 설정
- [ ] **Linter/Formatter 설정**
    - [ ] ESLint, Prettier 설정 및 Husky(pre-commit) 연동

### 0.2 인프라 및 데이터베이스 (DevOps/BE)
- [ ] **클라우드 환경 설정 (AWS)**
    - [ ] VPC, Subnet, Security Group 네트워크 구성
    - [ ] IAM 사용자 및 권한 정책 수립
- [ ] **데이터베이스 구축** (v6.0 Sec 8.2 참조)
    - [ ] PostgreSQL 15+ 설치 (RDS) 및 접속 테스트
    - [ ] Chroma DB (Vector DB) Docker 컨테이너 배포 및 영구 저장소 설정
    - [ ] Redis 7+ 클러스터 구성 (세션/캐싱용)
- [ ] **CI/CD 파이프라인 1차**
    - [ ] GitHub Actions: Build 및 Unit Test 자동화 스크립트 작성

### 0.3 디자인 시스템 구현 (FE) (v4.0 Part 1, 2, 4)
- [ ] **Theme 설정**
    - [ ] Color Palette 정의: Primary(#2E7D32), Secondary(#1976D2), Accent(#FF6F00)
    - [ ] Typography 정의: Pretendard 폰트 적용 (H1~Caption)
- [ ] **공통 컴포넌트 개발**
    - [ ] `Button`: Primary, Secondary, Text, FAB 구현
    - [ ] `Card`: Basic Card, Shadow 스타일링
    - [ ] `Input`: TextInput(Floating Label), SelectBox
    - [ ] `Feedback`: Custom Toast, Modal, Bottom Sheet
    - [ ] `Icon`: SVG 아이콘 컴포넌트 시스템 구축

---

## 🧱 Phase 1: 인증 및 가족 프로필 시스템 (Week 3-4)
> **목표**: 사용자 가입 및 데이터 구조의 핵심인 '가족 프로필' 완성

### 1.1 사용자 인증 (Auth) (v6.0 Sec 3.9)
- [ ] **Backend (API)**
    - [ ] `POST /signup`: 비밀번호 bcrypt 암호화 저장
    - [ ] `POST /login`: JWT Access/Refresh Token 발급 로직
    - [ ] 이메일 인증 시스템 구현 (SMTP/SendGrid 연동)
- [ ] **Frontend (UI)** (v4.0 Sec 5.3)
    - [ ] 스플래시 스크린 및 온보딩 슬라이드 구현
    - [ ] 회원가입 폼 (이메일, 비밀번호 유효성 검사)
    - [ ] 로그인 화면 및 자동 로그인 처리 (SecureStorage 토큰 저장)

### 1.2 가족 프로필 관리 (Core) (v6.0 Sec 3.2)
- [ ] **Database Schema 적용**
    - [ ] `users`, `profiles`, `chronic_conditions`, `medications`, `allergies` 테이블 생성
- [ ] **Backend (API)**
    - [ ] `POST /profiles`: 프로필 생성 (이미지 업로드 포함 S3 연동)
    - [ ] `GET /profiles`: 가족 목록 조회
    - [ ] `PUT /profiles/{id}`: 건강 정보 수정
- [ ] **Frontend (UI)** (v4.0 Sec 5.4, 8.1)
    - [ ] **온보딩 Step 2**: 체형 정보 입력 및 BMI 자동 계산 로직 구현
    - [ ] **온보딩 Step 3**: 만성질환/약물 선택 UI (Chip 컴포넌트 활용)
    - [ ] 홈 화면 상단 '가족 선택 캐러셀' 위젯 개발

---

## 🧠 Phase 2: AI 캐릭터 및 RAG 지식베이스 (Week 5-8)
> **목표**: 앱의 핵심 가치인 'AI 주치의'와 '의료 지식' 구축

### 2.1 RAG 지식베이스 구축 (AI/Data) (v6.0 Sec 3.6)
- [ ] **데이터 파이프라인**
    - [ ] 데이터 수집: 국민건강보험공단 47개 증상 가이드, 만성질환 가이드 확보
    - [ ] 전처리(Preprocessing): 텍스트 정제 및 Chunking (500-1000 토큰)
- [ ] **임베딩 및 저장**
    - [ ] OpenAI `text-embedding-3-small` API 연동
    - [ ] Chroma DB 적재 (Metadata: 출처, 카테고리 포함)
- [ ] **검색 엔진 구현**
    - [ ] `ragSearch` 함수 구현: Query Expansion -> Vector Search -> Re-ranking

### 2.2 AI 캐릭터 시스템 (BE/AI) (v6.0 Sec 3.1)
- [ ] **페르소나 정의**
    - [ ] 10명(남5/여5) 캐릭터 DB 데이터 시딩 (`characters` 테이블)
    - [ ] 각 캐릭터별 System Prompt 최적화 (성격, 어투, 전문분야 반영)
- [ ] **OpenAI Realtime API 연동**
    - [ ] WebSocket 서버 구축 (Node.js/Python)
    - [ ] 음성 모델 매핑 (alloy, echo, shimmer 등)

### 2.3 음성 상담 UI/UX (FE) (v4.0 Sec 10)
- [ ] **상담 인터페이스**
    - [ ] 캐릭터 선택 화면 구현 (필터링: 성별/전문분야)
    - [ ] **Visualizer**: 실시간 음성 파형 애니메이션 구현 (Lottie or Custom Canvas)
    - [ ] 상담 중 실시간 STT 텍스트 표시 기능
- [ ] **상담 결과 처리**
    - [ ] 대화 종료 후 상담 요약 리포트 자동 생성 UI
    - [ ] 상담 이력 저장 및 조회 기능

---

## 🛍️ Phase 3: 제품 추천 및 인게이지먼트 (Week 9-12)
> **목표**: 수익 모델(제품 추천) 적용 및 리텐션 기능(루틴) 구현

### 3.1 건강기능식품 추천 시스템 (BE/AI) (v6.0 Sec 3.7)
- [ ] **제품 데이터베이스**
    - [ ] `products`, `ingredients`, `contraindications` 스키마 구현
    - [ ] 식약처 인증 제품 데이터 크롤링 및 적재
- [ ] **추천 엔진 (Safety First)**
    - [ ] RAG 기반 증상-제품 매칭 로직
    - [ ] **Rule-based 필터링 구현**: 사용자 프로필(나이, 만성질환, 약물)과 제품 금기사항 대조 로직 (핵심)
- [ ] **API 개발**
    - [ ] `POST /products/recommend`: 상담 컨텍스트 기반 추천
    - [ ] 제휴 링크(쿠팡/iHerb) 클릭 트래킹 API

### 3.2 제품 및 상담 UI 고도화 (FE) (v4.0 Sec 14)
- [ ] **제품 추천 카드**
    - [ ] 상담 채팅 내 인라인 추천 카드 구현
    - [ ] 안전성 경고 배지(Warning Badge) 및 적합성 이유 표시
- [ ] **제품 상세 화면**
    - [ ] 성분 정보, 섭취 방법, 주의사항 UI
    - [ ] 구매 링크 버튼 연동

### 3.3 데일리 루틴 & 감사 일기 (FE/BE) (v6.0 Sec 3.4, 3.5)
- [ ] **건강 루틴 시스템**
    - [ ] 루틴 템플릿(아침/점심/저녁) DB 시딩
    - [ ] 루틴 체크박스 UI 및 Streak(연속 달성) 로직 구현
- [ ] **감사 일기**
    - [ ] 3가지 감사 항목 입력 및 기분 선택 UI
    - [ ] 캘린더 뷰 및 작성 히스토리 조회 기능

---

## ⌚ Phase 4: 웨어러블 & 플랫폼 고도화 (Week 13-14)
> **목표**: 외부 데이터 연동 및 결제 시스템 탑재

### 4.1 웨어러블 데이터 통합 (v6.0 Sec 3.8)
- [ ] **Terra API 연동 (BE)**
    - [ ] Widget Session 생성 API 및 Webhook 수신 핸들러 구현
- [ ] **Native SDK 연동 (FE)**
    - [ ] Android: Health Connect 권한 요청 및 데이터 Read (걸음, 심박, 수면)
    - [ ] iOS: HealthKit 설정 및 Info.plist 권한 문구 작성
- [ ] **데이터 시각화**
    - [ ] 홈 화면 '오늘의 건강 요약' 카드에 실제 데이터 바인딩

### 4.2 구독 및 결제 시스템 (v6.0 Sec 6)
- [ ] **IAP (In-App Purchase)**
    - [ ] `react-native-iap` 라이브러리 설정
    - [ ] Store(Apple/Google)에 구독 상품(Basic, Premium, Family) 등록
- [ ] **Backend 검증**
    - [ ] 영수증 검증(Receipt Validation) API 구현
    - [ ] 구독 등급별 기능 제한 로직(Middleware) 적용 (가족 수, 상담 횟수 제한 등)

---

## 🧪 Phase 5: QA, 최적화 및 출시 (Week 15-16)
> **목표**: 앱 안정성 확보 및 스토어 배포

### 5.1 테스트 및 QA
- [ ] **단위/통합 테스트**
    - [ ] BE: Jest를 이용한 주요 API(추천, 안전성 체크) 테스트 코드 작성
- [ ] **UI/UX 점검**
    - [ ] 다양한 화면 크기(Phone/Tablet) 대응 확인 (v4.0 Sec 3.3)
    - [ ] 다크 모드 색상 및 가독성 점검 (v4.0 Sec 2.10)
    - [ ] 접근성(WCAG AA) 테스트: 터치 영역 44px+ 및 명암비 확인

### 5.2 보안 및 규정 준수 (v6.0 Sec 10)
- [ ] **개인정보 보호**
    - [ ] DB 내 민감 정보(이름, 전화번호) 암호화 확인
    - [ ] 탈퇴 시 데이터 파기 로직 점검
- [ ] **의료 법적 고지**
    - [ ] 앱 실행 시 및 상담 화면에 '의료 행위 아님' 면책 조항(Disclaimer) 표시 확인
    - [ ] 개인정보처리방침 및 이용약관 앱 내 탑재

### 5.3 배포 준비
- [ ] **스토어 등록 정보**
    - [ ] 앱 아이콘, 스크린샷, 미리보기 영상 제작
    - [ ] 앱 설명 및 키워드 최적화 (ASO)
- [ ] **심사 제출**
    - [ ] Google Play Console / App Store Connect 업로드
    - [ ] 심사 반려 대비 소명 자료 준비 (의료 카테고리 관련)

---

## ✅ 개발 완료 기준 (Definition of Done)
1. 모든 **P0(최우선) 기능**이 구현되고 테스트를 통과했는가?
2. **가족 프로필** 생성 및 전환이 원활한가?
3. **AI 상담** 응답 속도가 3초 이내(Visualizer 포함)이며, 답변이 안전한가?
4. **제품 추천** 시 금기사항(알레르기/질환) 필터링이 정확히 작동하는가?
5. **크래시(Crash)** 없는 안정적인 빌드 상태인가?