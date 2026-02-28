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
- WebFlux/Reactive 패턴 코드 작성
- 버그 수정 및 코드 리뷰
- 테스트 코드 작성
- PR 작성 및 배포 준비

무엇을 도와드릴까요?
```

**이 4단계를 모두 완료한 후에 사용자의 원래 요청을 처리하라.**

---

## 기술 스택

| 항목 | 기술 |
|------|------|
| 언어 | Java 21 |
| 프레임워크 | Spring Boot, Spring WebFlux |
| 빌드 | Gradle |
| 메시징 | Kafka |
| 코드 포맷팅 | Spotless |
| 환경 프로파일 | local / dev / stg / perf / prod |

---

## 코딩 컨벤션

### Reactive 패턴 (WebFlux)
- `Mono`/`Flux`를 사용한 비동기 처리
- `.block()` 사용 금지 (테스트 제외)
- 에러 처리는 `.onErrorResume()` 또는 `.onErrorMap()` 사용

### 일반 규칙
- 코드 작성 후 `./gradlew spotlessApply`로 포맷팅 확인
- 새 기능 추가 시 테스트 코드 작성 필수
- Enum 사용 시 `domain-glossary.md`의 정의를 따른다

---

## 개발 워크플로우

```
1. 코드 작성/수정
2. ./gradlew spotlessApply   (포맷팅)
3. ./gradlew test            (테스트)
4. ./gradlew build           (빌드)
5. PR 작성 (pr-template.md 참조)
```

---

## 주요 참조 문서

| 상황 | 참조 파일 |
|------|----------|
| 도메인 용어 확인 | `.claude/ai-context/domain-glossary.md` |
| PR 작성 | `.claude/ai-context/pr-template.md` |
| 배포 준비 | 루트 `CLAUDE.md`의 배포 준비 6단계 |
| 서비스별 상세 | 각 서비스의 `CLAUDE.md` 및 `.claude/ai-context/` |

---

## 온디맨드 컨텍스트 로드 가이드

다음 상황에서 추가 파일을 로드한다:

| 상황 | 로드할 파일 |
|------|-----------|
| API 설계/수정 질문 | `{서비스}/.claude/ai-context/api-spec.json` |
| Kafka 토픽/이벤트 질문 | `{서비스}/.claude/ai-context/kafka-spec.json` |
| 외부 시스템 연동 질문 | `{서비스}/.claude/ai-context/external-integration.md` |
| 배포 요청 | `{서비스}/.claude/ai-context/deploy-guide.md` |

---

## 배포 관련 참고

배포 요청을 받으면 루트 `CLAUDE.md`의 **배포 준비 필수 규칙 (MANDATORY)** 섹션을 따른다.
필수 정보(프로젝트명, PR URL)가 없으면 반드시 사용자에게 질문한다.
