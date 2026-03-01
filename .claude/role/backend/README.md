# Backend 개발자 역할 가이드

---

## [MANDATORY] 역할 초기화

역할 선택 후 반드시 다음을 **순서대로** 수행하라:

### Step 1. 도메인 용어 숙지
- `.claude/ai-context/domain-glossary.md`를 읽는다

### Step 2. 서버 선택
- 사용자에게 서버를 선택하도록 질문한다 (AskUserQuestion 사용)
- 선택지: **oms-core** / **oms-plan**

### Step 3. 서비스 컨텍스트 로드
- 선택된 서비스의 다음 파일들을 **즉시 읽는다** (Read 도구 사용):

| 순서 | 파일 | 필수 여부 |
|------|------|----------|
| 1 | `{서비스}/CLAUDE.md` | 필수 |
| 2 | `{서비스}/.claude/ai-context/domain-overview.md` | 필수 |
| 3 | `{서비스}/.claude/ai-context/data-model.md` | 필수 |
| 4 | `{서비스}/.claude/ai-context/development-guide.md` | 필수 |

> 나머지 파일(`api-spec.json`, `kafka-spec.json`, `external-integration.md`, `deploy-guide.md`)은 관련 질문 시 로드한다.

### Step 4. 안내 메시지 출력

```
Backend 모드 ({서비스명}) 로 전환되었습니다.

다음 작업을 도와드릴 수 있습니다:
- Java/Spring Boot 마이크로서비스 개발
- 버그 수정 및 코드 리뷰
- 테스트 코드 작성
- PR 작성 및 배포 준비

무엇을 도와드릴까요?
```

**이 4단계를 모두 완료한 후에 사용자의 원래 요청을 처리하라.**

---

## 참조 가이드

| 상황 | 참조 |
|------|------|
| 빌드 / 아키텍처 / git | `/develop` 스킬 |
| 코드 컨벤션 | `/convention` 스킬 |
| 테스트 컨벤션 | `/test-guide` 스킬 |
| 서비스별 오버라이드 | `{서비스}/.claude/ai-context/development-guide.md` |
| 도메인 용어 | `.claude/ai-context/domain-glossary.md` |
| PR 작성 | `.claude/ai-context/pr-template.md` |
| 배포 | `/deploy` 스킬 |

---

## 온디맨드 컨텍스트 로드

질문에 따라 필요한 파일을 **자동으로** 읽는다:

| 상황 | 로드할 파일 | 트리거 |
|------|-----------|--------|
| API 설계/수정 | `{서비스}/.claude/ai-context/api-spec.json` | REST API 추가/수정/삭제 요청 시 |
| Kafka 토픽/이벤트 | `{서비스}/.claude/ai-context/kafka-spec.json` | Kafka 관련 코드 작성/수정 요청 시 |
| 외부 시스템 연동 | `{서비스}/.claude/ai-context/external-integration.md` | 외부 API 호출 관련 작업 시 |
| 배포 | `{서비스}/.claude/ai-context/deploy-guide.md` | 배포 준비 요청 시 |
