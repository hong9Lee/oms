---
paths:
  - "**/adapter/out/persistence/**"
  - "**/infrastructure/persistence/**"
---
# Persistence 컨벤션 (상세: /convention 스킬)

- MapStruct로 도메인 ↔ Entity 변환 (수동 매핑 금지)
- Entity 클래스명: Entity 접미사 (OrderEntity)
- Adapter 클래스명: Adapter 접미사 (OrderPersistenceAdapter)
- Mapper 클래스명: {Domain}PersistenceMapper
- Entity: @Getter + @Builder + @NoArgsConstructor(PROTECTED) + @AllArgsConstructor
- @Setter 금지
- persistence 어노테이션(@Document 등)은 서비스별 development-guide.md 참조
