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

## 공통화 + 오버라이드 패턴

```
oms/ (Root — 공통 규칙)
├── CLAUDE.md                  # Agent 행동 규칙
├── .claude/
│   ├── settings.json          # Hooks 설정 (공유)
│   ├── hooks/                 # Git·파일 보호 Hook
│   ├── skills/                # 공통 스킬 (develop, convention, test-guide, deploy)
│   ├── role/                  # 역할별 가이드 (TPM, Backend)
│   └── ai-context/            # 공통 도메인 용어, PR 템플릿
│
├── oms-core/                  ← git clone (서비스 오버라이드)
│   ├── CLAUDE.md
│   └── .claude/ai-context/
│       ├── development-guide.md   # DB, 트랜잭션, Entity 어노테이션 등
│       ├── domain-overview.md     # 서비스 역할·주문 흐름
│       ├── data-model.md          # 도메인 모델
│       ├── api-spec.json          # REST API 명세
│       ├── kafka-spec.json        # Kafka 이벤트 명세
│       └── ...
│
└── oms-plan/                  ← git clone (서비스 오버라이드)
    ├── CLAUDE.md
    └── .claude/ai-context/
        └── ...
```

**원칙:**
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

`.claude/hooks/` 디렉토리에 PreToolUse Hook이 설정되어 있다. Agent의 위험 동작을 코드 레벨에서 차단한다.

| Hook | 대상 | 동작 |
|------|------|------|
| `protect-git.sh` | Bash (git/gh) | main 커밋/push, `gh pr merge`, 브랜치 네이밍 위반 → **차단** |
| `protect-manual-only.sh` | Edit/Write | SKILL.md, CLAUDE.md, role README 등 → **사용자 확인 요청** |

Hook 설정은 `.claude/settings.json`에 정의되어 있으며, git에 커밋되어 팀 전체에 공유된다.

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

---

## 스킬 목록

| 스킬 | 설명 |
|------|------|
| `/develop` | 빌드, 아키텍처, git 규칙 |
| `/convention` | 코드 작성 컨벤션 (네이밍, record, MapStruct) |
| `/test-guide` | 테스트 구조 컨벤션 (한글 메서드명, Fixture, Fake) |
| `/deploy` | 6단계 배포 절차 |
