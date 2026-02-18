# OMS AI Context

| 항목 | 내용                                                |
|------|---------------------------------------------------|
| **Version** | opus 4.6                                          |
| **AI Agent** | [Claude Code](https://claude.ai/code) (Anthropic) |
| **대상 도메인** | OMS (Order Management System) MSA                 |

---

## 이 프로젝트는 무엇인가요?

> Claude Agent를 활용하여 OMS 도메인 지식을 체계화하고, 개발·배포 생산성을 높이기 위한 AI 컨텍스트 시스템

Claude Agent가 이 컨텍스트를 읽고, 역할(TPM/Backend)에 따라 필요한 정보를 즉시 제공하여:

- **도메인 지식**을 빠르게 파악하고
- **코드 개발·리뷰**를 가속화하며
- **배포 프로세스**를 자동화합니다

### 구조적 특징

> **Root 프로젝트 하나만 수정하면, 하위 MSA 전체에 즉시 반영됩니다.**

```
┌─────────────────────────────────────────────┐
│  OMS (Root Project)                         │
│  ┌───────────────┐  ┌───────────────┐       │
│  │  CLAUDE.md    │  │  .claude/     │       │
│  │  (메인 설정)    │  │  (AI 컨텍스트)  │       │
│  └───────┬───────┘  └───────┬───────┘       │
│          └────────┬─────────┘               │
│                   ▼                         │
│     ┌─────────────────────────┐             │
│     │   여기만 수정하면 끝!      │             │
│     └─────────────────────────┘             │
│          ╱             ╲                    │
│         ▼               ▼                   │
│   ┌──────────┐    ┌──────────┐              │
│   │ oms-plan │    │ oms-core │              │
│   │ 자동 반영  │    │ 자동 반영  │              │
│   └──────────┘    └──────────┘              │
└─────────────────────────────────────────────┘
```

- Opus 새 버전 출시 → Root 컨텍스트만 업데이트
- 다른 AI Agent로 전환 → Root 설정만 교체
- MSA 서비스 추가 → 하위에 clone만 하면 즉시 인식

---

## 시작하기

### 1. 사전 준비

```bash
# Claude Desktop 설치
# https://claude.ai/download 에서 다운로드

# GitHub CLI 설치 (PR 생성에 필요)
brew install gh
gh auth login
```

### 2. 프로젝트 세팅

```bash
# 1) 메인 프로젝트 클론
git clone https://github.com/hong9Lee/oms.git
cd oms

# 2) 하위 MSA 레포를 oms/ 폴더 안에 클론
git clone https://github.com/hong9Lee/oms-plan.git
git clone https://github.com/hong9Lee/oms-core.git
```

완료 후 폴더 구조:
> 각 MSA 레포를 `CLAUDE.md` 하위에 추가하면 Claude Agent가 자동으로 인식합니다.
```
OMS/
├── CLAUDE.md                          # AI 에이전트 메인 설정
├── .claude/
│   ├── ai-context/                    # 공통 AI 컨텍스트
│   │   ├── domain-glossary.md         # 도메인 용어집
│   │   └── pr-template.md             # PR 작성 템플릿
│   └── role/                          # 역할별 가이드
│       ├── tpm/README.md              # TPM 역할 가이드
│       └── backend/README.md          # Backend 역할 가이드
├── oms-plan/                          # 외부 API 게이트웨이 (MSA) ← git clone
├── oms-core/                          # 주문 엔진 - SSOT (MSA) ← git clone
└── oms-tools/                         # 배포 도구
```

### 3. Claude Code 실행

1. **Claude Desktop**을 실행합니다
2. 좌측 탭에서 **Code** 탭을 선택합니다
3. `oms/` 폴더 위치에서 새 세션을 시작합니다
4. `hi` 또는 아무 메시지를 입력하면 **역할 선택지**가 표시됩니다:

```
작업 역할을 선택해주세요:

1. TPM     - 기술 설계, 아키텍처, 배포 관리
2. Backend - Java/Spring Boot 마이크로서비스 개발
```

5. 번호를 입력하여 역할을 선택하면, 해당 역할에 맞는 컨텍스트가 자동 로드됩니다

### 역할별 활용 예시

| 역할 | 이런 질문을 할 수 있어요 |
|------|------------------------|
| **TPM** | "주문 상태 흐름 설명해줘", "oms-plan과 oms-core의 역할 차이가 뭐야?", "TemperatureType 종류 알려줘" |
| **Backend** | "oms-core 배포 준비해줘", "PR 만들어줘", "주문 생성 시 Kafka 이벤트 흐름이 어떻게 돼?" |

---

## 주요 기능

| 기능 | 설명 |
|------|------|
| **역할 기반 컨텍스트** | TPM / Backend 역할에 따라 다른 가이드 제공 |
| **도메인 용어집** | OrderType, TemperatureType 등 핵심 용어 즉시 조회 |
| **배포 자동화** | 6단계 배포 프로세스를 Claude Agent가 순차 실행 |
| **PR 생성** | gh CLI를 통한 PR 생성 및 템플릿 적용 |
| **서비스별 AI 컨텍스트** | API 스펙, 데이터 모델, Kafka 이벤트 등 서비스별 문서 관리 |

---