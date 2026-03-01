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
  │       ├── persistence/     # DB Repository 구현체
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
  ├── config/                  # 설정 클래스
  └── common/                  # 공통 유틸 (예외, 응답 포맷, 헬스체크)

DEPENDENCY_RULES:
  | 패키지 | 의존 가능 | 의존 불가 |
  | domain | 없음 (순수) | application, adapter |
  | application | domain | adapter |
  | adapter | application, domain | 다른 adapter |
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
  RECORD: 가능한 모든 곳에서 Java record 사용 (적극 사용)
  OBJECT_CREATION: record가 아닌 도메인 모델은 @Getter + @Builder + @AllArgsConstructor

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

DOMAIN_MODEL:
  CREATION: @Getter + @Builder + @AllArgsConstructor
  ENCAPSULATION:
    - 도메인 로직은 도메인 객체 내부에 캡슐화한다
    - 외부에서 상태를 꺼내서 조작하지 않는다 (Tell, Don't Ask)
    - 상태 변경은 의미 있는 메서드로 표현한다
  EXAMPLE: |
    @Getter
    @Builder
    @AllArgsConstructor
    public class Order {
        private final String id;
        private final OrderStatus status;
        private final List<OrderItem> items;

        /** 취소 가능 여부 판단 */
        public boolean isCancelable() {
            return this.status == OrderStatus.RECEIVED;
        }
    }

FIRST_CLASS_COLLECTION:
  RULE: List를 반복 사용하면 일급 객체로 감싸고 관련 로직을 내부에 캡슐화
  NAMING: 도메인 모델의 복수형 (Order → Orders, OrderItem → OrderItems)
  RULES:
    - 컬렉션을 직접 노출하지 않는다
    - 필터링, 집계, 검증 로직은 일급 객체 내부에 위치
    - record로 선언 가능 (불변 보장)
  EXAMPLE: |
    public record Orders(List<Order> values) {
        public Orders {
            values = List.copyOf(values);
        }

        public Orders filterByStatus(OrderStatus status) {
            return new Orders(
                    values.stream()
                          .filter(order -> order.getStatus() == status)
                          .toList());
        }

        public int count() {
            return values.size();
        }
    }

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

MAPSTRUCT:
  RULE: 모델 변환은 MapStruct를 사용한다. 수동 매핑 금지
  COMPONENT_MODEL: spring
  NAMING:
    - Persistence 매퍼: {Domain}PersistenceMapper (Order → OrderPersistenceMapper)
    - Message 매퍼: {Domain}MessageMapper (OrderMessage → OrderMessageMapper)
  LOCATION:
    - Persistence 매퍼: adapter/out/persistence/ 패키지
    - Message 매퍼: application/service/ 패키지
  RULES:
    - Enum ↔ String 변환은 @Named default 메서드로 정의
    - 일급 컬렉션 ↔ List 변환은 default 메서드로 정의
    - @Mapping(target, ignore/expression/source)으로 필드 매핑
  EXAMPLE: |
    @Mapper(componentModel = "spring")
    public interface OrderPersistenceMapper {
        @Mapping(target = "status", source = "status", qualifiedByName = "orderStatusToString")
        OrderEntity toEntity(Order order);

        @Named("orderStatusToString")
        default String orderStatusToString(OrderStatus status) {
            return status != null ? status.name() : null;
        }

        default OrderItems toOrderItems(List<OrderItemEntity> entities) {
            if (entities == null) { return new OrderItems(List.of()); }
            return new OrderItems(entities.stream().map(this::toItemDomain).toList());
        }
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

DOMAIN_MODEL:
  ANNOTATIONS:
    - @Getter
    - @Builder
    - @AllArgsConstructor
  RULES:
    - 도메인 로직(검증, 상태 변경, 판단)은 내부 메서드로 캡슐화
    - @Setter 사용 금지. 상태 변경은 의미 있는 메서드로 표현
    - List를 반복 사용하면 일급 객체(복수형 클래스)로 감싸기
  EXAMPLE: |
    @Getter @Builder @AllArgsConstructor
    public class Order {
        private final String id;
        private final OrderStatus status;

        public boolean isCancelable() {
            return this.status == OrderStatus.RECEIVED;
        }
    }

ENTITY:
  ANNOTATIONS:
    - @Getter
    - @Builder
    - @Document("{collection_name}")  // MongoDB
    - @NoArgsConstructor(access = AccessLevel.PROTECTED)
    - @AllArgsConstructor
  RULES:
    - 클래스명은 Entity 접미사 (OrderEntity ✅, OrderDocument ❌)
    - @Setter 사용 금지
    - @Builder 또는 @AllArgsConstructor로 객체 생성
    - @NoArgsConstructor(PROTECTED): Spring Data가 리플렉션으로 사용, 외부 빈 객체 생성 차단
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

## CLEAN_CODE

```dsl
BATCH_OVER_INDIVIDUAL:
  RULE: 동일한 DB 호출을 N번 반복하지 않는다. 일괄 조회/저장으로 대체
  EXAMPLE_GOOD: |
    // 1회 일괄 조회 + 1회 일괄 저장 = 2회 DB 호출
    Set<String> codes = orders.extractClientOrderCodes();
    Orders existing = repository.findByClientOrderCodeIn(codes);
    Orders newOrders = orders.excludeByClientOrderCodes(existing.extractClientOrderCodes());
    repository.saveAll(newOrders);
  EXAMPLE_BAD: |
    // N회 개별 조회 + N회 개별 저장 = 2N회 DB 호출
    orders.values().forEach(order -> {
        if (repository.findByClientOrderCode(order.getCode()).isEmpty()) {
            repository.save(order);
        }
    });

TELL_DONT_ASK:
  RULE: 객체의 상태를 꺼내서 외부에서 판단하지 않는다. 객체에게 행동을 요청한다
  EXAMPLE_GOOD: "order.isCancelable()"
  EXAMPLE_BAD: "order.getStatus() == OrderStatus.RECEIVED"

ENCAPSULATE_COLLECTION_LOGIC:
  RULE: 컬렉션 필터링, 추출, 집계 로직은 일급 객체 내부에 위치
  EXAMPLE_GOOD: "orders.excludeByClientOrderCodes(existingCodes)"
  EXAMPLE_BAD: "orders.values().stream().filter(o -> !codes.contains(o.getCode())).toList()"

SINGLE_RESPONSIBILITY:
  RULE: 메서드는 하나의 역할만 수행. 변환, 검증, 저장을 한 메서드에 혼합하지 않는다

EARLY_RETURN:
  RULE: 조건 불충족 시 빠르게 반환. 깊은 중첩(if-else 3단 이상) 금지
```

---

## TRANSACTION

```dsl
MONGODB:
  RULE: Service 계층의 다건 저장/변경에는 @Transactional 적용
  CONFIG: MongoTransactionManager 빈을 config/MongoConfig에 등록
  REQUIRES: MongoDB Replica Set (standalone은 트랜잭션 미지원)
  ANNOTATION_LOCATION: Service의 @Override public 메서드
  EXAMPLE: |
    @Override
    @Transactional
    public void consumeAndSave(List<OrderMessage> messages) {
        // 일괄 조회 → 중복 필터 → 일괄 저장 (전체가 하나의 트랜잭션)
    }

TEST_TRANSACTION:
  RULE: Embedded MongoDB는 트랜잭션 미지원. 테스트용 no-op TransactionManager 사용
  PATTERN: |
    // src/test/java/.../config/TestMongoConfig.java
    @TestConfiguration → no-op PlatformTransactionManager 빈 등록
    // 본 MongoConfig에 @ConditionalOnMissingBean(PlatformTransactionManager.class) 적용
    // 통합 테스트에 @Import(TestMongoConfig.class) 추가
```

---

## TEST_CONVENTION

```dsl
NAMING:
  LANGUAGE: 한글 메서드명 (시나리오 설명)
  FORMAT: {기능}_{조건이면}_{결과}
  EXAMPLES:
    - 주문생성_정상요청이면_READY상태로_생성된다
    - 주문취소_이미완료된_주문이면_예외발생
    - 배치주문저장_중복포함이면_중복제외하고_저장된다

STRUCTURE: |
  src/test/java/co/oms/{service}/
  ├── domain/model/              # 단위 테스트 (엔티티, VO)
  ├── application/service/       # 유스케이스 테스트 (Port.out 모킹)
  └── adapter/
      ├── in/web/                # API 통합 테스트 (MockMvc)
      ├── in/kafka/              # Kafka Consumer 통합 테스트
      └── out/persistence/       # Repository 통합 테스트

RULES:
  - 새 기능 추가 시 테스트 코드 작성 필수
  - 단위 테스트: Mockito로 Port.out 모킹
  - 통합 테스트: @SpringBootTest + 실제 인프라 (Embedded Kafka, Flapdoodle MongoDB)
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

MAIN_BRANCH_PROTECTION:
  RULE: main에 직접 커밋/push 절대 금지. PR 머지도 Agent가 수행하지 않는다. (상세: CLAUDE.md 참조)

CONFIRM_REQUIRED:
  - git commit (로컬 커밋)
  - git push (원격 반영)
  - PR 생성

AUTO_ALLOWED:
  - 로컬 브랜치 생성
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
| Record | 가능한 곳에 적극 사용 |
| 도메인 모델 | @Getter + @Builder + @AllArgsConstructor |
| 일급 객체 | List → 복수형 클래스로 감싸고 로직 캡슐화 |
| 캡슐화 | 도메인 로직은 도메인 객체 내부에 위치 |
| Entity 클래스 | @Getter + @Builder + @NoArgsConstructor(PROTECTED) + @AllArgsConstructor |
| Repository | SpringData 수식어 금지 |
| 변수명 | 클래스명 따라감 |
| 설정값 | application.yml + @Value |
| 컨슈머 | UseCase 위임만, 비즈니스 로직 금지 |
| 주석 | 논리 단위마다 // 1., // 2. |
| MapStruct | 모델 변환은 MapStruct, 수동 매핑 금지 |
| 트랜잭션 | 다건 저장/변경은 @Transactional |
| 일괄 처리 | N회 개별 호출 금지, 일괄 조회/저장 사용 |
| 캡슐화 | 컬렉션 로직은 일급 객체 내부에 위치 |
| Tell Don't Ask | 상태를 꺼내서 판단하지 말고 객체에게 요청 |
```
