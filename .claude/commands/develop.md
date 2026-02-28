---
name: develop
description: |
  OMS MSA 공통 개발 가이드 및 코드 컨벤션 적용.
  사용자가 "개발", "코드 작성", "API 추가", "기능 개발", "코드 리뷰",
  "컨벤션", "스타일 가이드", "테스트", "빌드" 등을 말할 때 사용.
  이 스킬은 OMS 전체 서비스의 공통 컨벤션을 정의한다.
  서비스별 오버라이드는 각 서비스의 development-guide.md를 참조한다.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# OMS MSA Develop Skill

> 이 스킬은 OMS 전체 서비스의 **공통 컨벤션**을 정의한다.
> 서비스별 차이(웹 프레임워크 등)는 각 서비스의 `development-guide.md`에서 오버라이드한다.

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

## CODE_CONVENTION

```dsl
GENERAL:
  INDENT: 4 spaces
  DI_STYLE: @RequiredArgsConstructor + final fields
  LOGGING: @Slf4j (Lombok)
  CONSTANTS: private static final (클래스 상단)
  GETTER: @Getter 사용 가능
  SETTER: ❌ @Setter 절대 사용 금지
  RECORD: 가능한 모든 곳에서 Java record 사용

CONFIG_VALUES:
  RULE: 설정값은 application.yml에 작성하고 @Value로 주입
  HARDCODE: ❌ 토픽명, groupId 등 설정값을 코드에 하드코딩 금지
  EXAMPLE_GOOD: |
    @Value("${kafka.topics.order-1p}")
    private String order1pTopic;
  EXAMPLE_BAD: |
    @KafkaListener(topics = {"order.1p"})  // 하드코딩 금지

NAMING:
  CLASS: PascalCase (OrderService, OutboundOrder)
  METHOD: camelCase (findByOrderCode, createOutbound)
  CONSTANT: UPPER_SNAKE (MAX_RETRY_COUNT)
  PACKAGE: lowercase (co.oms.{service}.domain)
  DTO: 접미사 사용 (OrderCreateRequest, OrderResponse)
  ENTITY: Entity 접미사 사용 (Document 사용 금지) → OrderEntity ✅, OrderDocument ❌
  REPOSITORY: SpringData 수식어 사용 금지 → OrderRepository ✅, SpringDataOrderRepository ❌
  VARIABLE: 클래스명을 따라감 → OrderRepository → orderRepository

RECORD_USAGE:
  RULE: record를 사용할 수 있다면 무조건 사용
  APPLICABLE:
    - Request/Response DTO
    - Kafka 메시지 DTO
    - Value Object
    - 불변 데이터 클래스
  NOT_APPLICABLE:
    - MongoDB Entity (Spring Data 매핑 필요)
    - 상태 변경이 필요한 도메인 모델

CHAINING_ALIGNMENT:
  RULE: 첫 호출의 "." 위치에 후속 체이닝 정렬
  EXAMPLE_GOOD: |
    return orders.stream()
                 .filter(order -> order.isValid())
                 .map(order -> this.toResponse(order))
                 .toList();
  EXAMPLE_BAD: |
    return orders.stream()
        .filter(order -> order.isValid())
        .map(order -> this.toResponse(order))
        .toList();

BUILDER_ALIGNMENT:
  RULE: ".builder()" 의 "." 위치에 후속 필드 정렬
  EXAMPLE: |
    return Response.builder()
                   .code(code)
                   .data(data)
                   .build();

PRIVATE_METHOD_CALL:
  RULE: private 메서드 호출 시 반드시 "this." prefix 사용
  MANDATORY: true
  EXAMPLE_GOOD: |
    long count = this.extractCount(timeline);
    Result result = this.buildResult(data);
  EXAMPLE_BAD: |
    long count = extractCount(timeline);

LAMBDA_STYLE:
  SHORT: 한 줄 → 중괄호 없이
  LONG: 여러 줄 → {} 블록 + 내부 들여쓰기
  EXAMPLE_SHORT: .map(item -> this.transform(item))
  EXAMPLE_LONG: |
    .flatMap(item -> {
        log.info("Processing: {}", item);
        return this.process(item);
    })

COMMENT_STYLE:
  METHOD: /** 한 줄 설명 */
  LOGIC_SECTION: // 1. 설명, // 2. 설명 (논리적 단위)
  EXAMPLE: |
    /** 결과 빌드 */
    private Result buildResult(...) {
        // 1. 데이터 추출
        Data data = this.extract(...);

        // 2. 변환
        return this.transform(data);
    }
```

---

## CLASS_STRUCTURE

```dsl
CONTROLLER:
  ANNOTATIONS:
    - @Slf4j
    - @RestController
    - @RequestMapping("/base-path")
    - @RequiredArgsConstructor
  FIELDS:
    - private final {UseCase} {useCaseName};
  METHODS:
    - @GetMapping/@PostMapping
    - Return: ResponseEntity<T> 등 일반 타입

SERVICE:
  ANNOTATIONS:
    - @Service
    - @Slf4j
    - @RequiredArgsConstructor
  ORDER:
    1. private static final (상수)
    2. private final (DI 필드)
    3. @Override public (인터페이스 구현)
    4. private (헬퍼 메서드)

ENTITY:
  ANNOTATIONS:
    - @Getter
    - @Document("{collection_name}")  // MongoDB
  RULES:
    - 클래스명은 Entity 접미사 (OrderEntity ✅, OrderDocument ❌)
    - @Setter 사용 금지
    - 생성자 또는 Builder로 객체 생성
    - @Id, @Indexed 등 필요한 매핑만 사용

KAFKA_CONSUMER:
  ANNOTATIONS:
    - @Slf4j
    - @Component
    - @RequiredArgsConstructor
  RULES:
    - 토픽/groupId 등 설정값은 application.yml에서 @Value로 주입
    - 컨슈머에서 비즈니스 로직/저장 로직 절대 수행 금지
    - 메시지 수신 → UseCase(Service)에 위임만 수행
    - 트랜잭션과 연관된 모든 로직은 Service 계층에서 처리
  EXAMPLE_GOOD: |
    @KafkaListener(
        topics = {"${kafka.topics.order-1p}", "${kafka.topics.order-3p}"},
        groupId = "${spring.kafka.consumer.group-id}",
        containerFactory = "orderKafkaListenerContainerFactory")
    public void consume(List<ConsumerRecord<String, OrderMessage>> records) {
        log.info("주문 메시지 수신 - {}건", records.size());
        saveOrderUseCase.consumeAndSave(records);
    }
  EXAMPLE_BAD: |
    public void consume(List<ConsumerRecord<String, OrderMessage>> records) {
        List<Order> orders = records.stream()
                                    .map(r -> r.value().toDomain())
                                    .toList();
        saveOrderUseCase.saveOrders(orders);  // 컨슈머에서 변환+저장 금지
    }
```

---

## GIT_RULES

```dsl
BRANCH:
  BASE: main
  FORMAT: {type}/{description}
  TYPES: [feature, fix, chore, refactor]
  EXAMPLE: feature/kafka-mongodb-order-consumer
  COMMANDS:
    - git checkout main
    - git pull origin main
    - git checkout -b {type}/{description}

CONFIRM_REQUIRED:
  - git push (원격 반영)
  - git merge (브랜치 병합)
  - PR 생성

AUTO_ALLOWED:
  - 로컬 브랜치 생성
  - 로컬 커밋
  - 빌드 / 테스트
  - 코드 포맷팅
```

---

## SUMMARY_TABLE

```dsl
| 항목 | 규칙 |
|------|------|
| 들여쓰기 | 4칸 스페이스 |
| 체이닝 정렬 | 첫 호출의 "." 위치에 맞춤 |
| Builder 정렬 | ".builder()"의 "." 위치에 맞춤 |
| Private 호출 | this. prefix 필수 |
| DI 방식 | @RequiredArgsConstructor + final |
| 상수 위치 | 클래스 상단 |
| 로깅 | @Slf4j |
| Getter | @Getter 사용 가능 |
| Setter | ❌ 절대 사용 금지 |
| Record | 가능한 곳에 무조건 사용 |
| Entity 클래스 | Entity 접미사 (Document ❌) |
| Repository | SpringData 수식어 금지 |
| 변수명 | 클래스명 따라감 |
| 설정값 | application.yml + @Value |
| 컨슈머 | UseCase 위임만, 비즈니스 로직 금지 |
| 주석 | 논리 단위마다 // 1., // 2. |
```
