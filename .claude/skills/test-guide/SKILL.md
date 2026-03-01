---
name: test-guide
description: |
  테스트 코드를 작성할 때 OMS 테스트 구조와 컨벤션을 적용한다.
  한글 메서드명, @Nested 구조, Fixture Factory, Fake 패턴, given/when/then 구분을 다룬다.
  코드 컨벤션은 /convention, 아키텍처는 /develop 스킬을 참조.
allowed-tools: Read, Edit, Write, Bash, Grep, Glob
---

# OMS Test Convention

> 이 스킬은 OMS 테스트 코드 컨벤션을 정의한다.
> 코드 작성 컨벤션은 `/convention`, 아키텍처는 `/develop` 스킬을 참조한다.

## TEST_CONVENTION

```dsl
PROHIBITED:
  - ❌ 사용자가 테스트 작성을 요청하지 않았으면 테스트 코드 작성 금지
  - ❌ 소스 코드 수정 요청에 테스트 코드를 자동으로 추가 금지

NAMING:
  LANGUAGE: 한글 메서드명 (시나리오 설명)
  FORMAT: {조건이면}_{결과}
  EXAMPLES: [정상요청이면_일괄저장된다, 중복주문이면_저장하지않는다, clientOrderCode로_조회가능]

NESTED_STRUCTURE:
  RULE: @Nested + @DisplayName으로 기능별 그룹핑
  OUTER_CLASS: 테스트 대상 클래스 (어노테이션만, DisplayName 없음)
  INNER_CLASS: 기능/메서드 단위 그룹 (@Nested + @DisplayName("{기능} 함수는"))
  EXAMPLE: |
    class SaveOrderServiceTest {
        @Nested @DisplayName("주문 저장 함수는")
        class SaveOrdersTest {
            @Test @DisplayName("정상 요청이면 일괄 저장된다")
            void 정상요청이면_일괄저장된다() { ... }
        }
    }

FIXTURE_FACTORY:
  RULE: 테스트 데이터 생성은 Fixture 팩토리 클래스로 중앙화
  LOCATION: src/test/java/co/oms/{service}/fixture/
  NAMING: {Domain}Fixture (OrderFixture, SaveOrderCommandFixture)
  RULES:
    - static 메서드: createDefault() + 파라미터 커스텀 메서드
    - 2개 이상 테스트 클래스에서 공유 → Fixture 추출
    - 단일 테스트 클래스에서만 사용 → private 메서드 유지 가능
  EXAMPLE: |
    public class OrderFixture {
        public static Order createDefault() { return Order.builder()...build(); }
        public static Order createWithCode(String code) { ... }
    }

FAKE:
  RULE: Port의 테스트용 Fake 구현체. Mockito 대신 상태 기반 테스트에 사용
  LOCATION: src/test/java/co/oms/{service}/fake/
  NAMING: Fake{PortName} (FakeOrderPersistencePort)
  WHEN_TO_USE: [Mockito 체인이 복잡할 때, 상태 기반 검증 필요 시, 동일 Port 스텁 반복 시]
  EXAMPLE: |
    public class FakeOrderPersistencePort implements OrderPersistencePort {
        private final List<Order> store = new ArrayList<>();
        @Override public Orders saveAll(Orders orders) { store.addAll(orders.values()); return orders; }
        public int savedCount() { return store.size(); }
    }

SECTION_COMMENTS:
  UNIT_TEST: "// given, // when, // then 주석으로 3단계 구분"
  INTEGRATION_TEST: "// 1. 설명, // 2. 설명 순차 주석 사용"

STRUCTURE: |
  src/test/java/co/oms/{service}/
  ├── fixture/                     # 테스트 픽스처 팩토리
  ├── fake/                        # Port Fake 구현체
  ├── domain/model/                # 단위 테스트 (엔티티, VO)
  ├── application/service/         # 유스케이스 테스트 (Port.out 모킹)
  └── adapter/
      ├── in/web/                  # API 통합 테스트 (MockMvc)
      ├── in/kafka/                # Kafka Consumer 통합 테스트
      └── out/persistence/         # Repository 통합 테스트

RULES:
  - 단위 테스트: Mockito로 Port.out 모킹 (또는 Fake 사용)
  - 통합 테스트: @SpringBootTest + 실제 인프라 (Embedded Kafka, Flapdoodle MongoDB)
  - @Nested + @DisplayName으로 기능별 그룹핑 필수
  - 공유 테스트 데이터는 Fixture 팩토리로 중앙화
```

---

## TEST_TRANSACTION

```dsl
RULE: Embedded MongoDB는 트랜잭션 미지원. 테스트용 no-op TransactionManager 사용
PATTERN: |
  // src/test/java/.../config/TestMongoConfig.java
  @TestConfiguration → no-op PlatformTransactionManager 빈 등록
  // MongoConfig에 @ConditionalOnMissingBean(PlatformTransactionManager.class) 적용
  // 통합 테스트에 @Import(TestMongoConfig.class) 추가
```
