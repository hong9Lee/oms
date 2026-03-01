# OMS AI Context

> Claude Agent 기반 도메인 지식 체계화 · 개발/배포 생산성 향상을 위한 AI 컨텍스트 시스템

| 항목 | 내용 |
|:---:|:---|
| **AI Agent** | [Claude Code](https://claude.ai/code) (Anthropic) |
| **Base Model** | Claude Opus 4.6 |
| **도메인** | OMS (Order Management System) MSA |
| **서비스** | oms-core (주문 엔진 · SSOT), oms-plan (외부 API 게이트웨이) |

> 현재 Opus 4.6 기준으로 컨텍스트 구조와 스킬을 설계했다. 모델 버전이 올라가면 해당 버전의 특성(컨텍스트 윈도우, 도구 사용 패턴 등)에 맞춰 개선해 나갈 예정이다.

---

## Agent 구조 — 왜 역할을 나누는가?

Claude Agent 세션에는 토큰 한도가 있다. 모든 서비스의 코드 컨텍스트를 한 번에 로드하면 정작 작업에 쓸 토큰이 부족해진다.
이를 해결하기 위해 **역할별로 로드 범위를 분리**했다.

| 역할 | 로드 전략 | 최적화 대상 |
|------|----------|-----------|
| **TPM** | 모든 서비스의 domain-overview를 얕고 넓게 | 비즈니스 흐름 · 영향도 분석 · 설계 리뷰 |
| **Backend** | 선택한 서비스의 코드 컨텍스트를 좁고 깊게 | 코드 개발 · 테스트 · 디버깅 |

- TPM은 **서버를 선택하지 않는다.** 크로스서비스 관점에서 비즈니스 영향도를 분석한다.
- Backend는 **서버를 선택한다.** 해당 서비스의 데이터 모델, 개발 가이드, API 스펙을 깊게 로드한다.

세션 시작 시 역할 선택 → 필요한 컨텍스트만 로드 → **토큰을 실제 작업에 집중 투자**

---

## 프로젝트 구조

```
oms/ (Root — 공통 규칙)
├── CLAUDE.md                  # Agent 행동 규칙
├── README.md                  # 이 문서
├── .claude/
│   ├── settings.json          # Hooks + Auto Memory 설정 (팀 공유)
│   ├── settings.local.json    # 로컬 권한 설정 (개인)
│   ├── hooks/                 # 안전장치 Hook
│   │   ├── protect-git.sh     # main 보호, 브랜치 네이밍 강제
│   │   ├── protect-manual-only.sh  # 규칙 파일 수정 시 확인 요청
│   │   ├── pre-compact.sh     # 컨텍스트 압축 시 핵심 규칙 재주입
│   │   └── select-role.sh     # 세션 시작 안내 메시지
│   ├── skills/                # 공통 스킬
│   │   ├── develop/           # 빌드, 아키텍처, git 규칙
│   │   ├── convention/        # 코드 작성 컨벤션
│   │   ├── test-guide/        # 테스트 구조 컨벤션
│   │   └── deploy/            # 6단계 배포 절차
│   ├── rules/                 # 경로별 스킬 참조 자동 로드
│   │   ├── controller.md      # adapter/in/web/
│   │   ├── kafka-consumer.md  # adapter/in/kafka/
│   │   ├── persistence.md     # adapter/out/persistence/, infrastructure/
│   │   ├── domain-model.md    # domain/model/, domain/enums/
│   │   ├── service.md         # application/service/
│   │   └── test.md            # src/test/
│   ├── agents/                # 커스텀 서브에이전트
│   │   └── code-reviewer.md   # 코드 리뷰 (읽기 전용)
│   ├── role/                  # 역할별 가이드
│   │   ├── tpm/README.md
│   │   └── backend/README.md
│   └── ai-context/            # 공통 도메인 지식
│       ├── domain-glossary.md # 도메인 용어집
│       └── pr-template.md     # PR 템플릿
│
├── oms-core/                  ← git clone (서비스 오버라이드)
│   ├── CLAUDE.md
│   └── .claude/ai-context/
│       ├── domain-overview.md
│       ├── data-model.md
│       ├── development-guide.md
│       ├── api-spec.json
│       ├── kafka-spec.json
│       └── ...
│
└── oms-plan/                  ← git clone (서비스 오버라이드)
    ├── CLAUDE.md
    └── .claude/ai-context/
        └── ...
```

**공통화 + 오버라이드 원칙:**
- **Root** — 모든 서비스에 공통인 규칙 (아키텍처, 네이밍, git 규칙, 코드 컨벤션)
- **서비스** — 해당 서비스 고유 오버라이드 (DB 종류, 트랜잭션 설정, Entity 어노테이션 등)
- 충돌 시 **서비스 오버라이드가 우선**

서비스를 추가할 때는 Root 하위에 clone하고 `.claude/ai-context/`를 구성하면 즉시 인식된다.

---

## 시작하기

### 1. 설치

```bash
# Claude Code CLI
npm install -g @anthropic-ai/claude-code

# GitHub CLI (PR 생성에 필요)
brew install gh && gh auth login
```

### 2. 프로젝트 세팅

```bash
git clone https://github.com/hong9Lee/oms.git
cd oms
git clone https://github.com/hong9Lee/oms-core.git
git clone https://github.com/hong9Lee/oms-plan.git
```

### 3. 실행

```bash
claude   # oms/ 디렉토리에서 실행
```

첫 메시지를 입력하면 역할 선택지가 표시된다. 역할을 선택하면 해당 컨텍스트가 자동 로드된다.

---

## Hooks — 안전장치

`.claude/hooks/` 디렉토리에 Hook이 설정되어 있다. 모두 command 타입으로 **토큰 비용 0**.

### protect-git.sh

| 항목 | 내용 |
|------|------|
| **시점** | PreToolUse (Bash) |
| **목적** | Git 워크플로우 강제 |

Agent의 Bash 명령을 실행 전에 가로채서 위험한 git 작업을 차단한다.

| 차단 대상 | 설명 |
|-----------|------|
| `gh pr merge` | PR 머지는 엔지니어가 직접 수행 |
| `git push ... main` | main 브랜치 직접 push 금지 |
| `git commit` (on main) | main 브랜치에서 직접 커밋 금지 |
| 브랜치 네이밍 위반 | `{type}/{description}` 형식 강제 (feature, fix, chore, refactor) |

### protect-manual-only.sh

| 항목 | 내용 |
|------|------|
| **시점** | PreToolUse (Edit, Write) |
| **목적** | 규칙/설정 파일 무단 수정 방지 |

다음 파일을 수정하려 할 때 사용자에게 확인을 요청한다. Agent가 임의로 규칙을 변경하는 것을 방지한다.

| 보호 대상 패턴 | 예시 |
|--------------|------|
| `*/SKILL.md` | 스킬 정의 파일 |
| `*/CLAUDE.md` | Agent 행동 규칙 |
| `*/role/*/README.md` | 역할 가이드 |
| `*/deploy-guide.md` | 배포 가이드 |
| `*/settings.json` | Hook/권한 설정 |
| `*/settings.local.json` | 로컬 권한 설정 |

### pre-compact.sh

| 항목 | 내용 |
|------|------|
| **시점** | PreCompact |
| **목적** | 컨텍스트 압축 시 핵심 규칙 참조 재주입 |

대화가 길어져 자동 압축이 발생할 때, 핵심 스킬 참조 포인터를 stdout으로 출력하여 압축 후 컨텍스트에 삽입한다. 스킬 전체를 재주입하면 토큰 낭비이므로, **참조 경로만** 넣는 경량 전략이다.

### select-role.sh

| 항목 | 내용 |
|------|------|
| **시점** | 수동 (세션 시작 안내용) |
| **목적** | 역할 선택 안내 메시지 출력 |

세션 시작 시 역할 선택 방법을 안내하는 셸 스크립트. Hook 등록 없이 필요 시 수동으로 실행한다.

### Hook 등록 설정

Hook은 `.claude/settings.json`에 정의되어 있으며, git에 커밋되어 팀 전체에 공유된다.

```json
{
  "hooks": {
    "PreToolUse": [
      { "matcher": "Bash",       "hooks": [{ "command": ".claude/hooks/protect-git.sh" }] },
      { "matcher": "Edit|Write", "hooks": [{ "command": ".claude/hooks/protect-manual-only.sh" }] }
    ],
    "PreCompact": [
      { "hooks": [{ "command": ".claude/hooks/pre-compact.sh" }] }
    ]
  }
}
```

### Spotless 포맷팅 — 수동 실행 전략

이전에는 `auto-spotless.sh` (PostToolUse Hook)로 Java 파일 수정마다 `./gradlew spotlessApply`를 자동 실행했으나, **세션 속도 저하** 문제로 제거했다.

| 항목 | 자동 Hook (제거됨) | 수동 실행 (현재) |
|------|-------------------|----------------|
| 실행 시점 | 매 Edit/Write마다 | 커밋 전 1회 |
| 파일 10개 수정 시 | Gradle 초기화 10회 (40~80초) | Gradle 초기화 1회 (4~8초) |
| 세션 체감 속도 | 느림 | 빠름 |

포맷팅이 필요하면 커밋 전에 수동으로 실행한다:

```bash
./gradlew spotlessApply
```

---

## Rules — 경로별 스킬 참조 자동 로드

`.claude/rules/` 디렉토리에 경로 패턴을 지정하면, 해당 경로의 파일을 작업할 때 **어떤 스킬의 어떤 섹션을 따를지 자동 로드**된다. 스킬을 직접 호출하지 않아도 컨벤션이 적용된다.

| Rule 파일 | 적용 경로 | 참조 스킬 |
|-----------|----------|----------|
| `controller.md` | `adapter/in/web/` | `/convention` CLASS_STRUCTURE.CONTROLLER |
| `kafka-consumer.md` | `adapter/in/kafka/` | `/convention` CLASS_STRUCTURE.KAFKA_CONSUMER |
| `persistence.md` | `adapter/out/persistence/`, `infrastructure/` | `/convention` CLASS_STRUCTURE.ENTITY + MAPSTRUCT |
| `domain-model.md` | `domain/model/`, `domain/enums/` | `/convention` DOMAIN_MODEL + FIRST_CLASS_COLLECTION |
| `service.md` | `application/service/` | `/convention` CLASS_STRUCTURE.SERVICE + TRANSACTION |
| `test.md` | `src/test/` | `/test-guide` |

---

## Agents — 커스텀 서브에이전트

`.claude/agents/` 디렉토리에 서브에이전트를 정의한다. 메인 세션과 **별도 컨텍스트**에서 실행되어 메인 토큰을 소모하지 않는다.

| Agent | 모델 | 허용 도구 | 용도 |
|-------|------|----------|------|
| `code-reviewer` | sonnet | Read, Grep, Glob | 코드 리뷰 (수정 불가, 분석만) |

### code-reviewer 리뷰 기준

- `/convention` 스킬의 CODE_CONVENTION + CLASS_STRUCTURE 기준으로 코드 스타일 검증
- `/develop` 스킬의 ARCHITECTURE 기준으로 의존성 방향 검증 (adapter → application → domain)
- `/test-guide` 스킬 기준으로 테스트 구조 검증

### 결과 등급

| 등급 | 의미 |
|------|------|
| Critical | 반드시 수정 (아키텍처 위반, @Setter 사용 등) |
| Warning | 수정 권장 (컨벤션 미준수) |
| Suggestion | 개선 제안 |

---

## Skills — 스킬 목록

| 스킬 | 호출 | 설명 |
|------|------|------|
| develop | `/develop` | 빌드, 아키텍처(헥사고날), git 규칙, AI Context 동기화 |
| convention | `/convention` | 코드 작성 컨벤션 (네이밍, record, MapStruct, 클래스 구조) |
| test-guide | `/test-guide` | 테스트 구조 컨벤션 (한글 메서드명, @Nested, Fixture Factory, Fake) |
| deploy | `/deploy` | 6단계 배포 절차 (버전 확인 → 운영배포 요청서) |

---

## AI Context — 도메인 지식 파일

### 공통 (Root)

| 파일 | 내용 |
|------|------|
| `domain-glossary.md` | 도메인 용어집 (배송정책, 주문상태, 출고상태, 배송사 등) |
| `pr-template.md` | PR 템플릿 가이드 (Rebase and merge 전략) |

### 서비스별 (oms-core, oms-plan)

| 파일 | 로드 시점 | 내용 |
|------|----------|------|
| `domain-overview.md` | 역할 초기화 시 | 서비스 역할, 주문 흐름, 상태 변경 |
| `data-model.md` | 역할 초기화 시 | 엔티티 필드, 관계, Enum 값 |
| `development-guide.md` | 역할 초기화 시 | DB, 트랜잭션, Entity 어노테이션 |
| `api-spec.json` | REST API 작업 시 | 엔드포인트, 요청/응답 구조 |
| `kafka-spec.json` | Kafka 작업 시 | 토픽명, 이벤트 스키마 |
| `external-integration.md` | 외부 연동 작업 시 | 외부 API 호출 방식 |
| `deploy-guide.md` | 배포 준비 시 | 서비스별 배포 절차 |

---

## 성능 설계 — 속도와 토큰 최적화

### 컨텍스트 비용 분석

Claude Code의 모든 최적화는 **컨텍스트 윈도우 관리**에 귀결된다. 각 구성 요소가 언제 로드되는지가 성능을 결정한다.

| 구성 요소 | 크기 | 로드 시점 | 매 요청 포함 |
|----------|------|----------|------------|
| CLAUDE.md | 3.3KB | 세션 시작 | O (항상) |
| Rules 6개 | 1.3KB | 매칭 파일 작업 시 | 조건부 |
| Skill description | ~0.8KB | 세션 시작 | O (설명만) |
| Skill 전체 내용 | 3~7KB/개 | 호출 시에만 | X |
| Role README | 2.8KB | 역할 초기화 시 | X |
| Hooks | 0 | 도구 실행 시 | X (외부 실행) |

### 속도 최적화 원칙

**Hook은 가벼워야 한다.** Hook은 토큰 비용이 0이지만 벽시계 시간(wall clock)을 소모한다. Gradle, npm build 같은 무거운 명령은 Hook에 넣지 않는다.

**Skill은 on-demand 로드.** Skill의 description만 매 요청에 포함되고, 전체 내용은 `/skill-name`으로 호출할 때만 로드된다. 따라서 Skill이 많아도 성능에 큰 영향이 없다.

**Rules는 경로 필터링.** `paths:` frontmatter로 매칭 파일 작업 시에만 로드되어, 불필요한 컨텍스트 낭비를 방지한다.

**pre-compact.sh로 압축 후에도 규칙 유지.** 대화가 길어져 자동 압축이 발생하면 이전 규칙이 사라질 수 있다. 핵심 스킬 참조 포인터만 재주입하는 경량 전략으로 토큰을 절약하면서 규칙을 유지한다.

---

## Auto Memory — 세션 간 학습 유지

`settings.json`에 `autoMemoryEnabled: true`가 설정되어 있다. Agent가 세션에서 학습한 내용을 자동 저장하고, 다음 세션 시작 시 자동 로드한다.

---

## 확장 — Jira 연동 (MCP)

Claude Code는 [MCP (Model Context Protocol)](https://modelcontextprotocol.io) 서버를 통해 외부 도구와 연동할 수 있다.
Jira를 연동하면 이슈 조회·코멘트·상태 변경을 Agent가 직접 수행한다.

### 설정

**파일 위치:** 프로젝트 레벨 `.mcp.json` (Root에 생성) 또는 전역 `~/.claude/mcp.json`

```json
{
  "mcpServers": {
    "jira": {
      "command": "npx",
      "args": ["-y", "mcp-jira-server"],
      "env": {
        "JIRA_HOST": "https://your-domain.atlassian.net",
        "JIRA_EMAIL": "your-email@example.com",
        "JIRA_API_TOKEN": "${JIRA_API_TOKEN}"
      }
    }
  }
}
```

> **API 토큰은 환경변수로 주입한다.** `.mcp.json`에 토큰을 직접 작성하지 않는다.
>
> API 토큰 발급: [Atlassian Account Settings](https://id.atlassian.com/manage-profile/security/api-tokens)

### CLI로 추가하는 방법

```bash
claude mcp add jira -- npx -y mcp-jira-server
```

연동 후 Agent에게 `"OMS 프로젝트의 열린 이슈 조회해줘"`, `"이 PR을 OMS-123 이슈에 연결해줘"` 등을 요청할 수 있다.
