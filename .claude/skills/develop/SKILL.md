---
name: develop
description: |
  OMS MSA 공통 개발 인프라: 기술 스택, 빌드 명령, 헥사고날 아키텍처, git 규칙.
  사용자가 "개발", "빌드", "아키텍처", "git" 등을 말할 때 사용.
  코드 작성 컨벤션은 /convention, 테스트 컨벤션은 /test-guide 스킬을 참조.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# OMS MSA Develop Skill

> 이 스킬은 OMS 전체 서비스의 **공통 인프라**를 정의한다.
> 코드 작성 컨벤션은 `/convention` 스킬, 테스트 컨벤션은 `/test-guide` 스킬을 참조한다.
> 서비스별 차이는 각 서비스의 `development-guide.md`에서 오버라이드한다.

## METADATA

```dsl
PROJECT:
  NAME: oms-msa
  LANGUAGE: Java 21
  FRAMEWORK: Spring Boot 4.0.3
  DATABASE: MongoDB
  MESSAGING: Apache Kafka
  BUILD: Gradle 9.3.1
  FORMAT: Spotless

SERVICES:
  oms-core: 8081   # 주문 엔진 (Single Source of Truth)
  oms-plan: 8080   # 외부 API 게이트웨이

PROFILES: [local, dev, stg, perf, prod]
```

---

## BUILD_COMMANDS

```dsl
RUN:
  local: ./gradlew bootRun
  with_profile: ./gradlew bootRun -Dspring.profiles.active={PROFILE}

BUILD:
  default: ./gradlew build
  clean: ./gradlew clean build
  skip_test: ./gradlew build -x test

TEST:
  all: ./gradlew test
  single_class: ./gradlew test --tests "*.{ClassName}"
  single_method: ./gradlew test --tests "*.{ClassName}.{methodName}"

FORMAT:
  check: ./gradlew spotlessCheck
  apply: ./gradlew spotlessApply
```

---

## ARCHITECTURE

```dsl
PATTERN: Hexagonal (Ports & Adapters)

PRINCIPLES:
  - 도메인은 외부를 모른다: domain 패키지는 adapter에 의존하지 않는다
  - Port: 도메인이 정의하는 인터페이스 (in: 유스케이스, out: 외부 연동)
  - Adapter: Port의 구현체 (in: Controller/Consumer, out: Repository/Client)
  - 의존성 방향: adapter → application → domain (항상 안쪽으로)

PACKAGE_TEMPLATE: |
  co.oms.{service}/
  ├── adapter/
  │   ├── in/
  │   │   ├── web/             # REST Controller + Request/Response DTO
  │   │   └── kafka/           # Kafka Consumer
  │   └── out/
  │       ├── persistence/     # Port 구현체 (Adapter + Mapper)
  │       ├── kafka/           # Kafka Producer
  │       └── client/          # 외부 API 클라이언트 (RestClient)
  ├── application/
  │   ├── port/
  │   │   ├── in/              # Inbound Port (유스케이스 인터페이스)
  │   │   └── out/             # Outbound Port (외부 연동 인터페이스)
  │   └── service/             # 유스케이스 구현 (Port.in 구현체)
  ├── domain/
  │   ├── model/               # 엔티티, VO, Aggregate Root
  │   └── enums/               # Enum 정의
  ├── infrastructure/
  │   └── persistence/         # Entity, Spring Data Repository
  ├── config/                  # 설정 클래스
  └── common/                  # 공통 유틸 (예외, 응답 포맷, 헬스체크)

DEPENDENCY_RULES:
  | 패키지 | 의존 가능 | 의존 불가 |
  | domain | 없음 (순수) | application, adapter, infrastructure |
  | application | domain | adapter, infrastructure |
  | adapter | application, domain, infrastructure | 다른 adapter |
  | infrastructure | 없음 (프레임워크 전용) | domain, application, adapter |

LAYER_DTO:
  RULE: Port(UseCase)는 인프라 독립적인 Command를 정의. 어댑터 DTO를 Port에 직접 사용 금지
  FLOW: Adapter(Kafka/REST) → [어댑터 DTO → Command 변환] → UseCase(Command) → Service → Domain
  NAMING:
    PORT_INPUT: {Action}{Domain}Command (SaveOrderCommand)
    ADAPTER_DTO: 인프라별 이름 (OrderMessage, OrderCreateRequest)
  LOCATION:
    PORT_INPUT: application/port/in/
    ADAPTER_DTO: 해당 어댑터 패키지
  ADAPTER_CONVERSION: 어댑터 DTO → Command 변환은 어댑터 책임. MapStruct Mapper는 어댑터 패키지에 위치
  GOOD: "SaveOrderUseCase.saveOrders(List<SaveOrderCommand>)"
  BAD: "SaveOrderUseCase.consumeAndSave(List<OrderMessage>)"
```

---

## CLEAN_CODE

```dsl
PRINCIPLES: [SOLID, DRY, KISS, Early Return, Tell Don't Ask]

BATCH_OVER_INDIVIDUAL: 동일한 DB 호출을 N번 반복 금지. findByXxxIn + saveAll 사용
ENCAPSULATE_COLLECTION_LOGIC: 컬렉션 필터링/추출/집계 로직은 일급 객체 내부에 위치
```

---

## GIT_RULES

```dsl
PROHIBITED:
  - ❌ 해당 메시지에 "커밋" 없으면 git commit 금지
  - ❌ 해당 메시지에 "push"/"푸쉬" 없으면 git push 금지
  - ❌ 해당 메시지에 "PR" 없으면 gh pr create 금지
  - ❌ gh pr merge 절대 금지
  - ❌ main 직접 커밋/push 금지
  - ❌ 코드 방향 동의를 git 작업 승인으로 해석 금지
  - ❌ 이전 메시지 git 요청을 이후 메시지에 자동 적용 금지

BRANCH:
  BASE: main
  FORMAT: {type}/{description}
  TYPES: [feature, fix, chore, refactor]

AUTO_ALLOWED: [로컬 브랜치 생성, 빌드/테스트, 코드 포맷팅]
```

---

## AI_CONTEXT_SYNC

```dsl
PROHIBITED:
  - ❌ 컨벤션/규칙 파일(SKILL.md, CLAUDE.md, role README 등)을 사용자 요청 없이 수정 금지
  - ❌ PR 미요청 시 어떤 동기화도 수행 금지

AUTO_SYNC (PR 요청 시 자동 수행):
  RULE: 사용자가 PR을 요청하면, 피쳐 변경에 해당하는 도메인 지식 파일을 자동으로 함께 업데이트
  | 코드 변경 | 업데이트 대상 | 업데이트 내용 |
  | REST API 추가/변경/삭제 | api-spec.json | 엔드포인트, method, path, 요청/응답 구조 |
  | Kafka Producer/Consumer 추가/변경/삭제 | kafka-spec.json | 토픽명, 이벤트 스키마 |
  | 엔티티/VO/Enum 추가/변경/삭제 | data-model.md | 엔티티 필드, 관계, Enum 값 |
  | 외부 시스템 연동 추가/변경 | external-integration.md | 연동 대상, 방식, 엔드포인트 |
  | 비즈니스 흐름 변경 | domain-overview.md | 서비스 역할, 주문 흐름, 상태 변경 |
  | 도메인 용어 추가/변경 | domain-glossary.md | 새 용어, Enum 값, 엔티티명 |
  | 기술 스택/빌드 변경 | development-guide.md | 라이브러리 추가, 빌드 설정 변경 |

MANUAL_ONLY (사용자 요청 시에만 수행):
  - SKILL.md (develop/convention/test-guide/deploy 스킬): 컨벤션/규칙 변경
  - CLAUDE.md (루트/서비스): Agent 행동 규칙 변경
  - role README: 역할 가이드 변경
  - deploy-guide.md: 배포 절차
```
