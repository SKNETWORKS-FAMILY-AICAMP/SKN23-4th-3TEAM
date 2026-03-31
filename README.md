<div align="center">
  <h1>💧 온유(On_You) :<br />AI 피부 분석 · 성분 OCR · 올리브영 제품 추천 챗봇</h1>
  <div align="center" style="margin: 16px 0 20px 0">
    <img src="front/src/assets/logo.png" width="400">
  </div>
  <b>AI Skin Analysis & OliveYoung Product Recommendation Chatbot</b>
  <p>딥러닝 피부 정량 분석 · VLM 기반 전성분 OCR · LangGraph 오케스트레이션 · 올리브영 실상품 검증 추천</p>
</div>

<br />

<h2><img src="assets/팀로고.png" width="70" style="margin-right: 8px"> Team. <b>King Ghidorah</b> v2.0 </h2>

### 팀원 소개

<div align="center">
  <table>
    <colgroup>
      <col style="width: 20%;">
      <col style="width: 20%;">
      <col style="width: 20%;">
      <col style="width: 20%;">
      <col style="width: 20%;">
    </colgroup>
    <tbody>
      <tr>
        <td align="center"><img src="assets/왼쪽.png" alt="왼쪽날개-송민채"></td>
        <td align="center"><img src="assets/왼쪽 얼굴.png" alt="왼쪽얼굴-정석원"></td>
        <td align="center"><img src="assets/중앙.png" alt="중앙얼굴-강승원"></td>
        <td align="center"><img src="assets/오른쪽 얼굴.png" alt="오른쪽얼굴-정유선"></td>
        <td align="center"><img src="assets/오른쪽 날개.png" alt="오른쪽날개-이승연"></td>
      </tr>
      <tr style="font-weight: bold;">
        <td align="center">송민채</td>
        <td align="center">정석원</td>
        <td align="center">강승원 (팀장)</td>
        <td align="center">정유선</td>
        <td align="center">이승연</td>
      </tr>
      <tr>
        <td align="center">
          <a href="https://github.com/minchaesong"><img src="https://img.shields.io/badge/minchaesong-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub - 송민채"></a>
        </td>
        <td align="center">
          <a href="https://github.com/jsrop07"><img src="https://img.shields.io/badge/jsrop07-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub - 정석원"></a>
        </td>
        <td align="center">
          <a href="https://github.com/chopa4452"><img src="https://img.shields.io/badge/chopa4452-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub - 강승원"></a>
        </td>
        <td align="center">
          <a href="https://github.com/jys96"><img src="https://img.shields.io/badge/jys96-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub - 정유선"></a>
        </td>
        <td align="center">
          <a href="https://github.com/oooonbbo-wq"><img src="https://img.shields.io/badge/oooonbbo wq-181717?style=for-the-badge&logo=github&logoColor=white" alt="GitHub - 이승연"></a>
        </td>
      </tr>
    </tbody>
  </table>
</div>

| 이름 | 담당 업무 |
| :-: | :-- |
| 강승원<br />(PM/LLM/BACK) | ResNet50 기반 피부 정량 분석 모델 학습(Fast/Deep), OCR 모델 비교 평가 및 전환, LangGraph 파이프라인 설계 및 프롬프트 엔지니어링, 웹캠 실시간 얼굴 감지,  FastAPI → Django 전환, 이용약관·개인정보처리방침 작성 |
| 정석원<br />(LLM/FRONT/BACK) | LLM 응답 생성기 구현 및 LLM 라우터, 올리브영 제품 검증 파이프라인, RAG 기반 답변 보강, 프론트엔드 개발, FastAPI 백엔드 개발 |
| 정유선<br />(FRONT/BACK) | React 프론트엔드 개발, FastAPI 백엔드 API 설계 및 개발, ChromaDB 기반 벡터 DB 구축 및 관리, ko-sroberta 임베딩 모델 연동, RAG 기반 검색 파이프라인 구현, 데이터 구조 개선 및 이미지 매핑 처리, 화면 설계, API 문서화, Google PlayStore 앱 배포 |
| 송민채<br />(AWS/BACK/DB) | AWS 인프라(EC2·S3·RDS) 구축 및 운영, MySQL 데이터베이스 설계(ERD) 및 사용자·분석·위시리스트 테이블 구조 설계, FastAPI 백엔드 API 설계 및 개발, 분석 이력 저장 로직 구현 |
| 이승연<br />(AWS/UI/FLUTTER) | 브랜드 아이덴티티 기획, AWS 인프라(EC2·S3·MariaDB) 구축 및 운영, 모바일 앱 UI/UX 디자인 및 API 연동, 피부 MBTI·퍼스널컬러 테스트 콘텐츠 구조 설계, 로고·디자인 이미지·인포그래픽 제작, 플러터 카메라 비전 구현 |

---

---

## 📌 목차

- [1. 프로젝트 기간](#1-프로젝트-기간)
- [2. 프로젝트 개요](#2-프로젝트-개요)
- [3. 경쟁 서비스 비교](#3-경쟁-서비스-비교)
- [4. 정책 및 신뢰성 설계](#4-정책-및-신뢰성-설계)
- [5. 수집된 데이터 및 데이터 전처리](#5-수집된-데이터-및-데이터-전처리)
- [6. 기능 및 모델/파이프라인 설계](#6-기능-및-모델파이프라인-설계)
- [7. 시스템 아키텍처](#7-시스템-아키텍처)
- [8. 데이터베이스 설계](#8-데이터베이스-설계)
- [9. 디렉토리 구조](#9-디렉토리-구조)
- [10. Tech Stack](#10-tech-stack)
- [11. 실행 방법](#11-실행-방법)
- [12. 화면 설계](#12-화면-설계)
- [13. Postman 문서](#13-postman-문서)
- [14. 배포 (AWS / Docker / Nginx)](#14-배포-aws--docker--nginx)
- [15. 시연 화면](#15-시연-화면)
- [16. 트러블 슈팅](#16-트러블-슈팅)
- [17. 비즈니스 전략](#17-비즈니스-전략)
- [18. 한 줄 회고](#18-한-줄-회고)
  
---


---

## 1. 프로젝트 기간

**2025.02.25 ~ 2025.03.25** (29일)

---

## 2. 프로젝트 개요

<div align="center" style="margin: 10px 0 20px 0">
  <img src="assets/logo.gif" width="600" />
</div>

**On You, 오직 당신만을 위한 스킨케어**

On-you(온유)는 화장품에 관심이 많은 20~30대를 대상으로 한 AI 기반 스킨케어 추천 챗봇입니다.

사용자는 대화를 통해 피부 타입·고민·성분·취향을 입력하여 자신에게 적합한 제품을 추천받을 수 있으며 제품의 전성분(성분표) 사진을 촬영/업로드 시, 성분을 추출·분석해 나에게 적합한 성분/주의가 필요한 성분을 안내합니다. 또한 피부 정밀 분석 결과를 통해 현재 피부 상태, 피부 타입, 민감 요인에 맞는 개인 피부관리법을 제공하는 맞춤 스킨케어 서비스입니다.

<br />

### 2.1. 프로젝트 배경 및 목적

<div align="center">
  <img src="assets/뉴스.png" width="500" alt="news1">
  <br />
  <img src="assets/뉴스2.png" width="500" alt="news2">
  <br />
  <img src="assets/뉴스3.png" width="500" alt="news3">
</div>

올리브영은 국내 온라인 뷰티 플랫폼 3사(올리브영·화해·글로우픽) 중에서도 사용자 관심도와 영향력이 가장 높은 플랫폼으로, 화장품 구매와 제품 정보 탐색이 활발하게 이루어지는 대표적인 뷰티 커머스 채널입니다. 이러한 시장 영향력과 사용자 접근성을 고려했을 때, **올리브영 기반의 제품 데이터는 실제 상품 상세 페이지와 연결된 구매 가능 정보를 포함하고 있어, 추천 결과를 실제 구매로 이어지게 할 수 있는 실사용 가치가 높은 데이터**라고 판단했습니다.

현재 올리브영은 매장에서 기기를 통해 피부 상태를 측정하는 체험형 AI 서비스 [스킨스캔(Skin Scan)]을 운영하고 있으며, 진단 결과를 앱에서 조회·관리할 수 있도록 서비스를 고도화하고 있습니다. 그러나 해당 서비스는 매장 방문을 전제로 한 오프라인 중심 서비스로, **시간과 장소의 제약이 있어 사용자가 집에서 즉시 피부 상태를 확인하거나 성분 정보를 분석하고 제품을 추천받기에는 한계**가 있습니다.

이러한 서비스 환경을 바탕으로, **사용자가 스마트폰 앱만으로 언제 어디서나 피부 상태 분석, 성분 분석, 맞춤 제품 추천을 받을 수 있는 홈 기반 스킨케어 챗봇 서비스의 필요성**을 확인하였으며, 이를 기반으로 본 프로젝트를 기획·개발하게 되었습니다.

<br />

### 2.2. 프로젝트 목표

본 프로젝트는 **벡터DB 기반 챗봇 상담, 피부 이미지 분석(빠른 분석/정밀 분석), 전성분 OCR 분석을 결합한 멀티모달 스킨케어 AI 챗봇**으로, 사용자의 피부 상태를 분석하고 성분 기반 추천 포인트를 도출하여 올리브영 실상품 검증 기반 제품 추천 및 위시리스트 저장 기능, 피부 이미지 분석 결과를 기반의 피부 관리법 추천까지 제공하는 서비스 개발을 목표로 합니다.

```mermaid
graph LR
    A["📸 피부 사진 : 1장/3장"] --> B["🔬 Vision : 피부 분석"]
    C["🏷️ 전성분 : 라벨 이미지"] --> D["📝 OCR : 성분 추출"]
    E["💬 피부 고민 : 텍스트/프로필"] --> F["👤 개인화 : 컨텍스트"]
    B --> G["📦 Evidence : Bundle"]
    D --> G["📦 Evidence : Bundle"]
    F --> G["📦 Evidence : Bundle"]
    G --> H["🔍 RAG : 후보 검색"]
    H --> I["✅ 올리브영 : 웹 검증"]
    I --> J["📋 추천/리포트 : 출력"]
    J --> K["💾 위시리스트 : 저장"]
```

> ⚠️ 본 서비스는 의료 진단/치료가 아닌 **스킨케어 정보 제공** 목적입니다.

### 2.3. 시장 규모

- 2025년 올리브영 매출: **5조 8,335억 원 수준**
- 전년 대비 성장률: **21.8%**

### 2.4. N년 후 예상 시장 규모

CJ올리브영의 매출은 2021년 2조 원, 2022년 2조 7,774억 원, 2023년 3조 8,611억 원, 2024년 4조 7,899억 원, 2025년 5조 8,335억 원으로 성장했습니다. 2025년 매출은 전년 대비 21.8% 증가했으며, 2021년부터 2025년까지의 연평균 성장률(CAGR)은 약 30.7% 수준입니다. 

이 흐름을 바탕으로 2025년 매출 5조 8,335억 원을 기준 삼아 3년 뒤 규모를 계산하면,
- **최근 1년 성장률(21.8%)을 기준으로 한 보수적 추정**: 약 **10조 5,000억 원**
- **2021~2025년 연평균 성장률(약 30.7%)을 기준으로 한 확장 추정**: 약 **13조 원**
수준까지 확대될 것으로 예측됩니다.

온유는 이처럼 빠르게 성장하는 뷰티 커머스 환경에서 피부 분석, 전성분 분석, 제품 추천, 퍼스널컬러, 피부 MBTI를 하나의 흐름으로 연결해 **개인화된 뷰티 경험**을 제공하는 AI 서비스로 기획되었습니다.

### 2.5. 기대효과
- 피부 분석, 전성분 분석, 퍼스널컬러, 피부 MBTI를 하나의 사용자 흐름으로 통합
- 단순 추천을 넘어 재방문, 저장, 공유까지 이어지는 서비스 구조 설계
- 올리브영 기반 실사용 제품 추천으로 구매 연결 가능성 강화
- 웹뿐 아니라 앱 확장 구조까지 고려한 서비스로 발전
- AI 기능 시연에 그치지 않고 실제 사용자 경험과 운영 요소까지 반영한 뷰티 AI 플랫폼으로 고도화

---

## 3. 경쟁 서비스 비교

### 3.1. 아이컬러(iColor)

#### 주요 기능 및 특징
- 사진 촬영 기반 퍼스널컬러 진단
- 어울리는 색상 탐색 및 스타일링 추천
- 퍼스널컬러 중심의 뷰티 콘텐츠 제공
- 컬러 진단 결과를 바탕으로 관련 상품/콘텐츠 탐색 지원 

#### 강점
- 퍼스널컬러 진단에 집중된 서비스라 사용 목적이 명확함
- 촬영 기반 진단 구조로 진입 장벽이 낮음

#### 한계점
- 서비스 중심축이 퍼스널컬러에 맞춰져 있어, 피부 정량 분석이나 전성분 분석까지 한 번에 연결되는 구조는 상대적으로 약함
- 스킨케어 상담, 피부 분석 이력 관리, 결과 공유형 리포트 등 확장형 흐름보다는 퍼스널 컬러 진단 중심 경험에 강점이 있음 

---

### 3.2. 잼페이스(Zamface)

#### 주요 기능 및 특징
- AI 피부 진단 및 피부 타입/피부 고민 분석
- 퍼스널컬러 진단
- 화장품 매칭 기능
- 사용자 리뷰 및 유튜버 리뷰 기반 제품 탐색

#### 강점
- 피부 진단과 퍼스널컬러를 함께 제공해 뷰티 앱으로서의 범용성이 높음
- 사용자 리뷰, 유튜버 리뷰, 제품 탐색을 자연스럽게 연결함
- 앱 서비스 운영 경험이 축적되어 있어 콘텐츠 소비와 탐색 흐름이 강함

#### 한계점
- 피부 분석 결과를 날짜별로 누적 비교하거나, 성분표 이미지를 직접 해석하는 흐름은 공개된 소개 기준으로는 상대적으로 덜 강조됨

---

### 3.3. 온유의 차별점

온유는 퍼스널컬러나 피부 진단 중 한 영역에만 집중하기보다, **피부 분석 → 전성분 분석 → 제품 추천 → 퍼스널컬러 진단**까지 이어지는 통합 흐름을 설계한 것이 가장 큰 차별점입니다. 아이컬러가 퍼스널컬러 특화 경험에 강점이 있고, 잼페이스가 진단과 콘텐츠 소비를 함께 제공하는 앱형 경험에 강점이 있다면, 온유는 여기에 **전성분 OCR, 챗봇 기반 상담, 날짜별 분석 이력, 피부 MBTI**까지 결합해 보다 연결된 사용자 경험을 제공하는 방향을 지향합니다.

| 비교 항목 | 온유 | 아이컬러 | 잼페이스 |
|---|---|---|---|
| 핵심 초점 | 피부 분석 + 성분 해석 + 추천 통합 | 퍼스널컬러 특화 | 퍼스널컬러 + 피부 진단 + 콘텐츠 탐색 |
| 피부 분석 리포트 | 빠른/정밀 분석, 이력 기반 확장 | 컬러 진단 중심 | AI 피부 진단 중심 |
| 성분 해석 | OCR/VLM 기반 성분 분석 제공 | 공개 소개 기준 주요 기능 아님 | 공개 소개 기준 주요 기능 아님 |
| 제품 연결 방식 | 챗봇 기반 추천 + 올리브영 연계 | 컬러 기반 탐색 중심 | 매칭 + 리뷰/콘텐츠 탐색 중심 |
| 사용자 경험 확장 | 피부 MBTI, 공유 링크, 날짜별 조회 | 퍼스널컬러 경험 집중 | 앱형 콘텐츠 소비와 탐색 경험 강점 |
| 서비스 포지션 | 통합형 뷰티 AI 어시스턴트 | 컬러 특화형 서비스 | 뷰티 탐색형 앱 서비스 |

#### 정리
- **아이컬러**: 퍼스널컬러 진단에 집중한 특화형 서비스
- **잼페이스**: 퍼스널컬러, 피부 진단, 리뷰 탐색을 결합한 앱형 서비스
- **온유**: 피부 분석, 성분 해석, 추천, 상담, 공유까지 하나의 흐름으로 묶은 통합형 뷰티 AI 서비스 

---

## 4. 정책 및 신뢰성 설계


### 4.1. 개요

본 서비스는 사용자의 **얼굴 사진**, **화장품 라벨 사진**, **피부 분석 결과**, **채팅 대화 내용** 등 민감할 수 있는 개인정보를 처리하며, 해외 AI 서비스(OpenAI API)로의 데이터 전송이 포함되어 있어, 서비스 출시 전 **개인정보 보호법** 및 관련 법령에 부합하는 이용약관과 개인정보처리방침을 수립하였습니다.

> 작성 과정에서 **로톡(LawTalk)** 플랫폼을 통해 6명의 변호사로부터 자문 답변을 받아 법적 쟁점을 검증하였으며, **로폼(LawForm)** 자동작성 서비스로 기본 틀을 생성한 뒤, 온유 서비스 고유의 AI 분석·국외 이전·자동화된 결정 관련 조항을 직접 추가하여 완성하였습니다.

---

### 4.2. 주요 법적 쟁점 및 대응

| 쟁점 | 관련 법령 | 판단 및 대응 |
|------|----------|-------------|
| **얼굴 사진의 법적 성격** | 개인정보보호법 제23조, 시행령 제18조 제3호 | 피부 분석 목적으로 "특정 개인을 알아볼 목적"이 아니므로 민감정보(생체인식정보) 비해당. 단, 법적 리스크를 위해 **별도 동의** 획득 구조 설계 |
| **OpenAI API 국외 이전** | 개인정보보호법 제28조의8 | 이전 국가(미국), 이전받는 자(OpenAI, L.L.C.), 이전 목적, 이전 항목, 보유기간을 **처리방침에 구체적 명시** 및 별도 동의 |
| **AI 자동화된 결정** | 개인정보보호법 제37조의2 | ResNet50·GPT-4.1-mini에 의한 완전 자동 분석 → 분석 기준·절차·처리방식 **공개**, 설명 요구권 안내 |
| **의료행위 해당 여부** | 의료법 | AI 분석 결과는 의료 진단이 아닌 **스킨케어 정보 제공 목적**임을 이용약관에 명시, 면책 조항 포함 |
| **카메라 실시간 얼굴 감지** | 생체정보 보호 가이드라인 | Google ML Kit 온디바이스 처리 → **서버 미전송**, 식별/인증 목적 아님을 처리방침에 명시 |

---

### 4.3. 동의 구조 설계

개인정보보호법 제22조에 따라 각각의 동의 사항을 구분하여 설계하였습니다.

```
[회원가입 시]
 ├─ ☑ [필수] 서비스 이용약관 동의
 ├─ ☑ [필수] 개인정보 수집·이용 동의 (이메일, 비밀번호, 닉네임)
 └─ ☐ [선택] 피부타입·피부고민·성별·나이 수집 동의

[사진 업로드 시 — 별도 동의 팝업]
 ├─ ☑ [필수] 얼굴 사진 수집·이용 및 AI 분석 동의
 └─ ☑ [필수] 개인정보 국외 이전 동의 (OpenAI, 미국)
```

---

### 4.4. 문서 구성

#### 📄 개인정보처리방침 (전 33조)

| 구분 | 조항 | 내용 |
|------|------|------|
| 수집 정보 | 제5~7조 | 필수/선택/AI분석용 수집 항목 및 별도 동의 근거 |
| 수집 방법 | 제8조 | 직접 입력, 사진 업로드, 소셜로그인(Google·Kakao·Naver), 카메라 실시간 촬영, 자동 수집(로그·쿠키) |
| 제3자 제공 | 제10조 | OpenAI, L.L.C.(미국) — 얼굴 검증, 피부 상담, 퍼스널컬러 분석 |
| 처리 위탁 | 제11조 | Amazon Web Services, Inc.(서울 리전) — 인프라 운영 |
| 보유기간 | 제12조 | 항목별 구체적 명시 (얼굴 사진·성분 사진: 사용자 삭제 시까지, 접속 로그: 1년 등) |
| 국외 이전 | 제28조 | 제28조의8 요건 충족 (이전 항목·국가·방법·수령자·목적·보유기간 명시) |
| 자동화된 결정 | 제29조 | 빠른 분석·정밀 분석·퍼스널컬러 분석의 기준·절차 공개, 설명 요구권 |
| 안전성 확보 | 제21조 | bcrypt 암호화, HTTPS/TLS, JWT 인증, 접속 기록 보관 |

#### 📄 서비스 이용약관 (전 22조)

| 구분 | 조항 | 내용 |
|------|------|------|
| AI 분석 한계 및 의료 면책 | 제14조 | 의료행위 아님, 정확성 미보장, 퍼스널컬러는 전문 컬러리스트 대체 불가 |
| 얼굴 사진 처리 특칙 | 제15조 | 본인 사진만 업로드, 타인 사진 금지, 식별 목적 미사용, 카메라 온디바이스 처리 명시 |
| 자동화된 결정 안내 | 제16조 | AI 완전 자동 분석 고지, 설명 요구권·이의 제기권 안내 |
| 면책사항 | 제20조 | AI 분석 결과 오류에 대한 면책, 제품 추천 정보 변경 가능성 |

---

### 4.5. 법적 검증 과정

| 단계 | 내용 |
|------|------|
| **1단계: 법령 조사** | 개인정보보호법, 시행령, 2025년 4월 처리방침 작성지침, 생체정보 보호 가이드라인, 자동화된 결정 안내서 등 관련 법령·가이드라인 조사 |
| **2단계: 변호사 자문** | 로톡(LawTalk) 플랫폼에서 6명의 변호사로부터 무료 답변 수령 — 얼굴 사진의 법적 성격, 동의 분리 구조, 국외 이전, 의료 면책 등 핵심 쟁점 검증 |
| **3단계: 초안 생성** | 로폼(LawForm) 자동작성 서비스로 표준 약관 틀 생성 |
| **4단계: 맞춤 조항 추가** | AI 의료 면책, 자동화된 결정 공개(제37조의2), 국외 이전 상세(제28조의8), 얼굴 사진 처리 특칙, 카메라 온디바이스 처리 명시 등 직접 추가 |
| **5단계: 실제 기능 대조 검증** | 서비스의 모든 기능(피부 분석, 퍼스널컬러, 성분 OCR, 챗봇, 위시리스트 등)과 문서 내용의 1:1 대조 검증 수행 |

4차 프로젝트에서 챗봇의 분석 기능 확장, 개인화 강화, 응답 UX 개선, 입력 품질 보장, 인프라 개선을 수행했습니다.




## 5. 수집된 데이터 및 데이터 전처리

### 5.1. 데이터 출처 및 수집 방식

| 데이터 유형 | 출처 및 수집 방식 | 활용 목적 |
| --- | --- | --- |
| 기능성 화장품 보고품목 | 공공 API (기능성화장품 보고품목 정보, 식약처) | 기능성화장품의 제품 목록 및 상세 정보 수집, 성분 안전성 판단 및 피부 교차 필터링 |
| 화장품 원료 성분 정보 | 공공 API (식약처 화장품 원료성분 정보) | 주의 및 제한 성분 조회 |
| 피부 질병 정보 | 대한피부과학회 웹크롤링 (비회원 공개 페이지) | 피부 질환별 상세 정보 수집 및 상담 근거 확보 |
| 피부 관련 리뷰 논문 | PubMed E-utilities API (논문 요약본) | 피부 장벽, 보습, 항노화 관련 최신 학술 근거 제공 |
| 피부 관리 가이드 | AAD(미국피부과학회) 웹 크롤링 | 피부 상태별 관리 단계 및 루틴 구성 |

※ 수집 제외 항목: 학회 회원 전용 콘텐츠, 라이선스 문제 있는 외부 사이트, 과도한 수집 부담 항목

<br />

### 5.2. 데이터 전처리 파이프라인

#### 5.2.1. 데이터 전처리 과정

- 각 데이터 출처별 문서를 다음과 같이 분류·정리
  - 피부 가이드 (guide) : 피부 고민별 관리, 단계별 관리, 관리 루틴 구성 등
  - 성분 정보 (ingredient) : 성분명, 기능 설명, 피부 타입별 적합성, 성분 간 상호작용, 주의/제한 정보 등
  - 피부 질병 정보 (disease) : 정의, 증상, 원인, 치료, 진단, 합병증 등 상세 항목
  - 기능성화장품 보고품목 (cosmetic_product): 제품명, 효능·효과, 용법·용량, 주의사항, SPF·PA 지수, 방수 여부 등

- 문서 내 청킹 처리: 대용량 문서는 최대 1,000자 단위로 분할하여 RAG(검색 기반 질의응답) 최적화
- 태깅 자동화: 키워드 매칭 방식으로 피부 고민, 성분명, 피부 타입 등 자동 태깅 적용
- 영문 원문은 태깅 후 GPT-4.1-mini 모델을 통해 한국어 요약·번역 적용
- 저장 및 검색 최적화:
  - 통일 JSONL 스키마로 정형화 후 ChromaDB에 저장
  - 한국어 특화 임베딩(jhgan/ko-sroberta-multitask) 사용
  - 중복 제거 및 메타데이터 기반 다중 필터링 적용
  - 기능성화장품 보고품목: 염모, 제모, 탈모, 샴푸 등 피부 분석 목적에 맞지 않는 헤어·두피 제품을 키워드 필터링으로 제거
  - 기능성화장품 보고품목: CANCEL_APPROVAL_YN 값이 'Y'인 제품을 제외하여 최신 유효 데이터만

<br />

#### 5.2.2. 주요 전처리 시스템 및 스키마

- 통일된 JSONL 스키마

```json
{
  "id": "고유 문서 ID",
  "doc_type": "guide | ingredient | disease | cosmetic_product",
  "category": "대분류 주제",
  "skin_type": ["피부 타입 리스트"],
  "concern_tag": ["피부 고민 키워드"],
  "ingredient_tag": ["주요 성분명"],
  "source": "데이터 출처",
  "chunk_index": "분할 순서",
  "content": "전처리된 텍스트 본문"
}
```

---

### 5.3. 수집 데이터 현황

<div>
  <table>
    <tr>
      <td valign="top">
        <h4 align="center">피부 가이드 (guide)</h4>
        <table>
          <thead><tr><th>카테고리</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>피부 타입별 관리</td><td>완료</td></tr>
            <tr><td>피부 장벽 관리</td><td>완료</td></tr>
            <tr><td>여드름/트러블 관리</td><td>완료</td></tr>
            <tr><td>미백·색소 관리</td><td>완료</td></tr>
            <tr><td>안티에이징 관리</td><td>완료</td></tr>
            <tr><td>민감 피부 진정 관리</td><td>완료</td></tr>
            <tr><td>모공 관리</td><td>완료</td></tr>
            <tr><td>단계별 관리 (mild→severe)</td><td>완료</td></tr>
            <tr><td>아침/저녁 데일리 루틴</td><td>완료</td></tr>
            <tr><td>주기적 관리 루틴</td><td>완료</td></tr>
            <tr><td>피해야 할 습관</td><td>완료</td></tr>
          </tbody>
        </table>
      </td>
      <td valign="top">
        <h4 align="center">성분 정보 (ingredient)</h4>
        <table>
          <thead><tr><th>항목</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>성분명·기능 설명</td><td>완료</td></tr>
            <tr><td>피부 타입별 적합성 설명</td><td>완료</td></tr>
            <tr><td>성분 간 시너지/충돌 관계</td><td>완료</td></tr>
            <tr><td>농도별 효과 차이 설명</td><td>완료</td></tr>
            <tr><td>주의/제한 성분 여부 및 이유</td><td>완료</td></tr>
            <tr><td>부작용 가능성</td><td>완료</td></tr>
          </tbody>
        </table>
      </td>
    </tr>
    <tr>
      <td valign="top">
        <h4 align="center">피부 질병 정보 (disease)</h4>
        <table>
          <thead><tr><th>항목</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>피부 질병별 상세 설명</td><td>완료</td></tr>
          </tbody>
        </table>
      </td>
      <td valign="top">
        <h4 align="center">화장품(제품) 목록 (cosmetic_product)</h4>
        <table>
          <thead><tr><th>항목</th><th>상태</th></tr></thead>
          <tbody>
            <tr><td>기능성 화장품 보고 품목</td><td>완료</td></tr>
          </tbody>
        </table>
      </td>
    </tr>
  </table>

  <h3>태그별 수집 개수</h3>
  <img src="assets/vector_data.png"  />
</div>

---

## 6. 기능 및 모델/파이프라인 설계

### 6.1. 핵심 기능 요약

| 기능 | 설명 | 사용 모델/기술 |
| :-: | :-- | :-- |
| 🔬 빠른 분석 | 정면 사진 1장 → 수분/탄력/주름/모공/색소 5개 항목 정량 분석 | ResNet50 (Fast Model) |
| 🔬 정밀 분석 | 정면+좌+우 3장 → 부위별(이마/볼/턱/눈가) 13개 지표 정밀 분석 | ResNet50 + AttentionFusion (Deep Model) |
| 📸 얼굴 검증 | 업로드 이미지가 사람 얼굴인지 + 3장 순서 검증 | GPT-4.1-mini (Vision) |
| 🏷️ 성분 분석 | 화장품 전성분 라벨 사진 → vlm 추출 → 피부타입 맞춤 성분 해석 | Qwen2.5-VL 7B |
| 🎨 퍼스널컬러 분석 | 정면 얼굴 사진 1장 → 14타입 퍼스널컬러 판정 + 컬러 팔레트 생성 | GPT-4o Vision + GPT-4.1-mini |
| 💬 피부 상담 | 자연어 질문 → RAG 기반 근거 답변 (루틴/성분/고민) | GPT-4.1-mini + ChromaDB |
| 🛒 제품 추천 | 키워드 추출 → 올리브영 실상품 URL 검증 → 검증된 제품만 추천 | GPT-4.1-mini + Tavily |
| 🤖 intent 라우팅 | 사용자 입력을 14개 intent로 분류 (비로그인/회원 분기) | GPT-4.1-mini |
| 📷 웹캠 얼굴 감지 | 브라우저에서 실시간 얼굴 감지 후 자동 촬영 | TensorFlow.js + MediaPipe FaceDetector |
| 🧬 피부 MBTI 연동 | MBTI 결과를 챗봇 프롬프트에 자동 주입하여 맞춤 답변 생성 | DB Context Builder + GPT-4.1-mini |
| ⏳ 로딩 UX | 파이프라인 단계별 SSE 진행 메시지 + 피부 상식 모달 | SSE + React Modal |
| 💾 위시리스트 | 추천 제품 저장/조회/삭제 | MySQL/MariaDB |
| 📊 분석 이력/비교 | 날짜별 피부 분석 결과 조회 및 2개 시점 비교 | FastAPI + MySQL/MariaDB |
| 🚪 온보딩 UX | 회원가입 후 튜토리얼 모달로 핵심 기능 안내 | React Modal + Router |
| 👤 마이페이지/계정 관리 | QnA, 관리자 문의 관리, 회원탈퇴, 닉네임 중복 확인/랜덤 생성 | FastAPI + MySQL/MariaDB |
| 🐶 챗봇 페르소나 | ‘옹글이’ 페르소나 기반 공감형·설명형 대화 경험 제공 | Persona Prompting + SSE |

<br />

### 6.2. 피부 분석 딥러닝 모델

**■ 데이터셋**

<table>
  <thead>
    <tr>
      <th align="center">항목</th>
      <th align="left">내용</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td align="center">출처</td>
      <td><a href="https://www.aihub.or.kr/aihubdata/data/view.do?dataSetSn=71645">AI Hub — 한국인 피부상태 측정 데이터</a></td>
    </tr>
    <tr>
      <td align="center">라벨 구조</td>
      <td>얼굴 9개 Area(0~8)별 JSON — 전문 장비 측정값(수분/탄력/주름Ra/모공/색소) + 전문가 등급(0~6)</td>
    </tr>
    <tr>
      <td align="center">정규화</td>
      <td>고정 분모 방식 (moisture /100, R2 그대로, Ra /50, pore /2500~2600, count /350)</td>
    </tr>
  </tbody>
</table>
<br />

**■ 학습 환경**

|    항목     |           Fast Model           |       Deep Model        |
| :---------: | :----------------------------: | :---------------------: |
|     GPU     |      RunPod RTX 5090 × 5       |   RunPod RTX 5090 × 5   |
|   병렬화    | DataParallel + GPU별 Area 분산 | GPU별 Area 분산 (spawn) |
| 이미지 크기 |           128 × 128            |        256 × 256        |
| Batch Size  |    32 × GPU수 (자동 스케일)    |           32            |
|   Epochs    |      100 (Early Stop 30)       |   100 (Early Stop 30)   |
|  Precision  |     FP16 (Mixed Precision)     | FP16 (Mixed Precision)  |

<br />

---

#### 6.2.1. Fast Model (빠른 분석)

**■ 개요**

정면 이미지 **1장**으로 수분·탄력·주름·모공·색소 5가지 피부 지표를 0.5초 내에 측정합니다. 각 얼굴 영역(Area)별로 독립된 ResNet50 모델이 회귀(수치)와 분류(등급)를 동시에 예측하고, 영역별 결과를 평균하여 최종 5개 항목 수치와 1~5등급을 산출합니다.

<br />

**■ 모델 아키텍처**

```
정면 이미지 1장
      ↓
Area별 Bbox Crop (JSON 메타데이터 기반)
      ↓
┌──────────────────────────────────────────────┐
│  Area별 SkinAreaModel (총 8개 독립 모델)      │
│                                              │
│  ResNet50 Backbone (ImageNet Pretrained)     │
│       ↓ Feature (2048-d)                     │
│       ├─▶ Regression Head                   │
│       │     Linear(2048,256) → ReLU          │
│       │     → Dropout(0.3)                   │
│       │     → Linear(256, reg_out)           │
│       │     → Sigmoid                        │
│       │     출력: 0~1 정규화 수치             │
│       │                                      │
│       └─▶ Classification Head               │
│             Linear(2048,256) → ReLU          │
│             → Dropout(0.3)                   │
│             → Linear(256, cls_out)           │
│             출력: 0-6 등급 logits            │
└──────────────────────────────────────────────┘
      ↓
Area별 수치 → 항목별 평균 집계
      ↓
5개 항목 수치(0~1) + 등급(1~5) 반환
```

<br />

**■ Area별 출력 매핑**

| Area | 부위     | Regression 출력                     | Classification 출력                           |
| :--: | :------- | :---------------------------------- | :-------------------------------------------- |
|  0   | 색소침착 | pigmentation_count (1개)            | —                                             |
|  1   | 이마     | moisture, elasticity_R2 (2개)       | forehead_wrinkle(7), forehead_pigmentation(6) |
|  2   | 미간     | —                                   | glabellus_wrinkle (7)                         |
|  3   | 왼눈가   | l_perocular_wrinkle_Ra (1개)        | l_perocular_wrinkle (7)                       |
|  4   | 오른눈가 | r_perocular_wrinkle_Ra (1개)        | r_perocular_wrinkle (7)                       |
|  5   | 왼볼     | moisture, elasticity_R2, pore (3개) | l_cheek_pore(6), l_cheek_pigmentation(6)      |
|  6   | 오른볼   | moisture, elasticity_R2, pore (3개) | r_cheek_pore(6), r_cheek_pigmentation(6)      |
|  8   | 턱       | moisture, elasticity_R2 (2개)       | chin_wrinkle (7)                              |

<br />

**■ 최종 5개 항목 집계 방식**

|        항목         | 사용 Area                                  |  집계  |
| :-----------------: | :----------------------------------------- | :----: |
|   moisture (수분)   | Area 1(이마) + 5(왼볼) + 6(오른볼) + 8(턱) |  평균  |
|  elasticity (탄력)  | Area 1(이마) + 5(왼볼) + 6(오른볼) + 8(턱) |  평균  |
|   wrinkle (주름)    | Area 3(왼눈가) + 4(오른눈가)               |  평균  |
|     pore (모공)     | Area 5(왼볼) + 6(오른볼)                   |  평균  |
| pigmentation (색소) | Area 0                                     | 단일값 |

<br />

**■ 학습 설정**

|         항목          | 설정                                                                                      |
| :-------------------: | :---------------------------------------------------------------------------------------- |
|       Optimizer       | Adam (lr=1e-4 × GPU수, Linear Scaling Rule)                                               |
|     Weight Decay      | 1e-4                                                                                      |
|   Loss (Regression)   | L1Loss (NaN 마스킹)                                                                       |
| Loss (Classification) | CrossEntropyLoss × 0.5 가중치                                                             |
|     Augmentation      | RandomHorizontalFlip(0.3), ColorJitter(brightness=0.3, contrast=0.3), RandomRotation(10°) |
|    Early Stopping     | 30 epochs patience                                                                        |

<br />

**■ 평가 지표**

**Regression — Validation MAE** (0~1 정규화 기준, 낮을수록 정확)

> MAE 0.07 = 예측값이 실제값에서 평균 ±7% 오차 (예: 수분 60 → 53~67 예측)

| Area | 부위          | Best val_MAE |
| :--: | :------------ | :----------: |
|  0   | 색소침착      |  **0.0615**  |
|  1   | 이마          |  **0.0744**  |
|  3   | 왼눈가        |  **0.0361**  |
|  4   | 오른눈가      |  **0.0343**  |
|  5   | 왼볼          |  **0.0734**  |
|  6   | 오른볼        |  **0.0730**  |
|  8   | 턱            |  **0.0857**  |
|      | **전체 평균** |  **0.0626**  |

<br />

**■ 등급 매핑 (Sigmoid → Grade)**

```python
def value_to_grade(value, n_grades=5):
    return min(int(value * n_grades) + 1, n_grades)
 0.0~0.2 → 1등급 | 0.2~0.4 → 2등급 | 0.4~0.6 → 3등급 | 0.6~0.8 → 4등급 | 0.8~1.0 → 5등급
```

<br />

**■ 반환값 예시**

```json
{
  "mode": "fast",
  "skin_metrics": {
    "moisture": { "value": 0.652, "grade": 4 },
    "elasticity": { "value": 0.621, "grade": 4 },
    "wrinkle": { "value": 0.382, "grade": 2 },
    "pore": { "value": 0.21, "grade": 2 },
    "pigmentation": { "value": 0.272, "grade": 2 }
  }
}
```

- `value`: 0~1 Sigmoid 정규화 수치 (각 부위 Area 평균)
- `grade`: 1~5등급 (5가 최고)

<br />

---

#### 6.2.2. Deep Model (정밀 분석)

**■ 개요**

정면(F) + 좌측(L) + 우측(R) **3장**의 이미지를 입력받아 부위별 13개 정밀 측정값, 10개 등급, 항목별 신뢰도를 산출합니다. 핵심 설계 결정은 **Regression과 Classification의 인코더를 분리**한 것입니다. 수치 측정값은 전문 장비가 정면(F) bbox 기반으로 측정하므로 F 이미지만 사용하고, 등급 판정은 다각도 정보가 유리하므로 F+L+R을 Attention Fusion으로 융합합니다.

<br />

**■ 모델 아키텍처 (v4: Triple-Encoder Attention Fusion)**

```
정면(F) + 좌측(L) + 우측(R) 이미지 3장
    ↓
Area별 Bbox Crop
    ↓
┌──────────────────────────────────────────────────────────────┐
│  Area별 DeepAreaModel                                        │
│                                                              │
│  ┌─ Regression Branch (F만) ──────────────────────────────┐  │
│  │  ResNet50 Encoder (F)                                  │  │
│  │      ↓ Feature (2048-d)                               │  │
│  │  Linear(2048,512) → BN → ReLU → Dropout(0.4)         │  │
│  │  → Linear(512,256) → ReLU → Dropout(0.4)             │  │
│  │  → Linear(256, reg_out)                               │  │
│  │  출력: 0~1 정규화 수치                                 │  │
│  └────────────────────────────────────────────────────────┘  │
│                                                              │
│  ┌─ Classification Branch (F+L+R Attention Fusion) ───────┐  │
│  │  ResNet50 Shared Encoder                               │  │
│  │      F → feat_F (2048-d)                              │  │
│  │      L → feat_L (2048-d)                              │  │
│  │      R → feat_R (2048-d)                              │  │
│  │          ↓                                            │  │
│  │  ┌─ AttentionFusion ─────────────────────────────┐    │  │
│  │  │  concat(F,L,R) → Linear(6144,3) → Softmax    │    │  │
│  │  │  = 가중치 w_F, w_L, w_R                       │    │  │
│  │  │  fused = w_F·F + w_L·L + w_R·R               │    │  │
│  │  │  → Linear(2048,512) → BN → ReLU → Drop(0.4)  │    │  │
│  │  └───────────────────────────────────────────────┘    │  │
│  │          ↓ (512-d)                                    │  │
│  │  Linear(512,256) → ReLU → Dropout(0.4)               │  │
│  │  → Linear(256, cls_out)                               │  │
│  │  출력: 0~6 등급 logits                                │  │
│  └────────────────────────────────────────────────────────┘  │
└──────────────────────────────────────────────────────────────┘
```

<br />

**■ v4 핵심 설계 의도:**

| 설계 결정                           | 이유                                                                    |
| :---------------------------------- | :---------------------------------------------------------------------- |
| Regression은 F(정면)만 사용         | 전문 장비 측정값(수분, 탄력 등)이 정면 bbox 기반이므로 동일 앵글이 최적 |
| Classification은 F+L+R Fusion       | 등급 판정은 여러 각도에서 본 종합 정보가 더 정확                        |
| Attention 방식 가중 합산            | 단순 concat/평균 대비 각 각도의 기여도를 학습, 품질 낮은 사진 자동 감쇠 |
| 인코더 가중치 공유 (Classification) | F/L/R에 동일 ResNet50을 적용하여 파라미터 효율 + 일관된 피처 공간       |

<br />

**■ 학습 설정**

|         항목          | 설정                                                                                       |
| :-------------------: | :----------------------------------------------------------------------------------------- |
|       Optimizer       | Adam (lr=1e-4, betas=(0.9, 0.999), weight_decay=0)                                         |
|      LR Schedule      | Warmup 5 epochs → Cosine Annealing (min_factor=0.01)                                       |
|   Loss (Regression)   | **CharbonnierLoss** (ε=1e-6) — L1보다 이상치에 강건하고 L2보다 스파이크에 둔감             |
| Loss (Classification) | **FocalLoss** (α=1, γ=3) × 0.5 가중치 — 클래스 불균형(등급 0~6) 대응                       |
|   Gradient Clipping   | max_norm=1.0                                                                               |
|        Sampler        | **WeightedRandomSampler** — 소수 등급 과소대표 방지                                        |
|     Augmentation      | RandomHorizontalFlip(0.3), ColorJitter(0.15/0.15/0.1/0.05), RandomAffine(5°, translate=2%) |
|    Early Stopping     | 30 epochs patience                                                                         |

<br />

**■ Loss 함수 상세**

**► CharbonnierLoss (Regression)**

```
L(pred, target) = mean( sqrt( (pred - target)² + ε² ) )
```

L1Loss의 smooth 버전으로, 원점 근처에서 미분 가능하여 학습이 안정적이고, L2Loss 대비 이상치에 덜 민감합니다.

<br />

**► FocalLoss (Classification)**

```
FL(p_t) = -α × (1 - p_t)^γ × log(p_t)
```

γ=3으로 설정하여 쉬운 샘플(높은 확신)의 loss를 크게 줄이고, 어려운 샘플(소수 등급)에 집중합니다. 피부 등급 데이터는 중앙값 등급에 편중되는 경향이 있어 이를 보완합니다.

<br />

**■ 평가 지표**

Deep Model은 수치(수분, 탄력, 주름Ra 등)와 등급(주름, 모공, 색소 등)을 동시에 예측하므로, **수치 항목은 MAE**, **등급 항목은 ±1 정확도**로 각각 평가합니다.

**► Regression — Validation MAE** (0~1 정규화 기준)

> MAE 0.05 = 예측값이 실제값에서 평균 ±5% 오차 (예: 수분 65 → 60~70 예측)

| Area | 부위     | Best val_MAE |
| :--: | :------- | :----------: |
|  0   | 색소침착 |  **0.0904**  |
|  1   | 이마     |  **0.0799**  |
|  3   | 왼눈가   |  **0.1055**  |
|  4   | 오른눈가 |  **0.0826**  |

**► Classification — ±1 정확도** (예측 등급이 실제 등급과 1단계 이내일 확률)

> ±1 정확도 90% = 100명 중 90명은 실제 등급 ±1 이내로 예측

| Area | 부위     | ±1 정확도 |
| :--: | :------- | :-------: |
|  1   | 이마     | **93.5%** |
|  2   | 미간     | **79.4%** |
|  3   | 왼눈가   | **90.0%** |
|  4   | 오른눈가 | **69.2%** |

<br />

**■ 출력 구조**

Deep Model은 3가지 정보를 반환합니다:

| 필드           | 설명                             | 예시                                                       |
| :------------- | :------------------------------- | :--------------------------------------------------------- |
| `measurements` | 실제 단위로 역정규화된 수치 13개 | 수분 0~100, 탄력 0~1, 주름Ra 0~50, 모공 0~2600, 색소 0~350 |
| `grades`       | 전문가 등급 기준 분류 10개       | 0~6등급 (0=최저)                                           |
| `reliability`  | 항목별 예측 신뢰도               | high / medium / low / very_low                             |

<br />

**■ 반환값 예시**

```json
{
  "mode": "deep",
  "measurements": {
    "forehead_moisture": 65.2,
    "l_cheek_moisture": 70.1,
    "r_cheek_moisture": 68.5,
    "chin_moisture": 55.3,
    "forehead_elasticity_R2": 0.621,
    "l_cheek_elasticity_R2": 0.587,
    "r_cheek_elasticity_R2": 0.563,
    "chin_elasticity_R2": 0.41,
    "l_perocular_wrinkle_Ra": 18.5,
    "r_perocular_wrinkle_Ra": 20.1,
    "pigmentation_count": 95.0,
    "l_cheek_pore": 2.0,
    "r_cheek_pore": 2.0
  },
  "grades": {
    "forehead_wrinkle": 1,
    "glabellus_wrinkle": 2,
    "l_perocular_wrinkle": 3,
    "r_perocular_wrinkle": 3,
    "l_cheek_pore": 2,
    "r_cheek_pore": 2,
    "l_cheek_pigmentation": 2,
    "r_cheek_pigmentation": 3,
    "chin_wrinkle": 1,
    "forehead_pigmentation": 1
  },
  "reliability": {
    "forehead_moisture": "medium",
    "forehead_elasticity_R2": "high",
    "l_perocular_wrinkle_Ra": "low"
  }
}
```

<br />

---

#### 6.2.3. Fast vs Deep 비교 요약

|                    |            Fast Model            |                     Deep Model                     |
| :----------------: | :------------------------------: | :------------------------------------------------: |
|      **입력**      |             정면 1장             |               정면 + 좌측 + 우측 3장               |
|  **이미지 크기**   |            128 × 128             |                     256 × 256                      |
|    **아키텍처**    | Area별 ResNet50 (Single Encoder) | Area별 ResNet50 + AttentionFusion (Triple Encoder) |
|   **Regression**   |      L1Loss + Sigmoid 출력       |           CharbonnierLoss + Linear 출력            |
| **Classification** |         CrossEntropyLoss         |            FocalLoss + WeightedSampler             |
|   **출력 수치**    |       5개 항목 (영역 평균)       |                 13개 부위별 측정값                 |
|   **출력 등급**    |        1~5등급 (5개 항목)        |                0~6등급 (10개 부위)                 |
|     **신뢰도**     |               없음               |          항목별 high/medium/low/very_low           |
|   **추론 속도**    |              ~0.5초              |                        ~2초                        |
|    **평균 MAE**    |              0.0626              |                       0.0896                       |
|      **용도**      |     빠른 피부 상태 스크리닝      |            부위별 정밀 분석 + 좌우 비교            |

<br />

#### 6.2.4. 피부타입 판정

두 모델 모두 수치 예측 후, **규칙 기반 알고리즘**으로 5가지 피부타입(건성/지성/복합성/중성/민감성)을 확정합니다. LLM이 아닌 수치 기반으로 판정하여 일관성을 보장합니다.

<br />

**► Fast Model 판정 기준 (0~1 Sigmoid 수치 기반):**

| 피부타입 | 판정 조건                                                    |
| :------: | :----------------------------------------------------------- |
|  민감성  | elasticity ≤ 0.46 AND pigmentation ≥ 0.50 AND wrinkle ≥ 0.50 |
|   건성   | moisture ≤ 0.46 AND pore ≤ 0.48                              |
|   지성   | pore ≥ 0.48 AND pigmentation ≥ 0.50 AND moisture > 0.46      |
|  복합성  | moisture ≤ 0.48 AND pore ≥ 0.46 (건조+지성 공존)             |
|   중성   | 전반적 양호, 극단 항목 없음                                  |

**► Deep Model 판정 기준 (실제 측정값 기반):**

| 피부타입 | 판정 조건                                                       |
| :------: | :-------------------------------------------------------------- |
|  민감성  | 평균 탄력 ≤ 0.48 AND (평균 주름Ra ≥ 22 OR 색소 ≥ 120)           |
|   건성   | 건조 부위 3곳 이상 AND 평균 탄력 ≤ 0.50, 또는 평균 수분 ≤ 53    |
|   지성   | 평균 모공 ≥ 900 AND 평균 수분 ≥ 62                              |
|  복합성  | 좌우 볼 수분 차이 ≥ 12, 또는 최대 모공 ≥ 900 AND 최소 수분 ≤ 52 |
|   중성   | 평균 수분 ≥ 60 AND 평균 탄력 ≥ 0.50 AND 평균 모공 ≤ 800         |

<br />

### 6.3. 성분 OCR & 성분 분석

#### 6.3.1. 모델 정보

|    항목     | 내용                                                  |
| :---------: | :---------------------------------------------------- |
| 베이스 모델 | Qwen/Qwen2.5-VL-7B-Instruct                           |
|  모델 유형  | Vision-Language Model (VLM)                           |
|  파라미터   | 7B                                                    |
|   정밀도    | float16 + Flash Attention 2                           |
|    VRAM     | ~15GB _(입력 해상도/visual token budget에 따라 변동)_ |
|  추론 환경  | NVIDIA RTX 5090 (RunPod)                              |
|  라이선스   | Apache-2.0 _(상업적 사용 가능)_                       |

<br />

#### 6.3.2. 핵심: OCR이 아닌 VLM 방식

기존 OCR(Tesseract, PaddleOCR)은 "글자를 읽는" 도구에 가깝고, 본 시스템은 이미지의 **맥락과 의미를 이해**하여 전성분만 골라냅니다.  
`[전성분]` 라벨을 시각적으로 인식하고, 마케팅 문구/설명 문장과 성분 목록을 **의미 차원에서 구분**하며, 곡면·그림자·작은 글씨에도 상대적으로 강건합니다.

<br />

#### 6.3.3. 왜 VLM이 전성분에 유리한가?

- **레이아웃/문서형 이미지에 강함**: 전성분은 “문서/라벨” 형태로 배치되는 경우가 많아, 문서형 시각 질의응답(DocVQA) 성격에 가까움
- **규칙 기반 후처리 의존도 감소**: “전성분 구간만 추출”을 정규식/좌표 규칙에만 맡기지 않고, 모델이 의미적으로 판별
- **속도-정확도 튜닝 가능**: 입력 해상도(visual token budget)를 제한해 처리시간/VRAM을 조절 가능 _(품질 ↔ 속도 트레이드오프)_

<br />

#### 6.3.4. Flash Attention 2 사용 이유 & 주의사항

- **이유**: 긴 컨텍스트·멀티모달 입력에서 메모리/속도 효율 개선
- **주의**: FA2는 일반적으로 `float16/bfloat16` 설정이 필요합니다. dtype 미설정/FP32로 동작하면 경고 또는 성능 저하/오류가 발생할 수 있어, 추론 초기화 시 dtype을 명시합니다.

<br />


<br />

#### 6.3.5. 성능 비교 (vs 기존 OCR)

|     평가 항목      | Tesseract OCR | PaddleOCR + 후처리 | **본 모델 (VLM)** |
| :----------------: | :-----------: | :----------------: | :---------------: |
|  곡면 텍스트 처리  |       ✗       |         △          |       **✓**       |
| 마케팅 문구 필터링 |       ✗       |   △ (규칙 기반)    | **✓ (의미 이해)** |
|  성분 분리 정확도  |       ✗       |  △ (오분리 발생)   |       **✓**       |
|   평균 처리 속도   |     0.5초     |      0.5~1초       |     **2~5초**     |

<br />

#### 6.3.6. 정확도 (3종 테스트 이미지 기반)

|         지표         |   결과   |
| :------------------: | :------: |
| 성분 검출률 (Recall) | **~95%** |
|  정밀도 (Precision)  | **~98%** |
|  마케팅 문구 필터율  | **~99%** |
|   성분 분리 정확도   | **~93%** |

> ⚠️ 3종 테스트 이미지 기반 추정치이며, 이미지 품질(해상도, 조명, 초점)에 따라 달라질 수 있습니다.

<br />

#### 6.3.7. 파이프라인 흐름

1. **성분 OCR(VLM)**: 이미지 → 전성분 텍스트/리스트 추출
2. **정규화(Normalization)**: 쉼표/중복/특수문자 제거, INCI 유사 표기 통일(가능한 범위)
3. **성분 매칭/분류**: 사용자 피부타입/고민과 매칭하여
   - 적합 성분 / 주의 성분 / 비추천 성분으로 태깅
4. **LLM 설명 생성**: 성분별 기능/주의사항을 자연어로 요약하여 사용자에게 제공

<br />

---

### 6.4. 제품 추천 (올리브영 검증)

#### 6.4.1 개요: “추천”이 아니라 “검증된 추천”

- 단순 웹검색 결과를 그대로 추천하지 않고, **올리브영 상품 상세 URL**로 실재성이 검증된 제품만 추천합니다.
- URL이 확인되지 않은 제품은 **절대 추천하지 않음** _(안전장치/신뢰성 핵심 정책)_

<br />

#### 6.4.2. 추천 파이프라인 (3-Stage)

1. **1차 후보 생성: RAG(ChromaDB)**
   - 제품/가이드 문서에서 후보를 검색해 “추천 후보 리스트” 구성
2. **2차 검증: Tavily 웹 검색**
   - 후보 제품명이 실제 올리브영에 존재하는지 웹에서 확인
3. **3차 생성: 검증 통과 제품만 LLM 입력**
   - 검증된 제품(상품 상세 URL 포함)만 근거로 추천 답변 생성

<br />

#### 6.4.3. URL 검증 정책(권장 명시)

- **Allowlist**: “올리브영 상품 상세” 패턴만 통과
  - 예: `.../store/goods/getGoodsDetail.do?goodsNo=...`
- **Reject**: 기획전/브랜드관/콘텐츠(매거진/셔터 등) URL은 상품 상세가 아니므로 제외
- **(선택) 2차 실재성 체크**: 후보 URL의 페이지에서 상품명/가격/옵션 등 핵심 요소 존재 여부 확인

<br />

#### 6.4.4. Tavily 검색 전략(2단계 운영)

- **정밀 단계(상품 상세 우선)**: `브랜드 + 제품명 + getGoodsDetail` 등으로 상품 상세 URL 우선 확보
- **완화 단계(폴백)**: 상품 상세가 안 잡히면 카테고리/라인 단위로 넓혀 후보를 확보한 뒤, 위 URL 정책으로 재필터링

> 이 2단계 전략을 통해 “기획전 링크만 잔뜩 걸리는 문제”를 구조적으로 완화합니다.

<br />

### 6.5. LangGraph 파이프라인

#### 6.5.1. 개요

사용자 메시지가 입력되면 LangGraph 기반의 **6-노드 DAG(방향 비순환 그래프)** 가 순차·병렬로 실행되어 최종 응답을 생성합니다. 기존 단일 `pipeline.py`의 절차적 흐름을 **선언적 그래프**로 전환하여, 각 노드의 역할을 분리하고 조건부 엣지로 불필요한 처리를 건너뛸 수 있도록 설계했습니다.

<br />

#### 6.5.2. 그래프 흐름

```
                        START
                          │
                   ┌──────┴──────┐
                   │  route_node │  GPT-4.1-mini로 intent 분류
                   └──────┬──────┘
                          │
                  route_condition 분기
                   ╱                ╲
          "instant"                  "continue"
              │                          │
             END                 ┌───────┴───────┐
     (greeting,                  │ context_node  │  프로필 로드 + 맥락 판단
      out_of_domain,             └───────┬───────┘
      login_required,                    │
      ask_for_context)          context_condition 분기
                                 ╱                ╲
                        "instant"                  "continue"
                            │                          │
                           END                 ┌───────┴───────┐
                    (맥락 부족 역질문)           │  vision_node  │  Fast/Deep 모델 추론
                                               └───────┬───────┘
                                                       │
                                               ┌───────┴───────┐
                                               │  search_node  │  RAG + Tavily 병렬
                                               └───────┬───────┘
                                                       │
                                               ┌───────┴───────┐
                                               │   llm_node    │  GPT-4.1-mini 답변 생성
                                               └───────┬───────┘
                                                       │
                                               ┌───────┴───────┐
                                               │ validate_node │  스키마 검증 + DB 저장
                                               └───────┬───────┘
                                                       │
                                                      END
```

#### 6.5.3. 노드 상세

**■ route_node — Intent 분류 (1~3초)**

| 항목     | 내용                                                                                 |
| :------- | :----------------------------------------------------------------------------------- |
| **역할** | 사용자 메시지를 14개 intent 중 하나로 분류                                           |
| **모델** | GPT-4.1-mini (temperature=0.0, JSON mode)                                            |
| **분기** | 비로그인(`_llm_decide_guest`) / 회원(`_llm_decide_member`) 별도 프롬프트             |
| **폴백** | LLM 실패 시 키워드 기반 규칙 라우터로 자동 전환                                      |
| **출력** | `RouteDecision(intent, needs_vision, needs_rag, needs_product, needs_context_check)` |

<br />

**■ Intent 분류 체계 (14개)**

| 분류      | Intent                | 설명                      | 실행 노드                               |
| :-------- | :-------------------- | :------------------------ | :-------------------------------------- |
| 즉시 응답 | `greeting`            | 인사/잡담                 | route_node에서 END                      |
|           | `out_of_domain`       | 피부 무관 질문            | route_node에서 END                      |
|           | `login_required`      | 비회원 분석 요청          | route_node에서 END                      |
|           | `ask_for_context`     | 피부 정보 부족 → 역질문   | route_node에서 END                      |
|           | `ask_for_category`    | 제품 종류 미특정 → 역질문 | route_node에서 END                      |
|           | `ask_for_skin_info`   | 피부타입 미수집 → 역질문  | route_node에서 END                      |
| 일반 상담 | `general_advice`      | 피부 관리법/일반 지식     | context → search(RAG) → llm             |
|           | `routine_advice`      | 스킨케어 루틴 추천        | context → search(RAG) → llm             |
|           | `medical_advice`      | 피부과 상담 권고          | context → search(RAG) → llm             |
|           | `ingredient_question` | 화장품 성분 질문          | context → search(RAG) → llm             |
| 제품 추천 | `product_recommend`   | 올리브영 제품 추천        | context → search(Tavily) → llm          |
|           | `routine_and_product` | 루틴 + 제품 동시          | context → search(RAG+Tavily 병렬) → llm |
| 피부 분석 | `skin_analysis_fast`  | 빠른 분석 (1장)           | context → vision → search(RAG) → llm    |
|           | `skin_analysis_deep`  | 정밀 분석 (3장)           | context → vision → search(RAG) → llm    |

<br />

**■ LLM 라우터 후처리 (오분류 보정)**

LLM이 intent를 반환한 후, 규칙 기반 후처리로 일관성을 보장합니다:

- **피부타입 선언 감지**: "지성이야", "복합성 피부" 같은 짧은 메시지는 이전 대화 맥락의 intent를 이어받기 (루틴 → `routine_advice`, 제품 → `product_recommend`)
- **루틴 우선 판단**: "루틴", "관리법" 키워드가 포함되면 `ask_for_category`가 아닌 `routine_advice`로 강제
- **맥락 부족 보정**: `product_recommend`인데 피부 정보 없으면 `ask_for_context`로, 카테고리 없으면 `ask_for_category`로 전환
- **회원 프로필 반영**: DB에 피부타입/고민이 저장되어 있으면 LLM 판단과 별개로 맥락 있음으로 처리

<br />

---

**■ context_node — 프로필 로드 + 맥락 판단 (~0초)**

| 항목       | 내용                                                                                |
| :--------- | :---------------------------------------------------------------------------------- |
| **역할**   | DB에서 사용자 프로필 로드, 맥락 부족 시 역질문 반환                                 |
| **회원**   | DB에서 skin_type, concern, age, gender, 최근 분석 이력 조회                         |
| **비회원** | chat_history에서 임시 프로필 구성 (피부타입/고민 추출)                              |
| **출력**   | `user_profile`, `instant_response`(역질문 시), `guest_upsell`(회원가입 유도 플래그) |

<br />

**■ 비회원 2단계 역질문 로직**

```
1단계: needs_context_check=True이고 피부 맥락 없음
  → "어떤 피부 타입이나 고민에 맞는 제품을 찾고 계신가요?" (즉시 END)

2단계: 개인화가 필요한 질문(관리법, 루틴, 제품)인데 피부타입 미수집
  → "답변드리기 전에 먼저 피부 타입을 알려주시면 더 정확한 정보를 드릴 수 있어요" (즉시 END)

통과: 일반 지식 질문(성분 효능, 원인 설명 등)은 피부타입 없이 바로 답변 진행
```

비로그인 사용자가 개인화가 필요한 질문을 하면 역질문 후 END로 분기하고, 답변이 제공된 경우에는 `guest_upsell=True` 플래그를 설정하여 validate_node에서 회원가입 유도 문구를 자동 추가합니다.

---

<br />

**■ vision_node — 피부 분석 모델 추론**

| 항목          | 내용                                                                                         |
| :------------ | :------------------------------------------------------------------------------------------- |
| **역할**      | Fast/Deep 모델 추론 또는 성분 OCR(VLM) 실행                                                  |
| **실행 조건** | `needs_vision=True`인 intent만 (skin_analysis_fast, skin_analysis_deep, ingredient_analysis) |
| **Fast**      | 정면 1장 → Area별 ResNet50 → 5개 항목 수치 + 등급 (~0.5초)                                   |
| **Deep**      | 정면+좌+우 3장 → Area별 ResNet50 + AttentionFusion → 13개 수치 + 10개 등급 + 신뢰도 (~2초)   |
| **성분 OCR**  | Qwen2.5-VL-7B로 전성분 이미지에서 성분명 추출                                                |
| **출력**      | `vision_result` (skin_metrics / measurements+grades+reliability / ingredients)               |

`needs_vision=False`인 일반 상담/제품 추천 intent에서는 이 노드를 통과(pass-through)합니다.

---

<br />

**■ search_node — RAG + Tavily 검색 (0.3~5초)**

| 항목       | 내용                                                                   |
| :--------- | :--------------------------------------------------------------------- |
| **역할**   | intent별 필요한 검색을 실행하여 LLM에 전달할 근거 자료 수집            |
| **RAG**    | ChromaDB 벡터 검색 — 피부 가이드, 성분 DB, 질환 정보, 화장품 데이터    |
| **Tavily** | 올리브영 실시간 제품 검색 (이름, 가격, URL, 성분)                      |
| **병렬**   | `needs_rag + needs_product` 동시 True → ThreadPoolExecutor로 병렬 실행 |
| **출력**   | `rag_passages`, `oliveyoung_products`                                  |

<br />

**■ intent별 검색 조합**

| Intent                         | RAG | Tavily | 비고                                    |
| :----------------------------- | :-: | :----: | :-------------------------------------- |
| general_advice, routine_advice | ✔️  |   —    | 가이드/질환 문서 검색                   |
| medical_advice                 | ✔️  |   —    | 질환 문서 중심                          |
| ingredient_question            | ✔️  |   —    | 성분/화장품 문서 검색                   |
| product_recommend              |  —  |   ✔️   | 올리브영 실시간 검색                    |
| routine_and_product            | ✔️  |   ✔️   | **병렬 실행**                           |
| skin_analysis_fast/deep        | ✔️  |   —    | 수치 기반 피부타입 → RAG 쿼리 자동 생성 |

<br />

**■ 분석 intent 특별 처리**

피부 분석 시 search_node는 vision_result의 수치로 **규칙 기반 피부타입을 확정**한 뒤, 이를 RAG 쿼리에 반영합니다. DB 프로필의 피부타입은 의도적으로 무시하여, 현재 분석 수치에 기반한 객관적인 정보를 검색합니다.

```python
# 예: Fast Model 수치 → 피부타입 확정 → RAG 쿼리
vision_result["determined_skin_type"] = "복합성"
→ RAG 쿼리: "복합성 피부 관리 루틴 스킨케어"
```

<br />

---

**■ llm_node — LLM 답변 생성 (5~15초)**

| 항목         | 내용                                                                                            |
| :----------- | :---------------------------------------------------------------------------------------------- |
| **역할**     | 확정된 피부타입 + 수치 + RAG/Tavily 결과를 종합하여 최종 답변 생성                              |
| **모델**     | GPT-4.1-mini                                                                                    |
| **입력**     | intent, user_text, user_profile, vision_result, rag_passages, oliveyoung_products, chat_history |
| **프롬프트** | intent별 전문 프롬프트 (general_chat.py, product_recommend.py, skin_analysis.py 등)             |
| **출력**     | `llm_output` (chat_answer, summary, observations, recommendations, products, skin_type 등)      |

intent에 따라 다른 시스템 프롬프트가 적용되며, 피부 분석 시에는 vision_result의 수치와 등급이 프롬프트에 직접 주입되어 LLM이 수치를 해석하고 조언을 생성합니다.

<br />

---

**■ validate_node — 검증 + 후처리 + DB 저장 (~0초)**

| 항목              | 내용                                                                         |
| :---------------- | :--------------------------------------------------------------------------- |
| **역할**          | LLM 출력 검증, 올리브영 링크 반영, 분석 결과 DB 저장                         |
| **스키마 검증**   | Pydantic `validate_report()`로 JSON 구조 검증 + 자동 복구                    |
| **올리브영 링크** | Tavily 검색 결과와 LLM 추천 제품을 fuzzy 매칭하여 구매 URL 반영              |
| **수치 정규화**   | Fast/Deep 원시 수치 → 0~100 통합 스코어 + 5단계 라벨(매우 양호~개선 필요)    |
| **DB 저장**       | 분석 intent이고 vision_result 있을 때 → analysis 테이블에 정규화된 결과 저장 |
| **회원가입 유도** | `guest_upsell=True`이면 답변 끝에 회원가입 유도 문구 자동 추가               |
| **출력**          | `report` (최종 응답 JSON)                                                    |

<br />

**■ 올리브영 링크 반영 로직**

```
1. Tavily 검색 결과에서 URL이 있는 제품만 유효 제품(valid_oy)으로 선별
2. LLM이 추천한 제품명과 valid_oy를 fuzzy 매칭 (정확 → 부분 포함 순)
3. 매칭 성공 → LLM 제품에 oliveyoung_url 보완
4. 매칭 실패와 무관하게 valid_oy 기준으로 구매 링크 섹션 추가
```

<br />

---

#### 6.5.4. 상태 관리 (GraphState)

LangGraph의 `TypedDict` 기반 상태 객체가 노드 간 데이터를 전달합니다:

```python
class GraphState(TypedDict):
    # 입력 (불변)
    user_text: str                    # 사용자 메시지
    images: list                      # 업로드 이미지
    analysis_type: str | None         # "quick" | "detailed" | "ingredient" | None
    user_id: int | None               # 회원 ID (비로그인 시 None)
    chat_history: list                # 이전 대화 이력
    is_first_message: bool            # 채팅방 첫 메시지 여부
    image_urls: list[str]             # S3 업로드 URL

    # 중간 상태 (노드가 채움)
    route: RouteDecision | None       # route_node 출력
    instant_response: dict | None     # 즉시 응답 (있으면 END로 분기)
    user_profile: dict | None         # context_node 출력
    guest_upsell: bool                # 회원가입 유도 플래그
    vision_result: dict | None        # vision_node 출력
    rag_passages: list                # search_node RAG 결과
    oliveyoung_products: list         # search_node Tavily 결과
    llm_output: dict                  # llm_node 출력
    report: dict                      # validate_node 최종 출력
```

<br />

#### 6.5.5. 조건부 엣지 (Conditional Edges)

그래프에는 2개의 조건부 분기점이 있어, 불필요한 노드 실행을 최소화합니다:

| 분기점 | 조건 | "instant" (→ END) | "continue" (→ 다음 노드) |
| :-- | :-- | :-- | :-- |
| **route_condition** | `intent ∈ {greeting, out_of_domain, login_required, ask_for_context}` | 즉시 응답 반환 | context_node로 이동 |
| **context_condition** | `instant_response ≠ None` | 역질문 반환 | vision_node로 이동 |

이를 통해 인사/도메인 외 질문은 **1개 노드만 실행**(route_node)하고, 맥락 부족 시 **2개 노드**(route + context)만 실행하여 응답 속도를 최적화합니다.

<br />

#### 6.5.6. 전체 응답 시간 (예시)

| 시나리오                       | 실행 노드                                                     | 총 소요 시간 |
| :----------------------------- | :------------------------------------------------------------ | :----------: |
| "안녕" (인사)                  | route_node                                                    |    ~1.5초    |
| "추천해줘" (맥락 부족)         | route → context                                               |    ~1.5초    |
| "건성 피부 관리법" (일반 상담) | route → context → search(RAG) → llm → validate                |    ~12초     |
| "지성 세럼 추천" (제품 추천)   | route → context → search(Tavily) → llm → validate             |    ~15초     |
| "루틴이랑 세럼 추천" (복합)    | route → context → search(RAG+Tavily 병렬) → llm → validate    |    ~15초     |
| 빠른 분석 (사진 1장)           | route → context → vision(0.5s) → search(RAG) → llm → validate |    ~13초     |
| 정밀 분석 (사진 3장)           | route → context → vision(2s) → search(RAG) → llm → validate   |    ~15초     |

<br />

#### 퍼스널컬러 분류체계
6.6.3. 분류 체계
퍼스널컬러는 8개 기본 타입 + 6개 브릿지 조합 = 총 14타입으로 구성됩니다.

- 기본 타입: 봄 라이트, 봄 브라이트, 여름 라이트, 여름 뮤트, 가을 뮤트, 가을 딥, 겨울 브라이트, 겨울 딥
- 브릿지 타입: 인접 시즌/톤 조합형 6개 타입
<br />

#### 6.6.4. 결과 구성
|   항목   | 설명                |
| :----: | :---------------- |
|   타입명  | 최종 판정된 퍼스널컬러 타입   |
|   시즌   | 봄/여름/가을/겨울        |
|  감성 멘트 | 사용자 이해를 돕는 직관적 표현 |
| 컬러 팔레트 | HEX 기반 추천 컬러 세트   |
| 스타일 추천 | 메이크업 / 헤어 / 의상 추천 |

<br />

### 6.7. 웹캠 실시간 얼굴 감지

사용자는 별도의 앱 설치 없이 웹캠을 실행할 수 있고, 시스템은 촬영 전 단계에서 얼굴 위치와 크기,  
가이드 영역 충족 여부를 먼저 확인한 뒤 조건이 만족될 때만 촬영을 진행합니다.  
이를 통해 잘못된 입력 이미지를 사전에 걸러내고, 퍼스널컬러 분석에 적합한 사진을 보다 안정적으로 확보할 수 있도록 했습니다.

<br />

#### 6.7.1. 적용 기술

| 항목 | 내용 |
| :--: | :-- |
| 프론트엔드 처리 | TensorFlow.js |
| 얼굴 검출 | MediaPipe Face Detector |
| 실행 환경 | 브라우저 온디바이스 |
| 처리 방식 | 실시간 얼굴 감지 후 조건 충족 시 자동 촬영 |

<br />

#### 6.7.2. 얼굴 검증 기준

웹캠 촬영은 단순히 얼굴이 보이는지만 확인하는 것이 아니라,  
분석 가능한 품질의 사진인지 판단하기 위해 아래 기준을 순차적으로 검사하도록 설계했습니다.

| 검증 항목 | 기준 | 목적 |
| :--: | :-- | :-- |
| 특징점 유효성 확인 | 주요 얼굴 특징점 값이 정상적으로 검출되어야 함 | 얼굴 오탐 방지 |
| 얼굴 크기 확인 | 얼굴 영역이 화면 내 최소 기준 이상이어야 함 | 너무 멀리 찍힌 사진 방지 |
| 가이드 영역 포함 여부 | 얼굴 박스가 촬영 가이드 안에 완전히 들어와야 함 | 잘린 얼굴, 치우친 구도 방지 |

<br />

#### 6.7.3. 동작 흐름

웹캠 촬영은 다음과 같은 순서로 동작합니다.

1. 사용자가 웹캠 촬영 기능을 실행합니다.  
2. 브라우저에서 실시간으로 얼굴을 감지합니다.  
3. 얼굴 특징점, 크기, 가이드 영역 충족 여부를 검사합니다.  
4. 모든 조건이 만족되면 자동 촬영 카운트다운을 시작합니다.  
5. 카운트다운 도중 얼굴이 이탈하거나 조건이 깨지면 카운트다운을 초기화합니다.  
6. 일정 시간 동안 조건이 유지되면 자동으로 이미지를 촬영합니다.  
7. 자동 촬영이 어려운 상황에서는 수동 촬영도 가능하도록 예외 흐름을 함께 제공했습니다.

<br />

### 6.8. 피부 MBTI 연동 파이프라인

피부 MBTI 기능은 단순히 결과 페이지를 보여주는 데서 끝나는 것이 아니라,  
사용자의 피부 성향을 이후 챗봇 대화에 반영하여 보다 개인화된 상담 경험으로 이어지도록 설계했습니다.

기존에는 MBTI 결과가 결과 페이지 내부에서만 소비되었다면,  
4차 버전에서는 사용자가 결과 페이지에서 챗봇으로 이동했을 때  
해당 MBTI 유형 정보를 기반으로 답변 톤과 관리 방향, 추천 문장을 함께 생성할 수 있도록 구조를 확장했습니다.  
이를 통해 사용자는 자신의 피부 성향에 맞는 루틴, 제품 방향, 관리 팁을 보다 자연스럽게 이어서 받을 수 있도록 했습니다.

<br />

#### 6.8.1. 연동 목적

피부 MBTI는 사용자의 성향을 직관적으로 이해시키는 기능이지만,  
결과 확인 이후 실제 상담이나 추천으로 연결되지 않으면 기능 활용도가 제한적일 수 있습니다.  
이에 따라 MBTI 결과를 챗봇 입력 맥락으로 연결하여,  
단발성 테스트가 아니라 **개인화 상담의 출발점**으로 활용할 수 있도록 설계했습니다.

<br />

#### 6.8.2. 동작 구조

피부 MBTI 연동은 프론트에서 복잡한 데이터를 직접 넘기기보다,  
백엔드가 사용자 결과를 조회하여 필요한 정보를 프롬프트에 주입하는 방식으로 구현했습니다.

1. 사용자가 피부 MBTI 결과 페이지에서 챗봇 진입 버튼을 클릭합니다.  
2. 프론트는 챗봇 페이지로 이동하며 시작 메시지 또는 진입 상태를 전달합니다.  
3. 백엔드는 사용자 식별 정보를 바탕으로 저장된 MBTI 결과를 조회합니다.  
4. 조회된 MBTI 타입명, 설명, 추천 포인트를 챗봇 프롬프트에 주입합니다.  
5. LLM은 해당 피부 성향을 반영하여 맞춤형 답변을 생성합니다.

<br />

#### 6.8.3. 설계 방식

| 항목 | 내용 |
| :--: | :-- |
| 데이터 조회 위치 | 백엔드 |
| 활용 데이터 | 피부 MBTI 타입, 설명, 추천 방향 |
| 반영 방식 | LLM 프롬프트 자동 주입 |
| 기대 효과 | 결과 페이지 → 챗봇 상담 흐름 자연스럽게 연결 |

<br />

#### 6.8.4. 기대 효과

이 구조를 통해 피부 MBTI는 단순한 재미 요소가 아니라,  
사용자의 피부 관리 성향을 반영한 개인화 상담 기능으로 확장될 수 있었습니다.  
또한 사용자는 테스트 결과를 다시 설명할 필요 없이,  
바로 자신의 성향에 맞춘 상담 흐름으로 이어질 수 있어 서비스 몰입도를 높일 수 있었습니다.

<br />

### 6.9. 응답 UX 최적화

챗봇 기반 피부 분석 서비스는 이미지 해석, 검색, 추천, 응답 생성까지 여러 단계가 순차적으로 실행되기 때문에  
일반적인 화면 전환보다 체감 대기 시간이 길어질 수 있습니다.  
특히 피부 분석, 성분 분석, 퍼스널컬러 분석처럼 입력 이미지가 포함되는 경우에는  
모델 처리 시간과 후처리 과정이 추가되어 사용자가 “멈췄다”는 인상을 받기 쉽습니다.

이 문제를 개선하기 위해 4차 버전에서는  
**단계별 진행 표시**, **피부 상식 모달**, **분석 실패 안내 메시지 통일** 등  
대기 경험과 재시도 경험을 함께 개선하는 UX 보완 구조를 적용했습니다.

<br />

#### 6.9.1. 단계별 진행 표시

기존에는 응답 생성 중 하나의 고정된 로딩 메시지만 표시되어  
현재 어떤 처리가 진행 중인지 사용자가 알기 어려웠습니다.  
이를 개선하기 위해 파이프라인 실행 상태를 SSE(Server-Sent Events)로 전달하여  
단계별 안내 메시지를 실시간으로 표시하도록 구성했습니다.

예를 들어 이미지 확인, 피부 분석, 성분 추출, 퍼스널컬러 판정, 일반 상담 응답 생성 등  
현재 수행 중인 작업을 문구로 분리하여 제공함으로써  
사용자가 대기 과정을 보다 이해할 수 있도록 했습니다.

| 실행 단계 | 안내 예시 |
| :--: | :-- |
| 이미지 확인 | 업로드한 이미지를 확인하고 있어요 |
| 피부 분석 | AI가 피부 상태를 분석하고 있어요 |
| 성분 분석 | 전성분을 추출하고 있어요 |
| 퍼스널컬러 분석 | 퍼스널컬러를 분석하고 있어요 |
| 일반 상담 | 피부 데이터에서 근거를 찾고 있어요 |

<br />

#### 6.9.2. 피부 상식 모달

단계별 진행 표시만으로는 긴 대기 시간을 충분히 완화하기 어려웠기 때문에,  
로딩 중 빈 화면 대신 피부 관리와 관련된 짧은 상식 콘텐츠를 모달 형태로 제공하도록 했습니다.

피부 상식은 여러 문장으로 구성된 데이터 중 일부를 요청마다 랜덤하게 노출하며,  
사용자는 답변을 기다리는 동안 간단한 정보를 함께 확인할 수 있습니다.  
이를 통해 단순 대기 시간을 정보 소비 시간으로 전환하고,  
서비스에 대한 흥미와 체감 품질을 함께 높이고자 했습니다.

| 항목 | 내용 |
| :--: | :-- |
| 콘텐츠 성격 | 피부 관리 팁 / 짧은 상식 |
| 노출 방식 | 로딩 중 모달 표시 |
| 구성 방식 | 랜덤 선택 후 순차 노출 |
| 목적 | 체감 대기 시간 완화, 사용자 몰입도 향상 |

<br />

#### 6.9.3. 분석 실패 안내 메시지 통일

기존에는 잘못된 이미지가 업로드되었을 때  
분석 유형과 무관하게 일반적인 오류 문구만 노출되어 사용자가 원인을 파악하기 어려웠습니다.  
예를 들어 만화 이미지, 동물 사진, 풍경 사진, 흐린 전성분 이미지 등  
실제 분석이 불가능한 입력에서도 단순한 오류로만 처리되어 재시도 경험이 좋지 않았습니다.

이를 개선하기 위해 각 분석 유형에 따라  
입력 조건과 촬영 팁을 포함한 **맞춤형 실패 안내 메시지**를 제공하도록 변경했습니다.  
퍼스널컬러, 빠른 분석, 정밀 분석, 성분 분석 각각에 대해  
필요한 사진 조건과 재촬영 가이드를 다르게 제시하여 사용자가 바로 다시 시도할 수 있도록 했습니다.

| 분석 유형 | 안내 방향 |
| :--: | :-- |
| 퍼스널컬러 분석 | 실제 사람의 정면 얼굴 사진 필요 |
| 빠른 피부 분석 | 정면 얼굴 사진 1장 필요 |
| 정밀 피부 분석 | 정면, 좌측, 우측 3장 필요 |
| 성분 분석 | 전성분표가 선명한 사진 필요 |

<br />

#### 6.9.4. 사용자 경험 측면의 의미

이러한 UX 최적화를 통해 사용자는  
단순히 결과를 기다리는 것이 아니라, 현재 어떤 분석이 진행 중인지 이해하고  
오류가 발생했을 때도 왜 실패했는지 즉시 파악할 수 있게 되었습니다.  
또한 대기 과정에서 피부 상식 콘텐츠를 제공함으로써  
서비스 전체가 더 친절하고 살아 있는 인터랙션처럼 느껴지도록 개선했습니다.

<br />

### 6.10. 퍼스널컬러 결과 후처리 및 HEX 파싱 전략

퍼스널컬러 분석 결과는 단순히 타입명만 반환하는 것이 아니라,  
사용자에게 어울리는 색상 팔레트와 스타일 추천까지 함께 제공하는 구조로 설계했습니다.  
이때 추천 컬러를 화면에 안정적으로 표시하기 위해서는  
LLM이 생성한 색상 정보가 프론트엔드에서 일관되게 해석될 수 있어야 했습니다.

하지만 실제 테스트 과정에서는 모델이 같은 계열 색상에 대해서도  
매번 다른 컬러명을 생성하거나, 프론트에서 정의하지 않은 표현을 사용하는 문제가 발생했습니다.  
이 경우 추천 팔레트가 비어 보이거나 일부 색상이 누락되는 문제가 생길 수 있었습니다.

이를 해결하기 위해 결과 후처리 단계에서  
**HEX 코드 강제 출력 + 프론트 폴백 매핑**의 이중 전략을 적용했습니다.

<br />

#### 6.10.1. 문제 상황

퍼스널컬러 결과 생성 시 LLM은  
“코랄 핑크”, “살구 베이지”, “딥 버건디”처럼 다양한 자연어 표현을 사용할 수 있습니다.  
하지만 프론트엔드에서는 색상명을 그대로 렌더링하는 것이 아니라  
실제 컬러칩을 만들기 위해 명확한 HEX 코드가 필요했습니다.

즉, 컬러명만 있고 코드가 없거나,  
프론트에서 알 수 없는 표현이 반환되면 팔레트가 정상적으로 생성되지 않는 문제가 있었습니다.

<br />

#### 6.10.2. 해결 전략

이 문제를 해결하기 위해 두 단계의 보완 구조를 적용했습니다.

1. 프롬프트 단계에서 모든 추천 색상을 `컬러명(#HEX)` 형식으로 출력하도록 강제했습니다.  
2. 프론트엔드에서는 HEX 코드가 누락되거나 형식이 맞지 않는 경우를 대비해  
   기존 컬러명-HEX 매핑 테이블을 활용한 폴백 처리를 추가했습니다.

이 구조를 통해 모델 출력이 조금 달라지더라도  
화면에서는 최대한 안정적으로 컬러 팔레트를 생성할 수 있도록 했습니다.

<br />

#### 6.10.3. 기대 효과

해당 후처리 전략을 통해 퍼스널컬러 결과 화면의 완성도를 높일 수 있었고,  
추천 색상이 누락되거나 비어 보이는 상황을 줄일 수 있었습니다.  
또한 사용자에게는 HEX 코드 자체를 노출하지 않고  
직관적인 컬러칩 중심 UI를 제공하여 결과 이해도를 높일 수 있었습니다.

---

<br />

### 6.11. 챗봇 페르소나 설계

**■ 개요**

기존의 피부/성분 정보를 전달하는 기능 중심 챗봇에서 확장하여, 사용자의 피부 고민에 공감하고 부드럽게 설명하는 **서비스형 캐릭터 페르소나**를 설계했습니다. 이를 통해 답변 품질뿐 아니라 서비스의 인상과 일관된 말투 경험까지 함께 강화했습니다.

| 항목 | 내용 |
| :--: | :-- |
| 이름 | 옹글이 |
| 역할 | 피부 코치형 · 성분 큐레이터형 챗봇 |
| 대화 방향 | 피부 고민 공감 + 이해하기 쉬운 설명 + 친절한 추천 |
| 말투 원칙 | 밝고 발랄하지만 가볍지 않음 |
| 핵심 성격 | 발랄함, 친절함, 공감성, 긍정성, 다정함, 쉬운 설명력 |

**■ 페르소나 기획 문서**
- https://www.notion.so/321614937e7a80799db9d355aed64753?source=copy_link

<br />

**■ 기대 효과**

- 피부/성분 정보를 단순 전달하는 챗봇이 아니라, 사용자의 고민에 공감하는 상담형 경험 제공
- 분석 결과, MBTI, 성분 해석, 추천 응답 전반에 일관된 브랜드 톤앤매너 유지
- 장문의 설명도 부담스럽지 않게 전달하여 사용자 친화성 강화

<br />

### 6.12. 분석 이력 및 비교 기능

**■ 개요**

피부 분석 결과를 단발성으로 확인하는 데 그치지 않고, 날짜별로 저장된 결과를 다시 조회하고 서로 비교할 수 있도록 분석 이력 기능을 확장했습니다.

| 항목 | 내용 |
| :--: | :-- |
| 분석 이력 조회 | 날짜별 피부 분석 결과 조회 |
| 비교 기능 | 선택한 2개 날짜 결과 비교 |
| 활용 목적 | 피부 변화 추적 및 이전/현재 상태 확인 |

<br />

### 6.13. 회원가입 이후 온보딩 UX

**■ 개요**

신규 사용자가 서비스의 주요 기능을 빠르게 이해할 수 있도록 회원가입 이후 온보딩 튜토리얼 모달과 핵심 기능 안내 흐름을 추가했습니다.

| 항목 | 내용 |
| :--: | :-- |
| 온보딩 | 첫 회원가입 후 튜토리얼 모달 제공 |
| 안내 내용 | 피부 분석, 피부 MBTI, 위시리스트, 퍼스널컬러 등 핵심 기능 소개 |
| 목적 | 초기 진입 장벽 완화 및 서비스 기능 이해도 향상 |

<br />

### 6.14. 마이페이지 및 계정 관리 기능

**■ 개요**

단순 사용자 정보 조회 수준을 넘어, 계정 관리와 운영 기능까지 수행할 수 있도록 마이페이지를 확장했습니다.

| 항목 | 내용 |
| :--: | :-- |
| QnA | 사용자 문의 등록 / 조회 기능 |
| 관리자 기능 | 전체 문의 관리 기능 |
| 권한 분리 | 사용자 / 관리자 권한에 따른 기능 분리 |
| 회원탈퇴 | 마이페이지에서 직접 탈퇴 가능 |
| 닉네임 기능 | 닉네임 중복 확인 + 랜덤 닉네임 생성 |

### 6.15. Flutter 앱

#### 6.15.1. 개요

웹 서비스의 모든 기능을 모바일 환경에서도 동일하게 사용할 수 있도록 **Flutter 기반 Android 앱**을 개발했습니다. 단순 웹뷰 래핑이 아닌 Flutter 네이티브로 모바일에 최적화된 UI를 별도 구현하였으며, 기존 백엔드 API를 그대로 호출하여 웹과 동일한 기능을 제공합니다.

#### 6.15.2. 기술 스택

| 항목 | 내용 |
| --- | --- |
| 프레임워크 | Flutter (Dart SDK ^3.11.1) |
| 개발 환경 | Android Studio |
| 타겟 플랫폼 | Android |
| 백엔드 연동 | 웹과 동일한 REST API 호출 (HTTPS) |

#### 6.15.3. 주요 패키지 및 역할

| 패키지 | 버전 | 역할 |
| --- | --- | --- |
| `dio` | ^5.9.2 | HTTP 클라이언트 (API 통신, 인터셉터, 에러 핸들링) |
| `http` | ^1.2.0 | 기본 HTTP 요청 |
| `flutter_secure_storage` | ^10.0.0 | JWT 토큰 등 민감 데이터 암호화 저장 (Android Keystore) |
| `shared_preferences` | ^2.2.2 | 사용자 설정값 로컬 저장 |
| `camera` | ^0.12.0 | 네이티브 카메라 촬영 (피부 분석, 퍼스널컬러) |
| `google_mlkit_face_detection` | ^0.13.2 | 온디바이스 얼굴 감지 (촬영 전 얼굴 유효성 검증) |
| `image_picker` | ^1.2.1 | 갤러리에서 이미지 선택 |
| `image` | ^4.8.0 | 이미지 리사이징 및 가공 |
| `video_player` | ^2.8.2 | 온보딩/홈 화면 배너 영상 재생 |
| `flutter_markdown` | ^0.7.7+1 | AI 챗봇 답변 마크다운 렌더링 |
| `url_launcher` | ^6.2.5 | 올리브영 제품 링크 외부 브라우저 열기 |
| `app_links` | latest | 소셜 로그인 OAuth 딥링크 처리 |

#### 6.15.4. 구현 기능

웹에서 제공되는 모든 기능이 앱에서도 동작합니다.

| 기능 | 앱 지원 | 주요 패키지 |
| --- | --- | --- |
| 회원가입 / 로그인 (로컬 + 소셜) | O | dio, flutter_secure_storage, app_links |
| 온보딩 (피부 정보 입력) | O | shared_preferences |
| AI 채팅 상담 | O | dio, flutter_markdown |
| 빠른 피부 분석 (1장) | O | camera, google_mlkit_face_detection |
| 정밀 피부 분석 (3장) | O | camera, google_mlkit_face_detection |
| 성분 분석 (OCR) | O | camera, image_picker |
| 퍼스널컬러 분석 | O | camera, google_mlkit_face_detection |
| 올리브영 제품 추천 + 위시리스트 | O | dio, url_launcher |
| 피부 MBTI 테스트 | O | dio |
| 분석 결과 조회 / 비교 | O | dio |
| 마이페이지 (프로필, QnA, 회원탈퇴) | O | dio, flutter_secure_storage |

#### 6.15.5. 웹 vs 앱 얼굴 감지 기술 비교

웹과 앱 모두 온디바이스 얼굴 감지를 수행하지만 사용 기술이 다릅니다.

| 항목 | 웹 (React) | 앱 (Flutter) |
| --- | --- | --- |
| 감지 기술 | TensorFlow.js + MediaPipe WASM | Google ML Kit (네이티브) |
| 패키지 | @tensorflow-models/face-detection | google_mlkit_face_detection |
| 런타임 | 브라우저 WASM | Android 네이티브 |
| 서버 전송 | 없음 (온디바이스) | 없음 (온디바이스) |

두 환경 모두 서버에 얼굴 영상을 전송하지 않으므로 개인정보보호법상 생체정보 이슈 없이 운영할 수 있습니다.

#### 6.15.6. 앱 리소스 구성

| 폴더 | 내용 |
| --- | --- |
| `assets/images/` | 로고, 아바타, 분석 가이드 이미지, 홈 화면 아이콘 |
| `assets/images/skin_mbti/` | MBTI 8타입별 캐릭터 일러스트 |
| `assets/images/home/` | 홈 화면 기능 소개 이미지 |
| `assets/videos/` | 홈 화면 배너 영상 (skin_banner 1~4) |
| `assets/social/` | 소셜 로그인 버튼 이미지 (Google, Kakao, Naver) |

#### 6.15.7. 아키텍처 연동

```text
Flutter App (Android)
    │
    │  HTTPS API 호출 (dio)
    │  JWT 토큰 인증 (flutter_secure_storage)
    ▼
Nginx (443) → FastAPI Backend → 동일한 AI 파이프라인

---

## 7. 시스템 아키텍처

### 7.1. 전체 아키텍처

<div align="center">
  <img src="assets\EC2_RunPodGPU_.jpg" width="80%">
</div>

<br />

### 7.2. 주요 흐름 (User Flow)

1. 사용자가 로그인 후 채팅창에서 대화 또는 분석 모드 선택
2. **빠른 분석**: 정면 사진 1장 업로드 → GPT Vision 얼굴 검증 → ResNet50 Fast Model 추론 → 피부타입 확정 → LLM 해설
3. **정밀 분석**: 정면/좌/우 3장 업로드 → GPT Vision 얼굴+순서 검증 → Deep Model 추론 → 부위별 13개 지표 + 피부타입 확정 → LLM 해설
4. **성분 분석**: 전성분 라벨 사진 업로드 → OCR 성분 추출 → 사용자 피부타입 맞춤 성분 해석
5. **제품 추천**: RAG 후보 검색 → Tavily 올리브영 검증 → 검증된 제품만 추천
6. **위시리스트**: 추천 제품 저장/조회/삭제

<br />

---

## 8. 데이터베이스 설계

ERD 링크: https://www.erdcloud.com/d/2cjZbEpqqK92Mw6AZ

<div align="center">
  <img src="assets/erd.png">
</div>

<!-- </div> -->
<br />

### 8.1. 주요 테이블

|    테이블     | 설명                                         |
| :-----------: | :------------------------------------------- |
|     users     | 사용자 정보 (피부타입, 피부고민, 나이, 성별) |
|  chat_rooms   | 채팅방 관리                                  |
| chat_messages | 대화 이력 저장                               |
| skin_analyses | 피부 분석 결과 (피부타입, 점수, 측정값)      |
|   wishlists   | 추천 제품 위시리스트 저장                    |

<br />

---

## 9. 디렉토리 구조

```
📦 **SKN23-3rd-3TEAM/**
├── **front/** *(React + Vite 프론트엔드)*
│   ├── index.html                          # 앱 진입점 HTML
│   ├── package.json                        # 의존성 및 스크립트
│   ├── vite.config.ts                      # Vite 빌드 설정 (alias 등)
│   ├── tsconfig.json                       # TypeScript 설정
│   ├── public/
│   │   └── favicon.icons                   # 파비콘 파일
│   └── src/
│       ├── main.tsx                        # React 앱 마운트 진입점
│       ├── vite-env.d.ts                   # Vite 환경변수 타입 정의
│       ├── app/
│       │   ├── App.tsx                     # RouterProvider 루트 컴포넌트
│       │   ├── routes.tsx                  # 전체 라우트 정의
│       │   ├── api/                        # 백엔드 API 호출 함수 모음
│       │   │   ├── authApi.ts              # 로그인·회원가입·이메일 인증·소셜 로그인
│       │   │   ├── chatApi.ts              # 채팅방 CRUD·메시지 전송·게스트 채팅
│       │   │   ├── userApi.ts              # 사용자 프로필 조회·수정·소셜 연동
│       │   │   ├── analysisApi.ts          # 피부 분석 결과 조회
│       │   │   ├── wishlistApi.ts          # 위시리스트 조회·추가·삭제
│       │   │   └── uploadApi.ts            # S3 이미지 업로드
│       │   ├── pages/                      # 라우트에 대응하는 페이지 컴포넌트
│       │   │   ├── ChatPage.tsx            # 메인 채팅 페이지 (비로그인 접근 가능)
│       │   │   ├── AnalysisPage.tsx        # 피부 분석 결과 상세 (로그인 필수)
│       │   │   ├── WishlistPage.tsx        # 위시리스트 목록 (로그인 필수)
│       │   │   ├── SettingsPage.tsx        # 프로필·계정 설정 (로그인 필수)
│       │   │   ├── LoginPage.tsx           # 로그인
│       │   │   ├── SignupPage.tsx          # 회원가입
│       │   │   ├── ForgotPasswordPage.tsx  # 비밀번호 재설정
│       │   │   ├── OnboardingPage.tsx      # 신규 회원 온보딩(피부정보 입력)
│       │   │   └── OAuthCallbackPage.tsx   # 소셜 로그인 콜백 처리
│       │   └── components/                 # 재사용 가능한 UI 컴포넌트
│       │       ├── Layout.tsx              # 전체 레이아웃(사이드바 + 콘텐츠)
│       │       ├── Sidebar.tsx             # 사이드바(네비·채팅 목록·사용자 정보)
│       │       └── ui/                     # 범용 UI 원자 컴포넌트(shadcn/ui 기반)
│       │           ├── bot.tsx             # 봇 아바타 컴포넌트
│       │           ├── icon.tsx            # SVG 아이콘 래퍼
│       │           ├── loading.tsx         # 로딩 스피너
│       │           ├── use-mobile.ts       # 모바일 감지 훅
│       │           └── utils.ts            # cn() 등 유틸 함수
│       │
│       ├── assets/                         # 정적 리소스(이미지/아이콘/애니메이션)
│       │   ├── logo.png
│       │   ├── profile.png
│       │   ├── info_1.png                  # 빠른/정밀 분석 안내사항 이미지
│       │   ├── info_2.png                  # 성분 분석 안내사항 이미지
│       │   ├── bot.svg
│       │   ├── animations/                 # 애니메이션 WebM 파일
│       │   │   ├── logo_idle_1.webm
│       │   │   ├── logo_loop_1.webm
│       │   │   ├── logo_pop_1.webm
│       │   │   └── logo_text.webm
│       │   ├── icons/                      # 커스텀 아이콘 SVG 파일
│       │   │   ├── beauty.svg
│       │   │   ├── chat.svg
│       │   │   ├── wish.svg
│       │   │   ├── moisture.svg
│       │   │   └── ...
│       │   └── factorial/                  # 피부분석-추천관리법 팩토리얼 SVG 파일 (17종)
│       │       ├── antiaging.svg
│       │       ├── brightening_care.svg
│       │       ├── moisturizing_boost.svg
│       │       └── ...
│       └── styles/                         # 전역 스타일
│           ├── index.css
│           ├── tailwind.css
│           ├── theme.css
│           └── fonts.css
│
├── **back/** *(FastAPI 백엔드)*
│   ├── main.py                             # FastAPI 앱 진입점(CORS, Router 등록)
│   │
│   ├── db/                                 # 데이터베이스 계층
│   │   ├── migrations/                     # 테이블 생성/변경 SQL
│   │   │   └── 001_init_tables.sql
│   │   ├── __init__.py
│   │   ├── db_manager.py                   # DB 연결 및 공통 쿼리 실행(Base layer)
│   │   ├── models.py                       # DB 모델(User, ChatSession 등)
│   │   └── schemas.py                      # Pydantic 스키마
│   │
│   ├── routers/                            # API 엔드포인트(Controller layer)
│   │   ├── __init__.py
│   │   ├── analysis_router.py              # 피부 분석 API
│   │   ├── auth_router.py                  # 인증/토큰 API
│   │   ├── chat_router.py                  # 채팅 API
│   │   ├── deps.py                         # Depends(인증/현재 유저 등)
│   │   ├── keyword_router.py               # 키워드 API
│   │   ├── upload_router.py                # S3 업로드 API
│   │   ├── user_router.py                  # 사용자 API
│   │   └── wishlist_router.py              # 위시리스트 API
│   │
│   ├── services/                           # 비즈니스 로직(Service layer)
│   │   ├── __init__.py
│   │   ├── analysis_service.py
│   │   ├── auth_service.py
│   │   ├── chat_service.py
│   │   ├── email_service.py
│   │   ├── keyword_service.py
│   │   └── user_service.py
│   │
│   ├── vector/                             # RAG 벡터 파이프라인(수집 → 전처리 → 임베딩)
│   │   ├── assets/
│   │   │   ├── links/                      # 외부 수집 링크/검색 결과 JSON
│   │   │   │   ├── aad_skin_care_*.json
│   │   │   │   ├── derma_skin_dis_*.json
│   │   │   │   ├── pubmed_search_*.json
│   │   │   │   └── single_search.json
│   │   │   └── vector_data/                # chunk 완료 JSONL(임베딩 입력)
│   │   │       ├── aad_guides.jsonl
│   │   │       ├── derma_disease.jsonl
│   │   │       ├── mfds_ingredient.jsonl
│   │   │       ├── pubmed_skin_guides.jsonl
│   │   │       └── single_item_collection.jsonl
│   │   ├── collectors/                     # 데이터 수집 모듈(RAG 1단계)
│   │   │   ├── aad_data_to_*.py
│   │   │   ├── cosmetic_*.py
│   │   │   ├── derma_data_*.py
│   │   │   ├── mfds_ingredient_*.py
│   │   │   └── pubmed_data_*.py
│   │   ├── utils/
│   │   │   ├── __init__.py
│   │   │   └── tagging.py                  # 메타 태깅/카테고리 로직
│   │   ├── check_collection.py             # Chroma 컬렉션 확인/생성
│   │   └── vectordb_insert.py              # 임베딩 생성 후 Chroma 업로드
│   │
│   ├── ai/                                 # AI 오케스트레이션 (LangGraph 파이프라인)
│   │   ├── orchestrator/                   # 그래프 실행 엔진
│   │   │   ├── graph.py                    # LangGraph DAG 정의 및 컴파일 (6-노드 그래프)
│   │   │   ├── state.py                    # GraphState TypedDict (노드 간 공유 상태)
│   │   │   ├── router.py                   # Intent 분류기 (LLM 라우팅 + 키워드 폴백)
│   │   │   ├── context_builder.py          # 사용자 프로필 빌드 (DB 조회 + chat_history 파싱)
│   │   │   └── nodes/                      # 그래프 노드 구현체
│   │   │       ├── route.py                # [route_node] GPT-4.1-mini intent 분류 + 즉시 응답
│   │   │       ├── context.py              # [context_node] 프로필 로드 + 맥락 부족 역질문
│   │   │       ├── vision.py               # [vision_node] Fast/Deep 모델 추론 · 성분 OCR
│   │   │       ├── search.py               # [search_node] RAG + Tavily 병렬 검색 · 피부타입 확정
│   │   │       ├── llm.py                  # [llm_node] GPT 답변 생성 (intent별 프롬프트)
│   │   │       └── validate.py             # [validate_node] 스키마 검증 · 올리브영 링크 · DB 저장
│   │   │
│   │   ├── llm/                            # LLM 호출 및 프롬프트 관리
│   │   │   ├── generator.py                # generate_report() — intent별 프롬프트 조합 → GPT 호출
│   │   │   ├── validators.py               # Pydantic 기반 LLM 출력 JSON 스키마 검증
│   │   │   └── prompts/                    # intent별 시스템 프롬프트
│   │   │       ├── system_base.py          # 공통 시스템 프롬프트 (역할 정의, 응답 형식)
│   │   │       ├── skin_analysis.py        # 빠른/정밀 분석 프롬프트 (수치 해석 + 피부타입 판정)
│   │   │       ├── ingredient_chat.py      # 성분 분석 프롬프트 (전성분 OCR 결과 해석)
│   │   │       ├── product_recommend.py    # 제품 추천 프롬프트 (올리브영 제품 기반 답변)
│   │   │       └── general_chat.py         # 일반 상담 프롬프트 (관리법, 루틴, 성분 질문)
│   │   │
│   │   ├── tools/                          # 외부 도구 연동
│   │   │   ├── rag_retriever.py            # ChromaDB 벡터 검색 (가이드/성분/질환/화장품)
│   │   │   └── oliveyoung.py               # Tavily API로 올리브영 실시간 제품 검색
│   │   │
│   │   └── config/
│   │       └── settings.py                 # API 키, 모델명, 경로 등 환경 설정
│   │
│   ├── skin_ai/                            # 딥러닝 모델 추론 (Fast/Deep)
│   │   ├── fast_inference.py               # Fast Model — 정면 1장 → 5개 항목 수치+등급 (~0.5초)
│   │   ├── deep_inference.py               # Deep Model — F+L+R 3장 → 13개 수치+10개 등급+신뢰도 (~2초)
│   │   ├── checkpoint/                     # 학습 완료 모델 가중치
│   │   │   ├── fast/                       # Area별 Fast Model state_dict.bin (7개)
│   │   │   └── deep/                       # Area별 Deep Model state_dict.bin (8개)
│   │   └── ingredient_demo/
│   │       └── demo_products.json          # 성분 분석 데모용 샘플 데이터
│   │
│   ├── assets/                             # 백엔드 리소스(팀 사진, 데모)
│   │   ├── images/
│   │   └── demo/
│   │
│   └── vector_store/                       # 로컬 Chroma 영속 저장소
│       └── chroma.sqlite3
│
├── README.md
└── requirements.txt
```

<br />

## 10. Tech Stack

<div align="center">

| Category | Stack |
| :-: | :-- |
| **Front-End** | ![React](https://img.shields.io/badge/React-61DAFB?style=flat&logo=react&logoColor=black) ![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?style=flat&logo=typescript&logoColor=black) ![vite](https://img.shields.io/badge/vite-9135FF?style=flat&logo=vite&logoColor=white) ![TailwindCSS](https://img.shields.io/badge/TailwindCSS-1572B6?style=flat&logo=tailwindcss&logoColor=white) ![RadixUI](https://img.shields.io/badge/RadixUI-161618?style=flat&logo=radixui&logoColor=white) ![shadcn/ui](https://img.shields.io/badge/shadcnui-000000?style=flat&logo=shadcnui&logoColor=white) |
| **Back-End** | ![FastAPI](https://img.shields.io/badge/FastAPI-009688?style=flat&logo=fastapi&logoColor=white) ![Python](https://img.shields.io/badge/Python-3776AB?style=flat&logo=python&logoColor=white) ![Uvicorn](https://img.shields.io/badge/Uvicorn-499848?style=flat&logoColor=white) |
| **인증 / 보안** | ![JWT](https://img.shields.io/badge/JWT-000000?style=flat&logo=jsonwebtokens&logoColor=white) ![bcrypt](https://img.shields.io/badge/bcrypt-338AF0?style=flat&logoColor=white) ![Google OAuth](https://img.shields.io/badge/Google_OAuth-4285F4?style=flat&logo=google&logoColor=white) ![Naver OAuth](https://img.shields.io/badge/Naver_OAuth-03C75A?style=flat&logo=naver&logoColor=white) ![SendGrid](https://img.shields.io/badge/SendGrid-1A82E2?style=flat&logo=sendgrid&logoColor=white) |
| **Database** | ![MariaDB](https://img.shields.io/badge/MariaDB-003545?style=flat&logo=mariadb&logoColor=white) |
| **Vector DB** | ![ChromaDB](https://img.shields.io/badge/ChromaDB-FF6B00?style=flat&logoColor=white) |
| **AI / LLM** | ![OpenAI](https://img.shields.io/badge/GPT--4o-412991?style=flat&logo=openai&logoColor=white) ![OpenAI](https://img.shields.io/badge/GPT--4o--mini-412991?style=flat&logo=openai&logoColor=white) |
| **ML / DL** | ![PyTorch](https://img.shields.io/badge/PyTorch-EE4C2C?style=flat&logo=pytorch&logoColor=white) ![ResNet50](https://img.shields.io/badge/ResNet50-FF6F00?style=flat&logoColor=white) ![Qwen2.5-VL](https://img.shields.io/badge/Qwen2.5--VL-7B-blueviolet?style=flat&logoColor=white) ![HuggingFace](https://img.shields.io/badge/HuggingFace-FFD21E?style=flat&logo=huggingface&logoColor=black) |
| **RAG / Orchestration** | ![LangGraph](https://img.shields.io/badge/LangGraph-1C3C3C?style=flat&logo=langgraph&logoColor=white) ![Tavily](https://img.shields.io/badge/Tavily-0066FF?style=flat&logoColor=white) ![Sentence-Transformers](https://img.shields.io/badge/Sentence--Transformers-FF6B00?style=flat&logoColor=white) ![ko-sroberta](https://img.shields.io/badge/ko--sroberta--multitask-yellow?style=flat&logoColor=white) |
| **이미지 처리** | ![OpenCV](https://img.shields.io/badge/OpenCV-5C3EE8?style=flat&logo=opencv&logoColor=white) ![Pillow](https://img.shields.io/badge/Pillow-3776AB?style=flat&logo=python&logoColor=white) |
| **Infra** | ![AWS](https://img.shields.io/badge/AWS_EC2-FF9900?style=flat&logo=amazonec2&logoColor=white) ![S3](https://img.shields.io/badge/S3-FF9900?style=flat&logo=amazonec2&logoColor=white) |
| **Tools** | ![Figma](https://img.shields.io/badge/Figma-F05032?style=flat&logo=Figma&logoColor=white) ![Git](https://img.shields.io/badge/Git-F05032?style=flat&logo=git&logoColor=white) ![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=flat&logo=visual-studio-code&logoColor=white) ![RunPod](https://img.shields.io/badge/RunPod-673AB7?style=flat&logoColor=white) |

</div>

<br />

## 11. 실행 방법

### 11.1. Backend (FastAPI)

```bash
  # back 폴더로 이동
  cd ./back
  # venv 생성
  python -m venv skin_venv
  # venv 실행 (Windows)
  skin_venv\Scripts\activate
  # venv 실행 (Mac/Linux)
  source skin_venv/bin/activate
  # 의존성 설치
  pip install -r requirements.txt
  # uvicorn 서버 실행
  uvicorn main:app --reload --port 8000
```

### 11.2. Frontend (React)

```bash
  # nodeJS 18버전 이상 필요
  node --version
  # pnpm 설치
  npm install -g pnpm
  # front 폴더로 이동
  cd ./front
  # 패키지 설치
  pnpm install
  # react 서버 실행
  pnpm dev
```

### 11.3. Environment (.env)

```
# vector DB
DATA_GO_CSMT_KEY
DATA_GO_COSMETIC_KEY
VECTOR_DATA_DIR
CHROMA_DB_PATH
CHROMA_COLLECTION

# mariadb 정보
DB_HOST
DB_PORT
DB_USER
DB_PASSWORD
DB_NAME

# JWT
JWT_SECRET_KEY

# EC2 접속 정보
SSH_HOST
SSH_PORT
SSH_USER
SSH_PKEY

# S3 정보
AWS_REGION=ap-northeast-2
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
S3_BUCKET_NAME

# API 연결 URL
VITE_API_BASE_URL=http://localhost:8000

# 임베딩 모델
EMBED_MODEL_NAME

# PubMed API
NCBI_API_KEY
PUBMED_EMAIL

# OPEN AI API KEY
OPENAI_API_KEY

# TAVILY_API_KEY
TAVILY_KEY

# VISION MODEL
VISION_MODEL_PATH

# 이메일 인증
SENDGRID_API_KEY
SENDGRID_FROM_EMAIL
EMAIL_OTP_SECRET

# Google OAuth
GOOGLE_CLIENT_ID
GOOGLE_CLIENT_SECRET
GOOGLE_REDIRECT_URI

# Naver OAuth
NAVER_CLIENT_ID
NAVER_CLIENT_SECRET
NAVER_REDIRECT_URI

# 소셜 로그인 콜백 URL
FRONTEND_BASE_URL

```

<br />

## 12. 화면 설계

### 12.1. 사이트 구조

```bash

On-you(온유)
   ├── chat (회원, 비회원)
   │      ├── 채팅 질문
   │      ├── 빠른 분석
   │      ├── 정밀 분석
   │      └── 성분 분석
   ├── 피부 분석
   │      ├── 현재 분석
   │      └── 비교 분석
   ├── 피부 MBTI
   ├── 위시리스트
   ├── 설정
   │      ├── 프로필 (회원정보, 피부정보)
   │      ├── 소셜 연동 (구글, 네이버)
   │      ├── 문의목록 (유저, 관리자)
   │      └── 회원탈퇴
   └── 로그인 (일반, 구글, 네이버)
        ├── 비밀번호 찾기 (이메일 인증)
        └── 회원가입 (이메일 인증)

```

<br />

### 12.2. 화면흐름도

<div align="center">
  <img src="assets/화면흐름도.jpg" width="80%" />
</div>

<br />

### 12.3. 와이어 프레임 (Figma):

https://www.figma.com/make/GidYts0kuhsYalIeB8HraC/Multimodal-Skin-Analysis-Chatbot?t=YhjLgI2srgQIFRuA-1

### 12.4. 인포그래픽

<div align="center">
  <div>
    <h4>🔍 분석 가이드라인</h4>
    <img src="assets/인포그래픽_분석.png">
  </div>
  <br />
  <div>
    <h4>🧪 전성분 추출 가이드라인</h4>
    <img src="assets/인포그래픽_전성분.png">
  </div>  
</div>
<br />

---

## 13. Postman 문서

API 문서는 Postman Documenter를 통해 확인할 수 있습니다.

**Postman 주소**  
https://documenter.getpostman.com/view/53095517/2sBXieta1g

주요 인증, 회원, 피부 분석, 피부 MBTI, 퍼스널컬러, 공유 기능 API는 Postman Documenter에서 확인할 수 있도록 구성했습니다.

---

## 14. 배포 (AWS / Docker / Nginx)

프로젝트는 AWS 환경에서 Docker Compose 기반으로 배포했으며,  
Nginx를 리버스 프록시 및 정적 파일 서버로 사용해 프론트엔드와 백엔드를 하나의 서비스처럼 연결했습니다.  
또한 AI 기능에 필요한 벡터 저장소를 별도 컨테이너로 분리하여,  
서비스 요청 처리와 벡터 검색이 독립적으로 동작할 수 있도록 구성했습니다.

<br />

### 14.1. 배포 인프라 구조

전체 서비스는 Docker Compose를 통해 다음 3개의 컨테이너로 구성됩니다.

```text
사용자 (브라우저)
     │  HTTP / HTTPS
     ▼
  [nginx]
     ├─ 정적 파일 서빙 (front/dist)
     └─ API 요청 프록시
            │
            ▼
        [backend]
           ├─ FastAPI 애플리케이션
           ├─ AI 분석 처리
           └─ DB 및 외부 API 연동
            │
            ▼
        [chromadb]
           └─ 임베딩 벡터 저장소
```
이 구조를 통해 사용자는 하나의 도메인으로 접속하더라도,
실제로는 프론트엔드 정적 리소스, 백엔드 API, 벡터 검색 기능이 역할에 따라 분리된 구조에서 동작하도록 설계했습니다.

<br/>

### 14.2. 컨테이너 구성
|   컨테이너   | 이미지              | 역할                        |
| :------: | :--------------- | :------------------------ |
|   nginx  | nginx:alpine     | 리버스 프록시, SSL 종료, 정적 파일 서빙 |
|  backend | Dockerfile 기반 빌드 | FastAPI 앱 서버, AI 분석 처리    |
| chromadb | chromadb/chroma  | 임베딩 벡터 저장소                |

### 14.3. Nginx 라우팅 구성

Nginx는 외부에서 들어오는 요청을 목적에 따라 프론트엔드 또는 백엔드로 분기하는 역할을 담당합니다.

HTTP(80) 요청은 HTTPS(443)로 자동 리다이렉트  
/auth/ 경로는 소셜 로그인 및 콜백 처리를 위해 백엔드로 프록시  
/users, /chats, /upload, /keywords, /analysis, /wishlist, /qna, /skin-mbti   경로는 백엔드 API로 프록시
그 외 모든 경로는 프론트엔드 정적 파일로 연결  
React SPA 라우팅을 위해 try_files 기반 fallback 적용  
업로드 파일 크기 제한은 최대 20MB  
SSL 인증서는 Let's Encrypt를 사용하고, 인증서 경로를 Nginx 컨테이너에   마운트하여 적용
<br />

### 14.4. 배포 및 실행 방법

### 14.4.1. .env 파일
> scp -i onyou-ec2-key.pem SKN23-4th-3TEAM/front/.env ec2-user@3.36.101.246:/home/ec2-user/SKN23-4th-3TEAM/front/

>scp -i onyou-ec2-key.pem .env ec2-user@3.36.101.246:/home/ec2-user/SKN23-4th-3TEAM/

### 14.4.2. 전체 재빌드 & 재시작
>docker-compose down
>
>docker-compose up -d --build

### 14.4.3. nginx 수정 후
>docker-compose restart nginx

## 15. 시연 화면

<div align="center">
  <div><img src="assets/0. 진입화면.png" width="90%" /></div>

  <details>
    <summary><b>전체 시연화면 보기</b></summary>
    <br/>
    <div><img src="assets/1_1_채팅-답변중.png" width="90%" /></div>
    <div><img src="assets/1_2_채팅-업로드.png" width="90%" /></div>
    <div><img src="assets/1_3_채팅-제품추천.png" width="90%" /></div>
    <div><img src="assets/1_4_채팅-분석.png" width="90%" /></div>
    <div><img src="assets/1_5_채팅-퍼스널컬러.png" width="90%" /></div>
    <div><img src="assets/2_1_피부분석-종합분석.png" width="90%" /></div>
    <div><img src="assets/2_2_피부분석-비교분석.png" width="90%" /></div>
    <div><img src="assets/3_1_MBTI-테스트.png" width="90%" /></div>
    <div><img src="assets/3_2_MBTI-결과.png" width="90%" /></div>
    <div><img src="assets/4_위시리스트.png" width="90%" /></div>
    <div><img src="assets/5_1_로그인.png" width="90%" /></div>
    <div><img src="assets/5_2_회원가입.png" width="90%" /></div>
    <div><img src="assets/5_3_비밀번호 찾기.png" width="90%" /></div>
    <div><img src="assets/6_온보딩.png" width="90%" /></div>
    <div><img src="assets/7_1_설정-프로필.png" width="90%" /></div>
    <div><img src="assets/7_2_설정-소셜연동.png" width="90%" /></div>
    <div><img src="assets/7_3_1_설정-문의목록_사용자.png" width="90%" /></div>
    <div><img src="assets/7_3_2_설정-문의목록_관리자.png" width="90%" /></div>
    <div><img src="assets/7_3_3_설정-문의목록_문의작성.png" width="90%" /></div>
    <div><img src="assets/7_4_설정-회원탈퇴.png" width="90%" /></div>
    <div><img src="assets/8_FAQ.png" width="90%" /></div>
  </details>
</div>

## 15.1 시연영상(웹)

<div align="center">
  <div><img src="assets/gif/Adobe Express - 비로그인 편집.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 회원관리법.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 레이저시술.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 빠른분석.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 정밀분석.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 전성분추출.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 퍼스널컬러.gif" width="90%"></div>
  <div><img src="assets/gif/Adobe Express - 피부MBTI.gif" width="90%"></div>
</div>

## 15.2 시연영상(앱)
<div align="center">

</div>

---

## 16. 트러블 슈팅

### 16.1. 피부타입 분류 편향 (복합성/지성 집중)

- **증상**: 다양한 얼굴 사진을 넣어도 복합성 또는 지성만 출력
- **원인**: ResNet50 Sigmoid 출력이 0.4~0.6 범위에 집중되는데, 판단 임계값이 이를 고려하지 않음
- **해결**:
  1. 모델 출력 분포에 맞춘 상대적 임계값으로 규칙 기반 판정 재설계
  2. 민감성 타입 판정 기준 추가
  3. 규칙 기반으로 확정된 피부타입을 `determined_skin_type`으로 LLM에 전달하여 LLM의 임의 변경 방지
  4. 기본값 "복합성" 제거 → 점수 기반 폴백으로 변경

<br />

### 16.2. RAG 검색 0건 문제

- **원인**: 실행 위치(cwd)에 따라 `CHROMA_DB_PATH` 상대경로가 달라져 새 vector_store가 생성
- **해결**: 프로젝트 루트 기준 절대경로 정규화 + `.env`는 루트 기준 상대경로 사용

<br />

### 16.3. OCR 모델 CPU 환경 실행 불가

- **원인**: Qwen2.5-VL 7B 모델을 RunPod GPU에서 학습했으나, 실제 서비스 환경은 CPU
- **해결**: 데모용 미리 추출된 전성분 JSON 매칭 테이블 방식으로 대체 (순서 기반 카운터)

<br />

### 16.4. LLM 응답에 JSON 구조 노출

- **증상**: 챗봇 답변에 `{"title": "수분 상태", "detail": "..."}` 형태 그대로 노출
- **해결**: 프롬프트에 `chat_answer에는 JSON 형식을 절대 포함하지 않는다` 규칙 및 구체적 예시 추가

<br />

---

## 17. 비즈니스 전략

1. **프리미엄 구독 서비스**  
   서비스를 빠른 검사(무료) / 정밀 검사(유료)로 구분합니다.  
   구독 결제를 통해 유료 회원에게는 정밀 검사 기능, 개인 정보·피부 기록 저장 확대, 개인화 추천 고도화 등 더 높은 수준의 서비스를 제공합니다.

2. **모바일 애플리케이션 확장**  
   향후 웹 서비스에서 나아가 모바일 애플리케이션으로 확장하여, 스마트폰을 통한 피부 촬영 기반 분석과 전성분 촬영(OCR) 분석을 더 편리하게 제공할 계획입니다.

3. **커뮤니티 기능 추가 및 구독 회원 혜택 확대**  
   사용자 사용 빈도와 접속률(리텐션)을 높이기 위해 커뮤니티 기능을 향후 추가합니다.  
   구독 회원에게는 전용 네임 배지, 유용한 게시글 저장, 피부 성향 테스트(피부 MBTI) 등 심화 기능을 제공하여 구독 가치를 높이고자 합니다.

4. **광고 및 제휴 기반 수익**  
   웹/앱 내 배너 광고를 도입해 광고 수익을 확보합니다.  
   또한 화장품 업체와의 제휴를 통해 쿠폰·체험단·이벤트를 제공하고, 이를 기반으로 마케팅 효과, 사용자 확장, 수익화를 함께 강화합니다.

<br />

---

## 18. 개발후기

- **강승원** : 이번 프로젝트에서 저는 ResNet50 기반 피부 정량분석 모델 학습과 LangGraph 6-노드 챗봇 파이프라인 설계를 담당했고, 4차에서는 퍼스널컬러 14타입 판정 파이프라인, TensorFlow.js 웹캠 얼굴 감지, MBTI 챗봇 연동, OCR 모델 전환(GPU 전용 → GPT-4o-mini Vision), 챗봇 로딩 UX 고도화(단계별 SSE + 피부 상식 모달), FastAPI → Django 전환 등 챗봇 고도화 전반을 수행했습니다. 또한 이용약관과 개인정보처리방침을 변호사 자문을 거쳐 직접 작성하며 개발 외적으로도 많이 배울 수 있었습니다. 3차부터 4차까지 각자의 역할을 끝까지 책임져 준 팀원들에게 감사합니다.

- **정석원** : 이번 프로젝트에서는 LLM 응답 생성기 구현, LLM 라우터 설계, 올리브영 제품 검증 파이프라인 구축, RAG 기반 답변 보강, React 프론트엔드 개발, FastAPI 백엔드 개발을 맡으며 LLM 서비스가 실제로 어떤 흐름으로 동작하는지 깊이 이해할 수 있었습니다. 특히 LLM이 단순히 답변만 생성하는 것이 아니라, 사용자 의도 분류 → 관련 근거 검색 → 답변 생성 → 결과 검증의 단계로 연결되어 동작한다는 점을 직접 구현하며 익힐 수 있었습니다. 짧은 기간이었지만 각자 맡은 역할을 끝까지 책임지고 함께 완성해준 팀원들 덕분에 프로젝트를 잘 마무리할 수 있었고, 모두에게 감사한 마음이 큽니다.

- **정유선** : 이번 프로젝트를 통해 ReactJS·TypeScript 기반 프론트엔드와 FastAPI 백엔드 구축을 직접 경험하며 많은 것을 배울 수 있었습니다. 특히 한국어 특화 임베딩 모델인 jhgan/ko-sroberta-multitask를 활용해 데이터 수집과 벡터 임베딩 작업까지 수행해본 점이 매우 뜻깊었습니다. 또한 프로젝트 후반에는 화면 기획서와 API 명세서 작성 및 정리, 그리고 Flutter 애플리케이션 플레이스토어 등록 작업까지 맡으며 개발뿐 아니라 서비스 마무리 단계의 실무도 경험할 수 있었습니다.
무엇보다 귀여운 이미지 디자인과 디자이너분들의 세심한 도움 덕분에 개발 과정이 더욱 즐거웠고, 모든 팀원이 각자의 역할에 최선을 다해주신 덕분에 프로젝트를 성공적으로 마무리할 수 있었습니다. 특히 팀장님의 훌륭한 리더십 아래 많이 배우고 성장할 수 있었던 점에 깊이 감사드립니다.

- **송민채** : 이번 프로젝트에서 저는 DB 설계, 백엔드 구조 설계, 인증·보안 구현을 맡으며, 단순 기능 개발을 넘어 서비스의 전체 구조와 흐름을 고민하는 경험을 할 수 있었습니다. ERD 작성과 외래키 설계를 통해 데이터 관계를 직접 구성했고, 계층형 백엔드 구조와 API 중심 개발을 경험하며 시스템을 더 깊이 이해할 수 있었습니다. 또한 비밀번호 암호화와 해싱 구현을 위해 보안 개념을 학습하면서, 이전에는 막연했던 인증·보안 영역에 대한 이해도 넓힐 수 있었습니다.
아울러 AWS 서버를 직접 구축하며 EC2, RDS, S3의 역할과 활용 방식을 익혔고, 프론트엔드·백엔드·LLM이 함께 맞물려 돌아가는 협업 과정을 통해 실서비스 개발의 흐름을 체감할 수 있었습니다. Git을 활용한 협업과 진행 상황 공유의 중요성도 직접 배우며, 기술뿐 아니라 협업 방식까지 한 단계 성장할 수 있었습니다. 3차와 4차 프로젝트를 함께하며 많은 것을 배우게 해주신 팀장님과 팀원분들께 감사드립니다.

- **이승연** : 이번 프로젝트를 통해 단순 기능 구현을 넘어, 실제 서비스 관점에서 기능 간 연결성과 사용자 흐름을 설계하고 운영까지 고려하는 경험을 할 수 있었습니다. 로컬 개발 환경부터 EC2 배포, S3 저장, FastAPI·MariaDB 연동까지 전체 서비스 흐름을 직접 다뤄보며 API 구조와 데이터 흐름에 대한 이해를 넓혔고, 환경 변수·DB 연결·서버 설정 오류를 해결하는 과정에서 운영 환경에 대한 감각도 키울 수 있었습니다. 또한 UI 구성과 인포그래픽, 챗봇 브랜드 디자인 작업에도 참여하며 서비스 완성도와 사용자 경험의 중요성을 깊이 느꼈습니다. 예상치 못한 오류와 반복적인 수정 과정이 쉽지는 않았지만, 그만큼 디버깅과 문제 해결 역량을 키울 수 있었고, 사용자 입장에서 자연스럽고 일관된 경험을 제공하는 설계의 가치를 배울 수 있었습니다. 부족한 점이 많았음에도 끝까지 이끌어주신 팀장님과 함께해주신 팀원분들께 감사드립니다.
