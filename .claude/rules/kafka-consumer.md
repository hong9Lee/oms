---
paths:
  - "**/adapter/in/kafka/**"
---
# Kafka Consumer 컨벤션 (상세: /convention 스킬)

- @Slf4j + @Component + @RequiredArgsConstructor
- 비즈니스 로직/저장 로직 직접 수행 금지
- 도메인 객체 직접 생성 금지 → Command까지만 변환
- 토픽명/groupId는 @Value로 주입 (하드코딩 금지)
- 흐름: 어댑터 DTO → Command 변환 → UseCase에 위임
