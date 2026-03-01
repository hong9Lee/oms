---
name: convention
description: |
  OMS 코드 컨벤션: 네이밍, 레코드, MapStruct, 클래스 구조, 트랜잭션.
  사용자가 "코드 작성", "컨벤션", "코드 리뷰", "API 추가", "기능 개발",
  "MapStruct", "엔티티", "컨트롤러", "서비스" 등을 말할 때 사용.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# OMS Code Convention

> 이 스킬은 OMS 코드 작성 컨벤션을 정의한다.
> 아키텍처(헥사고날, 패키지 구조)는 `/develop` 스킬, 테스트 컨벤션은 `/test-guide` 스킬을 참조한다.
> 서비스별 차이는 각 서비스의 `development-guide.md`에서 오버라이드한다.

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
  - ❌ 토픽명, groupId 등 설정값을 코드에 하드코딩 금지
  RULE: 설정값은 application.yml에 작성하고 @Value로 주입
  EXAMPLE: |
    @Value("${kafka.topics.order-1p}")
    private String order1pTopic;

NAMING:
  CLASS: PascalCase (SaveOrderService, OutboundOrder)
  METHOD: camelCase (findByOrderCode, createOutbound)
  CONSTANT: UPPER_SNAKE (MAX_RETRY_COUNT)
  PACKAGE: lowercase (co.oms.{service}.domain)
  DTO: 접미사 사용 (OrderCreateRequest, OrderResponse)
  ENTITY: Entity 접미사 (OrderEntity ✅, OrderDocument ❌)
  SPRING_DATA_REPOSITORY: SpringData 수식어 금지 (OrderEntityRepository ✅, SpringDataOrderRepository ❌)
  VARIABLE: 클래스명을 따라감 (OrderPersistencePort → orderPersistencePort)
  SERVICE: UseCase명과 일치 (SaveOrderUseCase → SaveOrderService ✅, OrderService ❌)
  OUT_PORT: 도메인 중심 + 역할 접미사 (OrderPersistencePort ✅, OrderRepository ❌)
  ADAPTER: Port 구현체 + Adapter 접미사 (OrderPersistenceAdapter ✅)

RECORD_USAGE:
  RULE: record를 사용할 수 있다면 무조건 사용
  APPLICABLE: [Request/Response DTO, Kafka 메시지 DTO, Value Object, 불변 데이터 클래스]
  NOT_APPLICABLE: [MongoDB Entity (Spring Data 매핑 필요), 상태 변경이 필요한 도메인 모델]

DOMAIN_MODEL:
  → 아래 CLASS_STRUCTURE.DOMAIN_MODEL 참조 (SSOT)

FIRST_CLASS_COLLECTION:
  RULE: List를 반복 사용하면 일급 객체로 감싸고 관련 로직을 내부에 캡슐화
  NAMING: 도메인 모델의 복수형 (Order → Orders, OrderItem → OrderItems)
  RULES:
    - compact constructor에서 null → List.of() 정규화 (NPE 방지 최우선)
    - 불필요한 방어적 복사(List.copyOf) 금지
    - 컬렉션을 직접 노출하지 않는다
    - 필터링, 집계, 검증 로직은 일급 객체 내부에 위치
    - record로 선언 가능 (불변 보장)
  EXAMPLE: |
    public record Orders(List<Order> values) {
        public Orders { if (values == null) { values = List.of(); } }
        public Orders filterByStatus(OrderStatus status) { ... }
        public int count() { return values.size(); }
    }

CHAINING_ALIGNMENT:
  RULE: 첫 호출의 "." 위치에 후속 체이닝 정렬
  EXAMPLE: |
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
  EXAMPLE: "long count = this.extractCount(timeline);"

LAMBDA_STYLE:
  SHORT: 한 줄 → 중괄호 없이 (.map(item -> this.transform(item)))
  LONG: 여러 줄 → {} 블록 + 내부 들여쓰기

COMMENT_STYLE:
  METHOD: /** 한 줄 설명 */
  LOGIC_SECTION: // 1. 설명, // 2. 설명 (논리적 단위)

MAPSTRUCT:
  RULE: 모델 변환은 MapStruct 사용. 수동 매핑 금지
  COMPONENT_MODEL: spring
  NAMING:
    - Persistence 매퍼: {Domain}PersistenceMapper (adapter/out/persistence/)
    - Command 매퍼: {Action}{Domain}CommandMapper (application/service/)
    - Adapter 매퍼: {Source}Mapper (해당 어댑터 패키지)
  RULES:
    - Enum ↔ String 변환: @Named default 메서드
    - 일급 컬렉션 ↔ List 변환: default 메서드
    - @Mapping(target, ignore/expression/source)으로 필드 매핑
  EXAMPLE: |
    @Mapper(componentModel = "spring")
    public interface OrderPersistenceMapper {
        @Mapping(target = "status", source = "status", qualifiedByName = "orderStatusToString")
        OrderEntity toEntity(Order order);
        @Named("orderStatusToString")
        default String orderStatusToString(OrderStatus status) { return status != null ? status.name() : null; }
    }
```

---

## CLASS_STRUCTURE

```dsl
CONTROLLER:
  ANNOTATIONS: [@Slf4j, @RestController, @RequestMapping("/base-path"), @RequiredArgsConstructor]
  FIELDS: private final {UseCase} {useCaseName}
  RETURN: ResponseEntity<T>

SERVICE:
  ANNOTATIONS: [@Service, @Slf4j, @RequiredArgsConstructor]
  MEMBER_ORDER: [static final 상수, final DI 필드, @Override public, private 헬퍼]

DOMAIN_MODEL:
  ANNOTATIONS: [@Getter, @Builder, @AllArgsConstructor]
  RULES:
    - ❌ @Setter 금지. 상태 변경은 의미 있는 메서드로 표현
    - ❌ 외부에서 상태를 꺼내서 조작 금지 (Tell, Don't Ask)
    - 도메인 로직(검증, 상태 변경, 판단)은 내부 메서드로 캡슐화
    - List 반복 사용 시 일급 객체(복수형 클래스)로 감싸기

ENTITY:
  ANNOTATIONS: [@Getter, @Builder, @Document("{collection}"), @NoArgsConstructor(PROTECTED), @AllArgsConstructor]
  RULES:
    - 클래스명은 Entity 접미사 (OrderEntity)
    - ❌ @Setter 금지
    - @NoArgsConstructor(PROTECTED): Spring Data 리플렉션용, 외부 빈 객체 생성 차단

KAFKA_CONSUMER:
  ANNOTATIONS: [@Slf4j, @Component, @RequiredArgsConstructor]
  RULES:
    - ❌ 비즈니스 로직/저장 로직 수행 금지
    - ❌ 도메인 객체 직접 생성 금지. Command까지만 변환
    - 토픽/groupId는 @Value로 주입
    - 어댑터 DTO → Command 변환 후 UseCase에 위임
```

---

## TRANSACTION

```dsl
MONGODB:
  RULE: Service 계층의 다건 저장/변경에는 @Transactional 적용
  CONFIG: MongoTransactionManager 빈을 config/MongoConfig에 등록
  REQUIRES: MongoDB Replica Set (standalone은 트랜잭션 미지원)
  ANNOTATION_LOCATION: Service의 @Override public 메서드
```
